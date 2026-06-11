$ErrorActionPreference = "Stop"

$baseExe = "WinTune_Official.exe"
$baseBytes = [IO.File]::ReadAllBytes($baseExe)
$newScriptBytes = [IO.File]::ReadAllBytes("shenDu_nobom.ahk")
Write-Host ("New script: {0} bytes (BOM stripped)" -f $newScriptBytes.Length)

# PE basics
$peOff = [BitConverter]::ToInt32($baseBytes, 0x3C)
$magic = [BitConverter]::ToInt16($baseBytes, $peOff + 24)
$is64 = ($magic -eq 0x20B)
$numSec = [BitConverter]::ToInt16($baseBytes, $peOff + 6)
$sizeOpt = [BitConverter]::ToInt16($baseBytes, $peOff + 20)
$so = $peOff + 24 + $sizeOpt

# Build RVA map
$rvamap = @{}
$rsrcVA = 0; $rsrcRaw = 0; $rsrcSz = 0
for ($i = 0; $i -lt $numSec; $i++) {
    $hdr = $so + ($i * 40)
    $va = [BitConverter]::ToInt32($baseBytes, $hdr + 12)
    $ro = [BitConverter]::ToInt32($baseBytes, $hdr + 20)
    $rs = [BitConverter]::ToInt32($baseBytes, $hdr + 16)
    $name = [Text.Encoding]::ASCII.GetString($baseBytes, $hdr, 8).Trim("`0")
    for ($o = 0; $o -lt $rs; $o++) { $rvamap[($va + $o)] = ($ro + $o) }
    if ($name -eq ".rsrc") { $rsrcVA = $va; $rsrcRaw = $ro; $rsrcSz = $rs }
    Write-Host ("Section {0}: VA=0x{1:X} Raw=0x{2:X} Size=0x{3:X}" -f $name, $va, $ro, $rs)
}

$rvaToOff = { param($r) if ($rvamap.ContainsKey($r)) { return $rvamap[$r] } else { return -1 } }

# Known script location
$scriptFO = 0x13D874
$scriptRVA = $rsrcVA + ($scriptFO - $rsrcRaw)
Write-Host ("Script FO=0x{0:X} => RVA=0x{1:X}" -f $scriptFO, $scriptRVA)

# Search .rsrc for IMAGE_RESOURCE_DATA_ENTRY pointing to scriptRVA
Write-Host ("`nSearching .rsrc for data entry with OffsetToData=0x{0:X}..." -f $scriptRVA)
$foundOff = -1
$foundSize = 0
for ($i = $rsrcRaw; $i -lt $rsrcRaw + $rsrcSz - 16; $i++) {
    $rva = [BitConverter]::ToInt32($baseBytes, $i)
    if ($rva -eq $scriptRVA) {
        $sz = [BitConverter]::ToInt32($baseBytes, $i + 4)
        $cp = [BitConverter]::ToInt32($baseBytes, $i + 8)
        Write-Host ("  Candidate at 0x{0:X}: RVA=0x{1:X} Size={2} CodePage=0x{3:X}" -f $i, $rva, $sz, $cp)
        if ($sz -gt 100000 -and $sz -lt 2000000) {
            if ($foundOff -lt 0) {
                $foundOff = $i
                $foundSize = $sz
                Write-Host ("  *** ACCEPTED as script resource entry ***")
            }
        }
    }
}

if ($foundOff -lt 0) {
    Write-Host "`nDirect search for script marker..."
    $marker = [Text.Encoding]::ASCII.GetBytes("; <COMPILER:")
    for ($i = $rsrcRaw; $i -lt $rsrcRaw + $rsrcSz - $marker.Length; $i++) {
        $m = $true
        for ($j = 0; $j -lt $marker.Length; $j++) { if ($baseBytes[$i+$j] -ne $marker[$j]) { $m = $false; break } }
        if ($m) {
            $scriptFO = $i
            Write-Host ("Found script at FO=0x{0:X}" -f $scriptFO)
            $scriptRVA = $rsrcVA + ($scriptFO - $rsrcRaw)
            Write-Host ("Script RVA=0x{0:X}" -f $scriptRVA)
            for ($k = $rsrcRaw; $k -lt $rsrcRaw + $rsrcSz - 16; $k++) {
                if ([BitConverter]::ToInt32($baseBytes, $k) -eq $scriptRVA) {
                    $foundOff = $k
                    $foundSize = [BitConverter]::ToInt32($baseBytes, $k + 4)
                    Write-Host ("Data entry at 0x{0:X}: Size={1}" -f $foundOff, $foundSize)
                    break
                }
            }
            break
        }
    }
}

if ($foundOff -ge 0) {
    Write-Host "`n=== PATCHING ==="
    Write-Host ("Old size: {0}, New size: {1}" -f $foundSize, $newScriptBytes.Length)
    
    if ($newScriptBytes.Length -le $foundSize) {
        $out = $baseBytes.Clone()
        [Array]::Copy($newScriptBytes, 0, $out, $scriptFO, $newScriptBytes.Length)
        for ($i = $scriptFO + $newScriptBytes.Length; $i -lt $scriptFO + $foundSize; $i++) { $out[$i] = 0 }
        
        $szb = [BitConverter]::GetBytes([int]$newScriptBytes.Length)
        $out[$foundOff + 4] = $szb[0]; $out[$foundOff + 5] = $szb[1]
        $out[$foundOff + 6] = $szb[2]; $out[$foundOff + 7] = $szb[3]
        
        $outPath = "shenDu_unpacked.exe"
        [IO.File]::WriteAllBytes($outPath, $out)
        Write-Host ("OUTPUT: {0} ({1} bytes)" -f $outPath, (Get-Item $outPath).Length)
        
        $v = [IO.File]::ReadAllBytes($outPath)
        $vt = [Text.Encoding]::UTF8.GetString($v, $scriptFO, [Math]::Min(300, $newScriptBytes.Length))
        $vl = $vt -split '\n'
        Write-Host ("First line: " + $vl[0])
        $idx = $vt.IndexOf("CheckUpdate(g:")
        if ($idx -ge 0) {
            Write-Host ("CheckUpdate: " + $vt.Substring($idx, [Math]::Min(120, $vt.Length - $idx)))
        }
    }
} else {
    Write-Host "COULD NOT FIND resource entry"
}