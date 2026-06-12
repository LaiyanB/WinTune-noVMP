; <COMPILER: v1.1.37.02>
#Requires AutoHotkey 2.0
#SingleInstance Off
#Warn
App:={Name: "深度优化", Ver: "2.7.5"}
SetTitleMatchMode 3
If WinExist(App.Name) {
WinActivate
Return
}
A_IconTip:= App.Name
tray := A_TrayMenu
tray.delete
tray.Add("Exit", (*) => ExitApp())
RunTerminal(CmdLine, WorkingDir:="", Codepage:="utf-8", Fn:="RunTerminal_Output") {
DllCall("CreatePipe", "PtrP",&hPipeR:=0, "PtrP",&hPipeW:=0, "Ptr",0, "Int",0)
, DllCall("SetHandleInformation", "Ptr",hPipeW, "Int",1, "Int",1)
, DllCall("SetNamedPipeHandleState","Ptr",hPipeR, "UIntP",&PIPE_NOWAIT:=1, "Ptr",0, "Ptr",0)
, P8 := (A_PtrSize=8)
, SI:=Buffer(P8 ? 104 : 68, 0)
, NumPut("UInt", P8 ? 104 : 68, SI)
, NumPut("UInt", STARTF_USESTDHANDLES:=0x100, SI, P8 ? 60 : 44)
, NumPut("Ptr", hPipeW, SI, P8 ? 88 : 60)
, NumPut("Ptr", hPipeW, SI, P8 ? 96 : 64)
, PI:=Buffer(P8 ? 24 : 16)
If not DllCall("CreateProcess", "Ptr",0, "Str",CmdLine, "Ptr",0, "Int",0, "Int",True
,"Int",0x08000000 | DllCall("GetPriorityClass", "Ptr",-1, "UInt"), "Int",0
,"Ptr",WorkingDir ? StrPtr(WorkingDir) : 0, "Ptr",SI.ptr, "Ptr",PI.ptr)
Return Format("{1:}", "", -1
,DllCall("CloseHandle", "Ptr",hPipeW), DllCall("CloseHandle", "Ptr",hPipeR))
DllCall("CloseHandle", "Ptr",hPipeW)
, PID := NumGet(PI, P8 ? 16 : 8, "UInt")
, sFile := FileOpen(hPipeR, "h", Codepage)
, LineNum := 1, sOutput := ""
While (PID + DllCall("Sleep", "Int",1)) and DllCall("PeekNamedPipe", "Ptr",hPipeR, "Ptr",0, "Int",0, "Ptr",0, "Ptr",0, "Ptr",0)
While PID and !sFile.AtEOF
Line := sFile.ReadLine() "`r`n", sOutput .= Type(Fn)="Func" ? Fn.Call(Line, LineNum++,&PID) : Line
PID := 0
, hProcess := NumGet(PI, 0, "Ptr")
, hThread  := NumGet(PI, A_PtrSize, "Ptr")
, DllCall("CloseHandle", "Ptr",hProcess)
, DllCall("CloseHandle", "Ptr",hThread)
, DllCall("CloseHandle", "Ptr",hPipeR)
Return sOutput
}
GetSleepIdleTimeout() {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{29f6c1db-86da-48c5-9fdb-f2b67b1f44da}")
return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}
SetSleepIdleTimeout(Num) {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{29f6c1db-86da-48c5-9fdb-f2b67b1f44da}")
PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}
GetHibernateIdleTimeout() {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{9d7815a6-7ee4-497e-8888-515a05f02364}")
return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}
SetHibernateIdleTimeout(Num) {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{9d7815a6-7ee4-497e-8888-515a05f02364}")
PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}
GetHybridSleepIdleTimeout() {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{94ac6d29-73ce-41a6-809f-6363ba21b47e}")
return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}
SetHybridSleepIdleTimeout(Num) {
SubGroupGUID:=GUID("{238c9fa8-0aad-41ed-83f4-97be242c8f20}")
PowerSettingGUID:=GUID("{94ac6d29-73ce-41a6-809f-6363ba21b47e}")
PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}
GetDisplayBrightnessLevel() {
SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
PowerSettingGUID:=GUID("{aded5e82-b909-4619-9949-f5d71dac0bcb}")
return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}
GetDisplayIdleTimeout() {
SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
PowerSettingGUID:=GUID("{3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e}")
return PowerReadValueIndex(SubGroupGUID, PowerSettingGUID)
}
SetDisplayIdleTimeout(Num) {
SubGroupGUID:=GUID("{7516b95f-f776-4464-8c53-06167f40cc99}")
PowerSettingGUID:=GUID("{3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e}")
PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num)
}
PowerWriteACValueIndex(SubGroupGUID, PowerSettingGUID, Num) {
DllCall("powrprof\PowerGetActiveScheme", "Ptr",0, "Ptr*",&currSchemeGuid:=0, "UInt")
If IsOnAc()
DllCall("powrprof\PowerWriteACValueIndex", "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", SubGroupGUID, "Ptr", PowerSettingGUID, "UInt", Num, "UInt")
Else
DllCall("powrprof\PowerWriteDCValueIndex", "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", SubGroupGUID, "Ptr", PowerSettingGUID, "UInt", Num, "UInt")
DllCall("powrprof\PowerSetActiveScheme", "Ptr",0, "Ptr",currSchemeGuid)
DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
}
PowerReadValueIndex(SubGroupGUID, PowerSettingGUID) {
DllCall("powrprof\PowerGetActiveScheme", "Ptr",0, "Ptr*",&currSchemeGuid:=0, "UInt")
If IsOnAc()
DllCall("powrprof\PowerReadACValueIndex", "Ptr",0, "Ptr",currSchemeGuid, "Ptr",SubGroupGUID, "Ptr",PowerSettingGUID, "UIntP",&r:=0, "UInt")
Else
DllCall("powrprof\PowerReadDCValueIndex", "Ptr",0, "Ptr",currSchemeGuid, "Ptr",SubGroupGUID, "Ptr",PowerSettingGUID, "UIntP",&r:=0, "UInt")
DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
Return r
}
IsOnAc() {
SystemPowerStatus := Buffer(12)
If DllCall("GetSystemPowerStatus", "Ptr", SystemPowerStatus)
If acStatus := NumGet(SystemPowerStatus, 0, "UChar") == 1
return True
return False
}
GUID(sGUID)
{
rGUID := Buffer(16, 0)
if DllCall("ole32\CLSIDFromString", "WStr", sGUID, "Ptr", rGUID) < 0
throw ValueError("Invalid parameter #1", -1, sGUID)
return rGUID
}
StringFromCLSID(rclsid)
{
DllCall("ole32\StringFromCLSID", "Ptr", rclsid, "Ptr*", &lplpsz:=0)
s := StrGet(lplpsz, "UTF-16")
DllCall("ole32\CoTaskMemFree", "Ptr", lplpsz)
return s
}
Service_State(ServiceName, textResult:=false) {
SCM_HANDLE := OpenSCManager(0x1)
hSvc := OpenService(SCM_HANDLE,ServiceName,0x4)
If (!hSvc)
result := 0
Else {
SC_STATUS := Buffer(28, 0)
QueryServiceStatus(hSvc, SC_STATUS)
result := NumGet(SC_STATUS,4,"UInt")
CloseServiceHandle(hSvc)
}
CloseServiceHandle(SCM_HANDLE)
If (textResult) {
r := result
result := (r=1) ? "Stopped" : (r=2) ? "Start Pending" : (r=3) ? "Stop Pending" : (r=4) ? "Running" : (r=5) ? "Continue Pending" : (r=6) ? "Pause Pending" : (r=7) ? "Paused" : "Unknown"
}
return result
}
Service_Info(ServiceName) {
encoding := (!StrLen(Chr(0xFFFF))) ? "UTF-8" : "UTF-16"
SCM_HANDLE := OpenSCManager(0xF003F)
hSvc := OpenService(SCM_HANDLE,ServiceName,0x0001)
If (!hSvc) {
result := 0
} Else {
QueryServiceConfig(hSvc,,,&bSize:=0)
QUERY_SERVICE_CONFIG := Buffer(bSize,0)
QueryServiceConfig(hSvc,QUERY_SERVICE_CONFIG,bSize)
If (bSize) {
svcType := NumGet(QUERY_SERVICE_CONFIG,0,"UInt")
svcStartMode := NumGet(QUERY_SERVICE_CONFIG,4,"UInt")
svcErrCtl := NumGet(QUERY_SERVICE_CONFIG,8,"UInt")
binPath_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 12 : 16, "UPtr")
svcPathName := StrGet(binPath_LPSTR,encoding)
depen_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 24 : 40, "UPtr")
ServiceStartName_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 28 : 48, "UPtr")
DispName_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 32 : 56, "UPtr")
svcDispName := StrGet(DispName_LPSTR,encoding)
offset := 0, svcDep := Map(), svcTrigger := 0, svcDelayed := false, svcDesc := ""
While (curDep := StrGet(depen_LPSTR+offset,encoding)) {
svcDep[curDep] := ""
offset += (StrLen(curDep) + 1) * ((A_PtrSize=4) ? 1 : 2)
}
SERVICE_CONFIG_DESCRIPTION:=1
QueryServiceConfig2(hSvc, SERVICE_CONFIG_DESCRIPTION,,, &bSize:=0)
if (bSize) {
SERVICE_DESCRIPTION := Buffer(bSize,0)
QueryServiceConfig2(hSvc, SERVICE_CONFIG_DESCRIPTION,SERVICE_DESCRIPTION,bSize)
str_ptr := NumGet(SERVICE_DESCRIPTION,"UPtr")
svcDesc := str_ptr ? StrGet(str_ptr,encoding) : ""
}
SERVICE_CONFIG_DELAYED_AUTO_START_INFO:=3
QueryServiceConfig2(hSvc, SERVICE_CONFIG_DELAYED_AUTO_START_INFO,,, &bSize:=0)
if (bSize) {
SERVICE_DELAYED_AUTO_START_INFO := Buffer(bSize,0)
r:=QueryServiceConfig2(hSvc, SERVICE_CONFIG_DELAYED_AUTO_START_INFO,SERVICE_DELAYED_AUTO_START_INFO,bSize)
svcDelayed := r ? NumGet(SERVICE_DELAYED_AUTO_START_INFO,"Char") : false
}
SERVICE_CONFIG_TRIGGER_INFO:=8
QueryServiceConfig2(hSvc, SERVICE_CONFIG_TRIGGER_INFO,,, &bSize:=0)
If (bSize) {
SERVICE_TRIGGER_INFO := Buffer(bSize,0)
QueryServiceConfig2(hSvc, SERVICE_CONFIG_TRIGGER_INFO,SERVICE_TRIGGER_INFO,bSize)
svcTrigger := NumGet(SERVICE_TRIGGER_INFO,"UInt")
}
}
CloseServiceHandle(hSvc)
result :=  Map("svcName",ServiceName,"svcDispName",svcDispName,"svcStartMode",svcStartMode
,"svcDesc",svcDesc,"svcPathName",svcPathName,"svcType",svcType,"svcDep",svcDep
,"svcTrigger",svcTrigger,"svcDelayed",svcDelayed)
}
CloseServiceHandle(SCM_HANDLE)
Return result
}
Service_List(State:="", SvcType:="") {
ServiceState := (State="Active") ? 0x1 : (State="Inactive") ? 0x2 : 0x3
ServiceType  := (SvcType="Driver") ? 0xB : (SvcType="All") ? 0x3B : 0x30
SCM_HANDLE := OpenSCManager(0x4)
EnumServicesStatus(SCM_HANDLE, ServiceType, ServiceState,,, &bSize:=0)
ENUM_SERVICE_STATUS := Buffer(bSize, 0)
EnumServicesStatus(SCM_HANDLE, ServiceType, ServiceState, ENUM_SERVICE_STATUS, bSize,, &ServiceCount:=0)
struct_size1 := (A_PtrSize=4) ? 36 : 48
encoding := (!StrLen(Chr(0xFFFF))) ? "UTF-8" : "UTF-16"
svcObjList := Map()
Loop ServiceCount {
SvcName_LPSTR := NumGet(ENUM_SERVICE_STATUS,(A_Index-1)*struct_size1,"UPtr")
svcName := StrGet(SvcName_LPSTR,encoding)
svcState := NumGet(ENUM_SERVICE_STATUS, ((A_Index-1)*struct_size1)+(A_PtrSize * 2)+4,"UInt")
svcObj := Service_Info(svcName)
svcObj["svcState"]:=svcState
svcObjList[svcName] := svcObj
}
CloseServiceHandle(SCM_HANDLE)
Return svcObjList
}
Service_Start(ServiceName) {
SCM_HANDLE := OpenSCManager(0x1)
hSvc := OpenService(SCM_HANDLE,ServiceName,0x10)
result := 0
If (hSvc) {
result := StartService(hSvc)
CloseServiceHandle(hSvc)
}
CloseServiceHandle(SCM_HANDLE)
return result
}
Service_Stop(ServiceName) {
SCM_HANDLE := OpenSCManager(0x1)
hSvc := OpenService(SCM_HANDLE,ServiceName,0x0020)
result := 0
If (!hSvc)
LastErr := 0
Else {
SERVICE_STATUS := Buffer((A_PtrSize=4)?28:32,0)
result := ControlService(hSvc, SERVICE_STATUS)
LastErr := A_LastError
SERVICE_STATUS := ""
CloseServiceHandle(hSvc)
}
CloseServiceHandle(SCM_HANDLE)
A_LastError := LastErr
return result
}
Service_Add(ServiceName, BinaryPath, StartType:="", DisplayName:="") {
if !A_IsAdmin
Return False
SCM_HANDLE := OpenSCManager(0x2)
StartType := (StartType="Auto" Or StartType="Automatic") ? 0x2 : (StartType="Demand" Or StartType="OnDemand") ? 0x3 : 0x4
SC_HANDLE := CreateService(SCM_HANDLE, ServiceName, DisplayName, 0xF01FF, 0x110, StartType, 0x1, BinaryPath)
result := A_LastError ? SC_HANDLE "," A_LastError : 1
CloseServiceHandle(SC_HANDLE)
CloseServiceHandle(SCM_HANDLE)
Return result
}
Service_Delete(ServiceName) {
if !A_IsAdmin
Return False
SCM_HANDLE := OpenSCManager(0x1)
result := 0
hSvc := OpenService(SCM_HANDLE,ServiceName,0xF01FF)
If !hSvc
result := -4
if !result
result := DeleteService(hSvc)
CloseServiceHandle(SCM_HANDLE)
Return result
}
Service_Change_StartType(ServiceName, sStartType) {
if !A_IsAdmin
Return False
SCM_HANDLE := OpenSCManager(0xF003F)
hSvc := OpenService(SCM_HANDLE,ServiceName,0x0002)
If (!hSvc) {
result := 0
} Else {
result := ChangeServiceConfig(hSvc,,sStartType)
CloseServiceHandle(hSvc)
}
CloseServiceHandle(SCM_HANDLE)
Return result
}
OpenSCManager(AR) {
f := (!StrLen(Chr(0xFFFF))) ? "OpenSCManagerA" : "OpenSCManagerW"
Return DllCall("advapi32\" f, "Ptr", 0, "Ptr", 0, "UInt", AR)
}
OpenService(SCM_HANDLE,ServiceName,AR) {
f := (!StrLen(Chr(0xFFFF))) ? "OpenServiceA" : "OpenServiceW"
Return DllCall("advapi32\" f, "UInt", SCM_HANDLE, "Str", ServiceName, "UInt", AR)
}
QueryServiceConfig(hService, ServiceConfig:=0, BufSize:=0, &BytesNeeded:=0) {
f := (!StrLen(Chr(0xFFFF))) ? "QueryServiceConfigA" : "QueryServiceConfigW"
Return DllCall("advapi32\" f, "Ptr", hService, "Ptr", (ServiceConfig?ServiceConfig.Ptr:0), "UInt", BufSize, "UInt*", &BytesNeeded)
}
QueryServiceConfig2(hService, InfoLevel:=0, Buff:=0, BufSize:=0, &BytesNeeded:=0) {
f := (!StrLen(Chr(0xFFFF))) ? "QueryServiceConfig2A" : "QueryServiceConfig2W"
Return DllCall("advapi32\" f,"Ptr",hService, "UInt", InfoLevel,"Ptr",(Buff?Buff.Ptr:0), "UInt", BufSize, "UInt*", &BytesNeeded)
}
ChangeServiceConfig(hService,sType:=0xFFFFFFFF,sStartType:=0xFFFFFFFF) {
f := (!StrLen(Chr(0xFFFF))) ? "ChangeServiceConfigA" : "ChangeServiceConfigW"
Return DllCall("advapi32\" f, "Ptr", hService, "UInt", sType, "UInt", sStartType, "UInt", 0xFFFFFFFF, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0)
}
EnumServicesStatus(hService, sType, sState, lpServices:=0, BufSize:=0, &BytesNeeded:=0, &sCount:=0, &ResumeHandle:=0) {
f := (!StrLen(Chr(0xFFFF))) ? "EnumServicesStatusA" : "EnumServicesStatusW"
Return DllCall("advapi32\" f
,"Ptr", hService,"UInt", sType,"UInt", sState,"Ptr", (lpServices?lpServices.Ptr:0)
,"UInt", BufSize,"UInt*", &BytesNeeded,"UInt*", &sCount,"UInt*", ResumeHandle)
}
QueryServiceStatus(hService, SC_STATUS) {
Return DllCall("advapi32\QueryServiceStatus", "Ptr", hService, "Ptr", SC_STATUS.ptr)
}
StartService(hService) {
f := (!StrLen(Chr(0xFFFF))) ? "StartServiceA" : "StartServiceW"
Return DllCall("advapi32\" f, "UPtr", hService, "UInt", 0, "Ptr", 0)
}
ControlService(hService, SERVICE_STATUS) {
Return DllCall("advapi32\ControlService", "UPtr", hService, "UInt", 1, "Ptr", SERVICE_STATUS.ptr)
}
CreateService(SCM_HANDLE, ServiceName, DisplayName:="", dwDesiredAccess:=0xF01FF, dwServiceType:=0x00000010, dwStartType:=2, dwErrorControl:=0x00000001, lpBinaryPathName:=0) {
funcName2 := (!StrLen(Chr(0xFFFF))) ? "CreateServiceA" : "CreateServiceW"
Return DllCall("advapi32\" funcName2
, "Ptr", SCM_HANDLE
, "Ptr", StrPtr(ServiceName)
, "Ptr", (!DisplayName ? StrPtr(ServiceName) : StrPtr(DisplayName))
, "UInt", dwDesiredAccess
, "UInt", dwServiceType
, "UInt", dwStartType
, "UInt", dwErrorControl
, "Ptr", (lpBinaryPathName?StrPtr(lpBinaryPathName):0)
, "Ptr",  0
, "UInt", 0
, "Ptr",  0
, "Int",  0
, "Ptr",  0)
}
DeleteService(hService) {
Return DllCall("advapi32\DeleteService", "Ptr", hService)
}
CloseServiceHandle(Handle) {
DllCall("advapi32\CloseServiceHandle", "Ptr", Handle)
}
NumToHex(Num, NumType:="UInt", Size:=4) {
buf:=Buffer(Size)
NumPut(NumType, Num, buf)
Return Bin2Hex(buf, buf.Size)
}
HexToNum(HexText, NumType:="UInt") {
Bin:=Hex2Bin(HexText)
Return NumGet(Bin, NumType)
}
StrToHex(Str, Encoding:="UTF-8") {
buf := Buffer(StrPut(Str, Encoding)-1)
StrPut(Str, buf, Encoding)
Return Bin2Hex(buf, buf.Size)
}
HexToStr(HexText, Encoding:="UTF-8") {
Bin:=Hex2Bin(HexText)
Return StrGet(Bin, Encoding)
}
Bin2Hex(addr,len, rType:="CP0") {
fun := MCode("2,x86:VTHSieVXVotNCFOLdRA58n02i0UMigQQwOgEjXg3g+gKwOgFifspw4tFDIgcUYoEEIPgD414N4PoCsDoBYn7KcOIXFEBQuvGhfa4AAAAAA9I8MYEcQBbXl9dww,x64:RTHJRTnIfjZCigQKwOgERI1QN4PoCsDoBUEpwkaIFElCigQKg+APRI1QN4PoCsDoBUEpwkaIVEkBSf/B68VFhcC4AAAAAEQPSMBNY8BCxgRBAMM")
hex:= Buffer(2*len+1)
DllCall(fun, "ptr", hex, "ptr", addr, "UInt", len , "CDecl")
If !rType
Return hex
Else
Return StrGet(hex,rType)
}
Hex2Bin(hex) {
fun := MCode("2,x86:VTHJieVXVot9DFOLdQiKFE+E0nQwidCD4g/A6AYBwo0EwsHgBIgEDopUTwGE0nQVidOD4g/A6wYB2o0U2gnQiAQOQevJW15fXcM,x64:RTHJQooESoTAdEBBicCD4A9BwOgGRAHAQo0EwMHgBEKIBAlGikRKAUWEwHQeRYnCQYPgD0HA6gZFAdBHjQTQRAnAQogECUn/weu4ww")
bin := Buffer(StrLen(hex)//2)
DllCall(fun, "ptr", bin, "AStr", hex , "CDecl")
Return bin
}
MCode(mcode) {
static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", &m))
return
if (!DllCall("crypt32\CryptStringToBinaryW", "str", m[3], "uint", 0, "uint", e.%m[1]%, "ptr", 0, "uint*", &s:=0, "ptr", 0, "ptr", 0))
return
p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
if (c="x64")
DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", &op:=0)
if (DllCall("crypt32\CryptStringToBinaryW", "str", m[3], "uint", 0, "uint", e.%m[1]%, "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
return p
DllCall("GlobalFree", "ptr", p)
}
class JSON {
static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)
static parse(text, keepbooltype := false, as_map := true) {
keepbooltype ? (_true := this.true, _false := this.false, _null := this.null) : (_true := true, _false := false, _null := "")
as_map ? (map_set := (maptype := Map).Prototype.Set) : (map_set := (obj, key, val) => obj.%key% := val, maptype := Object)
NQ := "", LF := "", LP := 0, P := "", R := ""
D := [C := (A := InStr(text := LTrim(text, " `t`r`n"), "[") = 1) ? [] : maptype()], text := LTrim(SubStr(text, 2), " `t`r`n"), L := 1, N := 0, V := K := "", J := C, !(Q := InStr(text, '"') != 1) ? text := LTrim(text, '"') : ""
Loop Parse text, '"' {
Q := NQ ? 1 : !Q
NQ := Q && RegExMatch(A_LoopField, '(^|[^\\])(\\\\)*\\$')
if !Q {
if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
continue
else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || A && RegExMatch(t, "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]")) {
Loop Parse t {
if N && N--
continue
if InStr("`n`r `t", A_LoopField)
continue
else if InStr("{[", A_LoopField) {
if !A && !V
throw Error("Malformed JSON - missing key.", 0, t)
C := A_LoopField = "[" ? [] : maptype(), A ? D[L].Push(C) : map_set(D[L], K, C), D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
continue
} else if InStr("]}", A_LoopField) {
if !A && V
throw Error("Malformed JSON - missing value.", 0, t)
else if L = 0
throw Error("Malformed JSON - to many closing brackets.", 0, t)
else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
} else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
if A
C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
else if V
map_set(C, K, R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R), K := V := ""
else throw Error("Malformed JSON - missing key.", 0, t)
} else {
if A_LoopField == '/' {
nt := SubStr(t, A_Index + 1, 1), N := 0
if nt == '/' {
if nt := InStr(t, '`n', , A_Index + 2)
N := nt - A_Index - 1
} else if nt == '*' {
if nt := InStr(t, '*/', , A_Index + 2)
N := nt + 1 - A_Index
} else nt := 0
if N
continue
}
throw Error("Malformed JSON - unrecognized character.", 0, A_LoopField " in " t)
}
}
}
} else if A || InStr(t, ':') > 1
throw Error("Malformed JSON - unrecognized character.", 0, SubStr(t, 1, 1) " in " t)
} else if NQ && (P .= A_LoopField '"', 1)
continue
else if A
LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
else if V
LF := P A_LoopField, map_set(C, K, InStr(LF, "\") ? UC(LF) : LF), K := V := P := ""
else
LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
}
return J
UC(S, e := 1) {
static m := Map('"', '"', "a", "`a", "b", "`b", "t", "`t", "n", "`n", "v", "`v", "f", "`f", "r", "`r")
local v := ""
Loop Parse S, "\"
if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
v .= (t := m.Get(SubStr(A_LoopField, 1, 1), 0)) ? t SubStr(A_LoopField, 2) :
(t := RegExMatch(A_LoopField, "i)^(u[\da-f]{4}|x[\da-f]{2})\K")) ?
Chr("0x" SubStr(A_LoopField, 2, t - 2)) SubStr(A_LoopField, t) : "\" A_LoopField,
e := A_LoopField = "" ? e : !e
return v
}
}
static stringify(obj, expandlevel := unset, space := "  ") {
expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
return Trim(CO(obj, expandlevel))
CO(O, J := 0, R := 0, Q := 0) {
static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ":"
if (OT := Type(O)) = "Array" {
D := !R ? S1 : ""
for key, value in O {
F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
D .= (J > R ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
}
} else {
D := !R ? M1 : ""
for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
D .= (J > R ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
if J = 0 && !R
D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
}
}
if J > R
D .= "`n" CL(R + 1)
if R = 0
D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
return D
}
ES(S) {
switch Type(S) {
case "Float":
if (v := '', d := InStr(S, 'e'))
v := SubStr(S, d), S := SubStr(S, 1, d - 1)
if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
S := Round(S, Max(1, d - InStr(S, ".") - 1))
return S v
case "Integer":
return S
case "String":
S := StrReplace(S, "\", "\\")
S := StrReplace(S, "`t", "\t")
S := StrReplace(S, "`r", "\r")
S := StrReplace(S, "`n", "\n")
S := StrReplace(S, "`b", "\b")
S := StrReplace(S, "`f", "\f")
S := StrReplace(S, "`v", "\v")
S := StrReplace(S, '"', '\"')
return '"' S '"'
default:
return S == this.true ? "true" : S == this.false ? "false" : "null"
}
}
CL(i) {
Loop (s := "", space ? i - 1 : 0)
s .= space
return s
}
}
}
Class PackageManager {
static __New() {
DllCall('combase\RoActivateInstance'
, 'Ptr', this.HString('Windows.Management.Deployment.PackageManager')
, 'Ptr*', IPackageManager := ComValue(13, 0), 'HRESULT')
this.IPackageManager:=IPackageManager
}
static IPackageManager2 {
get => ComObjQuery(this.IPackageManager, "{F7AAD08D-0840-46F2-B5D8-CAD47693A095}")
}
static IPackageManager3 {
get => ComObjQuery(this.IPackageManager, "{DAAD9948-36F1-41A7-9188-BC263E0DCB72}")
}
static IPackageManager8 {
get => ComObjQuery(this.IPackageManager, "{B8575330-1298-4EE2-80EE-7F659C5D2782}")
}
static IPackageManager9 {
get => ComObjQuery(this.IPackageManager, "{1AA79035-CC71-4B2E-80A6-C7041D8579A7}")
}
Class IPackage {
__New(ptr?) {
if IsSet(ptr) && !ptr
throw ValueError('Invalid IUnknown interface pointer', -2, this.__Class)
this.DefineProp("ptr", {Value:ptr ?? 0})
}
__Delete() => this.ptr ? ObjRelease(this.ptr) : 0
IsFramework {
get => (ComCall(8, this, "Char*", &value:=0), value)
}
Id {
get => (ComCall(6, this, "Ptr*", IPackageId:=ComValue(13, 0)), IPackageId)
}
Name {
get => (ComCall(6, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
Version {
get {
PackageVersion := Buffer(8)
ComCall(7, this.Id, 'Ptr', PackageVersion)
Return Major:=NumGet(PackageVersion, "UShort") "."
. Minor:=NumGet(PackageVersion,2, "UShort") "."
. Build:=NumGet(PackageVersion,4, "UShort") "."
. Revision:=NumGet(PackageVersion,6, "UShort")
}
}
Architecture {
get => (ComCall(8, this.Id, "Int*", &value:=0), value)
}
Publisher {
get => (ComCall(10, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
PublisherId {
get => (ComCall(11, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
FullName {
get => (ComCall(12, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
FamilyName {
get => (ComCall(13, this.Id, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
IPackage2 {
get => ComObjQuery(this, "{A6612FB6-7688-4ACE-95FB-359538E7AA01}")
}
DisplayName {
get => (ComCall(6, this.IPackage2, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
PublisherDisplayName {
get => (ComCall(7, this.IPackage2, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
IPackage3 {
get => ComObjQuery(this, "{5F738B61-F86A-4917-93D1-F1EE9D3B35D9}")
}
IPackageStatus {
get => (ComCall(6, this.IPackage3, "Ptr*", value:=ComValue(13, 0)), value)
}
VerifyIsOK {
get => (ComCall(6, this.IPackageStatus, "Char*", &value:=0), value)
}
NotAvailable {
get => (ComCall(7, this.IPackageStatus, "Char*", &value:=0), value)
}
PackageOffline {
get => (ComCall(8, this.IPackageStatus, "Char*", &value:=0), value)
}
DataOffline {
get => (ComCall(9, this.IPackageStatus, "Char*", &value:=0), value)
}
Disabled {
get => (ComCall(10, this.IPackageStatus, "Char*", &value:=0), value)
}
InstalledDate {
get => (ComCall(7, this.IPackage3, "Int64*", &value:=0), DateAdd(1601,value/10000000, "S"))
}
IPackage4 {
get => ComObjQuery(this, "{65AED1AE-B95B-450C-882B-6255187F397E}")
}
SignatureKind {
get => (ComCall(6, this.IPackage4, "Int*", &value:=0), value)
}
IPackage5 {
get => ComObjQuery(this, "{0E842DD4-D9AC-45ED-9A1E-74CE056B2635}")
}
UriLogo {
get {
ComCall(9, this.IPackage2, 'Ptr*', IUriRuntimeClass:=ComValue(13, 0))
Return ComObjQuery(IUriRuntimeClass, "{9e365e57-48b2-4160-956f-c7385120bbfc}")
}
}
DisplayUri {
get => (ComCall(7, this.UriLogo, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
RawUri {
get => (ComCall(16, this.UriLogo, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
Logo {
get {
InstalledPath:=this.InstalledPath
rLogo:=""
try rLogo:=this.RawUri
If !FileExist(rLogo) && FileExist(InstalledPath "\AppxManifest.xml") {
AppxManifest:=FileRead(InstalledPath "\AppxManifest.xml")
If RegExMatch(AppxManifest, 'Square44x44Logo="(.*?)"', &SubPat) {
rLogo:= InstalledPath "\" SubPat[1]
If !FileExist(rLogo) {
SplitPath rLogo,, &dir, &ext, &name_no_ext
rLogo:=dir "\" name_no_ext ".scale-100." ext
}
}
}
Return rLogo
}
}
IPackage8 {
get => ComObjQuery(this, "{2C584F7B-CE2A-4BE6-A093-77CFBB2A7EA1}")
}
InstalledPath {
get => (ComCall(9, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
MutablePath {
get => (ComCall(10, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
EffectivePath {
get => (ComCall(11, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
EffectiveExternalPath {
get => (ComCall(12, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
MachineExternalPath {
get => (ComCall(13, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
UserExternalPath {
get => (ComCall(14, this.IPackage8, "Ptr*", &value:=0), PackageManager.HStringToStr(value))
}
}
static RegisterPackage(manifestFilePath, dependencyPackageUris:=0, deploymentOptions:=0) {
ComCall(10, this.IPackageManager
, 'Ptr', this.CreateUri(manifestFilePath)
, 'Ptr', dependencyPackageUris
, 'Ptr', deploymentOptions
, 'Ptr*', DeploymentOperation := ComValue(13, 0))
Return this.WaitForAsync(DeploymentOperation)
}
static RegisterPackageByFullName(mainPackageFullName, dependencyPackageFullNames:=0, deploymentOptions:=0) {
ComCall(8, this.IPackageManager2
, 'Ptr', this.HString(mainPackageFullName)
, 'Ptr', dependencyPackageFullNames
, 'Ptr', deploymentOptions
, 'Ptr*', DeploymentOperation := ComValue(13, 0))
Return this.WaitForAsync(DeploymentOperation)
}
static RemovePackage(packageFullName, removalOptions:=0) {
If removalOptions {
ComCall(6, this.IPackageManager2
, 'Ptr', this.HString(packageFullName)
, 'UInt', removalOptions
, 'Ptr*', DeploymentOperation := ComValue(13, 0))
} Else {
ComCall(8, this.IPackageManager
, 'Ptr', this.HString(packageFullName)
, 'Ptr*', DeploymentOperation := ComValue(13, 0))
}
Return this.WaitForAsync(DeploymentOperation)
}
static FindPackages(UserSID:="", IncludeFramework:=0, IncludeSignatureKindSystem:=0) {
If UserSID="All"
ComCall(11, this.IPackageManager, 'Ptr*', PackageCollection := ComValue(13, 0))
Else
ComCall(12, this.IPackageManager
, 'Ptr', (UserSID?this.HString(UserSID):0)
, 'Ptr*', PackageCollection := ComValue(13, 0))
ComCall(6, PackageCollection, 'Ptr*', CPackage:=ComValue(13, 0))
arr := Array()
Loop {
Try {
obj:={}
ComCall(6, CPackage, 'Ptr*', IPackage:=this.IPackage())
SignatureKind:=IPackage.SignatureKind
IsFramework:=IPackage.IsFramework
FamilyName:=IPackage.FamilyName
If (IncludeSignatureKindSystem
|| (!IncludeSignatureKindSystem
&& SignatureKind!=4
&& FamilyName != "Microsoft.SecHealthUI_8wekyb3d8bbwe"
&& FamilyName!="Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"))
&& (IncludeFramework
|| (!IncludeFramework && IsFramework==0)) {
arr.Push IPackage
}
ComCall(8, CPackage, 'Char*', &IsMoveNext:=0)
If !IsMoveNext {
IPackage:=""
CPackage:=""
PackageCollection:=""
Break
}
} Catch {
IPackage:=""
CPackage:=""
PackageCollection:=""
Break
}
}
return arr
}
static FindPackagesByPackageFamilyName(packageFamilyName, UserSID:="") {
If UserSID && UserSID="All"
ComCall(19, this.IPackageManager
, 'Ptr', this.HString(packageFamilyName)
, 'Ptr*', PackageCollection := ComValue(13, 0))
Else
ComCall(20, this.IPackageManager
, 'Ptr', (UserSID?this.HString(UserSID):0)
, 'Ptr', this.HString(packageFamilyName)
, 'Ptr*', PackageCollection := ComValue(13, 0))
ComCall(6, PackageCollection, 'Ptr*', CPackage:=ComValue(13, 0))
arr := Array()
Loop {
Try {
ComCall(6, CPackage, 'Ptr*', IPackage:=this.IPackage())
arr.Push IPackage
ComCall(8, CPackage, 'Char*', &IsMoveNext:=0)
If !IsMoveNext {
IPackage:=""
CPackage:=""
PackageCollection:=""
Break
}
} Catch {
IPackage:=""
CPackage:=""
PackageCollection:=""
Break
}
}
return arr
}
static FindProvisionedPackages() {
arr := Array()
ComCall(6, this.IPackageManager9, 'Ptr*', PackageCollection := ComValue(13, 0))
ComCall(7, PackageCollection, 'UInt*', &Size:=0)
Loop Size {
ComCall(6, PackageCollection, "UInt", A_Index-1, 'Ptr*', IPackage := this.IPackage())
arr.Push IPackage
}
IPackage:=""
PackageCollection:=""
return arr
}
static DeprovisionPackageForAllUsers(packageFamilyName) {
ComCall(6, this.IPackageManager8
, 'Ptr', this.HString(packageFamilyName)
, 'Ptr*', DeploymentOperation := ComValue(13, 0))
Return this.WaitForAsync(DeploymentOperation)
}
static SetPackageStatus(packageFullName, PackageStatus:=0) {
ComCall(16, this.IPackageManager3, 'Ptr', this.HString(packageFullName), 'UInt', PackageStatus)
}
static ClearPackageStatus(packageFullName, PackageStatus:=0) {
ComCall(8, this.IPackageManager3, 'Ptr', this.HString(packageFullName), 'UInt', PackageStatus)
}
static CheckInstallUser(packageFullName, UserSID_Need_Search, InstallState:=2) {
ComCall(15, this.IPackageManager, 'Ptr', this.HString(packageFullName), 'Ptr*', Iterable_Users := ComValue(13, 0))
ComCall(6, Iterable_Users, 'Ptr*', Iterator_User:=ComValue(13, 0))
s:=0
Loop {
ComCall(7, Iterator_User, 'Char*', &HasCurrent:=0)
If !HasCurrent
Break
ComCall(6, Iterator_User, 'Ptr*', ABI_User:=ComValue(13, 0))
ComCall(6, ABI_User, 'Ptr*', &UserSecurityId:=0)
ComCall(7, ABI_User, 'UInt*', &PackageInstallState:=0)
If this.HStringToStr(UserSecurityId)=UserSID_Need_Search && PackageInstallState==InstallState {
s:=1
Break
}
ComCall(8, Iterator_User, 'Char*', &IsMoveNext:=0)
If !IsMoveNext
Break
}
ABI_User:=""
UserSecurityId:=""
Iterator_User:=""
Iterable_Users:=""
Return s
}
static WaitForAsync(obj, rIndex:=0, rType:="Ptr*", &rArg:=ComValue(13, 0)) {
local AsyncInfo := ComObjQuery(obj, "{00000036-0000-0000-C000-000000000046}"), status, ErrorCode
Loop {
ComCall(7, AsyncInfo, "uint*", &status:=0)
if (status != 0) {
if (status = 3) {
ComCall(8, ASyncInfo, "uint*", &ErrorCode:=0)
A_LastError:=ErrorCode
}
break
}
Sleep 10
}
If rIndex!=0 {
ComCall(rIndex, obj, rType, rArg)
}
ComCall(10, AsyncInfo)
Return status
}
static CreateUri(str) {
result := DllCall("Combase\RoGetActivationFactory"
, "Ptr", this.HString("Windows.Foundation.Uri")
, "Ptr", this.CLSIDFromString("{44A9796F-723E-4FDF-A218-033E75B0C084}")
, "Ptr*", IUriRuntimeClassFactory:=ComValue(13, 0), "HRESULT")
ComCall(6, IUriRuntimeClassFactory, "Ptr", this.HString(str), "Ptr*", IUriRuntimeClass2:=ComValue(13, 0))
Return IUriRuntimeClass2
}
class HString {
Ptr:=0
__New(str) => DllCall('combase\WindowsCreateString', 'WStr', str, 'UInt', StrLen(str), 'Ptr*', this, 'HRESULT')
__Delete() => DllCall('combase\WindowsDeleteString', 'Ptr', this, 'HRESULT')
}
static HStringToStr(HS) {
bStr:=DllCall("Combase.dll\WindowsGetStringRawBuffer", "Ptr", HS, "uint*", &length:=0, "Ptr")
Return StrGet(bStr)
}
static CLSIDFromString(IID) {
local CLSID := Buffer(16), res
if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
Return CLSID
}
}
Data:={
DisableAutoSuggest: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete",RegType: "REG_SZ",RegValue1: "no",RegValueDefault: "no",RegValueName: "AutoSuggest"}
]},
DisableAppendCompletion: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete",RegType: "REG_SZ",RegValue1: "no",RegValueDefault: "yes",RegValueName: "Append Completion"}
]},
DisableCustomInking: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Personalization\Settings",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "AcceptedPrivacyPolicy"},
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\InputPersonalization",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "RestrictImplicitTextCollection"},
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\InputPersonalization",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "RestrictImplicitInkCollection"},
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "HarvestContacts"}
]},
DisableBackgroundApps: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "GlobalUserDisabled"},
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Search",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "BackgroundAppGlobalToggle"}
]},
DisableLockScreen: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoLockScreen"}
]},
NumLockonStartup: {Act: [
{Type: "RegChange",RegKey: "HKU\.DEFAULT\Control Panel\Keyboard",RegType: "REG_SZ",RegValue1: "2",RegValue0: "2147483648",RegValueName: "InitialKeyboardIndicators"}
]},
HideStartMenuRecommendations: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "Start_IrisRecommendations"}
]},
HideMostUsedApps: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Start",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "0",RegValueName: "ShowFrequentList"}
]},
HideStartMenuRecentlyAdded: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Start",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ShowRecentList"}
]},
HideStartMenuRecentlyOpened: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "Start_TrackDocs"}
]},
HideStartMenuAccountNotifications: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "Start_AccountNotifications"}
]},
ShowHidden: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "2",RegValueName: "Hidden", RefreshExplorer: 1}
]},
ShowHiddenSystem: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "ShowSuperHidden", RefreshExplorer: 1}
]},
ShowExtensions: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "HideFileExt", RefreshExplorer: 1}
]},
DisableShortcutText: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",RegType: "REG_BINARY",RegValue1: "00000000",RegValue0: "16000000",RegValueName: "link"}
]},
DisableScheduledDefrag: {Act: [{Type: "ScheduleService", Location: "\Microsoft\Windows\Defrag",TaskName: "ScheduledDefrag"}]},
SnippingPrintScreen: {Act: [
{Type: "RegChange",RegKey: "HKCU\Control Panel\Keyboard",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "PrintScreenKeyForSnippingEnabled"}
]},
UninstallOneDrive: {Act: [{Type: "Custom"}]},
ShowThisPC: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", RefreshExplorer: 1}
]},
OpenFileExplorerThisPC: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "2",RegValueName: "LaunchTo"}
]},
ShutdownAcceleration: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "1000",RegValueDefault: "300",RegValueName: "LowLevelHooksTimeout"},
{Type: "RegAdd",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "5000",RegValueDefault: "5000",RegValueName: "WaitToKillServiceTimeout"},
{Type: "RegAdd",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "3000",RegValueDefault: "5000",RegValueName: "HungAppTimeout"},
{Type: "RegAdd",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "10000",RegValueDefault: "20000",RegValueName: "WaitToKillAppTimeout"}
]},
DisableMenuShowDelay: {Act: [
{Type: "RegChange",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "0",RegValue0: "400",RegValueName: "MenuShowDelay"}
]},
AutoEndTasks: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Control Panel\Desktop",RegType: "REG_SZ",RegValue1: "1",RegValueDefault: "0",RegValueName: "AutoEndTasks"}
]},
DisableAnimationEffectMaxMin: {Act: [
{Type: "RegChange",RegKey: "HKCU\Control Panel\Desktop\WindowMetrics",RegType: "REG_SZ",RegValue1: "0",RegValue0: "1",RegValueName: "MinAnimate"}
]},
MouseHoverTime: {Act: [
{Type: "RegChange",RegKey: "HKCU\Control Panel\Mouse",RegType: "REG_SZ",RegValue1: "100",RegValue0: "400",RegValueName: "MouseHoverTime"}
]},
OptimizeRefreshPolicy: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoSimpleNetIDList"}
]},
DisableLowDiskSpaceChecks: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoLowDiskSpaceChecks"}
]},
LinkResolveIgnoreLinkInfo: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "LinkResolveIgnoreLinkInfo"}
]},
NoResolveSearch: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoResolveSearch"}
]},
NoResolveTrack: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoResolveTrack"}
]},
NoInternetOpenWith: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "NoInternetOpenWith"}
]},
DisableBootOptimize: {Act: [
{Type: "RegAdd",RegKey: "HKLM\Software\Microsoft\Dfrg\BootOptimizeFunction",RegType: "REG_SZ",RegValue1: "n",RegValueDefault: "y",RegValueName: "Enable"}
]},
DisableAutoDefragIdle: {Act: [
{Type: "RegAdd",RegKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\OptimalLayout",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "EnableAutoLayout"}
]},
DisablePrefetchParameters: {Act: [
{Type: "RegChange",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "3",RegValueName: "EnablePrefetcher"}
]},
DisableErrorReporting: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\Windows Error Reporting",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "Disabled"}
]},
DisableAeDebug: {Act: [
{Type: "RegAdd",RegKey: "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AeDebug",RegType: "REG_SZ",RegValue1: "0",RegValueName: "Auto"}
]},
DisableCrashAutoReboot: {Act: [
{Type: "RegChange",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "AutoReboot"}
]},
Optimizeprocessorperformance: {RequiresWinInstallationType:"Client",Act: [
{Type: "RegChange",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl",RegType: "REG_DWORD",RegValue1: "38",RegValue0: "2",RegValueName: "Win32PrioritySeparation"}
]},
Disablememorypagination: {Act: [
{Type: "RegChange",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "DisablePagingExecutive"}
]},
IoPageLockLimit: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management",RegType: "REG_DWORD",RegValue1: "134217728",RegValueDefault: "512000",RegValueName: "IoPageLockLimit"}
]},
IncreaseIconCache: {Act: [
{Type: "RegAdd",RegKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer",RegType: "REG_SZ",RegValue1: "4096",RegValueDefault: "500",RegValueName: "Max Cached Icons"}
]},
OptimizeNetworkTransfer: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters",RegType: "REG_DWORD",RegValue1: "32",RegValueDefault: "16",RegValueName: "MaxCollectionCount"},
{Type: "RegAdd",RegKey: "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters",RegType: "REG_DWORD",RegValue1: "30",RegValueDefault: "17",RegValueName: "MaxThreads"},
{Type: "RegAdd",RegKey: "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters",RegType: "REG_DWORD",RegValue1: "100",RegValueDefault: "50",RegValueName: "MaxCmds"}
]},
DisableWCE: {Act: [
{Type: "ScheduleService", Location: "\Microsoft\Windows\Autochk",TaskName: "Proxy"},
{Type: "ScheduleService", Location: "\Microsoft\Windows\Application Experience",TaskName: "Microsoft Compatibility Appraiser"}
]},
DisableMicrosoftEdgeUpdateTask: {Act: [
{Type: "ScheduleService", Location: "\",TaskName: "MicrosoftEdgeUpdateTaskMachineCore"},
{Type: "ScheduleService", Location: "\",TaskName: "MicrosoftEdgeUpdateTaskMachineUA"},
{Type: "Service",Name: "edgeupdate",StartType1:4,StartType0:2,Check:0}
]},
DisableGoogleUpdateTask: {Act: [
{Type: "ScheduleService", Location: "\",TaskName: "GoogleUpdateTaskMachineCore"},
{Type: "ScheduleService", Location: "\",TaskName: "GoogleUpdateTaskMachineUA"}
]},
DisabledVBSCodeIntegrity: {Act: [
{Type: "RegDel",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity",RegType: "REG_DWORD",RegValue0: "1",RegValueName: "Enabled"},
{Type: "RegDel",RegKey: "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity",RegType: "REG_DWORD",RegValue0: "2",RegValueName: "WasEnabledBy"}
]},
DisableAutoplay: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers",RegType: "REG_DWORD",RegValue1: "1",RegValue0: "0",RegValueName: "DisableAutoplay"}
]},
DisableRemoteRegAccess: {Act: [
{Type: "Service",Name: "RemoteRegistry",State1:1,StartType1:4,State0:4,StartType0:2}
]},
DisableRecentFiles: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ShowRecent"}
]},
DisableFrequentFolders: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ShowFrequent"}
]},
DisableOfferSuggestions: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ScoobeSystemSettingEnabled"}
]},
DisableTipsAndSuggestions: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "SoftLandingEnabled"}
]},
DiagnosticDataOff: {Act: [
{Type: "RegChange",RegKey: "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "AllowTelemetry"},
{Type: "RegChange",RegKey: "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "MaxTelemetryAllowed"}
]},
DisableTailoredExperiences: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "TailoredExperiencesWithDiagnosticDataEnabled"}
]},
DisablePersonalizedAdsStoreApps: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "Enabled"}
]},
DisableWebSearch: {RequiresWinVer: ">=10.0.16299",Act: [
{RequiresWinVer: ">=10.0.19041",Type: "RegAdd",RegKey: "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "DisableSearchBoxSuggestions"},
{RequiresWinVer: ">=10.0.17763,<10.0.19041",Type: "RegAdd",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "BingSearchEnabled"},
{RequiresWinVer: ">=10.0.16299,<=10.0.17134",Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "AllowCortana"}
]},
DisableWebSearchStartMenu: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search",RegType: "REG_DWORD",RegValue1: "1",RegValueName: "DisableWebSearch"}
]},
DisableMSACloudSearch: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "IsMSACloudSearchEnabled"}
]},
DisableAADCloudSearch: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "IsAADCloudSearchEnabled"}
]},
DisableDeviceSearchHistory: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "IsDeviceSearchHistoryEnabled"}
]},
DisableWindowsFeedback: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Siuf\Rules",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "",RegValueName: "PeriodInNanoSeconds"},
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Siuf\Rules",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "",RegValueName: "NumberOfSIUFInPeriod"}
]},
DisableSyncProviderNotifications: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ShowSyncProviderNotifications"}
]},
DisableAdsOnLockScreen: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "RotatingLockScreenEnabled"},
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "RotatingLockScreenOverlayEnabled"},
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "SubscribedContent-338387Enabled"}
]},
DisableSettingsAppSuggestions: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "SubscribedContent-338393Enabled"},
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "SubscribedContent-353694Enabled"},
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "SubscribedContent-353696Enabled"}
]},
DisableStartMenuAppSuggestions: {RequiresWinVer: "<10.0.22000", Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValueDefault: "1",RegValueName: "SubscribedContent-338388Enabled"}
]},
DisableAutoInstallationApps: {Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "SilentInstalledAppsEnabled"}
]},
UnpinFileExplorer: {Act: [{Type: "SystemPinned",SearchName: "File Explorer",
Favorites: "00A40100003A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000709F13549EE7D801340D32889EE7D801115F39889EE7D8011400560031000000000058550F5E11005461736B42617200400009000400EFBE58550F5E58550F5E2E000000C7CC0100000001000000000000000000000000000000EF1BF8005400610073006B00420061007200000016001201320097010000A754662A200046494C4545587E312E4C4E4B00007C0009000400EFBE58550F5E58550F5E2E000000C8CC0100000001000000000000000000520000000000A413A200460069006C00650020004500780070006C006F007200650072002E006C006E006B00000040007300680065006C006C00330032002E0064006C006C002C002D003200320030003600370000001C00120000002B00EFBE115F39889EE7D8011C00420000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F00770073002E004500780070006C006F0072006500720000001C00260000001E00EFBE0200530079007300740065006D00500069006E006E006500640000001C000000",
FavoritesResolve: "3B0300004C0000000114020000000000C00000000000004683008000200000000C8334889EE7D80147E942889EE7D8015CF4E1FBD161D801970100000000000001000000000000000000000000000000A0013A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000709F13549EE7D801340D32889EE7D801115F39889EE7D8011400560031000000000058550F5E11005461736B42617200400009000400EFBE58550F5E58550F5E2E000000C7CC0100000001000000000000000000000000000000EF1BF8005400610073006B00420061007200000016000E01320097010000A754662A200046494C4545587E312E4C4E4B00007C0009000400EFBE58550F5E58550F5E2E000000C8CC0100000001000000000000000000520000000000A413A200460069006C00650020004500780070006C006F007200650072002E006C006E006B00000040007300680065006C006C00330032002E0064006C006C002C002D003200320030003600370000001C00220000001E00EFBE02005500730065007200500069006E006E006500640000001C00120000002B00EFBE115F39889EE7D8011C00420000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F00770073002E004500780070006C006F0072006500720000001C000000A40000001C000000010000001C0000002D00000000000000A3000000110000000300000042D5A4881000000000433A5C55736572735C41646D696E6973747261746F725C417070446174615C526F616D696E675C4D6963726F736F66745C496E7465726E6574204578706C6F7265725C517569636B204C61756E63685C557365722050696E6E65645C5461736B4261725C46696C65204578706C6F7265722E6C6E6B000060000000030000A058000000000000006465736B746F702D6534396D656B3500B6ECB67C1407F54390726C4105B222623459A4CD0654ED1985587C5079067BCDB6ECB67C1407F54390726C4105B222623459A4CD0654ED1985587C5079067BCD45000000090000A03900000031535053B1166D44AD8D7048A748402EA43D788C1D00000068000000004800000043F03D82C839F24C9CCFF555D8E425B6000000000000000000000000"
}]},
UnpinEdge: {Act: [{Type: "SystemPinned",SearchName: "Microsoft Edge",
Favorites: "00560100003A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000709F13549EE7D801340D32889EE7D80189B747889EE7D8011400560031000000000058550F5E11005461736B42617200400009000400EFBE58550F5E58550F5E2E000000C7CC010000000100000000000000000000000000000077C3E9005400610073006B0042006100720000001600C4003200860900005955810D20004D4943524F537E312E4C4E4B0000560009000400EFBE58550F5E58550F5E2E000000CACC0100000001000000000000000000000000000000280E0D004D006900630072006F0073006F0066007400200045006400670065002E006C006E006B0000001C00120000002B00EFBE89B747889EE7D8011C001A0000001D00EFBE02004D005300450064006700650000001C00260000001E00EFBE0200530079007300740065006D00500069006E006E006500640000001C000000",
FavoritesResolve: "EE0200004C0000000114020000000000C000000000000046830080002000000089B747889EE7D801C0C55A889EE7D801D88E244213E8D80186090000000000000100000000000000000000000000000052013A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000709F13549EE7D801340D32889EE7D80189B747889EE7D8011400560031000000000058550F5E11005461736B42617200400009000400EFBE58550F5E58550F5E2E000000C7CC010000000100000000000000000000000000000077C3E9005400610073006B0042006100720000001600C0003200860900005955810D20004D4943524F537E312E4C4E4B0000560009000400EFBE58550F5E58550F5E2E000000CACC0100000001000000000000000000000000000000280E0D004D006900630072006F0073006F0066007400200045006400670065002E006C006E006B0000001C00220000001E00EFBE02005500730065007200500069006E006E006500640000001C00120000002B00EFBE89B747889EE7D8011C001A0000001D00EFBE02004D005300450064006700650000001C000000A50000001C000000010000001C0000002D00000000000000A4000000110000000300000042D5A4881000000000433A5C55736572735C41646D696E6973747261746F725C417070446174615C526F616D696E675C4D6963726F736F66745C496E7465726E6574204578706C6F7265725C517569636B204C61756E63685C557365722050696E6E65645C5461736B4261725C4D6963726F736F667420456467652E6C6E6B000060000000030000A058000000000000006465736B746F702D6534396D656B3500B6ECB67C1407F54390726C4105B222623559A4CD0654ED1985587C5079067BCDB6ECB67C1407F54390726C4105B222623559A4CD0654ED1985587C5079067BCD45000000090000A03900000031535053B1166D44AD8D7048A748402EA43D788C1D00000068000000004800000043F03D82C839F24C9CCFF555D8E425B6000000000000000000000000"
}]},
UnpinStore: {Act: [{Type: "SystemPinned",SearchName: "Microsoft Store",
Favorites: "005C06000014001F809BD434424502F34DB7803893943456E146060000AA05415050539805080003000000000000005F0200003153505355284C9F799F394BA8D0E1D42DE1D5F35D00000011000000001F000000250000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B00790062003300640038006200620077006500000000001100000027000000000B00000000000000110000000E0000000013000000010000008500000015000000001F000000390000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F00320032003200300034002E0031003400300030002E0034002E0030005F007800360034005F005F003800770065006B00790062003300640038006200620077006500000000006500000005000000001F000000290000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B00790062003300640038006200620077006500210041007000700000000000BD0000000F000000001F0000005600000043003A005C00500072006F006700720061006D002000460069006C00650073005C00570069006E0064006F007700730041007000700073005C004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F00320032003200300034002E0031003400300030002E0034002E0030005F007800360034005F005F003800770065006B0079006200330064003800620062007700650000001D0000002000000000480000007E0E35D6229EEE40A7871BEB5615E2EB000000008A020000315350534D0BD48669903C44819A2A54090DCCEC550000000C000000001F000000210000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004D0065006400540069006C0065002E0070006E006700000000005500000002000000001F000000210000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004100700070004C006900730074002E0070006E00670000000000590000000F000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F0072006500420061006400670065004C006F0067006F002E0070006E00670000000000550000000D000000001F000000220000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065005700690064006500540069006C0065002E0070006E0067000000110000000400000000130000000078D4FF11000000050000000013000000FFFFFFFF5900000013000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004C006100720067006500540069006C0065002E0070006E00670000000000110000000E0000000013000000A5040000310000000B000000001F000000100000004D006900630072006F0073006F00660074002000530074006F007200650000005900000014000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F007200650053006D0061006C006C00540069006C0065002E0070006E00670000000000000000003100000031535053B1166D44AD8D7048A748402EA43D788C15000000640000000015000000CD02000000000000000000004D0000003153505330F125B7EF471A10A5F102608C9EEBAC310000000A000000001F000000100000004D006900630072006F0073006F00660074002000530074006F00720065000000000000002D00000031535053B377ED0D14C66C45AE5B285B38D7B01B110000000700000000130000000000000000000000000000000000120000002B00EFBE645D88889EE7D801B0055E0000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B0079006200330064003800620062007700650021004100700070000000B005260000001E00EFBE0200530079007300740065006D00500069006E006E00650064000000B0050000",
FavoritesResolve: "AA0600004C0000000114020000000000C0000000000000468100800000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000580614001F809BD434424502F34DB7803893943456E142060000AA05415050539805080003000000000000005F0200003153505355284C9F799F394BA8D0E1D42DE1D5F35D00000011000000001F000000250000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B00790062003300640038006200620077006500000000001100000027000000000B00000000000000110000000E0000000013000000010000008500000015000000001F000000390000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F00320032003200300034002E0031003400300030002E0034002E0030005F007800360034005F005F003800770065006B00790062003300640038006200620077006500000000006500000005000000001F000000290000004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B00790062003300640038006200620077006500210041007000700000000000BD0000000F000000001F0000005600000043003A005C00500072006F006700720061006D002000460069006C00650073005C00570069006E0064006F007700730041007000700073005C004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F00320032003200300034002E0031003400300030002E0034002E0030005F007800360034005F005F003800770065006B0079006200330064003800620062007700650000001D0000002000000000480000007E0E35D6229EEE40A7871BEB5615E2EB000000008A020000315350534D0BD48669903C44819A2A54090DCCEC550000000C000000001F000000210000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004D0065006400540069006C0065002E0070006E006700000000005500000002000000001F000000210000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004100700070004C006900730074002E0070006E00670000000000590000000F000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F0072006500420061006400670065004C006F0067006F002E0070006E00670000000000550000000D000000001F000000220000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065005700690064006500540069006C0065002E0070006E0067000000110000000400000000130000000078D4FF11000000050000000013000000FFFFFFFF5900000013000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F00720065004C006100720067006500540069006C0065002E0070006E00670000000000110000000E0000000013000000A5040000310000000B000000001F000000100000004D006900630072006F0073006F00660074002000530074006F007200650000005900000014000000001F000000230000004100730073006500740073005C00410070007000540069006C00650073005C00530074006F007200650053006D0061006C006C00540069006C0065002E0070006E00670000000000000000003100000031535053B1166D44AD8D7048A748402EA43D788C15000000640000000015000000CD02000000000000000000004D0000003153505330F125B7EF471A10A5F102608C9EEBAC310000000A000000001F000000100000004D006900630072006F0073006F00660074002000530074006F00720065000000000000002D00000031535053B377ED0D14C66C45AE5B285B38D7B01B110000000700000000130000000000000000000000000000000000220000001E00EFBE02005500730065007200500069006E006E00650064000000B005120000002B00EFBE645D88889EE7D801B0055E0000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F0077007300530074006F00720065005F003800770065006B0079006200330064003800620062007700650021004100700070000000B005000000000000"
}]},
UnpinSearch: {Act: [
{Type: "RegAdd",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search",RegType: "REG_DWORD",RegValue1: "0",RegValueName: "SearchboxTaskbarMode"}
]},
UnpinTaskView: {Act: [
{Type: "RegAdd",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueName: "ShowTaskViewButton"}
]},
UnpinWidgets: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueName: "TaskbarDa"}
]},
UnpinCopilot: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueName: "ShowCopilotButton"}
]},
UnpinChat: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValueName: "TaskbarMn"}
]},
UnpinCortana: {RequiresWinVer: "<10.0.22000",Act: [
{Type: "RegChange",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "ShowCortanaButton"}
]},
UnpinMail: {RequiresWinVer: "<10.0.22000",Act: [{Type: "SystemPinned",SearchName: "Mail",
Favorites: "00AF06000014001F809BD434424502F34DB7803893943456E199060000B50541505053A30508000300000000000000F60200003153505355284C9F799F394BA8D0E1D42DE1D5F37500000011000000001F000000320000006D006900630072006F0073006F00660074002E00770069006E0064006F007700730063006F006D006D0075006E00690063006100740069006F006E00730061007000700073005F003800770065006B007900620033006400380062006200770065000000110000000E000000001300000001000000A900000015000000001F0000004B0000006D006900630072006F0073006F00660074002E00770069006E0064006F007700730063006F006D006D0075006E00690063006100740069006F006E00730061007000700073005F00310036003000300035002E00310031003600320039002E00320030003300310036002E0030005F007800360034005F005F003800770065006B0079006200330064003800620062007700650000000000AD00000005000000001F0000004D0000006D006900630072006F0073006F00660074002E00770069006E0064006F007700730063006F006D006D0075006E00690063006100740069006F006E00730061007000700073005F003800770065006B0079006200330064003800620062007700650021006D006900630072006F0073006F00660074002E00770069006E0064006F00770073006C006900760065002E006D00610069006C0000000000E10000000F000000001F0000006800000043003A005C00500072006F006700720061006D002000460069006C00650073005C00570069006E0064006F007700730041007000700073005C006D006900630072006F0073006F00660074002E00770069006E0064006F007700730063006F006D006D0075006E00690063006100740069006F006E00730061007000700073005F00310036003000300035002E00310031003600320039002E00320030003300310036002E0030005F007800360034005F005F003800770065006B0079006200330064003800620062007700650000001D0000002000000000480000000C5AA79904344B4AA5AD2F5C3F90A5D10000000012020000315350534D0BD48669903C44819A2A54090DCCEC490000000C000000001F0000001C00000069006D0061006700650073005C00480078004D00610069006C004D0065006400690075006D00540069006C0065002E0070006E00670000004500000002000000001F0000001900000069006D0061006700650073005C00480078004D00610069006C004100700070004C006900730074002E0070006E00670000000000410000000F000000001F0000001700000069006D0061006700650073005C00480078004D00610069006C00420061006400670065002E0070006E00670000000000450000000D000000001F0000001A00000069006D0061006700650073005C00480078004D00610069006C005700690064006500540069006C0065002E0070006E0067000000110000000400000000130000000078D7FF4900000013000000001F0000001B00000069006D0061006700650073005C00480078004D00610069006C004C006100720067006500540069006C0065002E0070006E0067000000000011000000050000000013000000FFFFFFFF110000000E0000000013000000AD0400001D0000000B000000001F000000050000004D00610069006C00000000004900000014000000001F0000001B00000069006D0061006700650073005C00480078004D00610069006C0053006D0061006C006C00540069006C0065002E0070006E00670000000000000000003100000031535053B1166D44AD8D7048A748402EA43D788C15000000640000000015000000100100000000000000000000390000003153505330F125B7EF471A10A5F102608C9EEBAC1D0000000A000000001F000000050000004D00610069006C0000000000000000002D00000031535053B377ED0D14C66C45AE5B285B38D7B01B110000000700000000130000000000000000000000000000000000120000002B00EFBE149BAA8075F1D801BB05A60000001D00EFBE02006D006900630072006F0073006F00660074002E00770069006E0064006F007700730063006F006D006D0075006E00690063006100740069006F006E00730061007000700073005F003800770065006B0079006200330064003800620062007700650021006D006900630072006F0073006F00660074002E00770069006E0064006F00770073006C006900760065002E006D00610069006C000000BB05260000001E00EFBE0200530079007300740065006D00500069006E006E00650064000000BB050000",
FavoritesResolve: ""
}]},
UnpinNewsandInterests: {RequiresWinVer: "<10.0.22000",Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds",RegType: "REG_DWORD",RegValue1: "2",RegValue0: "0",RegValueName: "ShellFeedsTaskbarViewMode"}
]},
DisableVisualStudioTelemetry: {Act: [{Type: "Custom"}]},
EnableDarkMode: {Act: [
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "SystemUsesLightTheme"},
{Type: "RegChange",RegKey: "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "AppsUseLightTheme"}
]},
ClassicContextMenu: {RequiresWinVer: ">=10.0.22000",Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32",RegType: "REG_SZ",RegValue1: "",LvlKeyDel: 2, RestartExplorer: 2}
]},
DisableWindowsSearch: {Act: [{Type: "Service",Name: "WSearch",State1:1,StartType1:4,State0:4,StartType0:2}]},
DisablePrintSpooler: {Act: [{Type: "Service",Name: "Spooler",State1:1,StartType1:4,State0:4,StartType0:2}]},
DisableDiagTrack: {Act: [
{Type: "Service",Name: "DiagTrack",State1:1,StartType1:4,State0:4,StartType0:2},
{Type: "RunTerminal",Value1: A_Comspec ' /c netsh advfirewall firewall set rule name="Connected User Experiences and Telemetry" new action=block & netsh advfirewall firewall set rule name="Cortana" new action=block',Value0: A_Comspec ' /c netsh advfirewall firewall set rule name="Connected User Experiences and Telemetry" new action=allow & netsh advfirewall firewall set rule name="Cortana" new action=allow',}
]},
DisableSystemRestore: {Act: [{Type: "Custom"}]},
DisableMSDefender: {Act: [{Type: "Custom"}]},
DisableAutoWindowsUpdates: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",RegType: "REG_DWORD",RegValue1: "1",RegValueName: "NoAutoUpdate"}
]},
AUOptions: {Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",RegType: "REG_DWORD",RegValue1: "2",RegValueName: "AUOptions"}
]},
DisableGameBar: {Act: [
{Type: "RegAdd",RegKey: "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueDefault: "1",RegValueName: "AppCaptureEnabled"},
{Type: "RegChange",RegKey: "HKCU\System\GameConfigStore",RegType: "REG_DWORD",RegValue1: "0",RegValue0: "1",RegValueName: "GameDVR_Enabled"}
]},
HideWindowsSecurityNotifications: {RequiresWinVer: ">=10.0.16299",Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "DisableNotifications"}
]},
HideWindowsSecurityNoncriticalNotifications: {RequiresWinVer: ">=10.0.16299",Act: [
{Type: "RegAdd",RegKey: "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications",RegType: "REG_DWORD",RegValue1: "1",RegValueDefault: "0",RegValueName: "DisableEnhancedNotifications"}
]},
DisableSleep: {Act: [{Type: "Power",Name: "SleepIdleTimeout", Value1: 0, Value0: 900}]},
DisableHibernate: {Act: [{Type: "Power",Name: "HibernateIdleTimeout", Value1: 0, Value0: 1}]},
DisableHybridSleep: {Act: [{Type: "Power",Name: "HybridSleepIdleTimeout", Value1: 0, Value0: 1}]},
DisableTurnOffDisplay: {Act: [{Type: "Power",Name: "DisplayIdleTimeout", Value1: 0, Value0: 300}]}
}
Layout:=[
{ID: "System",Icon: "*icon106 imageres.dll",Fn: "OptimizeTab",Items: [
"DisableGameBar",
"AutoEndTasks",
"DisableAeDebug",
"DisableAnimationEffectMaxMin",
"DisableAutoDefragIdle",
"DisableBackgroundApps",
"DisableBootOptimize",
"DisableCustomInking",
"DisableCrashAutoReboot",
"DisableErrorReporting",
"DisableGoogleUpdateTask",
"DisableLockScreen",
"DisableLowDiskSpaceChecks",
"Disablememorypagination",
"DisableMenuShowDelay",
"DisableMicrosoftEdgeUpdateTask",
"DisablePrefetchParameters",
"DisableScheduledDefrag",
"DisableShortcutText",
"IoPageLockLimit",
"LinkResolveIgnoreLinkInfo",
"MouseHoverTime",
"NoInternetOpenWith",
"NoResolveSearch",
"NoResolveTrack",
"NumLockonStartup",
"OptimizeNetworkTransfer",
"Optimizeprocessorperformance",
"OptimizeRefreshPolicy",
"ShutdownAcceleration",
"SnippingPrintScreen"]},
{ID: "Privacy",Icon: "*icon185 imageres.dll",Fn: "OptimizeTab",Items: [
"DisableWebSearch",
"DisableMSACloudSearch",
"DisableAADCloudSearch",
"DisableDeviceSearchHistory",
"DisableDiagTrack",
"DiagnosticDataOff",
"DisableAdsOnLockScreen",
"DisableAutoInstallationApps",
"DisableAutoplay",
"DisabledVBSCodeIntegrity",
"DisableOfferSuggestions",
"DisablePersonalizedAdsStoreApps",
"DisableRemoteRegAccess",
"DisableSettingsAppSuggestions",
"DisableTailoredExperiences",
"DisableTipsAndSuggestions",
"DisableWCE",
"DisableVisualStudioTelemetry",
"DisableWindowsFeedback"]},
{ID: "Explorer",Icon: "*icon266 imageres.dll",Icon10: "*icon265 imageres.dll",Fn: "OptimizeTab",Items: [
"DisableAutoSuggest",
"DisableAppendCompletion",
"ShowExtensions",
"ShowHidden",
"ShowHiddenSystem",
"ShowThisPC",
"OpenFileExplorerThisPC",
"IncreaseIconCache",
"DisableRecentFiles",
"DisableFrequentFolders",
"DisableSyncProviderNotifications"]},
{ID: "StartMenu",Icon: "*icon190 imageres.dll",Fn: "OptimizeTab",Items: [
"DisableStartMenuAppSuggestions",
"HideMostUsedApps",
"HideStartMenuRecentlyAdded",
"HideStartMenuRecentlyOpened",
"HideStartMenuAccountNotifications",
"HideStartMenuRecommendations"]},
{ID: "Optional",Icon: "*icon23 imageres.dll",Fn: "OptimizeTab",Items: [
"EnableDarkMode",
"ClassicContextMenu",
"AUOptions",
"DisableAutoWindowsUpdates",
"DisableHibernate",
"DisableHybridSleep",
"DisablePrintSpooler",
"DisableSleep",
"DisableSystemRestore",
"DisableTurnOffDisplay",
"HideWindowsSecurityNotifications",
"HideWindowsSecurityNoncriticalNotifications",
"DisableWindowsSearch",
"UninstallOneDrive"]},
{ID: "PackageManager",Icon: "*icon295 imageres.dll",Fn: "BtnPackageManager_Click"},
{ID: "Search",Fn: "OptimizeTab",Hidden:1}
]
Themes:={
Modern: {BackColor: "F8F9FA", TextColor: "343A40", BackColorNavSelect: "20495057", BackColorPanel: "FFFFFF", BorderColorPanel: "DEE2E6", CtrDark: 0, HrColor: "CED4DA", TextColorHover: "495057"},
Elegant: {BackColor: "F1F3F4", TextColor: "2C3E50", BackColorNavSelect: "203498DB", BackColorPanel: "FEFEFE", BorderColorPanel: "E1E5E9", CtrDark: 0, HrColor: "BDC3C7", TextColorHover: "3498DB"},
Minimal: {BackColor: "F4F6F8", TextColor: "4A5568", BackColorNavSelect: "2038A169", BackColorPanel: "FFFFFF", BorderColorPanel: "E2E8F0", CtrDark: 0, HrColor: "CBD5E0", TextColorHover: "38A169"},
Soft: {BackColor: "F7F8FC", TextColor: "4C566A", BackColorNavSelect: "205E81AC", BackColorPanel: "FDFDFE", BorderColorPanel: "E5E9F0", CtrDark: 0, HrColor: "D8DEE9", TextColorHover: "5E81AC"},
Classic: {BackColor: "F5F6FA", TextColor: "2F3349", BackColorNavSelect: "206C7B7F", BackColorPanel: "FAFAFB", BorderColorPanel: "E4E6EA", CtrDark: 0, HrColor: "C5C9D1", TextColorHover: "6C7B7F"},
Dark: {BackColor: "202020", TextColor: "EAEAEA",BackColorNavSelect: "0DFFFFFF", BackColorPanel: "80000000", BorderColorPanel: "30FFFFFF", CtrDark: 1, HrColor: "4c4c4c", TextColorHover: "00A8EC"}
}
LangData:= {
de: {
Name: "Deutsch",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6MjQ6MjMrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjMzKzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjMzKzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5Yzk0YjE0MC0wNzFjLTMwNDgtOWRiYi1iM2ZiMDM0MGVlOTYiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OWM5NGIxNDAtMDcxYy0zMDQ4LTlkYmItYjNmYjAzNDBlZTk2IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6OWM5NGIxNDAtMDcxYy0zMDQ4LTlkYmItYjNmYjAzNDBlZTk2Ij4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo5Yzk0YjE0MC0wNzFjLTMwNDgtOWRiYi1iM2ZiMDM0MGVlOTYiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6MjQ6MjMrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+M7vobAAAAhZJREFUOBGtwT9LlXEYx+HPff9+z6NH4xRRECQRUUMttoRQQ0NoDkGvw2pu6R0EbZWvI2jIaAmqoUnboiGQoCnoD6bH89z3NyWMQzVodl3GiOPHTjE50WdzswOS2tQ5tzIDnGCbsWridQxtKRQ0xdjYXGP14zt2VP4g3O1iKe1tM7sGFHYIBOGVxxnclfSK3zgjMjtKae83tb509+tA4U/FXNdr4y9r097PTEZVOMw2M9EbP/AEuCpAEsbfpcDYUrjZjvdON83YfGYggY33pkBw5PDRh4f6YwuDzQGYsSsS7hXRLVK6GxJY//hJ3Or0WO/gcobYKwGG0Zuo06Xwpp4vk3ht7yEhEszYMyX2Pe5VL7P26dyF2ZrxVBL7Y1jxuTpQXE4JsV8C5eWqyKkB/4dCUzX5PwQUoA7DPpQU+2XAupcPtVvXcze7IwQY/8IQwtgoem7fXvTJoT1DXMH4NwLBMy+atfXPBSXTsVaXrSRg7I1QOGWyO2+mlZobgWBFG77YrdUFaxJk7IoJDQtlsltUGysYmARiS8KXt82THPhVK+yKArzJpYNnh/M4GOBsMcAcykQ3D/kgI8lIUomUSImUSEkqyUwyEsgH3uvmzcH4yRmhNLzVLW/zkiwfZSgiRISIEJEiQ5HSI6t5qbS6RRijTOKXr++d/F5QCdRBdMwpbQZxAgOJVUevvWXJiuFyvA36Z5IdPwBgEBla9zSGcwAAAABJRU5ErkJggg==",
AUOptions: {Name: "AUOptions",Desc: "Stellen Sie „Benachrichtigen“ ein, bevor Sie Windows-Updates herunterladen"},
AutoEndTasks: {Name: "Aufgaben automatisch beenden",Desc: "Schließen Sie eingefrorene Prozesse, um einen Systemabsturz zu vermeiden"},
BtnHostsEdit: {Name: "Gastgeber bearbeiten"},
BtnPackageManager: {Name: "UWP-Apps"},
BtnRestartExplorer: {Name: "Starten Sie den Explorer neu"},
BtnStartupManager: {Name: "Startup-Manager"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Sprache"},
BtnSys_LoadOptimizeConfig: {Desc: "Optimierungskonfigurationsdatei laden"},
BtnSys_Minimize: {Desc: "Minimieren"},
BtnSys_ReloadTab: {Desc: "Laden Sie diese Registerkarte neu"},
BtnSys_SaveImage: {Desc: "Selbstaufnahme und Speicherung im Bild"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Speichern Sie alle Optimierungskonfigurationen in einer Datei"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Speichern Sie nur die Optimierungskonfiguration dieser Registerkarte in einer Datei"},
BtnSys_Search: {Desc: "Suche nach Optimierungen"},
BtnSys_Setting: {Desc: "Einstellung"},
BtnSys_Theme: {Desc: "Thema"},
ClassicContextMenu: {Name: "Klassisches Kontextmenü"},
DiagnosticDataOff: {Name: "Diagnosedaten aus"},
DisableAADCloudSearch: {Name: "Deaktivieren Sie Cloud Content Search AAD",Desc: "Deaktivieren Sie die Cloud-Inhaltssuche für Ihr Geschäfts- oder Schulkonto"},
DisableAdsOnLockScreen: {Name: "Deaktivieren Sie Anzeigen auf dem Sperrbildschirm"},
DisableAeDebug: {Name: "Deaktivieren Sie AeDebug",Desc: "Deaktivieren Sie den Debugger, um die Fehlerverarbeitung zu beschleunigen"},
DisableAnimationEffectMaxMin: {Name: "Animationseffekt deaktivieren Max. Min",Desc: "Schließen Sie den Animationseffekt beim Maximieren oder Minimieren eines Fensters, um die Fensterreaktion zu beschleunigen"},
DisableAppendCompletion: {Name: "Deaktivieren Sie die Anfügevervollständigung",Desc: "Inline-Autovervollständigung deaktivieren (Vervollständigung anhängen oder automatisch ausfüllen)"},
DisableAutoDefragIdle: {Name: "Deaktivieren Sie die automatische Defragmentierung im Leerlauf",Desc: "Deaktivieren Sie die automatische Defragmentierung im Leerlauf, um die Lebensdauer der SSD zu verlängern"},
DisableAutoInstallationApps: {Name: "Deaktivieren Sie die automatische Installation von Apps"},
DisableAutoplay: {Name: "Deaktiviere Autoplay",Desc: "Deaktivieren Sie die Funktion „Autoplay“ auf Laufwerken, um eine Virusinfektion zu vermeiden"},
DisableAutoSuggest: {Name: "Deaktivieren Sie den automatischen Vorschlag",Desc: "Automatische Vorschläge deaktivieren (Dropdown-Menü „Automatische Vervollständigung“)"},
DisableAutoWindowsUpdates: {Name: "Deaktivieren Sie automatische Windows-Updates",Desc: "Deaktivieren Sie automatische Updates"},
DisableBackgroundApps: {Name: "Hintergrund-Apps deaktivieren"},
DisableBootOptimize: {Name: "Deaktivieren Sie die Boot-Optimierung",Desc: "Defragmentieren Sie das Systemlaufwerk beim Booten, um die Lebensdauer der SSD zu verlängern"},
DisableCrashAutoReboot: {Name: "Deaktivieren Sie den automatischen Neustart nach Absturz",Desc: "Deaktivieren Sie den automatischen Neustart, wenn das System auf einen Bluescreen of Death stößt"},
DisableCustomInking: {Name: "Deaktivieren Sie die benutzerdefinierte Freihandeingabe",Desc: "Deaktivieren Sie das benutzerdefinierte Freihand- und Tippwörterbuch"},
DisableDeviceSearchHistory: {Name: "Deaktivieren Sie den Suchverlauf lokal",Desc: "Deaktivieren Sie den Suchverlauf lokal auf diesen Geräten"},
DisableDiagTrack: {Name: "Deaktivieren Sie DiagTrack",Desc: "DiagTrack – Der Dienst „Connected User Experiences and Telemetry“ ermöglicht Funktionen, die anwendungsinterne und verbundene Benutzererfahrungen unterstützen.`nDarüber hinaus verwaltet dieser Dienst die ereignisgesteuerte Erfassung und Übertragung von Diagnose- und Nutzungsinformationen (wird zur Verbesserung der Erfahrung und Qualität von verwendet). die Windows-Plattform), wenn die Diagnose- und Nutzungsdatenschutz-Optionseinstellungen unter „Feedback und Diagnose“ aktiviert sind."},
DisabledVBSCodeIntegrity: {Name: "VBS-Codeintegrität deaktiviert",Desc: "Deaktivieren Sie den virtualisierungsbasierten Schutz der Codeintegrität"},
DisableErrorReporting: {Name: "Deaktivieren Sie die Fehlerberichterstattung",Desc: "Deaktivieren Sie die Bildschirmfehlerberichterstattung, um die Systemleistung zu verbessern"},
DisableFrequentFolders: {Name: "Deaktivieren Sie FrequentFolders"},
DisableGameBar: {Name: "Deaktivieren Sie die Spielleiste und den Spiel-DVR",Desc: "Mit der Game DVR-Funktion können Sie Ihr Gameplay im Hintergrund aufzeichnen.`nSie befindet sich in der Game Bar – dort finden Sie Schaltflächen zum Aufzeichnen des Gameplays und zum Erstellen von Screenshots mit der Game DVR-Funktion.`nAber es kann Ihr Spiel verlangsamen Gaming-Leistung durch Videoaufzeichnung im Hintergrund."},
DisableGoogleUpdateTask: {Name: "Deaktivieren Sie GoogleUpdateTask"},
DisableHibernate: {Name: "Deaktivieren Sie den Ruhezustand"},
DisableHybridSleep: {Name: "Deaktivieren Sie den Hybridschlaf"},
DisableLockScreen: {Name: "Deaktivieren Sie den Sperrbildschirm"},
DisableLowDiskSpaceChecks: {Name: "Deaktivieren Sie die Prüfung auf geringen Speicherplatz",Desc: "Optimieren Sie das Festplatten-E/A-Subsystem, um die Systemleistung zu verbessern"},
Disablememorypagination: {Name: "Deaktivieren Sie die Speicherpaginierung",Desc: "Deaktivieren Sie die Speicherpaginierung und reduzieren Sie die Festplatten-E/A, um die Anwendungsleistung zu verbessern.`n(Option kann ignoriert werden, wenn der physische Speicher <1 GB ist)"},
DisableMenuShowDelay: {Name: "Deaktivieren Sie die Verzögerung bei der Menüanzeige",Desc: "Optimierte Reaktionsgeschwindigkeit der Systemanzeige"},
DisableMicrosoftEdgeUpdateTask: {Name: "Deaktivieren Sie MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Deaktivieren Sie Cloud Content Search MSA",Desc: "Deaktivieren Sie die Cloud-Inhaltssuche für das Microsoft-Konto"},
DisableMSDefender: {Name: "Deaktivieren Sie Microsoft Defender",Desc: "Aktivieren/deaktivieren Sie Microsoft Defender mit einem Klick.`nDer Computer wird automatisch neu gestartet."},
DisableOfferSuggestions: {Name: "Angebotsvorschläge deaktivieren"},
DisablePersonalizedAdsStoreApps: {Name: "Deaktivieren Sie PersonalizedAds StoreApps"},
DisablePrefetchParameters: {Name: "Prefetch-Parameter deaktivieren",Desc: "Deaktivieren Sie die Prefetch-Parameter, um die Lebensdauer der SSD zu verlängern"},
DisablePrintSpooler: {Name: "Deaktivieren Sie den Druckspooler"},
DisableRecentFiles: {Name: "Deaktivieren Sie „RecentFiles“."},
DisableRemoteRegAccess: {Name: "Deaktivieren Sie den Remote-Registrierungszugriff",Desc: "Deaktivieren Sie die Registrierungsänderung von einem Remotecomputer aus"},
DisableScheduledDefrag: {Name: "Deaktivieren Sie die geplante Defragmentierung"},
DisableSettingsAppSuggestions: {Name: "Deaktivieren Sie die App-Vorschläge für Einstellungen"},
DisableShortcutText: {Name: "Verknüpfungstext deaktivieren"},
DisableSleep: {Name: "Deaktivieren Sie den Ruhezustand"},
DisableStartMenuAppSuggestions: {Name: "Deaktivieren Sie die App-Vorschläge für das Startmenü"},
DisableSyncProviderNotifications: {Name: "Deaktivieren Sie die Benachrichtigungen des Synchronisierungsanbieters"},
DisableSystemRestore: {Name: "Deaktivieren Sie die Systemwiederherstellung"},
DisableTailoredExperiences: {Name: "Deaktivieren Sie maßgeschneiderte Erlebnisse"},
DisableTipsAndSuggestions: {Name: "Deaktivieren Sie Tipps und Vorschläge"},
DisableTurnOffDisplay: {Name: "Deaktivieren Sie „Anzeige ausschalten“."},
DisableVisualStudioTelemetry: {Name: "Deaktivieren Sie die VisualStudio-Telemetrie"},
DisableWCE: {Name: "Deaktivieren Sie die WCE-Verbesserung",Desc: "Deaktivieren Sie die Windows-Kundenerlebnisverbesserung.`n`n- Proxy: Diese Aufgabe sammelt und lädt Autochk-SQM-Daten hoch, wenn Sie sich für das Microsoft-Programm zur Verbesserung der Kundenzufriedenheit angemeldet haben.`n- Microsoft Compatibility Appraiser: Erfasst Programmtelemetrieinformationen, wenn haben sich für das Microsoft-Programm zur Verbesserung der Benutzerfreundlichkeit entschieden."},
DisableWebSearch: {Name: "Deaktivieren Sie die Websuche",Desc: "Deaktivieren Sie die Online-Suche und beziehen Sie Web-Ergebnisse von Bing nur für Ihr Konto ein, wenn Sie eine Suche in der Taskleiste durchführen"},
DisableWebSearchStartMenu: {Name: "Deaktivieren Sie das WebSearch-Startmenü",Desc: "Deaktiviert die Websuche im Startmenü"},
DisableWindowsFeedback: {Name: "Deaktivieren Sie Windows-Feedback"},
DisableWindowsSearch: {Name: "Deaktivieren Sie die Windows-Suche"},
EnableDarkMode: {Name: "Aktivieren Sie den Dunkelmodus"},
Explorer: {Name: "Dateimanager"},
HideMostUsedApps: {Name: "Blenden Sie die am häufigsten verwendeten Apps aus",Desc: "Deaktivieren Sie `"Am häufigsten verwendete Apps anzeigen`" im Startmenü"},
HideStartMenuAccountNotifications: {Name: "Kontobezogene Benachrichtigungen ausblenden",Desc: "Deaktivieren Sie `"Kontobezogene Benachrichtigungen anzeigen`" im Startmenü"},
HideStartMenuRecentlyAdded: {Name: "Kürzlich hinzugefügte Apps ausblenden",Desc: "Deaktivieren Sie `"Zuletzt hinzugefügte Apps anzeigen`" im Startmenü"},
HideStartMenuRecentlyOpened: {Name: "Kürzlich geöffnete Elemente ausblenden",Desc: "Deaktivieren Sie `"Zuletzt geöffnete Elemente in Start, Sprunglisten und Datei-Explorer anzeigen`" im Startmenü"},
HideStartMenuRecommendations: {Name: "Empfehlungen ausblenden",Desc: "Deaktivieren Sie `"Empfehlungen für Tipps, Verknüpfungen, neue Apps und mehr anzeigen`" im Startmenü"},
HideWindowsSecurityNoncriticalNotifications: {Name: "Nicht kritische WS-Benachrichtigungen ausblenden",Desc: "Nur kritische Benachrichtigungen von der Windows-Sicherheit anzeigen.`nWenn die GP-Einstellung „Alle Benachrichtigungen unterdrücken“ aktiviert wurde, hat diese Einstellung keine Auswirkung."},
HideWindowsSecurityNotifications: {Name: "WS-Benachrichtigungen ausblenden",Desc: "Alle Benachrichtigungen aus der Windows-Sicherheit ausblenden."},
HostsEdit_BtnImportFromFile: {Name: "Aus Dateien importieren"},
HostsEdit_BtnImportFromLink: {Desc: "Import von Link zu Hosts"},
HostsEdit_BtnReload: {Name: "Hosts-Datei neu laden"},
HostsEdit_BtnResetDefault: {Name: "Standard zurücksetzen"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Speichern als"},
HostsEdit_TxtSelectLink: {Name: "Wählen Sie den Link zum Importieren der Sperrliste in Hosts aus:"},
IncreaseIconCache: {Name: "Erhöhen Sie den Symbol-Cache",Desc: "Erhöhen Sie den Systemsymbol-Cache und beschleunigen Sie die Desktop-Anzeige"},
IoPageLockLimit: {Name: "Io-Seitensperrlimit",Desc: "Optimieren Sie die Standardeinstellungen des Speichers, um die Systemleistung zu verbessern"},
Link_ClearStartMenu: {Name: "Startmenü löschen"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Linkauflösung LinkInfo ignorieren",Desc: "Verfolgen Sie beim Roaming keine Shell-Verknüpfungen"},
MouseHoverTime: {Name: "Mausschwebezeit",Desc: "Beschleunigen Sie die Anzeigegeschwindigkeit der Vorschau des Taskleistenfensters"},
NoInternetOpenWith: {Name: "Kein Internet OpenWith",Desc: "Deaktivieren Sie den Internet File Association-Dienst"},
NoResolveSearch: {Name: "Keine Lösungssuche",Desc: "Verwenden Sie beim Auflösen von Shell-Verknüpfungen nicht die suchbasierte Methode"},
NoResolveTrack: {Name: "Keine Lösungsspur",Desc: "Verwenden Sie beim Auflösen von Shell-Verknüpfungen nicht die Tracking-basierte Methode.`nDiese Einstellung verhindert, dass das System NTFS-Tracking-Funktionen zum Auflösen einer Verknüpfung verwendet."},
NumLockonStartup: {Name: "Num Lock beim Start"},
OpenFileExplorerThisPC: {Name: "Öffnen Sie den Datei-Explorer ThisPC"},
OptimizeNetworkTransfer: {Name: "Optimieren Sie die Netzwerkübertragung",Desc: "Optimieren Sie die Netzwerkeinstellungen, um die Übertragungsleistung zu verbessern"},
Optimizeprocessorperformance: {Name: "Optimieren Sie die Prozessorleistung",Desc: "Optimieren Sie die Prozessorleistung, damit Anwendungen, Spiele usw. reibungsloser laufen."},
OptimizeRefreshPolicy: {Name: "Optimieren Sie die Aktualisierungsrichtlinie",Desc: "Optimieren Sie das Festplatten-E/A-Subsystem, um die Systemleistung zu verbessern"},
Optional: {Name: "Optional"},
PackageManager_BtnDisable: {Desc: "Für alle Benutzer aktivieren/deaktivieren"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Hebt die Bereitstellung eines App-Pakets auf, sodass bei neuen Benutzern auf dem Gerät die App nicht mehr automatisch installiert wird."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Liste der von allen Benutzern installierten Pakete anzeigen."},
PackageManager_Mode: {Desc: "Installierter Modus: Liste der installierten Pakete anzeigen.`nNicht installierter Modus: Liste anzeigen, die sich auf Ihrem Computer befindet, aber nicht vom aktuellen Benutzer installiert wurde."},
Privacy: {Name: "Privatsphäre"},
ShowExtensions: {Name: "Erweiterungen anzeigen"},
ShowHidden: {Name: "Verborgenes zeigen"},
ShowHiddenSystem: {Name: "Verstecktes System anzeigen"},
ShowThisPC: {Name: "Diesen PC anzeigen"},
ShutdownAcceleration: {Name: "Abschaltbeschleunigung",Desc: "Reduzieren Sie die Leerlaufzeit der Anwendung beim Herunterfahren, um den Herunterfahrvorgang zu verbessern"},
SnippingPrintScreen: {Name: "PrintScreen ausschneiden"},
StartMenu: {Name: "Startmenü"},
System: {Name: "System"},
Text_Architecture: "Die Architektur",
Text_BackgroundImage: "Hintergrundbild",
Text_Cancel: "Stornieren",
Text_CheckUpdate: "Aktualisierung überprüfen",
Text_ClearStartMenu_Confirm: "Sind Sie sicher, dass Sie das Startmenü-Layout löschen möchten?`n(Es wird eine Sicherungsdatei `"深度优化_StartMenuLayout_xxxx.json`" erstellt.)",
Text_ClearStartMenu_Done: "Startmenü löschen Fertig!",
Text_Close: "Schließen",
Text_CommandLine: "Befehlszeile",
Text_ConnectionFailed: "Die Verbindung zum Server ist fehlgeschlagen.",
Text_CurrentVersion: "Aktuelle Version",
Text_Custom: "Brauch",
Text_DefaultImage: "Standardbild",
Text_Delete: "Löschen",
Text_DeprovisionPackage: "Bereitstellungspaket aufheben",
Text_DeselectAll: "Alle abwählen",
Text_Details: "Einzelheiten",
Text_Disable: "Deaktivieren",
Text_Disabled: "Deaktiviert",
Text_DisableMSDefender0: "Um Microsoft Defender zu aktivieren, muss der Computer neu gestartet werden.`nSind Sie sicher, dass Sie dies durchführen möchten?",
Text_DisableMSDefender1: "Das Deaktivieren von Microsoft Defender erfordert einen Neustart des Computers.`nSind Sie sicher, dass Sie dies durchführen möchten?",
Text_DisplayName: "Anzeigename",
Text_EffectivePath: "Effektiver Weg",
Text_Enable: "Aktivieren",
Text_Enabled: "Ermöglicht",
Text_FamilyName: "Familienname",
Text_FindRegistry: "Suchen Sie in der Registrierung",
Text_FullName: "Vollständiger Name",
Text_Homepage: "Startseite",
Text_HR_Optimize: "------- Optimieren -------",
Text_HR_Tools: "-------- Werkzeuge --------",
Text_Install: "Installieren",
Text_InstalledAllUsers: "Alle Nutzer",
Text_InstalledDate: "Installationsdatum",
Text_InstalledMode: "Installierter Modus",
Text_InstalledPath: "Installierter Pfad",
Text_Name: "Name",
Text_NewestVersion: "Neueste Version",
Text_No: "NEIN",
Text_None: "Keiner",
Text_NotInstalledMode: "Nicht installierter Modus",
Text_NoUpdate: "Es ist kein Update verfügbar. Sie verwenden die neueste Version.",
Text_OK: "OK",
Text_OpenTarget: "Zielort",
Text_Properties: "Eigenschaften",
Text_PublisherDisplayName: "Herausgeber",
Text_Save: "Speichern",
Text_SearchOnline: "Online suchen",
Text_SelectAll: "Wählen Sie Alle",
Text_SignatureKind: "Signaturart",
Text_Status: "Status",
Text_Target: "Ziel",
Text_Type: "Typ",
Text_Uninstall: "Deinstallieren",
Text_Update: "Aktualisieren",
Text_UpdateFailed: "Das Update ist fehlgeschlagen. Bitte versuchen Sie es später noch einmal.",
Text_Updating: "Aktualisierung",
Text_Version: "Ausführung",
Text_WaitDlg: "Bitte warten...",
Text_WhatsNew: "Was ist neu",
Text_Yes: "Ja",
UninstallOneDrive: {Name: "Deinstallieren Sie OneDrive"},
UnpinChat: {Name: "Plaudern"},
UnpinCopilot: {Name: "Kopilot"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Rand"},
UnpinFileExplorer: {Name: "Dateimanager"},
UnpinMail: {Name: "Post"},
UnpinNewsandInterests: {Name: "Neuigkeiten und Interessen"},
UnpinSearch: {Name: "Suchen"},
UnpinStore: {Name: "Speichern"},
UnpinTaskbar: {Name: "Taskleiste"},
UnpinTaskView: {Name: "TaskView"},
UnpinWidgets: {Name: "Widgets"},
VerCtrl: {Desc: "Klicken Sie hier, um nach Updates zu suchen",Desc1: "Es gibt eine neue Version`n(Klicken Sie, um Details anzuzeigen)"}
},
en: {
Name: "English",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAHYcAAB2HAGnwnjqAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSwgMjAyMy8wNi8yNS0yMDowMTo1NSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wMS0yNVQwOToyMToyMiswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDEtMjVUMTA6NTg6MjkrMDc6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDEtMjVUMTA6NTg6MjkrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmU3YWFmNDRiLTcyNGUtMGI0Yy04MDExLTE1NDZlMzgyNDI2ZSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDplN2FhZjQ0Yi03MjRlLTBiNGMtODAxMS0xNTQ2ZTM4MjQyNmUiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplN2FhZjQ0Yi03MjRlLTBiNGMtODAxMS0xNTQ2ZTM4MjQyNmUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmU3YWFmNDRiLTcyNGUtMGI0Yy04MDExLTE1NDZlMzgyNDI2ZSIgc3RFdnQ6d2hlbj0iMjAyNC0wMS0yNVQwOToyMToyMiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Ph33cm0AAAO8SURBVDjLhZRdiJRVHMZ/553ZxZ3VtFK60SAW1NmPmXX3YkOjLWzWNhW9qQuRSiGL1CCiIsOLIkq0qNw1hEW8SUwv/IDSdCmIUsjPVCo1pWz2Q9Kd3XZmnY/3PefpYnZnxr58OA/8zzkPz/mfl+c9SGKCu49ehllboOFDGlbvQVKHWudtFPQIetTavFHSosZn90LTVnhwP/ve3408EEWGqYAmVo2Z72FeA5YgFyoLALDG8DnGbEYcl7gNXuUkmwvgxkg3k8wxD28ZEJrwUdkxZIy3jCp7jNTN7mzN1H83FLAkMfvw4udb13JhkEy2UNooGY53M5bJwpURln7w5NpFk28cwlVec/Fj6KE27Pr13RrHho++sdM6d7icldTSLAuyILU0K2elaWuOuDd7//DV9bYEsqtWd2nLe+jjzXDuqRfof/HlJoGCe6dLZ09bSbrY/6cd9iUXj5UMXTyuVCBdPvVjoPa4FQSFPXudJA1IsXMS1G04Sdsnvx49+VtKbtEjzo9GXf7E91aSAkl+U5N8KHLePPmS1LlQwZy5Nnfzph9IOnU1pbZnPuutW7oDrJRI+06DknITzGRKtR+LlQ1jsdJ6tkI/mHdKS3JSImxamtsnG6gNHIHxIBwG5yAIwBiUTEJtbfGDJ5N48ThUVYG1RQ1wX8jDhAwYrz3snz03k/9DJAKh8Sjm83D+/D8kfjkpM8PiDqhMru6oJuw1x/o8CedEYMcDFQ4Xu/J9TDIJ/ngP1dWorq5oHAqNawLCOLyQB57XR1ZKpApW10ZzSksa/RvHGhs1BkU2Npb3hoZK9TVJqWxOo3IJr2FpT2/Hql29A33DVAPu+nVr5sxxUzraMYAzpvSnOGvxgCmAu3TJmdmzVZN4WANX+uncPtjbsv6nXr4dERelWCBp6NNdLgeB5je4H747EyRvFZSJRjUKGgVlolElMzmd+WXAStLYqZN2ZOrdEujCitVNXz++ArTpLfKb3mFo5cougbT5Db164GoQefqAG8kHutUQ1QhoBIp1IVDk0S73yrtflMI//Nya7ly8ATu/FRxl9m/deiix65qoeV0zl2yXLyldP1cpUAqUrp8rX9Ks5T2Cl7Rw1U71DacPu4o31TOAAYyBfekZT/Ru2L+NByLURKooYHHOlQ91jgKWSdUG6qfz1c7T2/Z/+XOn+a/3sDabhhnT15H3FlgbHHQ465zKhnI4OWudDmJZwD13rauNVN2ew8qJMYARWO+4LMsNXodFbQ7uB7BOv1fBCYx3BExxmNuD/RcidbCGL60y7QAAAABJRU5ErkJggg==",
AUOptions: {Name: "AUOptions",Desc: "Set Notify before download Windows Updates"},
AutoEndTasks: {Name: "Auto End Tasks",Desc: "Close frozen processes to avoid system crash"},
BtnHostsEdit: {Name: "Hosts Edit"},
BtnPackageManager: {Name: "UWP Apps"},
BtnRestartExplorer: {Name: "Restart Explorer"},
BtnStartupManager: {Name: "Startup Manager"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Language"},
BtnSys_LoadOptimizeConfig: {Desc: "Load optimization configurations file"},
BtnSys_Minimize: {Desc: "Minimize"},
BtnSys_ReloadTab: {Desc: "Reload this tab"},
BtnSys_SaveImage: {Desc: "Self-Capture and Save to Image"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Save all optimization configurations to file"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Save this tab only optimization configuration to file"},
BtnSys_Search: {Desc: "Search for Optimize"},
BtnSys_Setting: {Desc: "Setting"},
BtnSys_Theme: {Desc: "Theme"},
ClassicContextMenu: {Name: "Classic Context Menu"},
DiagnosticDataOff: {Name: "Diagnostic Data Off"},
DisableAADCloudSearch: {Name: "Turn off Cloud Content Search AAD",Desc: "Turn off Cloud Content Search for Work or School Account"},
DisableAdsOnLockScreen: {Name: "Disable Ads On Lock Screen"},
DisableAeDebug: {Name: "Disable AeDebug",Desc: "Disable the debugger to speed up error processing"},
DisableAnimationEffectMaxMin: {Name: "Disable Animation Effect Max Min",Desc: "Close animation effect when maximizing or minimizing a window to speed up the window response"},
DisableAppendCompletion: {Name: "Disable Append Completion",Desc: "Disable inline Auto-Complete (Append completion or Auto-fill)"},
DisableAutoDefragIdle: {Name: "Disable Auto Defrag Idle",Desc: "Disable auto defrag when idle to increase working life of SSD"},
DisableAutoInstallationApps: {Name: "Disable Auto Installation Apps"},
DisableAutoplay: {Name: "Disable Autoplay",Desc: "Disable the “Autoplay” feature on drives to avoid virus infection"},
DisableAutoSuggest: {Name: "Disable Auto-Suggest",Desc: "Disable Auto-Suggest (Auto-complete drop-down)"},
DisableAutoWindowsUpdates: {Name: "Disable Auto Windows Updates",Desc: "Disable Automatic Updates"},
DisableBackgroundApps: {Name: "Disable Background Apps"},
DisableBootOptimize: {Name: "Disable Boot Optimize",Desc: "Disable defrag system drive on boot to increase working life of SSD"},
DisableCrashAutoReboot: {Name: "Disable Crash Auto Reboot",Desc: "Disable automatical reboot when system encounters blue screen of death"},
DisableCustomInking: {Name: "Disable Custom Inking",Desc: "Disable Custom Inking and Typing Dictionary"},
DisableDeviceSearchHistory: {Name: "Turn off Search history locally",Desc: "Turn off Search history locally on this devices"},
DisableDiagTrack: {Name: "Disable DiagTrack",Desc: "DiagTrack - The Connected User Experiences and Telemetry service enables features that support in-application and connected user experiences.`nAdditionally, this service manages the event driven collection and transmission of diagnostic and usage information (used to improve the experience and quality of the Windows Platform) when the diagnostics and usage privacy option settings are enabled under Feedback and Diagnostics."},
DisabledVBSCodeIntegrity: {Name: "Disabled VBS Code Integrity",Desc: "Disable virtualization-based protection of code integrity"},
DisableErrorReporting: {Name: "Disable Error Reporting",Desc: "Disable screen error reporting to improve system performance"},
DisableFrequentFolders: {Name: "Disable FrequentFolders"},
DisableGameBar: {Name: "Disable Game Bar & Game DVR",Desc: "The Game DVR feature allows you to record your gameplay in the background.`nIt is located on the Game Bar – which offers buttons to record gameplay & take screenshots using the Game DVR feature.`nBut it can slow your gaming performance by recording video in the background."},
DisableGoogleUpdateTask: {Name: "Disable GoogleUpdateTask"},
DisableHibernate: {Name: "Disable Hibernate"},
DisableHybridSleep: {Name: "Disable Hybrid Sleep"},
DisableLockScreen: {Name: "Disable Lock Screen"},
DisableLowDiskSpaceChecks: {Name: "Disable Low Disk Space Checks",Desc: "Optimize disk I/O subsystem to improve system performance"},
Disablememorypagination: {Name: "Disable memory pagination",Desc: "Disable memory pagination and reduce disk I/O to improve application performance.`n(Option may be ignored if physical memory is <1 GB)"},
DisableMenuShowDelay: {Name: "Disable Menu Show Delay",Desc: "Optimized response speed of system display"},
DisableMicrosoftEdgeUpdateTask: {Name: "Disable MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Turn off Cloud Content Search MSA",Desc: "Turn off Cloud Content Search for Microsoft Account"},
DisableMSDefender: {Name: "Disable Microsoft Defender",Desc: "Enable/Disable Microsoft Defender with 1-click.`nIt will automatically restart the computer."},
DisableOfferSuggestions: {Name: "Disable Offer Suggestions"},
DisablePersonalizedAdsStoreApps: {Name: "Disable PersonalizedAds StoreApps"},
DisablePrefetchParameters: {Name: "Disable Prefetch Parameters",Desc: "Disable prefetch parameters to increase SSD working life"},
DisablePrintSpooler: {Name: "Disable Print Spooler"},
DisableRecentFiles: {Name: "Disable RecentFiles"},
DisableRemoteRegAccess: {Name: "Disable Remote Reg Access",Desc: "Disable registry modification from a remote computer"},
DisableScheduledDefrag: {Name: "Disable Scheduled Defrag"},
DisableSettingsAppSuggestions: {Name: "Disable Settings App Suggestions"},
DisableShortcutText: {Name: "Disable Shortcut Text"},
DisableSleep: {Name: "Disable Sleep"},
DisableStartMenuAppSuggestions: {Name: "Disable Start Menu App Suggestions"},
DisableSyncProviderNotifications: {Name: "Disable Sync Provider Notifications"},
DisableSystemRestore: {Name: "Disable System Restore"},
DisableTailoredExperiences: {Name: "Disable Tailored Experiences"},
DisableTipsAndSuggestions: {Name: "Disable Tips And Suggestions"},
DisableTurnOffDisplay: {Name: "Disable Turn Off Display"},
DisableVisualStudioTelemetry: {Name: "Disable VisualStudio Telemetry"},
DisableWCE: {Name: "Disable WCE Improvement",Desc: "Disable Windows Customer Experience Improvement`n`n- Proxy: This task collects and uploads autochk SQM data if opted-in to the Microsoft Customer Experience Improvement Program.`n- Microsoft Compatibility Appraiser: Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program."},
DisableWebSearch: {Name: "Disable Web Search",Desc: "Disable search online and include web results from Bing for only your account when you do a search on the taskbar"},
DisableWebSearchStartMenu: {Name: "Disable WebSearch Start Menu",Desc: "Disables Web Search in Start Menu"},
DisableWindowsFeedback: {Name: "Disable Windows Feedback"},
DisableWindowsSearch: {Name: "Disable Windows Search"},
EnableDarkMode: {Name: "Enable Dark Mode"},
Explorer: {Name: "File Explorer"},
HideMostUsedApps: {Name: "Hide most used apps",Desc: "Turn off `"Show most used apps`" on Start menu"},
HideStartMenuAccountNotifications: {Name: "Hide account-related notifications",Desc: "Turn off `"Show account-related notifications`" on Start menu"},
HideStartMenuRecentlyAdded: {Name: "Hide recently added apps",Desc: "Turn off `"Show recently added apps`" on Start menu"},
HideStartMenuRecentlyOpened: {Name: "Hide recently opened items",Desc: "Turn off `"Show recently opened items in Start, Jump Lists, and File Explorer`" on Start menu"},
HideStartMenuRecommendations: {Name: "Hide recommendations",Desc: "Turn off `"Show recommendations for tips, shortcuts, new apps, and more`" on Start menu"},
HideWindowsSecurityNoncriticalNotifications: {Name: "Hide WS Non-critical Notifications",Desc: "Only show critical notifications from Windows Security.`nIf the Suppress all notifications GP setting has been enabled, this setting will have no effect."},
HideWindowsSecurityNotifications: {Name: "Hide WS Notifications",Desc: "Hide all notifications from Windows Security."},
HostsEdit_BtnImportFromFile: {Name: "Import from files"},
HostsEdit_BtnImportFromLink: {Desc: "Import from link to hosts"},
HostsEdit_BtnReload: {Name: "Reload hosts file"},
HostsEdit_BtnResetDefault: {Name: "Reset Default"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Save As"},
HostsEdit_TxtSelectLink: {Name: "Select link for import block list to hosts:"},
IncreaseIconCache: {Name: "Increase Icon Cache",Desc: "Increase system icon cache and speed up desktop display"},
IoPageLockLimit: {Name: "Io Page Lock Limit",Desc: "Optimize the defauit settings of memory to improve system performance"},
Link_ClearStartMenu: {Name: "Clear StartMenu"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Link Resolve Ignore LinkInfo",Desc: "Do not track Shell shortcuts during roaming"},
MouseHoverTime: {Name: "Mouse Hover Time",Desc: "Speed up display speed of Taskbar Window Previews"},
NoInternetOpenWith: {Name: "No Internet OpenWith",Desc: "Turn off Internet File Association service"},
NoResolveSearch: {Name: "No Resolve Search",Desc: "Do not use the search-based method when resolving shell shortcuts"},
NoResolveTrack: {Name: "No Resolve Track",Desc: "Do not use the tracking-based method when resolving shell shortcuts.`nThis setting prevents the system from using NTFS tracking features to resolve a shortcut."},
NumLockonStartup: {Name: "Num Lock on Startup"},
OpenFileExplorerThisPC: {Name: "Open File Explorer ThisPC"},
OptimizeNetworkTransfer: {Name: "Optimize Network Transfer",Desc: "Optimize network settings to improve transfer performance"},
Optimizeprocessorperformance: {Name: "Optimize processor performance",Desc: "Optimize processor performance to make applications, games, etc. run more smoothly."},
OptimizeRefreshPolicy: {Name: "Optimize Refresh Policy",Desc: "Optimize disk I/O subsystem to improve system performance"},
Optional: {Name: "Optional"},
PackageManager_BtnDisable: {Desc: "Enable/Disable for all users"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Deprovisions an app Package so new users on the device will no longer have the app automatically installed."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Show list of installed packages by all users."},
PackageManager_Mode: {Desc: "Installed Mode: Show list of installed packages.`nNot Installed Mode: Show list that is on your computer but not installed by the current user."},
Privacy: {Name: "Privacy"},
ShowExtensions: {Name: "Show Extensions"},
ShowHidden: {Name: "Show Hidden"},
ShowHiddenSystem: {Name: "Show Hidden System"},
ShowThisPC: {Name: "Show ThisPC"},
ShutdownAcceleration: {Name: "Shutdown Acceleration",Desc: "Reduce application idleness at shutdown to improve the shutdown process"},
SnippingPrintScreen: {Name: "Snipping PrintScreen"},
StartMenu: {Name: "StartMenu"},
System: {Name: "System"},
Text_Architecture: "Architecture",
Text_BackgroundImage: "Background image",
Text_Cancel: "Cancel",
Text_CheckUpdate: "Check Update",
Text_ClearStartMenu_Confirm: "Are you sure you want to clear the Start menu layout?`n(A backup file `"深度优化_StartMenuLayout_xxxx.json`" will be created)",
Text_ClearStartMenu_Done: "Clear StartMenu Done!",
Text_Close: "Close",
Text_CommandLine: "Command line",
Text_ConnectionFailed: "Connection to the server failed.",
Text_CurrentVersion: "Current version",
Text_Custom: "Custom",
Text_DefaultImage: "Default image",
Text_Delete: "Delete",
Text_DeprovisionPackage: "Deprovision Package",
Text_DeselectAll: "Deselect All",
Text_Details: "Details",
Text_Disable: "Disable",
Text_Disabled: "Disabled",
Text_DisableMSDefender0: "Enabling Microsoft Defender requires restarting the computer.`nAre you sure you want to perform this?",
Text_DisableMSDefender1: "Disabling Microsoft Defender requires restarting the computer.`nAre you sure you want to perform this?",
Text_DisplayName: "Display name",
Text_EffectivePath: "Effective path",
Text_Enable: "Enable",
Text_Enabled: "Enabled",
Text_FamilyName: "Family name",
Text_FindRegistry: "Find in Registry",
Text_FullName: "Full name",
Text_Homepage: "Homepage",
Text_HR_Optimize: "------- Optimize -------",
Text_HR_Tools: "-------- Tools --------",
Text_Install: "Install",
Text_InstalledAllUsers: "All Users",
Text_InstalledDate: "Installed date",
Text_InstalledMode: "Installed Mode",
Text_InstalledPath: "Installed path",
Text_Name: "Name",
Text_NewestVersion: "Newest version",
Text_No: "No",
Text_None: "None",
Text_NotInstalledMode: "Not Installed Mode",
Text_NoUpdate: "No update is available. You are using the latest version.",
Text_OK: "OK",
Text_OpenTarget: "Target location",
Text_Properties: "Properties",
Text_PublisherDisplayName: "Publisher",
Text_Save: "Save",
Text_SearchOnline: "Search online",
Text_SelectAll: "Select All",
Text_SignatureKind: "Signature kind",
Text_Status: "Status",
Text_Target: "Target",
Text_Type: "Type",
Text_Uninstall: "Uninstall",
Text_Update: "Update",
Text_UpdateFailed: "Update failed please try again later.",
Text_Updating: "Updating",
Text_Version: "Version",
Text_WaitDlg: "Please wait...",
Text_WhatsNew: "What’s new",
Text_Yes: "Yes",
UninstallOneDrive: {Name: "Uninstall OneDrive"},
UnpinChat: {Name: "Chat"},
UnpinCopilot: {Name: "Copilot"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Edge"},
UnpinFileExplorer: {Name: "File Explorer"},
UnpinMail: {Name: "Mail"},
UnpinNewsandInterests: {Name: "News and Interests"},
UnpinSearch: {Name: "Search"},
UnpinStore: {Name: "Store"},
UnpinTaskbar: {Name: "Taskbar"},
UnpinTaskView: {Name: "TaskView"},
UnpinWidgets: {Name: "Widgets"},
VerCtrl: {Desc: "Click to check for update",Desc1: "There's a new version`n(Click to view details)"}
},
es: {
Name: "Español",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6NTY6MzIrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjMzKzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjMzKzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDozOTAzODJiOC00NTg5LTc2NDItYTY3OC04YTMwZTYyNWM5NDUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MzkwMzgyYjgtNDU4OS03NjQyLWE2NzgtOGEzMGU2MjVjOTQ1IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6MzkwMzgyYjgtNDU4OS03NjQyLWE2NzgtOGEzMGU2MjVjOTQ1Ij4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDozOTAzODJiOC00NTg5LTc2NDItYTY3OC04YTMwZTYyNWM5NDUiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6NTY6MzIrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+re9cuAAAA2JJREFUOBF1wd9r1WUcwPH353me7/ecnf06KZo0mmEqSVB0EVZCiWxOULDrgq68yB8XgeBFf0CQIYL4oz8guqwbLxwKWdEujMgmVmqYaStlY3PudM75nu/zfD5NxNrm9noF438/D6ynzKvkInRMcE52JpGtIgzyyG0xLpWpHM0wzOd0FS0237nJY4Gl1LDg3jDnjqiwR8CzgAnJhXCWlI4KjLFEYAFvSrNSOQl2kHlmxjK8E7fXgttbOneq1tJDLBDaCGAYGW3rPqeFH4kpggEiLMsAAfXuYFurG28TdpVEHBBubVnPQx2pnNasOlKNHQzBO0MNDGElmXXQUBn5vb7hdGnFAQHCprNgai/ForFf4izOCb6qtGNOcAmflBQBYVlm4FzYn/XJp3jGg++eIxVyzAeHGGiXopb460aN+upIfV2JNDzCysxKInrMOxsO7cl8WJwOiYNsjXHvfIWbH/WTvTDD5LXIU694Nh81dNYToyGswNxQEhkOhm4XcaRU0Jyepn/gWXreesCcz0ivr6W+SUizv1C0SrLsGcxKViJi2wNiA5QFZXede73bqH32A7NXZ1g1uJueXcdpV7/nVvMMPrTZkP1Iq10DYVkWGQhmIP0l7fF+WjfeJI1dRoZb/Hq9w/MTjtqW52h+/SJ5SpRD32G+BsqKQkpMZJnQmSqwqT8Iw036v6lzfGorO9on2N36DROjeaeLpAHzhilPEAGFiWDKxTjHh2EN9G7sQ6cK7l7O+cB9jF5rcPe6su6Td7HBOs4SMYEZTzJQtYsh79PzwccLMwPZ0BdXK7y3ukr304Ju2wdfXWf9xlG+bSqTUXh/TUZnThFhETNwXi6EzM6Hxn1DqB1em+7+tG/wBF29Su2dXhr534SXp+mu5exI59DCc/9OD2AsYiAhEL0eVoNwZa+hMO7zypm82r/fSsNnJV6/xEIXt9JaJCriDFUHwn/EgBBotJtnHpSNcQ+EVyemMcC4f+DKqsENrbwyEiLz1gHCI47FDBCi93R1itHXZv48YCgOCD08lqjS2NXM/EkyO8hDpgiLGfNEAEOQU5Xin0N9KI8FFlDnCLFzKCCfFyJHnMgeBc9iyUzP5pqOesvG1DkWCiwlgkQdw8nbTtgZka2IDDLP4LY3u6SWRjHDnLDUv2wlml8JdIuBAAAAAElFTkSuQmCC",
AUOptions: {Name: "Opción UA",Desc: "Configure notificaciones antes de descargar actualizaciones de Windows"},
AutoEndTasks: {Name: "Completar tareas automáticamente",Desc: "Cierre los procesos bloqueados para evitar fallas del sistema."},
BtnHostsEdit: {Name: "Cambiar anfitrión"},
BtnPackageManager: {Name: "aplicación para UWP"},
BtnRestartExplorer: {Name: "Reinicie el Explorador de Windows."},
BtnStartupManager: {Name: "responsable de la inicialización"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Idioma"},
BtnSys_LoadOptimizeConfig: {Desc: "Descargue el archivo de configuración de optimización"},
BtnSys_Minimize: {Desc: "minimización"},
BtnSys_ReloadTab: {Desc: "Vuelva a cargar esta pestaña."},
BtnSys_SaveImage: {Desc: "Captura y guarda automáticamente en la imagen"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Guarde todas las configuraciones de optimización en archivos"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Esta pestaña guarda solo la configuración de optimización en un archivo."},
BtnSys_Search: {Desc: "Buscar optimización"},
BtnSys_Setting: {Desc: "sistema"},
BtnSys_Theme: {Desc: "sujeto"},
ClassicContextMenu: {Name: "Menú contextual clásico"},
DiagnosticDataOff: {Name: "Los datos de diagnóstico están deshabilitados."},
DisableAADCloudSearch: {Name: "Deshabilitar la búsqueda de contenido en la nube de AAD",Desc: "Desactive la detección de contenido en la nube para su cuenta profesional o educativa."},
DisableAdsOnLockScreen: {Name: "Desactivar anuncios en la pantalla de bloqueo"},
DisableAeDebug: {Name: "Deshabilitar AEDebug",Desc: "Acelere el manejo de errores desactivando el depurador."},
DisableAnimationEffectMaxMin: {Name: "Deshabilitar efectos de animación mínimos máximos",Desc: "Acelera la capacidad de respuesta de la ventana al suprimir los efectos de animación cuando la ventana está maximizada o minimizada."},
DisableAppendCompletion: {Name: "Deshabilite complementos adicionales.",Desc: "Deshabilitar el autocompletar integrado (agregar relleno o autocompletar)"},
DisableAutoDefragIdle: {Name: "Deshabilitar la desfragmentación automática durante el tiempo de inactividad",Desc: "Amplíe la vida útil de su SSD desactivando la desfragmentación automática durante los períodos de inactividad."},
DisableAutoInstallationApps: {Name: "Deshabilitar la instalación automática de aplicaciones"},
DisableAutoplay: {Name: "Desactivar ejecución automática",Desc: "Para evitar una infección de virus, desactive la función `"autorun`" en el disco."},
DisableAutoSuggest: {Name: "Desactivar sugerencias automáticas",Desc: "Desactivar sugerencia automática (menú desplegable de autocompletar)"},
DisableAutoWindowsUpdates: {Name: "Deshabilitar las actualizaciones automáticas de Windows",Desc: "Desactivar actualizaciones automáticas"},
DisableBackgroundApps: {Name: "Deshabilitar aplicaciones que se ejecutan en segundo plano"},
DisableBootOptimize: {Name: "Deshabilitar la optimización de lanzamiento",Desc: "Para extender la vida útil de su SSD, desactive las unidades de desfragmentación del sistema en el momento del arranque."},
DisableCrashAutoReboot: {Name: "Deshabilitar el reinicio automático en caso de falla",Desc: "Desactive el reinicio automático cuando el sistema detecte una pantalla azul."},
DisableCustomInking: {Name: "Deshabilitar el dibujo a mano alzada personalizado",Desc: "Deshabilitar diccionarios de escritura y entrada personalizados"},
DisableDeviceSearchHistory: {Name: "Deshabilitar el historial de búsqueda local",Desc: "Deshabilitar el historial de navegación local en estos dispositivos"},
DisableDiagTrack: {Name: "Desactivar DiagTrack",Desc: "DiagTrack: el servicio de telemetría y experiencia de usuario conectado proporciona conectividad al usuario dentro de la aplicación. `n Este servicio también gestiona la recopilación y transmisión de diagnósticos de eventos e información de uso (utilizada para mejorar la comodidad y la calidad). (En plataformas Windows) La opción Configuración de privacidad de uso y diagnóstico está disponible en Comentarios y diagnóstico."},
DisabledVBSCodeIntegrity: {Name: "La integridad del código VBS está deshabilitada.",Desc: "Deshabilitar la protección de integridad del código basada en virtualización"},
DisableErrorReporting: {Name: "Deshabilitar el informe de errores",Desc: "Desactive los informes de errores en pantalla para mejorar el rendimiento del sistema."},
DisableFrequentFolders: {Name: "Deshabilitar carpetas de uso frecuente"},
DisableGameBar: {Name: "Desactive la barra de juegos y la grabadora de juegos.",Desc: "La función Game DVR te permite grabar juegos en segundo plano. `nEsta función está ubicada en la barra de juegos y muestra botones que te permiten grabar juegos y tomar capturas de pantalla usando Game DVR. `n Sin embargo, esto puede ralentizar el proceso. Mejora el rendimiento de tu juego grabando vídeos en segundo plano."},
DisableGoogleUpdateTask: {Name: "Deshabilitar la tarea GoogleUpdate"},
DisableHibernate: {Name: "Desactivar el modo de suspensión"},
DisableHybridSleep: {Name: "Sin suspensión híbrida."},
DisableLockScreen: {Name: "Desactivar la pantalla de bloqueo"},
DisableLowDiskSpaceChecks: {Name: "Deshabilitar la verificación de poco espacio en disco",Desc: "Mejore el rendimiento del sistema optimizando la E/S del disco."},
Disablememorypagination: {Name: "Deshabilitar el intercambio de memoria",Desc: "Deshabilite la paginación de memoria para reducir la E/S del disco y mejorar el rendimiento de la aplicación. `n (se puede ignorar si la memoria física es inferior a 1 GB)"},
DisableMenuShowDelay: {Name: "Deshabilitar la visualización del menú diferido",Desc: "Optimice el tiempo de respuesta de la pantalla de su sistema"},
DisableMicrosoftEdgeUpdateTask: {Name: "Deshabilitar MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Deshabilitar la búsqueda de contenido en la nube de MSA",Desc: "Desactive la detección de contenido en la nube para su cuenta de Microsoft."},
DisableMSDefender: {Name: "Deshabilitar Microsoft Defender",Desc: "1 Toque para activar o desactivar Microsoft Defender. `nSu computadora se reiniciará automáticamente."},
DisableOfferSuggestions: {Name: "Desactivar ofertas de cupones"},
DisablePersonalizedAdsStoreApps: {Name: "Optar por no participar en aplicaciones de tienda de anuncios personalizadas"},
DisablePrefetchParameters: {Name: "No utilices opciones de precarga",Desc: "Amplíe la vida útil de su SSD desactivando las opciones de prearranque."},
DisablePrintSpooler: {Name: "Deshabilitar la cola de impresión"},
DisableRecentFiles: {Name: "Deshabilitar archivos usados ​​recientemente"},
DisableRemoteRegAccess: {Name: "Deshabilitar el acceso remoto al registro",Desc: "Deshabilite la edición del registro en computadoras remotas"},
DisableScheduledDefrag: {Name: "Deshabilitar la desfragmentación programada"},
DisableSettingsAppSuggestions: {Name: "Deshabilitar sugerencias de aplicaciones en la configuración"},
DisableShortcutText: {Name: "Deshabilitar el texto de la etiqueta"},
DisableSleep: {Name: "apagar el sueño"},
DisableStartMenuAppSuggestions: {Name: "Deshabilitar sugerencias de aplicaciones en el menú Inicio"},
DisableSyncProviderNotifications: {Name: "Deshabilitar las notificaciones del proveedor de sincronización"},
DisableSystemRestore: {Name: "Deshabilitar la restauración del sistema"},
DisableTailoredExperiences: {Name: "Desactivar experiencias personalizadas"},
DisableTipsAndSuggestions: {Name: "Consejos y trucos para darse de baja"},
DisableTurnOffDisplay: {Name: "Apagar Apagar pantalla"},
DisableVisualStudioTelemetry: {Name: "Deshabilitar la telemetría de VisualStudio"},
DisableWCE: {Name: "Deshabilitar extensiones WCE",Desc: "Deshabilitar la mejora de la experiencia del cliente de Windows`n`n - Proxy: esta tarea verifica automáticamente si ha sido seleccionado para participar en el Programa de mejora de la experiencia del cliente de Microsoft para recopilar y descargar datos de SQM. `n - Evaluador de compatibilidad de Microsoft: recopila información sobre programas. Telemetría si elige unirse al Programa de mejora de la experiencia del cliente de Microsoft."},
DisableWebSearch: {Name: "Desactivar la navegación web",Desc: "Desactive la búsqueda en línea e incluya solo los resultados web de Bing de su cuenta cuando realice búsquedas en su barra de tareas."},
DisableWebSearchStartMenu: {Name: "Desactivar el menú principal de búsqueda web",Desc: "Deshabilitar la búsqueda en Internet desde el menú Inicio"},
DisableWindowsFeedback: {Name: "Deshabilitar comentarios de Windows"},
DisableWindowsSearch: {Name: "Deshabilitar la búsqueda de Windows"},
EnableDarkMode: {Name: "Usar modo oscuro"},
Explorer: {Name: "Explorador de archivos"},
HideMostUsedApps: {Name: "Ocultar aplicaciones de uso frecuente",Desc: "Desmarque la casilla de verificación `"Mostrar aplicaciones utilizadas frecuentemente`"] en el `"menú Inicio`"."},
HideStartMenuAccountNotifications: {Name: "Ocultar notificaciones de cuenta",Desc: "Desmarque `"Mostrar notificaciones de la cuenta {\}`" en el menú Inicio."},
HideStartMenuRecentlyAdded: {Name: "Ocultar aplicaciones agregadas recientemente",Desc: "En el menú Inicio, desmarque [`" Mostrar aplicaciones agregadas recientemente `"]."},
HideStartMenuRecentlyOpened: {Name: "Ocultar elementos abiertos recientemente",Desc: "En el menú Inicio, desmarque {\}Mostrar elementos abiertos recientemente en el menú Inicio, listas de salto y Explorador de archivos{\}."},
HideStartMenuRecommendations: {Name: "Ocultar consejos",Desc: "Desactiva {\} para ver sugerencias del menú Inicio como [{\} sugerencias, accesos directos, nuevas aplicaciones y más."},
HideWindowsSecurityNoncriticalNotifications: {Name: "Ocultar notificaciones WS innecesarias",Desc: "Seguridad de Windows muestra sólo notificaciones importantes. `nEsta configuración no tendrá ningún efecto si la configuración [Rechazar todas las notificaciones de GP] está habilitada."},
HideWindowsSecurityNotifications: {Name: "Ocultar notificaciones de WS",Desc: "Oculta todas las notificaciones de seguridad de Windows."},
HostsEdit_BtnImportFromFile: {Name: "Importar desde archivo"},
HostsEdit_BtnImportFromLink: {Desc: "Importar desde enlace de host"},
HostsEdit_BtnReload: {Name: "Vuelva a cargar el archivo de hosts."},
HostsEdit_BtnResetDefault: {Name: "Restaurar los valores predeterminados"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "guardar como"},
HostsEdit_TxtSelectLink: {Name: "Seleccione el enlace para importar la lista negra a su host."},
IncreaseIconCache: {Name: "Aumenta tu caché de iconos",Desc: "Aumenta el caché de los iconos del sistema y acelera la visualización del escritorio."},
IoPageLockLimit: {Name: "Limitar el bloqueo de páginas de E/S",Desc: "Mejore el rendimiento del sistema optimizando la configuración de memoria predeterminada."},
Link_ClearStartMenu: {Name: "Limpia tu menú Inicio"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Se corrigió un error por el cual el enlace ignoraba LinkInfo.",Desc: "No rastree las conexiones shell mientras esté en roaming"},
MouseHoverTime: {Name: "señalando el tiempo",Desc: "Acelera la visualización de vistas previas en las ventanas de la barra de tareas."},
NoInternetOpenWith: {Name: "sin internet",Desc: "Deshabilite el servicio de combinación de archivos de Internet"},
NoResolveSearch: {Name: "Tu búsqueda no fue resuelta.",Desc: "Evite el uso de métodos de búsqueda al resolver enlaces de shell."},
NoResolveTrack: {Name: "No hay señales de permiso",Desc: "Evite el uso de métodos de seguimiento al resolver referencias de shell. `n Esta configuración evita que el sistema reconozca enlaces mediante el espionaje NTFS."},
NumLockonStartup: {Name: "Bloquear número al iniciar"},
OpenFileExplorerThisPC: {Name: "Abra el Explorador de archivos en esta computadora"},
OptimizeNetworkTransfer: {Name: "Optimización de la transmisión de datos a través de la red.",Desc: "Mejore el rendimiento de la transmisión optimizando la configuración de la red."},
Optimizeprocessorperformance: {Name: "Optimización del rendimiento de la CPU",Desc: "Optimice el rendimiento de su procesador para ejecutar aplicaciones, juegos y más. Más tierna."},
OptimizeRefreshPolicy: {Name: "Optimización de la política de actualización",Desc: "Mejore el rendimiento del sistema optimizando la E/S del disco."},
Optional: {Name: "opción"},
PackageManager_BtnDisable: {Desc: "Activar/desactivar para todos los usuarios"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Si cancela el registro de un paquete de aplicación, no se instalará automáticamente para los nuevos usuarios en el dispositivo."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Enumera los paquetes instalados por todos los usuarios."},
PackageManager_Mode: {Desc: "Modo de instalación: lista de paquetes instalados. `nModo desinstalado: una lista de paquetes que existen en la computadora pero que no han sido instalados por el usuario actual."},
Privacy: {Name: "Confidencialidad"},
ShowExtensions: {Name: "Mostrar extensiones"},
ShowHidden: {Name: "Ocultar vista"},
ShowHiddenSystem: {Name: "Mostrar sistemas ocultos"},
ShowThisPC: {Name: "muéstrame esta computadora"},
ShutdownAcceleration: {Name: "Apagado más rápido",Desc: "Reduce el tiempo de inactividad de la aplicación después del cierre y acelera el proceso de apagado."},
SnippingPrintScreen: {Name: "imprimir captura de pantalla"},
StartMenu: {Name: "menu de inicio"},
System: {Name: "sistema"},
Text_Architecture: "Arquitectura",
Text_BackgroundImage: "Imagen de fondo",
Text_Cancel: "Cancelar",
Text_CheckUpdate: "Comprueba la actualización",
Text_ClearStartMenu_Confirm: "¿Está seguro de que desea borrar el diseño del menú Inicio?`n(Se creará un archivo de copia de seguridad `"WinTune_StartMenuLayout_xxxx.json`")",
Text_ClearStartMenu_Done: "Borrar menú Inicio ¡Listo!",
Text_Close: "Cerca",
Text_CommandLine: "Línea de comando",
Text_ConnectionFailed: "La conexión al servidor falló.",
Text_CurrentVersion: "Versión actual",
Text_Custom: "Costumbre",
Text_DefaultImage: "Imagen por defecto",
Text_Delete: "Borrar",
Text_DeprovisionPackage: "Paquete de baja de suministro",
Text_DeselectAll: "Deseleccionar todo",
Text_Details: "Detalles",
Text_Disable: "Desactivar",
Text_Disabled: "Desactivado",
Text_DisableMSDefender0: "Para habilitar Microsoft Defender es necesario reiniciar la computadora.`n¿Está seguro de que desea realizar esto?",
Text_DisableMSDefender1: "Para deshabilitar Microsoft Defender es necesario reiniciar la computadora.`n¿Está seguro de que desea realizar esto?",
Text_DisplayName: "Nombre para mostrar",
Text_EffectivePath: "Camino efectivo",
Text_Enable: "Permitir",
Text_Enabled: "Activado",
Text_FamilyName: "Apellido",
Text_FindRegistry: "Buscar en el Registro",
Text_FullName: "Nombre completo",
Text_Homepage: "Página principal",
Text_HR_Optimize: "------- Optimizar -------",
Text_HR_Tools: "-------- Herramientas --------",
Text_Install: "Instalar",
Text_InstalledAllUsers: "Todos los usuarios",
Text_InstalledDate: "Fecha de instalación",
Text_InstalledMode: "Modo instalado",
Text_InstalledPath: "Ruta instalada",
Text_Name: "Nombre",
Text_NewestVersion: "La versión más nueva",
Text_No: "No",
Text_None: "Ninguno",
Text_NotInstalledMode: "Modo no instalado",
Text_NoUpdate: "No hay ninguna actualización disponible. Estás utilizando la última versión.",
Text_OK: "DE ACUERDO",
Text_OpenTarget: "Ubicación del objetivo",
Text_Properties: "Propiedades",
Text_PublisherDisplayName: "Editor",
Text_Save: "Ahorrar",
Text_SearchOnline: "Buscar en línea",
Text_SelectAll: "Seleccionar todo",
Text_SignatureKind: "Tipo de firma",
Text_Status: "Estado",
Text_Target: "Objetivo",
Text_Type: "Tipo",
Text_Uninstall: "Desinstalar",
Text_Update: "Actualizar",
Text_UpdateFailed: "La actualización falló. Vuelve a intentarlo más tarde.",
Text_Updating: "Actualizando",
Text_Version: "Versión",
Text_WaitDlg: "Espere por favor...",
Text_WhatsNew: "Qué hay de nuevo",
Text_Yes: "Sí",
UninstallOneDrive: {Name: "Quitar OneDrive"},
UnpinChat: {Name: "hablar"},
UnpinCopilot: {Name: "segundo piloto"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "bocina"},
UnpinFileExplorer: {Name: "Explorador de archivos"},
UnpinMail: {Name: "publicar"},
UnpinNewsandInterests: {Name: "noticias e interés"},
UnpinSearch: {Name: "pruebas"},
UnpinStore: {Name: "comercio"},
UnpinTaskbar: {Name: "barra de tareas"},
UnpinTaskView: {Name: "Ver tareas"},
UnpinWidgets: {Name: "herramienta"},
VerCtrl: {Desc: "Haga clic para buscar actualizaciones.",Desc1: "Nueva versión disponible `n (haga clic para obtener más detalles)"}
},
fr: {
Name: "Français",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFzGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6MjI6NTQrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQwOjI4KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQwOjI4KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDphOGZkMzJmMS1hNTEyLTNkNDUtOGI4MS0zOWI0NzE5YTJmYzQiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDo0MmU5MzdjZC0yZmRjLTU3NDQtYWU4Zi01MzcwZmM3MjIyZjEiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmODk3NmMwMi04MzFlLWY3NDUtOTdiMy1kNjcxMDAwOTM4Y2QiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmY4OTc2YzAyLTgzMWUtZjc0NS05N2IzLWQ2NzEwMDA5MzhjZCIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0yOFQxMToyMjo1NCswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6YThmZDMyZjEtYTUxMi0zZDQ1LThiODEtMzliNDcxOWEyZmM0IiBzdEV2dDp3aGVuPSIyMDI0LTA3LTI4VDE0OjQwOjI4KzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMTEgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pgo5fN8AAAJwSURBVDiNfZQ7axVRFIW/c2YmuTc38UGKIIq/IJBeEQU1CWmS0lpsfBRCalOksEvno9BeS9OIMUjSJH1+gUK8ggix0TzuOWcvi7nvhwOLDYfZ3+y9FnM8iJbG7+1Qu78DK9vMPt9C0rxkz2KMb2KMb6L0LErzNjtbdkxOomq1iwCe/kdArmve8g/AR2AdeNDUOvDROfcBuDbQ2w/UWYG/8OcFk8d7xGwZyEBITZXfy+TcsmBP3r9A6gMWAYoGTP2lmD7+5PL0GInOiwPAbj1Wnn/qAWZP35E9fc/Eg8+viqmwoOMxcFC2AzicawpKSe2qPF/QxMQrsgyyDF8Zq1ItqnOFiocWPM53IFBOOjChc+2KGSqKh6pU5hgfx+vXFO731IZFj0hIHQgYmGEtlSeY1KktObdhkvNZHu/i0+3SN2j71/Swx/K+ALrP5dxt8/6Od163Bqx2zSo6644Opi2y7Ka3xOX+pvbKsuHA7tolM7vi23sN1Qjgf+RRqgshWVu0ancg3cEMCUUSCeregnaRGPrt/ulGTdg8Tyntert4vK3xky+YkPV6aMOAZgMeNqf9kkvbPtVniD+nV3GxXNlECz6wbkv9KwMuxlWlhA/fZ2j8uHQQGtXXVE6wVKZrGgHr9tKMBLgQXtNoHLgQ8Hy7Cl+vEj7feBSPaluMnfYC03+AgGLcqoXwqAJUAM/heTg8B/XzxKPaojl7iRlKreQHfaTpYZReEuOip7wHHX33ocsM4tgTGv66aGyaKZkZKSVSSq3p0pm0eQrXDZ7gXM9fOHhjA5jbl7eVlGwphLAm6S3wNoSwFkJYasBKgn03pPUfuS6qjESMFGAAAAAASUVORK5CYII=",
AUOptions: {Name: "AUOptions",Desc: "Définir Notify avant de télécharger les mises à jour Windows"},
AutoEndTasks: {Name: "Tâches de fin automatique",Desc: "Fermez les processus gelés pour éviter un crash du système"},
BtnHostsEdit: {Name: "Hôtes Modifier"},
BtnPackageManager: {Name: "Applications UWP"},
BtnRestartExplorer: {Name: "Redémarrer l'explorateur"},
BtnStartupManager: {Name: "Gestionnaire de démarrage"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Langue"},
BtnSys_LoadOptimizeConfig: {Desc: "Charger le fichier de configurations d'optimisation"},
BtnSys_Minimize: {Desc: "Minimiser"},
BtnSys_ReloadTab: {Desc: "Recharger cet onglet"},
BtnSys_SaveImage: {Desc: "Auto-Capturer et enregistrer dans l'image"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Enregistrez toutes les configurations d'optimisation dans un fichier"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Enregistrez cet onglet uniquement la configuration d'optimisation dans un fichier"},
BtnSys_Search: {Desc: "Recherche d'optimiser"},
BtnSys_Setting: {Desc: "Paramètre"},
BtnSys_Theme: {Desc: "Thème"},
ClassicContextMenu: {Name: "Menu contextuel classique"},
DiagnosticDataOff: {Name: "Données de diagnostic désactivées"},
DisableAADCloudSearch: {Name: "Désactiver la recherche de contenu cloud AAD",Desc: "Désactiver la recherche de contenu cloud pour un compte professionnel ou scolaire"},
DisableAdsOnLockScreen: {Name: "Désactiver les publicités sur l'écran de verrouillage"},
DisableAeDebug: {Name: "Désactiver AeDebug",Desc: "Désactivez le débogueur pour accélérer le traitement des erreurs"},
DisableAnimationEffectMaxMin: {Name: "Désactiver l'effet d'animation Max Min",Desc: "Fermer l'effet d'animation lors de la maximisation ou de la réduction d'une fenêtre pour accélérer la réponse de la fenêtre"},
DisableAppendCompletion: {Name: "Désactiver l'achèvement des ajouts",Desc: "Désactiver la saisie semi-automatique en ligne (achèvement des ajouts ou remplissage automatique)"},
DisableAutoDefragIdle: {Name: "Désactiver la défragmentation automatique au ralenti",Desc: "Désactivez la défragmentation automatique en cas d'inactivité pour augmenter la durée de vie du SSD"},
DisableAutoInstallationApps: {Name: "Désactiver les applications d'installation automatique"},
DisableAutoplay: {Name: "Désactiver la lecture automatique",Desc: "Désactivez la fonction « Lecture automatique » sur les lecteurs pour éviter toute infection virale"},
DisableAutoSuggest: {Name: "Désactiver la suggestion automatique",Desc: "Désactiver la suggestion automatique (liste déroulante de saisie semi-automatique)"},
DisableAutoWindowsUpdates: {Name: "Désactiver les mises à jour automatiques de Windows",Desc: "Désactiver les mises à jour automatiques"},
DisableBackgroundApps: {Name: "Désactiver les applications en arrière-plan"},
DisableBootOptimize: {Name: "Désactiver l'optimisation du démarrage",Desc: "Désactivez le lecteur système de défragmentation au démarrage pour augmenter la durée de vie du SSD"},
DisableCrashAutoReboot: {Name: "Désactiver le redémarrage automatique en cas d'accident",Desc: "Désactivez le redémarrage automatique lorsque le système rencontre un écran bleu de la mort"},
DisableCustomInking: {Name: "Désactiver l'encrage personnalisé",Desc: "Désactiver le dictionnaire d'entrée manuscrite et de saisie personnalisé"},
DisableDeviceSearchHistory: {Name: "Désactiver l'historique des recherches localement",Desc: "Désactivez l'historique de recherche localement sur ces appareils"},
DisableDiagTrack: {Name: "Désactiver DiagTrack",Desc: "DiagTrack – Le service d'expériences utilisateur connectées et de télémétrie active des fonctionnalités qui prennent en charge les expériences utilisateur intégrées à l'application et connectées.`nDe plus, ce service gère la collecte et la transmission basées sur les événements d'informations de diagnostic et d'utilisation (utilisées pour améliorer l'expérience et la qualité de la plate-forme Windows) lorsque les paramètres des options de diagnostic et de confidentialité d'utilisation sont activés sous Commentaires et Diagnostics."},
DisabledVBSCodeIntegrity: {Name: "Intégrité du code VBS désactivée",Desc: "Désactiver la protection de l'intégrité du code basée sur la virtualisation"},
DisableErrorReporting: {Name: "Désactiver le rapport d'erreurs",Desc: "Désactivez le rapport d'erreurs d'écran pour améliorer les performances du système"},
DisableFrequentFolders: {Name: "Désactiver les dossiers fréquents"},
DisableGameBar: {Name: "Désactiver la barre de jeu et le DVR de jeu",Desc: "La fonctionnalité Game DVR vous permet d'enregistrer votre jeu en arrière-plan.`nElle est située sur la barre de jeu, qui propose des boutons pour enregistrer le jeu et prendre des captures d'écran à l'aide de la fonctionnalité Game DVR.`nMais cela peut ralentir votre performances de jeu en enregistrant une vidéo en arrière-plan."},
DisableGoogleUpdateTask: {Name: "Désactiver GoogleUpdateTask"},
DisableHibernate: {Name: "Désactiver la mise en veille prolongée"},
DisableHybridSleep: {Name: "Désactiver la veille hybride"},
DisableLockScreen: {Name: "Désactiver l'écran de verrouillage"},
DisableLowDiskSpaceChecks: {Name: "Désactiver les vérifications d'espace disque faible",Desc: "Optimiser le sous-système d'E/S disque pour améliorer les performances du système"},
Disablememorypagination: {Name: "Désactiver la pagination de la mémoire",Desc: "Désactivez la pagination de la mémoire et réduisez les E/S disque pour améliorer les performances des applications.`n(L'option peut être ignorée si la mémoire physique est <1 Go)"},
DisableMenuShowDelay: {Name: "Désactiver le délai d'affichage du menu",Desc: "Vitesse de réponse optimisée de l'affichage du système"},
DisableMicrosoftEdgeUpdateTask: {Name: "Désactiver MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Désactiver la recherche de contenu cloud MSA",Desc: "Désactiver la recherche de contenu cloud pour le compte Microsoft"},
DisableMSDefender: {Name: "Désactiver Microsoft Defender",Desc: "Activez/Désactivez Microsoft Defender en 1 clic.`nIl redémarrera automatiquement l'ordinateur."},
DisableOfferSuggestions: {Name: "Désactiver les suggestions d'offres"},
DisablePersonalizedAdsStoreApps: {Name: "Désactiver les applications StoreApps d'annonces personnalisées"},
DisablePrefetchParameters: {Name: "Désactiver les paramètres de prélecture",Desc: "Désactivez les paramètres de prélecture pour augmenter la durée de vie du SSD"},
DisablePrintSpooler: {Name: "Désactiver le spouleur d'impression"},
DisableRecentFiles: {Name: "Désactiver les fichiers récents"},
DisableRemoteRegAccess: {Name: "Désactiver l'accès à l'enregistrement à distance",Desc: "Désactiver la modification du registre à partir d'un ordinateur distant"},
DisableScheduledDefrag: {Name: "Désactiver la défragmentation programmée"},
DisableSettingsAppSuggestions: {Name: "Désactiver les suggestions d'applications de paramètres"},
DisableShortcutText: {Name: "Désactiver le texte de raccourci"},
DisableSleep: {Name: "Désactiver le sommeil"},
DisableStartMenuAppSuggestions: {Name: "Désactiver les suggestions d'applications du menu Démarrer"},
DisableSyncProviderNotifications: {Name: "Désactiver les notifications du fournisseur de synchronisation"},
DisableSystemRestore: {Name: "Désactiver la restauration du système"},
DisableTailoredExperiences: {Name: "Désactiver les expériences personnalisées"},
DisableTipsAndSuggestions: {Name: "Désactiver les conseils et suggestions"},
DisableTurnOffDisplay: {Name: "Désactiver l'affichage désactivé"},
DisableVisualStudioTelemetry: {Name: "Désactiver la télémétrie VisualStudio"},
DisableWCE: {Name: "Désactiver l'amélioration WCE",Desc: "Désactiver l'amélioration de l'expérience client Windows`n`n- Proxy : cette tâche collecte et télécharge les données Autochk SQM si vous êtes inscrit au programme d'amélioration de l'expérience client Microsoft.`n- Évaluateur de compatibilité Microsoft : collecte les informations de télémétrie du programme si vous avez adhéré au programme d'amélioration de l'expérience client Microsoft."},
DisableWebSearch: {Name: "Désactiver la recherche sur le Web",Desc: "Désactivez la recherche en ligne et incluez les résultats Web de Bing uniquement pour votre compte lorsque vous effectuez une recherche dans la barre des tâches."},
DisableWebSearchStartMenu: {Name: "Désactiver le menu Démarrer de WebSearch",Desc: "Désactive la recherche Web dans le menu Démarrer"},
DisableWindowsFeedback: {Name: "Désactiver les commentaires Windows"},
DisableWindowsSearch: {Name: "Désactiver la recherche Windows"},
EnableDarkMode: {Name: "Activer le mode sombre"},
Explorer: {Name: "Explorateur de fichiers"},
HideMostUsedApps: {Name: "Masquer les applications les plus utilisées",Desc: "Désactivez `"Afficher les applications les plus utilisées`" dans le menu Démarrer."},
HideStartMenuAccountNotifications: {Name: "Masquer les notifications liées au compte",Desc: "Désactivez `"Afficher les notifications liées au compte`" dans le menu Démarrer."},
HideStartMenuRecentlyAdded: {Name: "Masquer les applications récemment ajoutées",Desc: "Désactivez `"Afficher les applications récemment ajoutées`" dans le menu Démarrer."},
HideStartMenuRecentlyOpened: {Name: "Masquer les éléments récemment ouverts",Desc: "Désactivez `"Afficher les éléments récemment ouverts dans Démarrer, les listes de raccourcis et l'Explorateur de fichiers`" dans le menu Démarrer."},
HideStartMenuRecommendations: {Name: "Masquer les recommandations",Desc: "Désactivez `"Afficher les recommandations concernant les conseils, les raccourcis, les nouvelles applications et bien plus encore`" dans le menu Démarrer."},
HideWindowsSecurityNoncriticalNotifications: {Name: "Masquer les notifications WS non critiques",Desc: "Afficher uniquement les notifications critiques de la sécurité Windows.`nSi le paramètre GP Supprimer toutes les notifications a été activé, ce paramètre n'aura aucun effet."},
HideWindowsSecurityNotifications: {Name: "Masquer les notifications WS",Desc: "Masquez toutes les notifications de la sécurité Windows."},
HostsEdit_BtnImportFromFile: {Name: "Importer à partir de fichiers"},
HostsEdit_BtnImportFromLink: {Desc: "Importer du lien vers les hôtes"},
HostsEdit_BtnReload: {Name: "Recharger le fichier hosts"},
HostsEdit_BtnResetDefault: {Name: "Réinitialiser par défaut"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Enregistrer sous"},
HostsEdit_TxtSelectLink: {Name: "Sélectionnez le lien pour importer la liste de blocage vers les hôtes :"},
IncreaseIconCache: {Name: "Augmenter le cache des icônes",Desc: "Augmentez le cache des icônes du système et accélérez l'affichage du bureau"},
IoPageLockLimit: {Name: "Limite de verrouillage de page Io",Desc: "Optimiser les paramètres par défaut de la mémoire pour améliorer les performances du système"},
Link_ClearStartMenu: {Name: "Effacer le menu Démarrer"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Résoudre le lien Ignorer LinkInfo",Desc: "Ne pas suivre les raccourcis Shell pendant l'itinérance"},
MouseHoverTime: {Name: "Temps de survol de la souris",Desc: "Accélérer la vitesse d'affichage des aperçus de la fenêtre de la barre des tâches"},
NoInternetOpenWith: {Name: "Pas d'Internet OuvertAvec",Desc: "Désactiver le service d'association de fichiers Internet"},
NoResolveSearch: {Name: "Aucune recherche résolue",Desc: "N'utilisez pas la méthode basée sur la recherche lors de la résolution des raccourcis shell"},
NoResolveTrack: {Name: "Aucune piste de résolution",Desc: "N'utilisez pas la méthode basée sur le suivi lors de la résolution des raccourcis shell.`nCe paramètre empêche le système d'utiliser les fonctionnalités de suivi NTFS pour résoudre un raccourci."},
NumLockonStartup: {Name: "Verrouillage numérique au démarrage"},
OpenFileExplorerThisPC: {Name: "Ouvrir l'explorateur de fichiers sur ce PC"},
OptimizeNetworkTransfer: {Name: "Optimiser le transfert réseau",Desc: "Optimiser les paramètres réseau pour améliorer les performances de transfert"},
Optimizeprocessorperformance: {Name: "Optimiser les performances du processeur",Desc: "Optimisez les performances du processeur pour rendre les applications, les jeux, etc. plus fluides."},
OptimizeRefreshPolicy: {Name: "Optimiser la politique d'actualisation",Desc: "Optimiser le sous-système d'E/S disque pour améliorer les performances du système"},
Optional: {Name: "Facultatif"},
PackageManager_BtnDisable: {Desc: "Activer/Désactiver pour tous les utilisateurs"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Supprime la gestion d'un package d'application afin que les nouveaux utilisateurs sur l'appareil ne voient plus l'application automatiquement installée."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Afficher la liste des packages installés par tous les utilisateurs."},
PackageManager_Mode: {Desc: "Mode installé : afficher la liste des packages installés.`nMode non installé : afficher la liste qui se trouve sur votre ordinateur mais qui n'est pas installée par l'utilisateur actuel."},
Privacy: {Name: "Confidentialité"},
ShowExtensions: {Name: "Afficher les extensions"},
ShowHidden: {Name: "Afficher masqué"},
ShowHiddenSystem: {Name: "Afficher le système caché"},
ShowThisPC: {Name: "Afficher ce PC"},
ShutdownAcceleration: {Name: "Accélération de l'arrêt",Desc: "Réduisez l’inactivité des applications à l’arrêt pour améliorer le processus d’arrêt"},
SnippingPrintScreen: {Name: "Capture d'écran d'impression"},
StartMenu: {Name: "Le menu Démarrer"},
System: {Name: "Système"},
Text_Architecture: "Architecture",
Text_BackgroundImage: "Image de fond",
Text_Cancel: "Annuler",
Text_CheckUpdate: "Vérifier la mise à jour",
Text_ClearStartMenu_Confirm: "Êtes-vous sûr de vouloir effacer la disposition du menu Démarrer ?`n(Un fichier de sauvegarde `"WinTune_StartMenuLayout_xxxx.json`" sera créé)",
Text_ClearStartMenu_Done: "Effacer le menu Démarrer Terminé !",
Text_Close: "Fermer",
Text_CommandLine: "Ligne de commande",
Text_ConnectionFailed: "La connexion au serveur a échoué.",
Text_CurrentVersion: "Version actuelle",
Text_Custom: "Coutume",
Text_DefaultImage: "Image par défaut",
Text_Delete: "Supprimer",
Text_DeprovisionPackage: "Forfait de déprovisionnement",
Text_DeselectAll: "Tout déselectionner",
Text_Details: "Détails",
Text_Disable: "Désactiver",
Text_Disabled: "Désactivé",
Text_DisableMSDefender0: "L'activation de Microsoft Defender nécessite le redémarrage de l'ordinateur.`nÊtes-vous sûr de vouloir effectuer cette opération ?",
Text_DisableMSDefender1: "La désactivation de Microsoft Defender nécessite le redémarrage de l'ordinateur.`nÊtes-vous sûr de vouloir effectuer cette opération ?",
Text_DisplayName: "Afficher un nom",
Text_EffectivePath: "Chemin efficace",
Text_Enable: "Activer",
Text_Enabled: "Activé",
Text_FamilyName: "Nom de famille",
Text_FindRegistry: "Rechercher dans le registre",
Text_FullName: "Nom et prénom",
Text_Homepage: "Page d'accueil",
Text_HR_Optimize: "------- Optimiser -------",
Text_HR_Tools: "-------- Outils --------",
Text_Install: "Installer",
Text_InstalledAllUsers: "Tous les utilisateurs",
Text_InstalledDate: "Date d'installation",
Text_InstalledMode: "Mode installé",
Text_InstalledPath: "Chemin installé",
Text_Name: "Nom",
Text_NewestVersion: "Version la plus récente",
Text_No: "Non",
Text_None: "Aucun",
Text_NotInstalledMode: "Mode non installé",
Text_NoUpdate: "Aucune mise à jour n'est disponible. Vous utilisez la dernière version.",
Text_OK: "D'ACCORD",
Text_OpenTarget: "Emplacement cible",
Text_Properties: "Propriétés",
Text_PublisherDisplayName: "Éditeur",
Text_Save: "Sauvegarder",
Text_SearchOnline: "Rechercher en ligne",
Text_SelectAll: "Tout sélectionner",
Text_SignatureKind: "Type de signature",
Text_Status: "Statut",
Text_Target: "Cible",
Text_Type: "Taper",
Text_Uninstall: "Désinstaller",
Text_Update: "Mise à jour",
Text_UpdateFailed: "La mise à jour a échoué, veuillez réessayer plus tard.",
Text_Updating: "Mise à jour",
Text_Version: "Version",
Text_WaitDlg: "S'il vous plaît, attendez...",
Text_WhatsNew: "Quoi de neuf",
Text_Yes: "Oui",
UninstallOneDrive: {Name: "Désinstaller OneDrive"},
UnpinChat: {Name: "Chat"},
UnpinCopilot: {Name: "Copilote"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Bord"},
UnpinFileExplorer: {Name: "Explorateur de fichiers"},
UnpinMail: {Name: "Mail"},
UnpinNewsandInterests: {Name: "Actualités et intérêts"},
UnpinSearch: {Name: "Recherche"},
UnpinStore: {Name: "Magasin"},
UnpinTaskbar: {Name: "Barre des tâches"},
UnpinTaskView: {Name: "Vue des tâches"},
UnpinWidgets: {Name: "Widgets"},
VerCtrl: {Desc: "Cliquez pour vérifier la mise à jour",Desc1: "Il existe une nouvelle version`n(Cliquez pour afficher les détails)"}
},
it: {
Name: "Italiano",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6MjU6MjYrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjI0KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjI0KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo2NTYzNjcxYy02ZWRlLWFjNDItOTYxZS1kYjBhZGMyYWU0YmIiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NjU2MzY3MWMtNmVkZS1hYzQyLTk2MWUtZGIwYWRjMmFlNGJiIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NjU2MzY3MWMtNmVkZS1hYzQyLTk2MWUtZGIwYWRjMmFlNGJiIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo2NTYzNjcxYy02ZWRlLWFjNDItOTYxZS1kYjBhZGMyYWU0YmIiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6MjU6MjYrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+jQLSHAAAAq1JREFUOMuNlE1rVVcUhp919r4e4021IFqoYkEqdVI6FJy0NGpSUaST/oek6UjaQX+CIBREpb+g4NiBVQRHoc6MTpx0olhaaBTjtd7knLXeDnLuuTnJvaUbNhv2x7M+3rVXRrSjvLNAuX6Q9eJvPu2f5PFXP50DTrn7MQBL6Rnw8PWX5+/WTx4Thz6kHLzh/edPW0Zm0ojitMl+AC4g0mhbgIFHSrdl6QpoZefTLjA51PkanpaZVUuR1LklS5ecdMmK4nqhWO4C1w5umd4syYP9d0DzEI0/E4EgIQmFvt0sy48Hs/0FN8OAnG59AzLK/vBGr9yY994GOLQMAzNrWQZgwswowqn29ueHR0/cyIO1JcPIM/sqkH2WetVi5BpTAWZbEI296TiIbR2ZYV6RrbfYt5mfTb6ao/+GhK5GFOAGpjEkgAgiog3VzIhRyBIgBAz2zV7tVcOzOVXFWYw5bJyzdo6XFojZrkumAGOuIp3JZvGFsG1Jax5KrSBtyM0qgWxsbGSCPeXnOdARpqhIJ7TtwO6+RtVg9dGMmD6mAbtZ2a4WGeeFih0JC6FQK0grSgSmICRCYwPWKA68yK54UIgfpabGOjmc4KG0y0M1Z1FvPsgaztyT+X32DOdkjb0GEtOAO/bDjALd74XuZf/gTwIu51fvPZK21+E43E7IMQpZ45walIP1yxZBrsq3EMWq/MDNXOXFmHkHISI0HdhMi8Bzjzz0m/HOV02QOf4XYFQnny/x2yfHi9cH5uH/AcOM/M/g14/+eLUECRCZE7+3qtdPDy/0Xu6/hrQsxe56kygUCNGYuJ6Gw+Wktcn90DxB9u/YqH+R19+7x8VQJHen6dhEyL322+H1lUSsqCj+o8G2/SpWFP51VVXnKtWnZDpmZtRV9UxmD3HdlcfEv/Av2uYe5vu+olEAAAAASUVORK5CYII=",
AUOptions: {Name: "AUOpzioni",Desc: "Imposta Notifica prima di scaricare gli aggiornamenti di Windows"},
AutoEndTasks: {Name: "Termina automaticamente le attività",Desc: "Chiudi i processi bloccati per evitare arresti anomali del sistema"},
BtnHostsEdit: {Name: "Modifica host"},
BtnPackageManager: {Name: "App UWP"},
BtnRestartExplorer: {Name: "Riavvia Esplora risorse"},
BtnStartupManager: {Name: "Responsabile dell'avvio"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Lingua"},
BtnSys_LoadOptimizeConfig: {Desc: "Carica il file delle configurazioni di ottimizzazione"},
BtnSys_Minimize: {Desc: "Minimizzare"},
BtnSys_ReloadTab: {Desc: "Ricarica questa scheda"},
BtnSys_SaveImage: {Desc: "Autocattura e salvataggio nell'immagine"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Salva tutte le configurazioni di ottimizzazione su file"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Salva questa scheda solo la configurazione di ottimizzazione su file"},
BtnSys_Search: {Desc: "Cerca ottimizzare"},
BtnSys_Setting: {Desc: "Collocamento"},
BtnSys_Theme: {Desc: "Tema"},
ClassicContextMenu: {Name: "Menu contestuale classico"},
DiagnosticDataOff: {Name: "Dati diagnostici disattivati"},
DisableAADCloudSearch: {Name: "Disattiva AAD Cloud Content Search",Desc: "Disattiva la ricerca di contenuti cloud per l'account aziendale o scolastico"},
DisableAdsOnLockScreen: {Name: "Disattiva gli annunci sulla schermata di blocco"},
DisableAeDebug: {Name: "Disabilita AeDebug",Desc: "Disabilitare il debugger per accelerare l'elaborazione degli errori"},
DisableAnimationEffectMaxMin: {Name: "Disabilita effetto animazione Max Min",Desc: "Chiudi l'effetto di animazione quando si massimizza o si riduce a icona una finestra per accelerare la risposta della finestra"},
DisableAppendCompletion: {Name: "Disabilita il completamento dell'aggiunta",Desc: "Disattiva il completamento automatico in linea (Aggiungi completamento o Compilazione automatica)"},
DisableAutoDefragIdle: {Name: "Disattiva la deframmentazione automatica inattiva",Desc: "Disabilita la deframmentazione automatica quando è inattivo per aumentare la durata operativa dell'SSD"},
DisableAutoInstallationApps: {Name: "Disabilita le app di installazione automatica"},
DisableAutoplay: {Name: "Disabilita la riproduzione automatica",Desc: "Disabilitare la funzione `"Riproduzione automatica`" sulle unità per evitare l'infezione da virus"},
DisableAutoSuggest: {Name: "Disattiva il suggerimento automatico",Desc: "Disattiva suggerimento automatico (elenco a discesa di completamento automatico)"},
DisableAutoWindowsUpdates: {Name: "Disabilita gli aggiornamenti automatici di Windows",Desc: "Disabilita Aggiornamenti automatici"},
DisableBackgroundApps: {Name: "Disattiva le app in background"},
DisableBootOptimize: {Name: "Disabilita l'ottimizzazione dell'avvio",Desc: "Disabilitare l'unità di deframmentazione del sistema all'avvio per aumentare la durata operativa dell'SSD"},
DisableCrashAutoReboot: {Name: "Disabilita il riavvio automatico in caso di arresto anomalo",Desc: "Disabilita il riavvio automatico quando il sistema incontra la schermata blu della morte"},
DisableCustomInking: {Name: "Disabilita l'input penna personalizzato",Desc: "Disabilita l'inchiostro personalizzato e il dizionario di digitazione"},
DisableDeviceSearchHistory: {Name: "Disattiva la cronologia delle ricerche localmente",Desc: "Disattiva la cronologia delle ricerche localmente su questi dispositivi"},
DisableDiagTrack: {Name: "Disabilita DiagTrack",Desc: "DiagTrack: il servizio Esperienze utente connesse e telemetria abilita funzionalità che supportano esperienze utente connesse e nell'applicazione.`nInoltre, questo servizio gestisce la raccolta e la trasmissione guidata dagli eventi di informazioni diagnostiche e di utilizzo (utilizzate per migliorare l'esperienza e la qualità di sulla piattaforma Windows) quando le impostazioni dell'opzione di diagnostica e privacy sull'utilizzo sono abilitate in Feedback e diagnostica."},
DisabledVBSCodeIntegrity: {Name: "Integrità del codice VBS disabilitata",Desc: "Disabilitare la protezione dell'integrità del codice basata sulla virtualizzazione"},
DisableErrorReporting: {Name: "Disabilita segnalazione errori",Desc: "Disattiva la segnalazione degli errori sullo schermo per migliorare le prestazioni del sistema"},
DisableFrequentFolders: {Name: "Disabilita le cartelle frequenti"},
DisableGameBar: {Name: "Disattiva la barra di gioco e il DVR di gioco",Desc: "La funzione Game DVR ti consente di registrare il tuo gameplay in background.`nSi trova sulla barra dei giochi, che offre pulsanti per registrare il gameplay e acquisire screenshot utilizzando la funzione Game DVR.`nMa può rallentare il tuo prestazioni di gioco registrando video in background."},
DisableGoogleUpdateTask: {Name: "Disabilita GoogleUpdateTask"},
DisableHibernate: {Name: "Disabilita Ibernazione"},
DisableHybridSleep: {Name: "Disabilita la sospensione ibrida"},
DisableLockScreen: {Name: "Disabilita schermata di blocco"},
DisableLowDiskSpaceChecks: {Name: "Disabilita i controlli di spazio su disco insufficiente",Desc: "Ottimizza il sottosistema I/O del disco per migliorare le prestazioni del sistema"},
Disablememorypagination: {Name: "Disabilita l'impaginazione della memoria",Desc: "Disabilita l'impaginazione della memoria e riduci l'I/O del disco per migliorare le prestazioni dell'applicazione.`n(L'opzione può essere ignorata se la memoria fisica è <1 GB)"},
DisableMenuShowDelay: {Name: "Disabilita menu Mostra ritardo",Desc: "Velocità di risposta ottimizzata del display del sistema"},
DisableMicrosoftEdgeUpdateTask: {Name: "Disabilitare MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Disattiva MSA Cloud Content Search",Desc: "Disattiva Ricerca contenuto cloud per l'account Microsoft"},
DisableMSDefender: {Name: "Disabilita Microsoft Defender",Desc: "Abilita/Disabilita Microsoft Defender con 1 clic.`nIl computer verrà riavviato automaticamente."},
DisableOfferSuggestions: {Name: "Disabilita suggerimenti di offerte"},
DisablePersonalizedAdsStoreApps: {Name: "Disattiva le app Store di annunci personalizzati"},
DisablePrefetchParameters: {Name: "Disabilita i parametri di precaricamento",Desc: "Disabilita i parametri di precaricamento per aumentare la durata operativa dell'SSD"},
DisablePrintSpooler: {Name: "Disattiva lo spooler di stampa"},
DisableRecentFiles: {Name: "Disabilita file recenti"},
DisableRemoteRegAccess: {Name: "Disabilita accesso registro remoto",Desc: "Disabilita la modifica del registro da un computer remoto"},
DisableScheduledDefrag: {Name: "Disabilita la deframmentazione pianificata"},
DisableSettingsAppSuggestions: {Name: "Disattiva Impostazioni Suggerimenti app"},
DisableShortcutText: {Name: "Disabilita testo di scelta rapida"},
DisableSleep: {Name: "Disabilita il sonno"},
DisableStartMenuAppSuggestions: {Name: "Disattiva i suggerimenti delle app del menu Start"},
DisableSyncProviderNotifications: {Name: "Disattiva le notifiche del provider di sincronizzazione"},
DisableSystemRestore: {Name: "Disabilita Ripristino configurazione di sistema"},
DisableTailoredExperiences: {Name: "Disabilita esperienze personalizzate"},
DisableTipsAndSuggestions: {Name: "Disattiva suggerimenti e suggerimenti"},
DisableTurnOffDisplay: {Name: "Disabilita Spegni display"},
DisableVisualStudioTelemetry: {Name: "Disabilitare la telemetria di VisualStudio"},
DisableWCE: {Name: "Disabilita il miglioramento WCE",Desc: "Disattiva Miglioramento esperienza cliente Windows`n`n- Proxy: questa attività raccoglie e carica i dati SQM con controllo automatico se si è aderito al Programma di miglioramento esperienza cliente Microsoft.`n- Microsoft Compatibility Appraiser: raccoglie informazioni di telemetria del programma se ha aderito al Programma di miglioramento dell'esperienza del cliente Microsoft."},
DisableWebSearch: {Name: "Disattiva la ricerca sul Web",Desc: "Disattiva la ricerca online e includi risultati Web di Bing solo per il tuo account quando esegui una ricerca sulla barra delle applicazioni"},
DisableWebSearchStartMenu: {Name: "Disabilita il menu di avvio di WebSearch",Desc: "Disabilita la ricerca Web nel menu Start"},
DisableWindowsFeedback: {Name: "Disattiva il feedback di Windows"},
DisableWindowsSearch: {Name: "Disabilita la ricerca di Windows"},
EnableDarkMode: {Name: "Abilita la modalità oscura"},
Explorer: {Name: "Esplora file"},
HideMostUsedApps: {Name: "Nascondi le app più utilizzate",Desc: "Disattiva `"Mostra le app più utilizzate`" nel menu Start"},
HideStartMenuAccountNotifications: {Name: "Nascondi le notifiche relative all'account",Desc: "Disattiva `"Mostra notifiche relative all'account`" nel menu Start"},
HideStartMenuRecentlyAdded: {Name: "Nascondi le app aggiunte di recente",Desc: "Disattiva `"Mostra le app aggiunte di recente`" nel menu Start"},
HideStartMenuRecentlyOpened: {Name: "Nascondi gli elementi aperti di recente",Desc: "Disattiva `"Mostra gli elementi aperti di recente in Start, Jump List ed Esplora file`" nel menu Start"},
HideStartMenuRecommendations: {Name: "Nascondi consigli",Desc: "Disattiva `"Mostra consigli per suggerimenti, scorciatoie, nuove app e altro`" nel menu Start"},
HideWindowsSecurityNoncriticalNotifications: {Name: "Nascondi notifiche WS non critiche",Desc: "Mostra solo le notifiche critiche da Sicurezza di Windows.`nSe l'impostazione Elimina tutte le notifiche GP è stata abilitata, questa impostazione non avrà alcun effetto."},
HideWindowsSecurityNotifications: {Name: "Nascondi notifiche WS",Desc: "Nascondi tutte le notifiche da Sicurezza di Windows."},
HostsEdit_BtnImportFromFile: {Name: "Importa da file"},
HostsEdit_BtnImportFromLink: {Desc: "Importa dal collegamento agli host"},
HostsEdit_BtnReload: {Name: "Ricarica il file host"},
HostsEdit_BtnResetDefault: {Name: "Ripristina predefinito"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Salva come"},
HostsEdit_TxtSelectLink: {Name: "Seleziona il collegamento per importare l'elenco dei blocchi negli host:"},
IncreaseIconCache: {Name: "Aumenta la cache delle icone",Desc: "Aumenta la cache delle icone di sistema e velocizza la visualizzazione del desktop"},
IoPageLockLimit: {Name: "Limite blocco pagina Io",Desc: "Ottimizza le impostazioni predefinite della memoria per migliorare le prestazioni del sistema"},
Link_ClearStartMenu: {Name: "Cancella il menu Start"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Risolvi collegamento Ignora LinkInfo",Desc: "Non tenere traccia dei collegamenti Shell durante il roaming"},
MouseHoverTime: {Name: "Tempo al passaggio del mouse",Desc: "Accelera la velocità di visualizzazione delle anteprime delle finestre della barra delle applicazioni"},
NoInternetOpenWith: {Name: "Nessun Internet OpenWith",Desc: "Disattiva il servizio Associazione file Internet"},
NoResolveSearch: {Name: "Nessuna ricerca risolta",Desc: "Non utilizzare il metodo basato sulla ricerca durante la risoluzione dei collegamenti alla shell"},
NoResolveTrack: {Name: "Nessuna traccia di risoluzione",Desc: "Non utilizzare il metodo basato sul tracciamento durante la risoluzione dei collegamenti alla shell.`nQuesta impostazione impedisce al sistema di utilizzare le funzionalità di tracciamento NTFS per risolvere un collegamento."},
NumLockonStartup: {Name: "Blocco Num all'avvio"},
OpenFileExplorerThisPC: {Name: "Apri Esplora file su questo PC"},
OptimizeNetworkTransfer: {Name: "Ottimizza il trasferimento di rete",Desc: "Ottimizza le impostazioni di rete per migliorare le prestazioni di trasferimento"},
Optimizeprocessorperformance: {Name: "Ottimizza le prestazioni del processore",Desc: "Ottimizza le prestazioni del processore per far funzionare applicazioni, giochi, ecc. in modo più fluido."},
OptimizeRefreshPolicy: {Name: "Ottimizza la politica di aggiornamento",Desc: "Ottimizza il sottosistema I/O del disco per migliorare le prestazioni del sistema"},
Optional: {Name: "Opzionale"},
PackageManager_BtnDisable: {Desc: "Abilita/Disabilita per tutti gli utenti"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Effettua il deprovisioning di un pacchetto dell'app in modo che i nuovi utenti del dispositivo non avranno più l'app installata automaticamente."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Mostra l'elenco dei pacchetti installati da tutti gli utenti."},
PackageManager_Mode: {Desc: "Modalità installata: mostra l'elenco dei pacchetti installati.`nModalità non installata: mostra l'elenco che è sul tuo computer ma non installato dall'utente corrente."},
Privacy: {Name: "Privacy"},
ShowExtensions: {Name: "Mostra estensioni"},
ShowHidden: {Name: "Mostra nascosto"},
ShowHiddenSystem: {Name: "Mostra sistema nascosto"},
ShowThisPC: {Name: "Mostra questo PC"},
ShutdownAcceleration: {Name: "Accelerazione di spegnimento",Desc: "Ridurre l'inattività dell'applicazione all'arresto per migliorare il processo di arresto"},
SnippingPrintScreen: {Name: "Cattura PrintScreen"},
StartMenu: {Name: "Menu iniziale"},
System: {Name: "Sistema"},
Text_Architecture: "Architettura",
Text_BackgroundImage: "Immagine di sfondo",
Text_Cancel: "Annulla",
Text_CheckUpdate: "Controlla aggiornamento",
Text_ClearStartMenu_Confirm: "Vuoi cancellare il layout del menu Start?`n(Verrà creato un file di backup `"WinTune_StartMenuLayout_xxxx.json`")",
Text_ClearStartMenu_Done: "Cancella menu iniziale Fatto!",
Text_Close: "Vicino",
Text_CommandLine: "Riga di comando",
Text_ConnectionFailed: "La connessione al server non è riuscita.",
Text_CurrentVersion: "Versione attuale",
Text_Custom: "Costume",
Text_DefaultImage: "Immagine predefinita",
Text_Delete: "Eliminare",
Text_DeprovisionPackage: "Pacchetto di deprovisioning",
Text_DeselectAll: "Deselezionare tutto",
Text_Details: "Dettagli",
Text_Disable: "disattivare",
Text_Disabled: "Disabilitato",
Text_DisableMSDefender0: "L'abilitazione di Microsoft Defender richiede il riavvio del computer.`nSei sicuro di volerlo eseguire?",
Text_DisableMSDefender1: "La disabilitazione di Microsoft Defender richiede il riavvio del computer.`nSei sicuro di voler eseguire questa operazione?",
Text_DisplayName: "Nome da visualizzare",
Text_EffectivePath: "Percorso efficace",
Text_Enable: "Abilitare",
Text_Enabled: "Abilitato",
Text_FamilyName: "Cognome",
Text_FindRegistry: "Trova nel Registro di sistema",
Text_FullName: "Nome e cognome",
Text_Homepage: "Home page",
Text_HR_Optimize: "------- Ottimizza -------",
Text_HR_Tools: "-------- Utensili --------",
Text_Install: "Installare",
Text_InstalledAllUsers: "Tutti gli utenti",
Text_InstalledDate: "Data di installazione",
Text_InstalledMode: "Modalità installata",
Text_InstalledPath: "Percorso installato",
Text_Name: "Nome",
Text_NewestVersion: "Ultima versione",
Text_No: "NO",
Text_None: "Nessuno",
Text_NotInstalledMode: "Modalità non installata",
Text_NoUpdate: "Nessun aggiornamento è disponibile. Stai utilizzando la versione più recente.",
Text_OK: "OK",
Text_OpenTarget: "Posizione di destinazione",
Text_Properties: "Proprietà",
Text_PublisherDisplayName: "Editore",
Text_Save: "Salva",
Text_SearchOnline: "Cerca in linea",
Text_SelectAll: "Seleziona tutto",
Text_SignatureKind: "Tipo di firma",
Text_Status: "Stato",
Text_Target: "Bersaglio",
Text_Type: "Tipo",
Text_Uninstall: "Disinstallare",
Text_Update: "Aggiornamento",
Text_UpdateFailed: "Aggiornamento non riuscito, riprova più tardi.",
Text_Updating: "In aggiornamento",
Text_Version: "Versione",
Text_WaitDlg: "Attendere prego...",
Text_WhatsNew: "Cosa c'è di nuovo",
Text_Yes: "SÌ",
UninstallOneDrive: {Name: "Disinstallare OneDrive"},
UnpinChat: {Name: "Chiacchierata"},
UnpinCopilot: {Name: "Copilota"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Bordo"},
UnpinFileExplorer: {Name: "Esplora file"},
UnpinMail: {Name: "Posta"},
UnpinNewsandInterests: {Name: "Notizie e interessi"},
UnpinSearch: {Name: "Ricerca"},
UnpinStore: {Name: "Negozio"},
UnpinTaskbar: {Name: "Barra delle applicazioni"},
UnpinTaskView: {Name: "TaskView"},
UnpinWidgets: {Name: "Widget"},
VerCtrl: {Desc: "Fare clic per verificare l'aggiornamento",Desc1: "È disponibile una nuova versione`n(Fai clic per visualizzare i dettagli)"}
},
ja: {
Name: "日本語",
Translator: "coolvitto",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6MjY6MDcrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjE1KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjE1KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpiZmE5Yzk3OS04MmE3LTM1NDYtYjU3Ni02MDJiZmFiODc5N2MiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6YmZhOWM5NzktODJhNy0zNTQ2LWI1NzYtNjAyYmZhYjg3OTdjIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6YmZhOWM5NzktODJhNy0zNTQ2LWI1NzYtNjAyYmZhYjg3OTdjIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpiZmE5Yzk3OS04MmE3LTM1NDYtYjU3Ni02MDJiZmFiODc5N2MiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6MjY6MDcrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+VMrgLQAAAnFJREFUOI2NlM1u01AQha8ErFHFDkh5hIhChZR92ldAILFkU/EIdNXuugHSblIJ9Q2y7KLvgKho05QgUSrl///HdhLbwzkTX8lOgqilLx7PnHN8fZ3EiIix+L6vBEFg2QK76OUJa7DNWRiGxp7jGWYxMArKoC7480MW4FFAUOZOgSA3m83kLlAb9y8FQnQ6nU5lCZiVFTN6VgZi+UeRQGaR2Jflgz3VRdrJZCL0JgKxD2kO7F1Zh2oOpX38RSof3int48/ih6HOlvTI4H7qvqFx5nmeWLgK53dZyhvrcnnfyNWjOazZ44yauIcZzDK4yCYGQSAT15Hy5roU1xDw6pmUXzydg1p7mE1dV7ULoVnjuu4+EEuAOze/HsrFg3nYTwTFYY8zaqilh2HRec84jnMCxDKF6M/OW7nAI14j4HrjSRL0OKOG2rh3PB6fGH4AsUwgutl5Iz9gKiFgFZzdIJDauFcDR6PR/nA4FJyFZw+iWv6TnOMFlDZTcvX8cQL2zu8Z1VAb9+K8Z1BkB4OBWIb4GoxwtyJWcv4Qb/dlSooIIqzZ44waauNekOUjGxRnvV5P+v2+9LpdGeHO3V8luUyn5BtW831tDmv2OKOGWvXAywxm8aUwNN1ut6ULAemgHsLQx9fn9vBAyu9fK7e5A+k5Y5114vpOh4+b1kB+ENzlqNlsCoMV1B3HkwHMcbqupzOro4dem2N/egoEp/V6XUVJWhHJPrX0WP/Svw32wTQajVytVlMxwXUC2480OXr++feFDTatVouhGRgK1WrVB7KAzxlWmMHq1PPfQIgNTGQLAR8rlUo+YhfX21gZt8esCvwL2Gse7kUJhlsAAAAASUVORK5CYII=",
AUOptions: {Name: "AUオプション",Desc: "Windows アップデートをダウンロードする前に通知する"},
AutoEndTasks: {Name: "タスクを自動的に終了する",Desc: "システムクラッシュを避けるためにフリーズしたプロセスを閉じる"},
BtnHostsEdit: {Name: "Hosts の編集"},
BtnPackageManager: {Name: "UWP アプリ"},
BtnRestartExplorer: {Name: "エクスプローラーを再起動"},
BtnStartupManager: {Name: "スタートアップマネージャ"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "言語"},
BtnSys_LoadOptimizeConfig: {Desc: "最適化設定ファイルの読み込み"},
BtnSys_Minimize: {Desc: "最小化"},
BtnSys_ReloadTab: {Desc: "タブの再読み込み"},
BtnSys_SaveImage: {Desc: "自動キャプチャして画像に保存"},
BtnSys_SaveOptimizeConfigAll: {Desc: "すべての最適化設定をファイルに保存"},
BtnSys_SaveOptimizeConfigTab: {Desc: "このタブのみの、最適化設定をファイルに保存"},
BtnSys_Search: {Desc: "最適化の検索"},
BtnSys_Setting: {Desc: "設定"},
BtnSys_Theme: {Desc: "テーマ"},
ClassicContextMenu: {Name: "クラシックコンテキストメニュー"},
DiagnosticDataOff: {Name: "診断データを無効にする"},
DisableAADCloudSearch: {Name: "AAD クラウド コンテンツ検索を無効にする",Desc: "職場または学校のアカウントのクラウド コンテンツ検索をオフにする"},
DisableAdsOnLockScreen: {Name: "ロック画面の広告をオフにする"},
DisableAeDebug: {Name: "AEDebugを無効にする",Desc: "デバッガを無効にしてエラー処理を高速化する"},
DisableAnimationEffectMaxMin: {Name: "最大最小アニメーション効果を無効にする",Desc: "ウィンドウを最大化または最小化するときにアニメーション効果を無効にして、ウィンドウの応答を高速化します"},
DisableAppendCompletion: {Name: "自動補完を無効にする",Desc: "インラインオートコンプリートを無効にする (追加補完またはオートフィル)"},
DisableAutoDefragIdle: {Name: "アイドル時の自動デフラグをオフにする",Desc: "アイドル時の自動デフラグを無効にして、SSD の動作寿命を延ばします"},
DisableAutoInstallationApps: {Name: "自動インストールアプリを無効にする"},
DisableAutoplay: {Name: "自動再生を無効にする",Desc: "ウイルス感染を避けるために、ドライブの`"自動再生`"機能を無効にします"},
DisableAutoSuggest: {Name: "自動提案を無効にする",Desc: "自動提案を無効にします (オートコンプリート ドロップダウン)"},
DisableAutoWindowsUpdates: {Name: "自動更新を無効にする",Desc: "Windows の自動更新を無効にする"},
DisableBackgroundApps: {Name: "バックグラウンドアプリをを無効にする"},
DisableBootOptimize: {Name: "起動時の最適化を無効にする",Desc: "起動時にシステムドライブのデフラグを無効にして、SSDの寿命を延ばします"},
DisableCrashAutoReboot: {Name: "クラッシュ時の自動再起動を無効にする",Desc: "システムがブルー スクリーンに遭遇した場合の自動再起動を無効にします"},
DisableCustomInking: {Name: "カスタム手書き入力を無効にする",Desc: "カスタム手書き入力と入力辞書を無効にします"},
DisableDeviceSearchHistory: {Name: "ローカルでの検索履歴を無効にする",Desc: "これらのデバイスでローカルの検索履歴を無効にします"},
DisableDiagTrack: {Name: "診断追跡サービス(DiagTrack)を無効にする",Desc: "DiagTrack - 接続されたユーザー エクスペリエンスとテレメトリ サービスは、接続されたアプリケーション内ユーザー エクスペリエンスをサポートする機能を有効にします。`nさらに、このサービスは、[フィードバックと診断] で診断と使用状況のプライバシー オプション設定が有効になっている場合に、診断情報と使用状況情報 (Windows プラットフォームのエクスペリエンスと品質を向上させるために使用されます) のイベント ドリブン収集と送信を管理します。"},
DisabledVBSCodeIntegrity: {Name: "VBS コードの整合性を無効にする",Desc: "仮想化ベースのコード整合性保護を無効にします"},
DisableErrorReporting: {Name: "エラー報告を無効にする",Desc: "システムのパフォーマンスを向上させるために、画面上のエラー報告を無効にします"},
DisableFrequentFolders: {Name: "よく使うフォルダーを無効にする"},
DisableGameBar: {Name: "ゲームバーとゲームDVRを無効にする",Desc: "ゲーム DVR 機能を使用すると、ゲームプレイをバックグラウンドで録画できます。`nこの機能はゲーム バーにあり、ゲーム DVR 機能を使用してゲームプレイを録画し、スクリーンショットを撮るためのボタンが表示されます。`nただし、速度が低下する可能性があります。バックグラウンドでビデオを録画することでゲームのパフォーマンスを向上させます。"},
DisableGoogleUpdateTask: {Name: "GoogleUpdateタスクを無効にする"},
DisableHibernate: {Name: "休止状態を無効にする"},
DisableHybridSleep: {Name: "ハイブリッドスリープを無効にする"},
DisableLockScreen: {Name: "ロック画面を無効にする"},
DisableLowDiskSpaceChecks: {Name: "ディスク容量不足チェックを無効にする",Desc: "ディスク I/O サブシステムを最適化してシステム パフォーマンスを向上させます"},
Disablememorypagination: {Name: "ページングメモリを無効にする",Desc: "ページングメモリを無効にしてディスク I/O を減らし、アプリケーションのパフォーマンスを向上させます。`n(物理メモリが 1 GB 未満の場合、オプションは無視できます)"},
DisableMenuShowDelay: {Name: "メニューの遅延表示を無効にする",Desc: "システムディスプレイの応答性の最適化"},
DisableMicrosoftEdgeUpdateTask: {Name: "MicrosoftEdgeUpdateTaskを無効にする"},
DisableMSACloudSearch: {Name: "MSAクラウドコンテンツ検索を無効にする",Desc: "Microsoft アカウントのクラウド コンテンツ検索をオフにする"},
DisableMSDefender: {Name: "Microsoft Defenderを無効にする",Desc: "1 クリックで Microsoft Defender を有効または無効にします。`nコンピュータは自動的に再起動します。"},
DisableOfferSuggestions: {Name: "おすすめを無効にする"},
DisablePersonalizedAdsStoreApps: {Name: "ストア アプリのパーソナライズされた広告を無効にする"},
DisablePrefetchParameters: {Name: "プリロードパラメータを無効にする",Desc: "プリロードパラメータを無効にしてSSDの動作寿命を延ばします"},
DisablePrintSpooler: {Name: "印刷スプーラーを無効にする"},
DisableRecentFiles: {Name: "最近使ったファイルを無効にする"},
DisableRemoteRegAccess: {Name: "リモート レジストリ アクセスを無効にする",Desc: "リモート コンピュータからのレジストリ編集を無効にする"},
DisableScheduledDefrag: {Name: "スケジュールされたデフラグを無効にする"},
DisableSettingsAppSuggestions: {Name: "設定アプリの提案を無効にする"},
DisableShortcutText: {Name: "ショートカットテキストを無効にする"},
DisableSleep: {Name: "スリープを無効にする"},
DisableStartMenuAppSuggestions: {Name: "スタート メニューのアプリの提案を無効にする"},
DisableSyncProviderNotifications: {Name: "同期プロバイダーの通知を無効にする"},
DisableSystemRestore: {Name: "システムの復元を無効にする"},
DisableTailoredExperiences: {Name: "パーソナライズされたエクスペリエンスを無効にする"},
DisableTipsAndSuggestions: {Name: "ヒントと提案を無効にする"},
DisableTurnOffDisplay: {Name: "ディスプレイの電源をオフにするを無効にする"},
DisableVisualStudioTelemetry: {Name: "VisualStudio テレメトリを無効にする"},
DisableWCE: {Name: "WCE 拡張機能を無効にする",Desc: "Windows カスタマー エクスペリエンスを無効にする`n`n- プロキシ: このタスクは、Microsoft カスタマー エクスペリエンス向上プログラムにオプトインしている場合、autochk SQM データを収集してアップロードします。`n- Microsoft Compatibility Appraiser: Microsoft カスタマー エクスペリエンス向上プログラムにオプトインした場合は、プログラム テレメトリ情報を収集します。"},
DisableWebSearch: {Name: "Web検索をオフにする",Desc: "オンライン検索をオフにし、タスクバー検索を実行するときに自分のアカウントの Bing Web 結果のみを含めます"},
DisableWebSearchStartMenu: {Name: "Web 検索を無効にする",Desc: "スタートメニューの Web 検索を無効にします"},
DisableWindowsFeedback: {Name: "Windows フィードバックを無効にする"},
DisableWindowsSearch: {Name: "Windows サーチを無効にする"},
EnableDarkMode: {Name: "ダークモードを有効にする"},
Explorer: {Name: "ファイル エクスプローラー"},
HideMostUsedApps: {Name: "よく使うアプリを非表示にする",Desc: "[スタート] メニューの [`"よく使用されるアプリの表示`"] をオフにします"},
HideStartMenuAccountNotifications: {Name: "アカウントの通知を非表示にする",Desc: "[スタート] メニューの [`"アカウント通知を表示`"] をオフにします"},
HideStartMenuRecentlyAdded: {Name: "最近追加したアプリを非表示にする",Desc: "[スタート] メニューの [`"最近追加したアプリを表示`"] をオフにします"},
HideStartMenuRecentlyOpened: {Name: "最近開いたアイテムを非表示にする",Desc: "[スタート] メニューの [`"スタート、ジャンプ リスト、ファイル エクスプローラーで最近開いたアイテムを表示する`"をオフにします"},
HideStartMenuRecommendations: {Name: "ヒントを非表示にする",Desc: "[スタート] メニューの [`"ヒント、ショートカット、新しいアプリなどのおすすめを表示する`"をオフにします"},
HideWindowsSecurityNoncriticalNotifications: {Name: "重要でない WS 通知を非表示にする",Desc: "Windows セキュリティからの重要な通知のみを表示します。`n[すべての GP 通知を抑制する] 設定が有効になっている場合、この設定は効果がありません。"},
HideWindowsSecurityNotifications: {Name: "WS通知を非表示にする",Desc: "Windows セキュリティからの通知をすべて非表示にします。"},
HostsEdit_BtnImportFromFile: {Name: "ファイルからインポート"},
HostsEdit_BtnImportFromLink: {Desc: "リンクからhostsへインポート"},
HostsEdit_BtnReload: {Name: "hostsファイルの再読み込み"},
HostsEdit_BtnResetDefault: {Name: "デフォルトを復元"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "名前を付けて保存"},
HostsEdit_TxtSelectLink: {Name: "リンクを選択してブロック リストをhostsにインポートします。"},
IncreaseIconCache: {Name: "アイコンキャッシュを増やす",Desc: "システムアイコンのキャッシュを増やし、デスクトップの表示を高速化します。"},
IoPageLockLimit: {Name: "IO ページ ロック制限",Desc: "デフォルトのメモリ設定を最適化してシステムパフォーマンスを向上させます"},
Link_ClearStartMenu: {Name: "スタートメニューをクリアする"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "リンク解決時に LinkInfo を無視する",Desc: "ローミング中にシェルのショートカットを追跡しません"},
MouseHoverTime: {Name: "ホバー時間",Desc: "タスクバーウィンドウのプレビューの表示速度を高速化します。"},
NoInternetOpenWith: {Name: "インターネットの『プログラムから開く』を無効にする",Desc: "インターネット ファイル アソシエーション サービスを無効にする"},
NoResolveSearch: {Name: "リンク解決時の検索を無効にする",Desc: "シェル リンクを解決するときに検索ベースの方法を使用しません。"},
NoResolveTrack: {Name: "リンク解決時の追跡を無効にする",Desc: "シェル リンクを解決するときは、トレース ベースの方法を使用しません。`nこの設定により、システムはリンクを解決するために NTFS トレース機能を使用できなくなります。"},
NumLockonStartup: {Name: "起動時のNumロック"},
OpenFileExplorerThisPC: {Name: "この PC でエクスプローラーを開く"},
OptimizeNetworkTransfer: {Name: "ネットワーク転送を最適化する",Desc: "ネットワーク設定を最適化して転送パフォーマンスを向上させます"},
Optimizeprocessorperformance: {Name: "プロセッサのパフォーマンスを最適化する",Desc: "プロセッサのパフォーマンスを最適化して、アプリケーションやゲームなどをよりスムーズに実行します。"},
OptimizeRefreshPolicy: {Name: "更新ポリシーを最適化する",Desc: "ディスク I/O サブシステムを最適化してシステム パフォーマンスを向上させます"},
Optional: {Name: "オプション"},
PackageManager_BtnDisable: {Desc: "すべてのユーザーに対して有効化/無効化"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "アプリ パッケージのプロビジョニングを解除すると、デバイスの新しいユーザーにアプリが自動的にインストールされなくなります。"},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "すべてのユーザーによってインストールされたパッケージのリストを表示します。"},
PackageManager_Mode: {Desc: "インストール モード: インストールされているパッケージのリストを表示します。`n非インストール モード: コンピュータ上にあるものの、現在のユーザーによってインストールされていないパッケージのリストを表示します。"},
Privacy: {Name: "プライバシー"},
ShowExtensions: {Name: "拡張子を表示"},
ShowHidden: {Name: "隠しファイルを表示"},
ShowHiddenSystem: {Name: "システムファイルを表示"},
ShowThisPC: {Name: "このPC を表示"},
ShutdownAcceleration: {Name: "シャットダウンの高速化",Desc: "シャットダウン時のアプリケーションのアイドル状態を減らし、シャットダウン プロセスを改善します。"},
SnippingPrintScreen: {Name: "PrintScreenキーでSnipping Toolを起動"},
StartMenu: {Name: "スタートメニュー"},
System: {Name: "システム"},
Text_Architecture: "アーキテクチャ",
Text_BackgroundImage: "背景画像",
Text_Cancel: "キャンセル",
Text_CheckUpdate: "アップデートの確認",
Text_ClearStartMenu_Confirm: "[スタート] メニューのレイアウトをクリアしてもよろしいですか?`n(バックアップ ファイル `"WinTune_StartMenuLayout_xxxx.json`" が作成されます)",
Text_ClearStartMenu_Done: "スタートメニューのクリア完了!",
Text_Close: "閉じる",
Text_CommandLine: "コマンドライン",
Text_ConnectionFailed: "サーバーへの接続に失敗しました。",
Text_CurrentVersion: "現行バージョン",
Text_Custom: "カスタム",
Text_DefaultImage: "デフォルトの画像",
Text_Delete: "削除",
Text_DeprovisionPackage: "パッケージのプロビジョニングを解除する",
Text_DeselectAll: "すべて選択解除",
Text_Details: "詳細",
Text_Disable: "無効",
Text_Disabled: "無効済",
Text_DisableMSDefender0: "Microsoft Defender を有効にするには、コンピュータを再起動する必要があります。`nこれを実行してもよろしいですか?",
Text_DisableMSDefender1: "Microsoft Defender を無効にするには、コンピュータを再起動する必要があります。`nこれを実行してもよろしいですか?",
Text_DisplayName: "表示名",
Text_EffectivePath: "有効なパス",
Text_Enable: "有効",
Text_Enabled: "有効済",
Text_FamilyName: "苗字",
Text_FindRegistry: "レジストリ内で検索",
Text_FullName: "フルネーム",
Text_Homepage: "ホームページ",
Text_HR_Optimize: "------- 最適化 -------",
Text_HR_Tools: "-------- ツール --------",
Text_Install: "インストール",
Text_InstalledAllUsers: "すべてのユーザー",
Text_InstalledDate: "インストール日",
Text_InstalledMode: "インストールモード",
Text_InstalledPath: "インストールされたパス",
Text_Name: "名前",
Text_NewestVersion: "最新バージョン",
Text_No: "いいえ",
Text_None: "なし",
Text_NotInstalledMode: "未インストールモード",
Text_NoUpdate: "利用可能なアップデートはありません。最新バージョンを使用しています。",
Text_OK: "OK",
Text_OpenTarget: "ターゲットの位置",
Text_Properties: "プロパティ",
Text_PublisherDisplayName: "発行者",
Text_Save: "保存",
Text_SearchOnline: "オンラインで検索",
Text_SelectAll: "すべて選択",
Text_SignatureKind: "署名の種類",
Text_Status: "状態",
Text_Target: "対象",
Text_Type: "種類",
Text_Uninstall: "アンインストール",
Text_Update: "アップデート",
Text_UpdateFailed: "アップデートに失敗しました。後でもう一度お試しください。",
Text_Updating: "更新中",
Text_Version: "バージョン",
Text_WaitDlg: "お待ちください...",
Text_WhatsNew: "新着情報",
Text_Yes: "はい",
UninstallOneDrive: {Name: "OneDrive をアンインストールする"},
UnpinChat: {Name: "チャット"},
UnpinCopilot: {Name: "Copilot"},
UnpinCortana: {Name: "コルタナ"},
UnpinEdge: {Name: "Edge"},
UnpinFileExplorer: {Name: "ファイル エクスプローラー"},
UnpinMail: {Name: "メール"},
UnpinNewsandInterests: {Name: "ニュースと関心事項"},
UnpinSearch: {Name: "検索"},
UnpinStore: {Name: "ストア"},
UnpinTaskbar: {Name: "タスクバー"},
UnpinTaskView: {Name: "タスクビュー"},
UnpinWidgets: {Name: "ウィジェット"},
VerCtrl: {Desc: "クリックして更新を確認します",Desc1: "新しいバージョンが利用可能です`n(クリックして詳細表示)"}
},
ko: {
Name: "한국어",
Translator: "비너스걸",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFzGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMDk6NDk6NTYrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDEwOjA0OjEwKzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDEwOjA0OjEwKzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoxY2VlNTQ3My01MjZhLTZiNDMtOTgyYi0xNjA1NDE3YjE4YTYiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDo2NGJmM2IyNy04Y2EzLTU2NGYtOGU0NS02NDgxOTI0ZGM0MjMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDphODRjMzZiMS0yN2YzLTg4NDctOWY2YS03M2ZjMTE2MjQzOWUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmE4NGMzNmIxLTI3ZjMtODg0Ny05ZjZhLTczZmMxMTYyNDM5ZSIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0yOFQwOTo0OTo1NiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MWNlZTU0NzMtNTI2YS02YjQzLTk4MmItMTYwNTQxN2IxOGE2IiBzdEV2dDp3aGVuPSIyMDI0LTA3LTI4VDEwOjA0OjEwKzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMTEgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PqpvOisAAANRSURBVDiNhZRLSJRRFMcvrSKkWrRpE2HtCt20skWb1GUEkSCJ9NJ8pY6jhelUOKP4QoTBjZCMoBQEjaY1gUEL8zGg1EYq7eGoM+oo6Tydb77x3zn3+75Bh8QL/5l77znnd+89595PABCGVFWVSiQShnJIFprrZXGflMu23d1dYfzvZYhUoA7Kor5T1RpSxM1JoKxDgbrsihJHPH642Dc1ft9AURRXIBBkR9DqoPF/xTZugUCAx66DgD3DQ+9QXmqG2z0DBid3Q0Ypfcw29qkgX+ebEWb3JIF6DjLnfyygpLgazdZOPCiqgsezhF0yKCniOY9nGffvVqChvgk2aweWl70MzWSWpEYj0bFGMtZU15PjQ4yOfJBH2tnZgWIyIZ6RIcV9nuM2NelG4xMrKsrMEswMWk5w3rLD4TAmyeGZpRktzZ3QErQF5fx5qLRmXBdnSKU5hfy5dbR1w9Jgw+SEG8ygdGSLSCRii8Vi0mFpaRneFZ88Wqi2jtdD7MRJqGlpWrqPHtH+K0qhks/KilfGcGNGNBq1MtBBkisY7Rep91qZFqyr7XIBLpQO4/6l24inn0EsEU/6c6zOcAj+4YlgMJh0iCGB00/H0X4uG3OnzqL+ShGEZQ7CPAHxcBYtN+vJyZ/051hmSCANbMbufv/+I6vL7d7AV4jr7wnyCaJuGsdKhnC81AmR04+afrf0WVz0yBhjl8SyCjp39tbWFiY+T+FRrUVWTNYkFEZ6zSgBHBD5rzRdfYF001tsRLWcP6ci1tY0YGJ8Csxglny/4XBkzFT5WMLMpid4OfhaO0o4iKq+aVysG5WqfDFNCwWk7YPrIzpau1FnbkQ1xVIOx5glQqGQvNizM19QWV6Lrk478vPuYGH+p/4+qJ6xkCZZ27i05d0ohK2pHW2tXfj27TvoUmcyi4vCeZRPr98xiMJbxXSvprG+7qdjbGNzc5Ou5F8p7vMc29insKAYjr4B+fSYwSz5UoxP0MbGhssoCvUpcB1+v3+feI5tkE9wifuuvYx9XxvKgwgEA3afz4e1tTUpBuyVMc8+9LWxR6ORgz9f29vbvEtBgVmrq6tOClI5MEUq22i3WZQCGXMokJwFBbFyCNDo9Xp7dVlonEs7FAz7H/Af1bYHCwPiEKwAAAAASUVORK5CYII=",
AUOptions: {Name: "AU옵션",Desc: "Windows 업데이트를 다운로드하기 전에 알림 설정"},
AutoEndTasks: {Name: "작업 자동 종료",Desc: "시스템 충돌을 방지하기 위해 정지된 프로세스를 닫습니다."},
BtnHostsEdit: {Name: "호스트 편집"},
BtnPackageManager: {Name: "UWP 앱"},
BtnRestartExplorer: {Name: "탐색기 다시 시작"},
BtnStartupManager: {Name: "시작 관리자"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "언어"},
BtnSys_LoadOptimizeConfig: {Desc: "최적화 구성 파일 로드"},
BtnSys_Minimize: {Desc: "최소화"},
BtnSys_ReloadTab: {Desc: "이 탭 새로 고침"},
BtnSys_SaveImage: {Desc: "셀프 캡처 및 이미지 저장"},
BtnSys_SaveOptimizeConfigAll: {Desc: "모든 최적화 구성을 파일에 저장"},
BtnSys_SaveOptimizeConfigTab: {Desc: "이 탭의 최적화 구성만 파일에 저장"},
BtnSys_Search: {Desc: "최적화 검색"},
BtnSys_Setting: {Desc: "설정"},
BtnSys_Theme: {Desc: "테마"},
ClassicContextMenu: {Name: "클래식 상황에 맞는 메뉴"},
DiagnosticDataOff: {Name: "진단 데이터 끄기"},
DisableAADCloudSearch: {Name: "클라우드 콘텐츠 검색 AAD 끄기",대상Desc: "회사 또는 학교 계정에 대한 클라우드 콘텐츠 검색 끄기"},
DisableAdsOnLockScreen: {Name: "잠금 화면에서 광고 비활성화"},
DisableAeDebug: {Name: "AeDebug 비활성화",Desc: "디버거를 비활성화하여 오류 처리 속도를 높입니다"},
DisableAnimationEffectMaxMin: {Name: "애니메이션 효과 최대 최소 비활성화:",Desc: "창 응답 속도를 높이기 위해 창을 최대화하거나 최소화할 때 애니메이션 효과를 닫습니다"},
DisableAppendCompletion: {Name: "추가 완료 비활성화",Desc: "인라인 자동 완성 비활성화 (완료 추가 또는 자동 채우기)"},
DisableAutoDefragIdle: {Name: "유휴 자동 조각 모음 비활성화",Desc: "SSD의 작동 수명을 늘리기 위해 유휴 상태일 때 자동 조각 모음 비활성화합니다"},
DisableAutoInstallationApps: {Name: "자동 설치 앱 비활성화"},
DisableAutoplay: {Name: "자동재생 비활성화",Desc: "바이러스 감염을 방지하기 위해 드라이브에서 "},
DisableAutoSuggest: {Name: "자동 제안 비활성화",Desc: "자동 제안 비활성화 (자동 완성 드롭다운)"},
DisableAutoWindowsUpdates: {Name: "자동 Windows 업데이트 비활성화",Desc: "자동 업데이트 비활성화"},
DisableBackgroundApps: {Name: "백그라운드 앱 비활성화"},
DisableBootOptimize: {Name: "부팅 최적화 비활성화",Desc: "SSD의 작동 수명을 늘리기 위해 부팅 시 시스템 드라이브 조각 모음을 비활성화합니다"},
DisableCrashAutoReboot: {Name: "충돌 자동 재부팅 비활성화",Desc: "시스템에 블루 스크린이 발생하면 자동 재부팅을 비활성화합니다"},
DisableCustomInking: {Name: "사용자 지정 잉크 비활성화",Desc: "사용자 지정 입력 및 타이핑 사전 비활성화합니다"},
DisableDeviceSearchHistory: {Name: "로컬에서 검색 기록 끄기",Desc: "이 기기에서 로컬로 검색 기록을 끕니다"},
DisableDiagTrack: {Name: "DiagTrack 비활성화",Desc: "DiagTrack - 연결된 사용자 환경 및 원격 측정 서비스를 사용하면 응용 프로그램 내 및 연결된 사용자 환경을 지원하는 기능을 사용할 수 있습니다.`n또한 이 서비스는 피드백 및 진단에서 진단 및 사용 개인 정보 보호 옵션 설정이 활성화된 경우 진단 및 사용 정보의 이벤트 기반 수집 및 전송 (Windows 플랫폼의 환경 및 품질 개선에 사용됨)을 관리합니다."},
DisabledVBSCodeIntegrity: {Name: "비활성화된 VBS 코드 무결성",Desc: "가상화 기반 코드 무결성 보호 비활성화합니다"},
DisableErrorReporting: {Name: "오류 보고 비활성화",Desc: "시스템 성능 향상을 위해 화면 오류 보고 기능 비활성화합니다"},
DisableFrequentFolders: {Name: "자주 사용하는 폴더 비활성화"},
DisableGameBar: {Name: "Game Bar 및 게임 DVR 비활성화",Desc: "게임 DVR 기능을 사용하면 배경에서 게임 플레이를 녹화할 수 있습니다.`n게임 DVR 기능을 사용하여 게임 플레이를 녹화하고 스크린샷을 찍을 수 있는 버튼을 제공하는 Game Bar에 위치해 있습니다.`n하지만 배경에서 비디오를 녹화하면 게임 성능이 느려질 수 있습니다."},
DisableGoogleUpdateTask: {Name: "GoogleUpdateTask 비활성화"},
DisableHibernate: {Name: "최대 절전 모드 비활성화"},
DisableHybridSleep: {Name: "하이브리드 절전 비활성화"},
DisableLockScreen: {Name: "잠금 화면 비활성화"},
DisableLowDiskSpaceChecks: {Name: "디스크 공간 부족 검사 비활성화",Desc: "시스템 성능을 향상시키기 위해 디스크 I/O 하위 시스템 최적화합니다"},
Disablememorypagination: {Name: "메모리 페이지화 비활성화",Desc: "메모리 페이지화를 비활성화하고 디스크 입출력을 줄여 응용 프로그램 성능을 향상시킵니다.`n(물리적 메모리가 1GB 미만인 경우 옵션이 무시될 수 있습니다)"},
DisableMenuShowDelay: {Name: "메뉴 표시 지연 비활성화",Desc: "시스템 디스플레이의 최적화된 응답 속도"},
DisableMicrosoftEdgeUpdateTask: {Name: "MicrosoftEdgeUpdateTask 비활성화"},
DisableMSACloudSearch: {Name: "클라우드 콘텐츠 검색 MSA 끄기",Desc: "Microsoft 계정에 대한 클라우드 콘텐츠 검색 끄기"},
DisableMSDefender: {Name: "Microsoft Defender 비활성화",Desc: "1 클릭으로 Microsoft Defender를 활성화/비활성화합니다.`n컴퓨터가 자동으로 다시 시작됩니다."},
DisableOfferSuggestions: {Name: "오퍼 제안 비활성화"},
DisablePersonalizedAdsStoreApps: {Name: "PersonalizedAds StoreApp 비활성화"},
DisablePrefetchParameters: {Name: "프리페치 매개변수 비활성화",Desc: "SSD 작동 수명을 늘리기 위해 프리페치 매개변수를 비활성화합니다."},
DisablePrintSpooler: {Name: "인쇄 스풀러 비활성화"},
DisableRecentFiles: {Name: "최근 파일 비활성화"},
DisableRemoteRegAccess: {Name: "원격 등록 액세스 비활성화",Desc: "원격 컴퓨터에서 레지스트리 수정 비활성화"},
DisableScheduledDefrag: {Name: "예약된 조각 모음 비활성화"},
DisableSettingsAppSuggestions: {Name: "설정 앱 제안 비활성화"},
DisableShortcutText: {Name: "바로가기 텍스트 비활성화"},
DisableSleep: {Name: "절전 모드 비활성화"},
DisableStartMenuAppSuggestions: {Name: "시작 메뉴 앱 제안 비활성화"},
DisableSyncProviderNotifications: {Name: "동기화 공급자 알림 비활성화"},
DisableSystemRestore: {Name: "시스템 복원 비활성화"},
DisableTailoredExperiences: {Name: "맞춤형 경험 비활성화"},
DisableTipsAndSuggestions: {Name: "팁 및 제안 비활성화"},
DisableTurnOffDisplay: {Name: "디스플레이 끄기 비활성화"},
DisableVisualStudioTelemetry: {Name: "VisualStudio 원격 측정 비활성화"},
DisableWCE: {Name: "WCE 개선 비활성화",Desc: "Windows 고객 환경 개선 비활성화`n`n- 프록시: 이 작업은 Microsoft 고객 환경 개선 프로그램을 선택한 경우 자동 확인 SQM 데이터를 수집하고 업로드합니다.`n- Microsoft 호환성 평가자: 다음과 같은 경우 프로그램 원격 측정 정보를 수집합니다. Microsoft 고객 환경 개선 프로그램에 참여했습니다."},
DisableWebSearch: {Name: "웹 검색 비활성화",Desc: "작업 표시줄에서 검색을 수행할 때 온라인 검색을 비활성화하고 귀하의 계정에 대해서만 Bing의 웹 결과를 포함합니다."},
DisableWebSearchStartMenu: {Name: "WebSearch 시작 메뉴 비활성화",Desc: "시작 메뉴에서 웹 검색을 비활성화합니다."},
DisableWindowsFeedback: {Name: "Windows 피드백 비활성화"},
DisableWindowsSearch: {Name: "Windows 검색 비활성화"},
EnableDarkMode: {Name: "다크 모드 활성화"},
Explorer: {Name: "파일 탐색기"},
HideMostUsedApps: {Name: "가장 많이 사용하는 앱 숨기기",Desc: "시작 메뉴에서 `"가장 많이 사용하는 앱 표시`"를 끄세요."},
HideStartMenuAccountNotifications: {Name: "계정 관련 알림 숨기기",Desc: "시작 메뉴에서 `"계정 관련 알림 표시`"를 끄세요."},
HideStartMenuRecentlyAdded: {Name: "최근 추가된 앱 숨기기",Desc: "시작 메뉴에서 `"최근 추가된 앱 표시`"를 끄세요."},
HideStartMenuRecentlyOpened: {Name: "최근에 열어본 항목 숨기기",Desc: "시작 메뉴에서 `"시작, 점프 목록 및 파일 탐색기에 최근에 연 항목 표시`"를 끕니다."},
HideStartMenuRecommendations: {Name: "추천 숨기기",Desc: "시작 메뉴에서 `"팁, 바로가기, 새 앱 등에 대한 권장 사항 표시`"를 끕니다."},
HideWindowsSecurityNoncriticalNotifications: {Name: "WS의 중요하지 않은 알림 숨기기",Desc: "Windows 보안의 중요한 알림만 표시합니다.`n모든 알림 억제 GP 설정이 활성화된 경우 이 설정은 효과가 없습니다."},
HideWindowsSecurityNotifications: {Name: "WS 알림 숨기기",Desc: "Windows 보안에서 모든 알림을 숨깁니다."},
HostsEdit_BtnImportFromFile: {Name: "파일에서 가져오기"},
HostsEdit_BtnImportFromLink: {Desc: "링크에서 호스트로 가져오기"},
HostsEdit_BtnReload: {Name: "호스트 파일 다시 로드"},
HostsEdit_BtnResetDefault: {Name: "기본값 재설정"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "다른 이름으로 저장"},
HostsEdit_TxtSelectLink: {Name: "호스트로 블록 목록 가져오기 링크 선택:"},
IncreaseIconCache: {Name: "아이콘 캐시 늘리기",Desc: "시스템 아이콘 캐시를 늘리고 데스크톱 디스플레이 속도 향상합니다"},
IoPageLockLimit: {Name: "Io 페이지 잠금 제한",Desc: "메모리의 기본 설정을 최적화하여 시스템 성능 향상합니다"},
Link_ClearStartMenu: {Name: "시작 메뉴 지우기"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "링크 해결 LinkInfo 무시",Desc: "로밍 중에 셸 바로가기를 추적하지 안습니다"},
MouseHoverTime: {Name: "마우스 호버 시간",Desc: "작업 표시줄 창 미리 보기의 표시 속도를 높입니다"},
NoInternetOpenWith: {Name: "인터넷 OpenWith 없음",Desc: "인터넷 파일 연결 서비스 끄기"},
NoResolveSearch: {Name: "해결되지 않은 검색",Desc: "셸 바로가기를 확인할 때 검색 기반 방법을 사용하지 않습니다"},
NoResolveTrack: {Name: "해결 추적 없음",Desc: "셸 바로가기를 확인할 때 추적 기반 방법을 사용하지 않습니다.`n이 설정은 시스템이 바로가기를 해결하기 위해 NTFS 추적 기능을 사용하는 것을 방지합니다."},
NumLockonStartup: {Name: "시작 시 Num Lock"},
OpenFileExplorerThisPC: {Name: "파일 탐색기 열기"},
OptimizeNetworkTransfer: {Name: "네트워크 전송 최적화",Desc: "네트워크 설정을 최적화하여 전송 성능 향상"},
Optimizeprocessorperformance: {Name: "프로세서 성능 최적화",Desc: "프로세서 성능을 최적화하여 응용 프로그램, 게임 등을 더 원활하게 실행할 수 있습니다."},
OptimizeRefreshPolicy: {Name: "새로 고침 정책 최적화",Desc: "디스크 I/O 하위 시스템을 최적화하여 시스템 성능 향상"},
Optional: {Name: "옵션"},
PackageManager_BtnDisable: {Desc: "모든 사용자 활성화/비활성화"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "앱 패키지를 프로비저닝 해제하여 기기의 새 사용자에게 더 이상 앱이 자동으로 설치되지 않도록 합니다."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "모든 사용자로 설치한 패키지 목록을 표시합니다."},
PackageManager_Mode: {Desc: "설치 모드: 설치된 패키지 목록을 표시합니다.`n설치되지 않음 모드: 컴퓨터에 있지만 현재 사용자가 설치하지 않은 목록을 표시합니다."},
Privacy: {Name: "개인 정보 보호"},
ShowExtensions: {Name: "확장 프로그램 표시"},
ShowHidden: {Name: "숨김 표시"},
ShowHiddenSystem: {Name: "숨김 시스템 표시"},
ShowThisPC: {Name: "이 PC 표시"},
ShutdownAcceleration: {Name: "종료 가속",Desc: "종료 시 응용 프로그램 유휴 상태를 줄여 종료 프로세스 개선합니다"},
SnippingPrintScreen: {Name: "PrintScreen 스니핑"},
StartMenu: {Name: "시작 메뉴"},
System: {Name: "시스템"},
Text_Architecture: "구조",
Text_BackgroundImage: "배경 이미지",
Text_Cancel: "취소",
Text_CheckUpdate: "업데이트 확인",
Text_ClearStartMenu_Confirm: "시작 메뉴 레이아웃을 지우시겠습니까?`n(백업 파일 `"WinTune_StartMenuLayout_xxxx.json`"이 생성됩니다)",
Text_ClearStartMenu_Done: "시작 메뉴 지우기 완료!",
Text_Close: "닫기",
Text_CommandLine: "명령줄",
Text_ConnectionFailed: "서버 연결에 실패했습니다.",
Text_CurrentVersion: "현재 버전",
Text_Custom: "사용자 지정",
Text_DefaultImage: "기본 이미지",
Text_Delete: "삭제",
Text_DeprovisionPackage: "프로비저닝 패키지",
Text_DeselectAll: "모두 선택 취소",
Text_Details: "세부 사항",
Text_Disable: "비활성화",
Text_Disabled: "비활성화됨",
Text_DisableMSDefender0: "Microsoft Defender를 활성화하려면 컴퓨터를 다시 시작해야 합니다.`n이 작업을 수행하시겠습니까?",
Text_DisableMSDefender1: "Microsoft Defender를 비활성화하려면 컴퓨터를 다시 시작해야 합니다.`n이 작업을 수행하시겠습니까?",
Text_DisplayName: "표시 이름",
Text_EffectivePath: "유효 경로",
Text_Enable: "활성화",
Text_Enabled: "활성화됨",
Text_FamilyName: "성",
Text_FindRegistry: "레지스트리에서 찾기",
Text_FullName: "전체 이름",
Text_Homepage: "홈페이지",
Text_HR_Optimize: "------- 최적화 -------",
Text_HR_Tools: "-------- 도구 --------",
Text_Install: "설치",
Text_InstalledAllUsers: "모든 사용자",
Text_InstalledDate: "설치된 날짜",
Text_InstalledMode: "설치된 모드",
Text_InstalledPath: "설치된 경로",
Text_Name: "이름",
Text_NewestVersion: "최신 버전",
Text_No: "아니오",
Text_None: "없음",
Text_NotInstalledMode: "설치되지 않은 모드",
Text_NoUpdate: "사용 가능한 업데이트가 없습니다. 최신 버전을 사용하고 있습니다.",
Text_OK: "확인",
Text_OpenTarget: "대상 위치",
Text_Properties: "속성",
Text_PublisherDisplayName: "발행자",
Text_Save: "저장",
Text_SearchOnline: "온라인으로 검색",
Text_SelectAll: "모두 선택",
Text_SignatureKind: "서명 유형",
Text_Status: "상태",
Text_Target: "대상",
Text_Type: "유형",
Text_Uninstall: "설치 제거",
Text_Update: "업데이트",
Text_UpdateFailed: "업데이트하지 못했습니다. 나중에 다시 시도해 주세요.",
Text_Updating: "업데이트 중",
Text_Version: "버전",
Text_WaitDlg: "기다리세요...",
Text_WhatsNew: "새로운 소식",
Text_Yes: "예",
UninstallOneDrive: {Name: "OneDrive 제거"},
UnpinChat: {Name: "채팅"},
UnpinCopilot: {Name: "Copilot"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Edge"},
UnpinFileExplorer: {Name: "파일 탐색기"},
UnpinMail: {Name: "메일"},
UnpinNewsandInterests: {Name: "뉴스 및 관심 분야"},
UnpinSearch: {Name: "검색"},
UnpinStore: {Name: "스토어"},
UnpinTaskbar: {Name: "작업 표시줄"},
UnpinTaskView: {Name: "태스크뷰"},
UnpinWidgets: {Name: "위젯"},
VerCtrl: {Desc: "업데이트를 확인하려면 클릭하세요.",Desc1: "새로운 버전이 있습니다`n(자세한 내용을 보려면 클릭하세요)"}
},
pl: {
Name: "Polski",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6MjY6NDgrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjA0KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQzOjA0KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpmNTg2ZmE2My01YjAwLTlkNGUtODYzMC03YTMyMjIwOTJjMjQiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6ZjU4NmZhNjMtNWIwMC05ZDRlLTg2MzAtN2EzMjIyMDkyYzI0IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6ZjU4NmZhNjMtNWIwMC05ZDRlLTg2MzAtN2EzMjIyMDkyYzI0Ij4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpmNTg2ZmE2My01YjAwLTlkNGUtODYzMC03YTMyMjIwOTJjMjQiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6MjY6NDgrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+T6YLZwAAAddJREFUOMut1M1S4kAQB/D27rq4lotCQgSSYRVIuOyFO/pUetI3oLh44g04cuAtlph1gQhSSKnlCuEbQrU9EbaEWgtBDr+ayfTMvzofFUBEmOr1etDpdKDb7TpzckzzM3I5wecnvD41GAzgbQa8ExgnGWITnGNPavGFgbxIgUmCH5QcDofvB9KGbLvdxmVQl9mZQNu2Hf1+P9VqtXCJ7hz8DD87zXEeLBU0Xli2u6lJIxrPcl4ELeYsy8LPoNCcE9hsNhOfDXsjAdZoeGGNRrgm59B4eEw/PzziOvAsqIZ/pgmuSRrKAruoeBmuhcDO4UbWEmVFw7KsojOuYnLWlGMJuJVCYMpqzqSFGyqsoqTE0FTUXMUXArh3S1DfD2p/5BiWgtGVFBQVa25Jq++KAI1tBRrfGFT80ZTBVCz6w1j4IL7X4LcsRlNPLh/8dVHgeGsTxl/Jl00oCkr2KhDBa+lwsYMj1GlvSWDZ8YYLxhs7DqD/wz+1HQEMKZI0pCM0fIf42/fjvwwKvOJjIJy8+34wkzFzUaVnUPSG4drD4rrIMroYsgnO4WuZwn4wbkoMqnuBBYECBe7JkPfKoHtDx7rATn8J7DL/6iwvshPDo0DR7QeTvpD5wBevBDyxIytJBQAAAABJRU5ErkJggg==",
AUOptions: {Name: "Opcja UA",Desc: "Skonfiguruj powiadomienia przed pobraniem aktualizacji systemu Windows"},
AutoEndTasks: {Name: "Automatycznie kończ zadania",Desc: "Zamknij zablokowane procesy, aby uniknąć awarii systemu."},
BtnHostsEdit: {Name: "Edytuj hosta"},
BtnPackageManager: {Name: "Aplikacja UWP"},
BtnRestartExplorer: {Name: "Uruchom ponownie Eksploratora Windows."},
BtnStartupManager: {Name: "odpowiedzialny za rozruch"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "język"},
BtnSys_LoadOptimizeConfig: {Desc: "Załaduj plik konfiguracyjny optymalizacji"},
BtnSys_Minimize: {Desc: "minimalizacja"},
BtnSys_ReloadTab: {Desc: "Załaduj ponownie tę kartę."},
BtnSys_SaveImage: {Desc: "Automatycznie przechwytuj i zapisuj na obrazie"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Zapisz wszystkie konfiguracje optymalizacji do plików"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Zakładka ta zapisuje do pliku jedynie konfigurację optymalizacji."},
BtnSys_Search: {Desc: "Wyszukaj zoptymalizowane"},
BtnSys_Setting: {Desc: "układ"},
BtnSys_Theme: {Desc: "temat"},
ClassicContextMenu: {Name: "Klasyczne menu kontekstowe"},
DiagnosticDataOff: {Name: "Dane diagnostyczne zostały wyłączone."},
DisableAADCloudSearch: {Name: "Wyłącz wyszukiwanie zawartości w chmurze usługi AAD",Desc: "Wyłącz wykrywanie treści w chmurze na swoim koncie służbowym lub szkolnym"},
DisableAdsOnLockScreen: {Name: "Wyłącz reklamy na ekranie blokady"},
DisableAeDebug: {Name: "Wyłącz AEDebug",Desc: "Przyspiesz obsługę błędów poprzez wyłączenie debugera."},
DisableAnimationEffectMaxMin: {Name: "Wyłącz maksymalne minimalne efekty animacji",Desc: "Przyspiesza reakcję okna, zamykając efekty animacji, gdy okno jest maksymalizowane lub minimalizowane."},
DisableAppendCompletion: {Name: "Wyłącz dodatkowe uzupełnienia.",Desc: "Wyłącz wbudowane autouzupełnianie (dodaj uzupełnienie lub autouzupełnianie)"},
DisableAutoDefragIdle: {Name: "Wyłącz automatyczną defragmentację w czasie bezczynności",Desc: "Wydłuż żywotność dysku SSD, wyłączając automatyczną defragmentację w czasie bezczynności."},
DisableAutoInstallationApps: {Name: "Wyłącz automatyczne instalowanie aplikacji"},
DisableAutoplay: {Name: "Wyłącz autoodtwarzanie",Desc: "Aby zapobiec infekcji wirusowej, wyłącz funkcję `"autoodtwarzania`" dysku."},
DisableAutoSuggest: {Name: "Wyłącz automatyczne sugestie",Desc: "Wyłącz automatyczną sugestię (automatyczne uzupełnianie listy rozwijanej)"},
DisableAutoWindowsUpdates: {Name: "Wyłącz automatyczne aktualizacje systemu Windows",Desc: "Wyłącz automatyczne aktualizacje"},
DisableBackgroundApps: {Name: "Wyłącz aplikacje działające w tle"},
DisableBootOptimize: {Name: "Wyłącz optymalizację rozruchu",Desc: "Aby przedłużyć żywotność dysku SSD, wyłącz dyski defragmentacyjne systemu podczas uruchamiania."},
DisableCrashAutoReboot: {Name: "Wyłącz automatyczne ponowne uruchamianie w przypadku awarii",Desc: "Wyłącz automatyczne ponowne uruchamianie, gdy system napotka niebieski ekran."},
DisableCustomInking: {Name: "Wyłącz niestandardowe rysowanie odręczne",Desc: "Wyłącz niestandardowe słowniki pisma odręcznego i wprowadzania"},
DisableDeviceSearchHistory: {Name: "Wyłącz lokalną historię wyszukiwania",Desc: "Wyłącz lokalną historię przeglądania na tych urządzeniach"},
DisableDiagTrack: {Name: "Wyłącz DiagTrack",Desc: "DiagTrack: usługa Connected User Experience and Telemetry Service umożliwia korzystanie z funkcji obsługujących łączność użytkowników w aplikacji. `n Ta usługa zarządza również gromadzeniem i przesyłaniem informacji diagnostycznych i informacji o użytkowaniu na podstawie zdarzeń (wykorzystywanych do poprawy komfortu i jakości). (Na platformach Windows) ustawienie Opcje prywatności diagnostyki i użytkowania jest dostępne w obszarze Opinia i diagnostyka."},
DisabledVBSCodeIntegrity: {Name: "Integralność kodu VBS jest wyłączona.",Desc: "Wyłącz ochronę integralności kodu opartą na wirtualizacji"},
DisableErrorReporting: {Name: "Wyłącz raportowanie błędów",Desc: "Wyłącz raportowanie błędów na ekranie, aby poprawić wydajność systemu."},
DisableFrequentFolders: {Name: "Wyłącz często używane foldery"},
DisableGameBar: {Name: "Wyłącz pasek gier i rejestrator gier",Desc: "Funkcja Game DVR umożliwia nagrywanie rozgrywki w tle. `nTa funkcja znajduje się na pasku gry i wyświetla przyciski umożliwiające nagrywanie rozgrywki i robienie zrzutów ekranu za pomocą funkcji Game DVR. `n Może jednak działać wolniej. Popraw wydajność gier, nagrywając wideo w tle."},
DisableGoogleUpdateTask: {Name: "Wyłącz zadanie GoogleUpdate"},
DisableHibernate: {Name: "Wyłącz hibernację"},
DisableHybridSleep: {Name: "Bez zawieszenia hybrydowego"},
DisableLockScreen: {Name: "Wyłącz ekran blokady"},
DisableLowDiskSpaceChecks: {Name: "Wyłącz sprawdzanie małej ilości miejsca na dysku",Desc: "Popraw wydajność systemu poprzez optymalizację podsystemu we/wy dysku"},
Disablememorypagination: {Name: "Wyłącz stronicowanie pamięci",Desc: "Wyłącz stronicowanie pamięci, aby zmniejszyć liczbę operacji we/wy dysku i poprawić wydajność aplikacji. `n (opcję można zignorować, jeśli pamięć fizyczna jest mniejsza niż 1 GB)"},
DisableMenuShowDelay: {Name: "Wyłącz opóźnione wyświetlanie menu",Desc: "Zoptymalizuj czas reakcji wyświetlacza systemu"},
DisableMicrosoftEdgeUpdateTask: {Name: "Wyłącz zadanie MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Wyłącz wyszukiwanie treści w chmurze MSA",Desc: "Wyłącz wykrywanie zawartości w chmurze dla swojego konta Microsoft"},
DisableMSDefender: {Name: "Wyłącz usługę Microsoft Defender",Desc: "1 Kliknij, aby włączyć lub wyłączyć usługę Microsoft Defender. `nTwój komputer zostanie automatycznie uruchomiony ponownie."},
DisableOfferSuggestions: {Name: "Wyłącz oferty kuponów"},
DisablePersonalizedAdsStoreApps: {Name: "Rezygnacja ze spersonalizowanych aplikacji sklepu z reklamami"},
DisablePrefetchParameters: {Name: "Nie używaj parametrów wstępnego ładowania",Desc: "Wydłuż żywotność dysku SSD, wyłączając parametry wstępnego ładowania."},
DisablePrintSpooler: {Name: "Wyłącz bufor wydruku"},
DisableRecentFiles: {Name: "Wyłącz ostatnio używane pliki"},
DisableRemoteRegAccess: {Name: "Wyłącz zdalny dostęp do rejestru",Desc: "Wyłącz edycję rejestru na komputerach zdalnych"},
DisableScheduledDefrag: {Name: "Wyłącz zaplanowaną defragmentację"},
DisableSettingsAppSuggestions: {Name: "Wyłącz sugestie aplikacji ustawień"},
DisableShortcutText: {Name: "Wyłącz tekst skrótu"},
DisableSleep: {Name: "Wyłącz sen"},
DisableStartMenuAppSuggestions: {Name: "Wyłącz sugestie aplikacji w menu Start"},
DisableSyncProviderNotifications: {Name: "Wyłącz powiadomienia dostawcy synchronizacji"},
DisableSystemRestore: {Name: "Wyłącz przywracanie systemu"},
DisableTailoredExperiences: {Name: "Wyłącz spersonalizowane doświadczenia"},
DisableTipsAndSuggestions: {Name: "Podpowiedzi i wyłączanie podpowiedzi"},
DisableTurnOffDisplay: {Name: "Wyłącz Wyłącz wyświetlacz"},
DisableVisualStudioTelemetry: {Name: "Wyłącz telemetrię VisualStudio"},
DisableWCE: {Name: "Wyłącz rozszerzenia WCE",Desc: "Wyłącz poprawę jakości obsługi klienta systemu Windows`n`n- Serwer proxy: To zadanie automatycznie sprawdza, czy zostałeś wybrany do Programu poprawy jakości obsługi klienta firmy Microsoft w celu gromadzenia i ładowania danych SQM. `n- Microsoft Compatibility Appraiser: Gromadzi programy informacyjne. Telemetria, jeśli zdecydujesz się przystąpić do Programu poprawy jakości obsługi klienta firmy Microsoft."},
DisableWebSearch: {Name: "Wyłącz przeglądanie stron internetowych",Desc: "Wyłącz wyszukiwanie online i podczas wyszukiwania na pasku zadań uwzględniaj tylko wyniki internetowe Bing ze swojego konta"},
DisableWebSearchStartMenu: {Name: "Wyłącz menu startowe WebSearch",Desc: "Wyłącz wyszukiwanie internetowe w menu Start"},
DisableWindowsFeedback: {Name: "Wyłącz komentarze systemu Windows"},
DisableWindowsSearch: {Name: "Wyłącz wyszukiwanie systemu Windows"},
EnableDarkMode: {Name: "Użyj trybu ciemnego"},
Explorer: {Name: "Przeglądarka plików"},
HideMostUsedApps: {Name: "Ukryj często używane aplikacje",Desc: "Odznacz opcję `"Pokaż często używane aplikacje`"] w menu Start."},
HideStartMenuAccountNotifications: {Name: "Ukryj powiadomienia dotyczące konta",Desc: "Odznacz opcję Pokaż powiadomienia konta {\} w menu Start."},
HideStartMenuRecentlyAdded: {Name: "Ukryj ostatnio dodane aplikacje",Desc: "W menu Start odznacz [`" Pokaż ostatnio dodane aplikacje `"]."},
HideStartMenuRecentlyOpened: {Name: "Ukryj ostatnio otwarte elementy",Desc: "W menu Start odznacz opcję {\}Pokaż ostatnio otwierane elementy w menu Start, Listach szybkiego dostępu i Eksploratorze plików{\}."},
HideStartMenuRecommendations: {Name: "Ukryj wskazówki",Desc: "Wyłącz opcję {\}, aby wyświetlać w menu Start sugestie, takie jak [{\} wskazówki, skróty, nowe aplikacje i inne."},
HideWindowsSecurityNoncriticalNotifications: {Name: "Ukryj nieistotne powiadomienia WS",Desc: "Zabezpieczenia Windows wyświetlają tylko ważne powiadomienia. `nTo ustawienie nie ma żadnego efektu, jeśli włączone jest ustawienie [Pomiń wszystkie powiadomienia GP]."},
HideWindowsSecurityNotifications: {Name: "Ukryj powiadomienia WS",Desc: "Ukrywa wszystkie powiadomienia z Zabezpieczeń Windows."},
HostsEdit_BtnImportFromFile: {Name: "Importuj z pliku"},
HostsEdit_BtnImportFromLink: {Desc: "Importuj z łącza do hosta"},
HostsEdit_BtnReload: {Name: "Załaduj ponownie plik hosts."},
HostsEdit_BtnResetDefault: {Name: "Przywróć domyślne"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Zapisz jako"},
HostsEdit_TxtSelectLink: {Name: "Wybierz link, aby zaimportować czarną listę do swojego hosta."},
IncreaseIconCache: {Name: "Zwiększ pamięć podręczną ikon",Desc: "Zwiększa pamięć podręczną ikon systemowych i przyspiesza wyświetlanie pulpitu."},
IoPageLockLimit: {Name: "Limit bloków stron Io",Desc: "Popraw wydajność systemu, optymalizując domyślne ustawienia pamięci"},
Link_ClearStartMenu: {Name: "Wyczyść menu Start"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Napraw łącze ignorujące LinkInfo",Desc: "Nie śledź połączeń powłoki podczas roamingu"},
MouseHoverTime: {Name: "czas zawisu",Desc: "Przyspiesza wyświetlanie podglądów w oknach paska zadań."},
NoInternetOpenWith: {Name: "brak internetu",Desc: "Wyłącz usługę łączenia plików internetowych"},
NoResolveSearch: {Name: "Twoje wyszukiwanie nie zostało rozwiązane.",Desc: "Unikaj używania metod opartych na wyszukiwaniu podczas rozwiązywania łączy powłoki."},
NoResolveTrack: {Name: "Żadnego znaku rozwiązania",Desc: "Unikaj stosowania metod opartych na śledzeniu podczas rozwiązywania łączy powłoki. `n To ustawienie uniemożliwia systemowi rozpoznawanie łączy przy użyciu funkcji śledzenia NTFS."},
NumLockonStartup: {Name: "Zablokuj Num przy uruchomieniu"},
OpenFileExplorerThisPC: {Name: "Otwórz Eksploratora na tym komputerze"},
OptimizeNetworkTransfer: {Name: "Optymalizacja transmisji sieciowej",Desc: "Popraw wydajność transferu, optymalizując ustawienia sieciowe"},
Optimizeprocessorperformance: {Name: "Zoptymalizuj wydajność procesora",Desc: "Zoptymalizuj wydajność procesora, aby uruchamiać aplikacje, gry i nie tylko. Bardziej delikatnie."},
OptimizeRefreshPolicy: {Name: "Zaktualizuj optymalizację zasad",Desc: "Popraw wydajność systemu poprzez optymalizację podsystemu we/wy dysku"},
Optional: {Name: "opcja"},
PackageManager_BtnDisable: {Desc: "Włącz/wyłącz dla wszystkich użytkowników"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Jeśli wyrejestrujesz pakiet aplikacji, nie zostanie ona automatycznie zainstalowana dla nowych użytkowników na urządzeniu."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Wyświetla listę pakietów zainstalowanych przez wszystkich użytkowników."},
PackageManager_Mode: {Desc: "Tryb instalacji: Wyświetla listę zainstalowanych pakietów. `nTryb niezainstalowany: wyświetla listę pakietów, które istnieją na komputerze, ale nie zostały zainstalowane przez bieżącego użytkownika."},
Privacy: {Name: "Prywatność"},
ShowExtensions: {Name: "Pokaż rozszerzenia"},
ShowHidden: {Name: "Hide Show"},
ShowHiddenSystem: {Name: "Pokaż ukryte systemy"},
ShowThisPC: {Name: "pokaż mi ten komputer"},
ShutdownAcceleration: {Name: "Przyspieszone wyłączanie",Desc: "Zmniejsza bezczynność aplikacji po zamknięciu i usprawnia proces zamykania."},
SnippingPrintScreen: {Name: "wydrukuj zrzut ekranu"},
StartMenu: {Name: "menu startowe"},
System: {Name: "system"},
Text_Architecture: "Architektura",
Text_BackgroundImage: "Zdjęcie w tle",
Text_Cancel: "Anulować",
Text_CheckUpdate: "Sprawdź aktualizację",
Text_ClearStartMenu_Confirm: "Czy na pewno chcesz wyczyścić układ menu Start?`n(Zostanie utworzony plik kopii zapasowej `"WinTune_StartMenuLayout_xxxx.json`")",
Text_ClearStartMenu_Done: "Wyczyść menu Start Gotowe!",
Text_Close: "Zamknąć",
Text_CommandLine: "Wiersz poleceń",
Text_ConnectionFailed: "Połączenie z serwerem nie powiodło się.",
Text_CurrentVersion: "Obecna wersja",
Text_Custom: "Zwyczaj",
Text_DefaultImage: "Domyślny obraz",
Text_Delete: "Usuwać",
Text_DeprovisionPackage: "Pakiet wyrejestrowania",
Text_DeselectAll: "Odznacz wszystkie",
Text_Details: "Detale",
Text_Disable: "Wyłączyć",
Text_Disabled: "Wyłączony",
Text_DisableMSDefender0: "Włączenie usługi Microsoft Defender wymaga ponownego uruchomienia komputera.`nCzy na pewno chcesz to zrobić?",
Text_DisableMSDefender1: "Wyłączenie usługi Microsoft Defender wymaga ponownego uruchomienia komputera.`nCzy na pewno chcesz to zrobić?",
Text_DisplayName: "Wyświetlana nazwa",
Text_EffectivePath: "Skuteczna ścieżka",
Text_Enable: "Włączać",
Text_Enabled: "Włączony",
Text_FamilyName: "Nazwisko rodowe",
Text_FindRegistry: "Znajdź w rejestrze",
Text_FullName: "Pełne imię i nazwisko",
Text_Homepage: "Strona główna",
Text_HR_Optimize: "------- Optymalizować -------",
Text_HR_Tools: "-------- Narzędzia --------",
Text_Install: "zainstalować",
Text_InstalledAllUsers: "Wszyscy użytkownicy",
Text_InstalledDate: "Data zainstalowania",
Text_InstalledMode: "Tryb zainstalowany",
Text_InstalledPath: "Zainstalowana ścieżka",
Text_Name: "Nazwa",
Text_NewestVersion: "Najnowsza wersja",
Text_No: "NIE",
Text_None: "Nic",
Text_NotInstalledMode: "Tryb niezainstalowany",
Text_NoUpdate: "Żadna aktualizacja nie jest dostępna. Używasz najnowszej wersji.",
Text_OK: "OK",
Text_OpenTarget: "Docelowa lokalizacja",
Text_Properties: "Nieruchomości",
Text_PublisherDisplayName: "Wydawca",
Text_Save: "Ratować",
Text_SearchOnline: "Szukaj w internecie",
Text_SelectAll: "Zaznacz wszystko",
Text_SignatureKind: "Rodzaj podpisu",
Text_Status: "Status",
Text_Target: "Cel",
Text_Type: "Typ",
Text_Uninstall: "Odinstaluj",
Text_Update: "Aktualizacja",
Text_UpdateFailed: "Aktualizacja nie powiodła się. Spróbuj ponownie później.",
Text_Updating: "Aktualizowanie",
Text_Version: "Wersja",
Text_WaitDlg: "Proszę czekać...",
Text_WhatsNew: "Co nowego",
Text_Yes: "Tak",
UninstallOneDrive: {Name: "Odinstaluj OneDrive"},
UnpinChat: {Name: "rozmawiać"},
UnpinCopilot: {Name: "drugi pilot"},
UnpinCortana: {Name: "kortana"},
UnpinEdge: {Name: "klakson"},
UnpinFileExplorer: {Name: "Przeglądarka plików"},
UnpinMail: {Name: "post"},
UnpinNewsandInterests: {Name: "nowości i zainteresowanie"},
UnpinSearch: {Name: "badania"},
UnpinStore: {Name: "sklep"},
UnpinTaskbar: {Name: "pasek zadań"},
UnpinTaskView: {Name: "Zobacz zadania"},
UnpinWidgets: {Name: "widżet"},
VerCtrl: {Desc: "Kliknij, aby sprawdzić dostępność aktualizacji.",Desc1: "Dostępna jest nowa wersja `n (kliknij, aby uzyskać szczegółowe informacje)"}
},
pt: {
Name: "Português",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6NTU6MzUrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjU3KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjU3KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5M2E3ZDU3YS03ZGE4LTY1NGQtOWYxMy0yOTc1NTc3ZTQ2ZDkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OTNhN2Q1N2EtN2RhOC02NTRkLTlmMTMtMjk3NTU3N2U0NmQ5IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6OTNhN2Q1N2EtN2RhOC02NTRkLTlmMTMtMjk3NTU3N2U0NmQ5Ij4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo5M2E3ZDU3YS03ZGE4LTY1NGQtOWYxMy0yOTc1NTc3ZTQ2ZDkiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6NTU6MzUrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+XA4apAAAA2JJREFUOBEFwV+on3UdAODn877f35+zs9925rKF0mA20SAUCluEZbi1WTaGTQJvIiSFzemNjcD+XRqCFzKmCF0UCEaiFM5q2EoxRlK4P3mxi2y2kWOpO/OcHc/OeX/v99PzFAAY7RkZ3zBWsvhwdtXP/zbY+cNj020muRlwHm+q9SiIoO9ZXgZQAAAkVf2y1sHadd9CAQD0Io7gCRwHACgAoCOHeWh6dXpAoAIJALQi9mAPDkfmAQAoPgVoKZvKH6VdEkkGkAAAABEPKWVrcBdAaXe1JKO50dODmcGu/uPe4mLQcmUeiEVMEACATFnKLmvWPB0rK/tFKOO1Y9HGrWXQ7ltZSMsLvZ23r7pua2PH58h/kv+uvDxkZsAwSUAEtcrBYJ+meTZqPVWyy2g0T3ZZLc/3nvrOxOcnE7984yObPoETqT4wxx0L/GCJaGgBAAiexI7SRrsjGtuX3uNHD3Ye2bneR98Lv/jtRg7PmL69JF8t4lcbWJrnZ2PWIQGQKSO2a9uvlxjF15a7NLuR734l+PsF61/aysJbfvePd+35cLP+s7epXz3Lt4MteA9DAAAi845S+3p9t8SdtzB/Ib38dnX3T0ZefGPeyXPV1cVL7n1kxCspb05uTM5iAABA8ukikawpnLsSfv/Xxu63etNtY8a91TqUz1V5DbmSBAAAAFCE/5aZdPo8X7zA0icnrozOuG/LH7y48R57hy9Y2XBG/ek6zixxIhkgAYCAiPOlv9q/Nh42j73zTipfGnj2x5f9+vYNvr/3fnsvPeXja0/z+By3vc+RIf/DWiQAMmWErPX1koP8U615bLzJ9oO/SePS+8wNlz103zr7Lp1y039mrV7+gMd6Hm8ZowIAkJnHotZXS11bs2Z9dLBSTraz6eHnGnd/obfhpovOXVPdfHFRPTTkzw1t0iABABHavn80MpXVhVXSqWzymdFs2deX6pWTwdmha//CN/9FhVESqADIpGlk1z1Tu+4UFC8A3bjb705bmrnmrtEkraxnZg6oI0ACAIl2Oj066br9CSjmAZhenH5jMBkcysgDKhLICgAkQMThmE4PtAAoABBtsOrhrPm83sGadqPtEwD0kXkkeKJpmuMiyARQAECgwdRxfd7T1dxJbMu0GXBe5pvB0YgAAAD/B1FLe6pMXO6PAAAAAElFTkSuQmCC",
AUOptions: {Name: "Opção AU",Desc: "Configure notificações antes de baixar atualizações do Windows"},
AutoEndTasks: {Name: "Encerramento automático de tarefas",Desc: "Feche processos travados para evitar falhas no sistema."},
BtnHostsEdit: {Name: "Editar anfitrião"},
BtnPackageManager: {Name: "Aplicativo UWP"},
BtnRestartExplorer: {Name: "Reinicie o Explorador"},
BtnStartupManager: {Name: "Gerente de startup"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "linguagem"},
BtnSys_LoadOptimizeConfig: {Desc: "Carregar arquivo de configuração de otimização"},
BtnSys_Minimize: {Desc: "minimização"},
BtnSys_ReloadTab: {Desc: "Atualize esta guia"},
BtnSys_SaveImage: {Desc: "Capturar automaticamente e salvar na imagem"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Salve todas as configurações de otimização em arquivos"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Salve apenas esta guia de configuração de otimização em um arquivo"},
BtnSys_Search: {Desc: "Procure otimizar"},
BtnSys_Setting: {Desc: "ambiente"},
BtnSys_Theme: {Desc: "assunto"},
ClassicContextMenu: {Name: "Menu de contexto clássico"},
DiagnosticDataOff: {Name: "Desative os dados de diagnóstico"},
DisableAADCloudSearch: {Name: "Descoberta de conteúdo na nuvem Desligue o AAD",Desc: "Desative a pesquisa de conteúdo na nuvem para sua conta corporativa ou escolar"},
DisableAdsOnLockScreen: {Name: "Desative anúncios na tela de bloqueio"},
DisableAeDebug: {Name: "Desativar AeDebug",Desc: "Desative o depurador para acelerar o tratamento de erros."},
DisableAnimationEffectMaxMin: {Name: "Desativar efeitos de animação Max Min",Desc: "Feche os efeitos de animação quando as janelas estiverem maximizadas ou minimizadas para torná-las mais responsivas."},
DisableAppendCompletion: {Name: "Desativar conclusão de adição",Desc: "Desativar o preenchimento automático in-line (anexar conclusão ou preenchimento automático)"},
DisableAutoDefragIdle: {Name: "Desativar a desfragmentação automática ociosa",Desc: "Desative a desfragmentação automática quando estiver ocioso para aumentar a vida útil do seu SSD."},
DisableAutoInstallationApps: {Name: "Desative a instalação automática de aplicativos"},
DisableAutoplay: {Name: "Desativar reprodução automática",Desc: "Para evitar infecção por vírus, desative o recurso `"Reprodução automática`" em sua unidade."},
DisableAutoSuggest: {Name: "Desativar sugestão automática",Desc: "Desativar sugestão automática (menu suspenso de preenchimento automático)"},
DisableAutoWindowsUpdates: {Name: "Desative as atualizações automáticas do Windows",Desc: "Desative atualizações automáticas"},
DisableBackgroundApps: {Name: "Desative aplicativos em segundo plano"},
DisableBootOptimize: {Name: "Desativar otimização de inicialização",Desc: "Aumente a vida útil do seu SSD desativando a desfragmentação da unidade do sistema na inicialização."},
DisableCrashAutoReboot: {Name: "Desativar reinicialização automática de falha",Desc: "Desative a reinicialização automática quando o sistema encontrar uma tela azul."},
DisableCustomInking: {Name: "Desativar desenho à mão livre personalizado",Desc: "Desativar tinta personalizada e dicionários de entrada"},
DisableDeviceSearchHistory: {Name: "Desative o histórico de pesquisa localmente",Desc: "Desative o histórico de navegação localmente neste dispositivo."},
DisableDiagTrack: {Name: "Desativar DiagTrack",Desc: "DiagTrack - Connected User Experience and Telemetry Service permite recursos que oferecem suporte a experiências de usuário conectadas e no aplicativo.`nO serviço também gerencia a coleta e transmissão baseada em eventos de informações de diagnóstico e uso (experiência do usuário e qualidade usada para melhorar). (Plataformas Windows) quando a configuração de opções de privacidade de Diagnóstico e Uso está habilitada em Feedback e Diagnóstico."},
DisabledVBSCodeIntegrity: {Name: "Integridade do código VBS desativada",Desc: "Desative a proteção da integridade do código baseada em virtualização"},
DisableErrorReporting: {Name: "Desativar relatório de erros",Desc: "Para melhorar o desempenho do sistema, desative o relatório de erros de tela."},
DisableFrequentFolders: {Name: "Desative pastas frequentes"},
DisableGameBar: {Name: "Desativar barra de jogos e DVR de jogos",Desc: "O recurso Game DVR permite gravar o jogo em segundo plano.`nEsse recurso está localizado na Barra de Jogo. Este recurso fornece botões para gravar o jogo e fazer capturas de tela usando o recurso Game DVR.`nNo entanto, isso pode tornar o jogo mais lento. Melhore o desempenho dos jogos gravando vídeo em segundo plano."},
DisableGoogleUpdateTask: {Name: "Desativar GoogleUpdateTask"},
DisableHibernate: {Name: "Desativar hibernação"},
DisableHybridSleep: {Name: "Desativar suspensão híbrida"},
DisableLockScreen: {Name: "Desativar tela de bloqueio"},
DisableLowDiskSpaceChecks: {Name: "Desative a verificação de pouco espaço em disco",Desc: "Melhore o desempenho do sistema otimizando o subsistema de E/S de disco"},
Disablememorypagination: {Name: "Desativar paginação de memória",Desc: "Melhora o desempenho do aplicativo desativando a paginação de memória e reduzindo a E/S do disco.`n(A opção pode ser ignorada se a memória física for inferior a 1 GB)"},
DisableMenuShowDelay: {Name: "Desativar atraso de exibição do menu",Desc: "Velocidade de resposta otimizada da exibição do sistema"},
DisableMicrosoftEdgeUpdateTask: {Name: "Desabilitar MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Desative o MSA do Cloud Content Discovery",Desc: "Desative a descoberta de conteúdo na nuvem para sua conta da Microsoft"},
DisableMSDefender: {Name: "Desative o Microsoft Defender",Desc: "Ative/desative o Microsoft Defender com um clique.`nSeu computador será reiniciado automaticamente."},
DisableOfferSuggestions: {Name: "Desativar sugestões de sugestões"},
DisablePersonalizedAdsStoreApps: {Name: "Desativar CustomizedAds StoreApp"},
DisablePrefetchParameters: {Name: "Desativar parâmetros de pré-busca",Desc: "Desative o parâmetro de pré-busca para aumentar a vida útil operacional do SSD."},
DisablePrintSpooler: {Name: "Desativar spooler de impressão"},
DisableRecentFiles: {Name: "Desabilitar arquivos recentes"},
DisableRemoteRegAccess: {Name: "Desabilitar o acesso remoto ao registro",Desc: "Desative modificações de registro em computadores remotos"},
DisableScheduledDefrag: {Name: "Desativar a desfragmentação programada"},
DisableSettingsAppSuggestions: {Name: "Desativar sugestões de aplicativos de configurações"},
DisableShortcutText: {Name: "Desativar texto de atalho"},
DisableSleep: {Name: "Desativar modo de suspensão"},
DisableStartMenuAppSuggestions: {Name: "Desativar sugestões de aplicativos do menu Iniciar"},
DisableSyncProviderNotifications: {Name: "Desativar notificações do provedor de sincronização"},
DisableSystemRestore: {Name: "Desativar restauração do sistema"},
DisableTailoredExperiences: {Name: "Desative experiências personalizadas"},
DisableTipsAndSuggestions: {Name: "Desative dicas e sugestões"},
DisableTurnOffDisplay: {Name: "Desativar exibição"},
DisableVisualStudioTelemetry: {Name: "Desabilitar a telemetria do VisualStudio"},
DisableWCE: {Name: "Desativar melhorias do WCE",Desc: "Desativar o Windows Customer Experience Improvement`n`n- Proxy: esta tarefa coleta e carrega dados SQM de verificação automática se você tiver selecionado o Programa Microsoft Customer Experience Improvement.`n- Microsoft Compatibility Evaluator: o programa coleta informações de telemetria. Participou do Programa de Melhoria da Experiência do Cliente da Microsoft."},
DisableWebSearch: {Name: "Desativar navegação na web",Desc: "Desativa pesquisas online quando você realiza uma pesquisa na barra de tarefas e inclui resultados da web do Bing apenas para sua conta."},
DisableWebSearchStartMenu: {Name: "Desativar menu Iniciar do WebSearch",Desc: "Desative a navegação na web no menu Iniciar."},
DisableWindowsFeedback: {Name: "Desativar comentários do Windows"},
DisableWindowsSearch: {Name: "Desative a Pesquisa do Windows"},
EnableDarkMode: {Name: "Ative o modo escuro"},
Explorer: {Name: "Explorador de arquivos"},
HideMostUsedApps: {Name: "Oculte seus aplicativos mais usados",Desc: "Desative `"Mostrar aplicativos mais usados`" no menu Iniciar."},
HideStartMenuAccountNotifications: {Name: "Ocultar notificações relacionadas à conta",Desc: "Desative `"Mostrar notificações relacionadas à conta`" no menu Iniciar."},
HideStartMenuRecentlyAdded: {Name: "Ocultar aplicativos adicionados recentemente",Desc: "Desative `"Mostrar aplicativos adicionados recentemente`" no menu Iniciar."},
HideStartMenuRecentlyOpened: {Name: "Ocultar itens visualizados recentemente",Desc: "No menu Iniciar, desative `"Mostrar itens abertos recentemente em Iniciar, Listas de Atalhos e Explorador de Arquivos`"."},
HideStartMenuRecommendations: {Name: "Ocultar recomendações",Desc: "Desative Mostrar recomendações de dicas, atalhos, novos aplicativos, etc. no menu Iniciar."},
HideWindowsSecurityNoncriticalNotifications: {Name: "Ocultar notificações sem importância do WS",Desc: "Mostrar apenas notificações importantes da Segurança do Windows.`nEssa configuração não terá efeito se a configuração GP Suprimir todas as notificações estiver ativada."},
HideWindowsSecurityNotifications: {Name: "Ocultar notificações do WS",Desc: "Oculta todas as notificações da Segurança do Windows."},
HostsEdit_BtnImportFromFile: {Name: "Importar do arquivo"},
HostsEdit_BtnImportFromLink: {Desc: "Importar do link para o host"},
HostsEdit_BtnReload: {Name: "Recarregar arquivo hosts"},
HostsEdit_BtnResetDefault: {Name: "Restaurar padrões"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Salvar como"},
HostsEdit_TxtSelectLink: {Name: "Selecione o link para importar a lista de bloqueios para o seu host."},
IncreaseIconCache: {Name: "Aumentar o cache de ícones",Desc: "Aumente o cache de ícones do sistema e acelere a exibição na área de trabalho."},
IoPageLockLimit: {Name: "Limite de bloqueio de página Io",Desc: "Otimiza as configurações padrão de memória para melhorar o desempenho do sistema."},
Link_ClearStartMenu: {Name: "Limpar menu Iniciar"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Resolução do link LinkInfo ignorado",Desc: "Evite rastrear atalhos de shell em roaming."},
MouseHoverTime: {Name: "tempo de passar o mouse",Desc: "Acelera a exibição de visualizações de janelas da barra de tarefas."},
NoInternetOpenWith: {Name: "Sem Internet aberta com",Desc: "Desative o serviço de conexão de arquivos da Internet"},
NoResolveSearch: {Name: "pesquisa não resolvida",Desc: "Evite usar métodos baseados em pesquisa ao resolver atalhos de shell."},
NoResolveTrack: {Name: "Sem faixa de resolução",Desc: "Não use métodos baseados em rastreamento ao resolver atalhos de shell.`nEssa configuração impede que o sistema use o recurso de rastreamento NTFS para resolver atalhos."},
NumLockonStartup: {Name: "Num Lock na inicialização"},
OpenFileExplorerThisPC: {Name: "Abra o Explorador de Arquivos"},
OptimizeNetworkTransfer: {Name: "Otimização de transmissão de rede",Desc: "Melhore o desempenho de transferência otimizando as configurações de rede"},
Optimizeprocessorperformance: {Name: "Otimize o desempenho do processador",Desc: "Otimize o desempenho do processador para ajudar aplicativos, jogos e muito mais a funcionar com mais fluidez."},
OptimizeRefreshPolicy: {Name: "Otimizar política de atualização",Desc: "Melhore o desempenho do sistema otimizando o subsistema de E/S de disco"},
Optional: {Name: "opcional"},
PackageManager_BtnDisable: {Desc: "Habilitar/Desabilitar para todos os usuários"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Desprovisione o pacote do aplicativo para que novos usuários do dispositivo não instalem mais o aplicativo automaticamente."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Exibe uma lista de pacotes instalados por todos os usuários."},
PackageManager_Mode: {Desc: "Modo instalado: exibe uma lista de pacotes instalados.`nModo não instalado: exibe uma lista de pacotes que existem no computador, mas que não foram instalados pelo usuário atual."},
Privacy: {Name: "isolamento"},
ShowExtensions: {Name: "Mostrar extensões"},
ShowHidden: {Name: "sinal escondido"},
ShowHiddenSystem: {Name: "Mostrar sistemas ocultos"},
ShowThisPC: {Name: "me mostre esse pc"},
ShutdownAcceleration: {Name: "aceleração de saída",Desc: "Reduza a ociosidade do aplicativo no desligamento para melhorar o processo de desligamento."},
SnippingPrintScreen: {Name: "Detecção de PrintScreen"},
StartMenu: {Name: "menu Iniciar"},
System: {Name: "sistema"},
Text_Architecture: "Arquitetura",
Text_BackgroundImage: "Imagem de fundo",
Text_Cancel: "Cancelar",
Text_CheckUpdate: "Checar atualização",
Text_ClearStartMenu_Confirm: "Tem certeza de que deseja limpar o layout do menu Iniciar?`n(Um arquivo de backup `"WinTune_StartMenuLayout_xxxx.json`" será criado)",
Text_ClearStartMenu_Done: "Limpar StartMenu Concluído!",
Text_Close: "Fechar",
Text_CommandLine: "Linha de comando",
Text_ConnectionFailed: "A conexão com o servidor falhou.",
Text_CurrentVersion: "Versão Atual",
Text_Custom: "Personalizado",
Text_DefaultImage: "Imagem padrão",
Text_Delete: "Excluir",
Text_DeprovisionPackage: "Pacote de desprovisionamento",
Text_DeselectAll: "Desmarcar todos",
Text_Details: "Detalhes",
Text_Disable: "Desativar",
Text_Disabled: "Desabilitado",
Text_DisableMSDefender0: "A ativação do Microsoft Defender requer a reinicialização do computador.`nTem certeza de que deseja fazer isso?",
Text_DisableMSDefender1: "A desativação do Microsoft Defender requer a reinicialização do computador.`nTem certeza de que deseja fazer isso?",
Text_DisplayName: "Nome de exibição",
Text_EffectivePath: "Caminho eficaz",
Text_Enable: "Habilitar",
Text_Enabled: "Habilitado",
Text_FamilyName: "Nome de família",
Text_FindRegistry: "Encontrar no registro",
Text_FullName: "Nome completo",
Text_Homepage: "Pagina inicial",
Text_HR_Optimize: "------- Otimizar -------",
Text_HR_Tools: "-------- Ferramentas --------",
Text_Install: "Instalar",
Text_InstalledAllUsers: "Todos os usuários",
Text_InstalledDate: "Data de instalação",
Text_InstalledMode: "Modo Instalado",
Text_InstalledPath: "Caminho instalado",
Text_Name: "Nome",
Text_NewestVersion: "Versão mais recente",
Text_No: "Não",
Text_None: "Nenhum",
Text_NotInstalledMode: "Modo não instalado",
Text_NoUpdate: "Nenhuma atualização está disponível. Você está usando a versão mais recente.",
Text_OK: "OK",
Text_OpenTarget: "Local de destino",
Text_Properties: "Propriedades",
Text_PublisherDisplayName: "Editor",
Text_Save: "Salvar",
Text_SearchOnline: "Pesquise on-line",
Text_SelectAll: "Selecionar tudo",
Text_SignatureKind: "Tipo de assinatura",
Text_Status: "Status",
Text_Target: "Alvo",
Text_Type: "Tipo",
Text_Uninstall: "Desinstalar",
Text_Update: "Atualizar",
Text_UpdateFailed: "Falha na atualização, tente novamente mais tarde.",
Text_Updating: "Atualizando",
Text_Version: "Versão",
Text_WaitDlg: "Por favor, aguarde...",
Text_WhatsNew: "O que há de novo",
Text_Yes: "Sim",
UninstallOneDrive: {Name: "Desinstalar o OneDrive"},
UnpinChat: {Name: "conversando"},
UnpinCopilot: {Name: "co-piloto"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "borda"},
UnpinFileExplorer: {Name: "Explorador de arquivos"},
UnpinMail: {Name: "publicar"},
UnpinNewsandInterests: {Name: "Notícias e interesses"},
UnpinSearch: {Name: "encontrar"},
UnpinStore: {Name: "loja"},
UnpinTaskbar: {Name: "barra de tarefas"},
UnpinTaskView: {Name: "Exibição de tarefa"},
UnpinWidgets: {Name: "ferramenta"},
VerCtrl: {Desc: "Clique para verificar se há atualizações.",Desc1: "Há uma nova versão`n (clique para detalhes)"}
},
ru: {
Name: "Русский",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE8GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjhUMTE6NTY6MDMrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjQ5KzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI4VDE0OjQyOjQ5KzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDplMzAwMDc3Yy05YTIwLTc2NDUtYmZiMy03Njk5MjU2MzIyN2IiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6ZTMwMDA3N2MtOWEyMC03NjQ1LWJmYjMtNzY5OTI1NjMyMjdiIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6ZTMwMDA3N2MtOWEyMC03NjQ1LWJmYjMtNzY5OTI1NjMyMjdiIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDplMzAwMDc3Yy05YTIwLTc2NDUtYmZiMy03Njk5MjU2MzIyN2IiIHN0RXZ0OndoZW49IjIwMjQtMDctMjhUMTE6NTY6MDMrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+2k6lpAAAAchJREFUOMutVb1uk0EQnLk7OwQQHQWSRYEQJUGiCEqKFJFjl7wGUt6A18hPw0MkXYzcREIUqUiLkJBIXiCBOCTf7g4FNnx2KOzgkUbaO92N9vbvKAkjuDsAgORoa0PSMoDHw/U3AEckeyQhCSTr5wFJf2hmcHe4+4qZ7dlvaIJmZnsRseLuiIgxjRuCZrZVVZWmoZlt1e9LAutPNrMDSR3MAJK9Ukp3tE4jIyJ2JHVGMZmWEdGJiJ3JGC7p//FcEvjl5Azu1o/Q+li2ZoSkPog288t3bQff314KGGUhQxulWdJaMGEeyOBaySW3MuaGVhEEzklNIkoApz4XSaKUOC2Xyocg3/4N7e3EACJUHfLD01eI0ugLXGcIMzsrQIkA1Od11ebPRw8hlqXLuw8+Jbdb+Re5YGHw4wUjjsvZ9yYEHF8Su1f37r/Jlc30UGs0sXBxtrt4fnFMANSwMAXga+vZwXVzoZOn8pTwnNGornpPTj53U304cGjcGQy6FLZDQkzMyjoDgiNAaXtxcNGtt0Uaj0VGw2wzWbUK932X3CVM0OXYb1TXq023zUjjbVFuJI0EQx8T/LWQNoJYBln7AuIoe+pR8c9C+wVsCq4jiFqufgAAAABJRU5ErkJggg==",
AUOptions: {Name: "Вариант UA",Desc: "Настройте уведомления перед загрузкой обновлений Windows"},
AutoEndTasks: {Name: "Выполняйте задачи автоматически",Desc: "Закройте заблокированные процессы, чтобы предотвратить сбои системы."},
BtnHostsEdit: {Name: "Изменить хост"},
BtnPackageManager: {Name: "Приложение UWP"},
BtnRestartExplorer: {Name: "Перезапустите Проводник Windows."},
BtnStartupManager: {Name: "отвечает за инициализацию"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Язык"},
BtnSys_LoadOptimizeConfig: {Desc: "Загрузите файл конфигурации оптимизации"},
BtnSys_Minimize: {Desc: "минимизация"},
BtnSys_ReloadTab: {Desc: "Перезагрузите эту вкладку."},
BtnSys_SaveImage: {Desc: "Автоматически захватывать и сохранять в изображение"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Сохраните все настройки оптимизации в файлы"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Эта вкладка сохраняет в файл только конфигурацию оптимизации."},
BtnSys_Search: {Desc: "Поиск оптимизации"},
BtnSys_Setting: {Desc: "система"},
BtnSys_Theme: {Desc: "тема"},
ClassicContextMenu: {Name: "Классическое контекстное меню"},
DiagnosticDataOff: {Name: "Диагностические данные отключены."},
DisableAADCloudSearch: {Name: "Отключить поиск содержимого облака AAD",Desc: "Отключите обнаружение облачного контента для вашей рабочей или учебной учетной записи."},
DisableAdsOnLockScreen: {Name: "Отключить рекламу на экране блокировки"},
DisableAeDebug: {Name: "Отключить AEDebug",Desc: "Ускорьте обработку ошибок, отключив отладчик."},
DisableAnimationEffectMaxMin: {Name: "Отключить минимум максимум эффектов анимации",Desc: "Ускоряет реакцию окна, закрывая эффекты анимации, когда окно развернуто или свернуто."},
DisableAppendCompletion: {Name: "Отключите дополнительные дополнения.",Desc: "Отключить встроенное автозаполнение (добавить заливку или автозаполнение)"},
DisableAutoDefragIdle: {Name: "Отключить автоматическую дефрагментацию во время простоя",Desc: "Продлите срок службы вашего SSD, отключив автоматическую дефрагментацию в периоды бездействия."},
DisableAutoInstallationApps: {Name: "Отключить автоматическую установку приложения"},
DisableAutoplay: {Name: "Отключить автозапуск",Desc: "Чтобы избежать заражения вирусом, отключите функцию `"автозапуска`" на диске."},
DisableAutoSuggest: {Name: "Отключить автоматические предложения",Desc: "Отключить автопредложение (раскрывающийся список автозаполнения)"},
DisableAutoWindowsUpdates: {Name: "Отключить автоматическое обновление Windows",Desc: "Отключить автоматические обновления"},
DisableBackgroundApps: {Name: "Отключить приложения, работающие в фоновом режиме"},
DisableBootOptimize: {Name: "Отключить оптимизацию запуска",Desc: "Чтобы продлить срок службы SSD, отключите диски дефрагментации системы во время загрузки."},
DisableCrashAutoReboot: {Name: "Отключить автоматический перезапуск при сбое",Desc: "Отключите автоматический перезапуск, когда система обнаруживает синий экран."},
DisableCustomInking: {Name: "Отключить пользовательское рисование от руки",Desc: "Отключить пользовательские рукописный ввод и словари ввода"},
DisableDeviceSearchHistory: {Name: "Отключить локальную историю поиска",Desc: "Отключить локальную историю просмотров на этих устройствах"},
DisableDiagTrack: {Name: "Отключить ДиагТрек",Desc: "DiagTrack: Connected User Experience и служба телеметрии обеспечивают возможности подключения пользователей внутри приложения. `n Эта служба также управляет сбором и передачей событийной диагностики и информации об использовании (используется для повышения комфорта и качества). (На платформах Windows) параметр «Параметры конфиденциальности диагностики и использования» доступен в разделе «Отзывы и диагностика»."},
DisabledVBSCodeIntegrity: {Name: "Целостность кода VBS отключена.",Desc: "Отключить защиту целостности кода на основе виртуализации"},
DisableErrorReporting: {Name: "Отключить отчеты об ошибках",Desc: "Отключите отчеты об ошибках на экране, чтобы повысить производительность системы."},
DisableFrequentFolders: {Name: "Отключить часто используемые папки"},
DisableGameBar: {Name: "Отключите игровую панель и записывающее устройство игр.",Desc: "Функция Game DVR позволяет записывать игровой процесс в фоновом режиме. `nЭта функция расположена на панели игры и отображает кнопки, позволяющие записывать игровой процесс и делать снимки экрана с помощью Game DVR. `n Однако это может замедлить работу. Улучшите производительность игры, записывая видео в фоновом режиме."},
DisableGoogleUpdateTask: {Name: "Отключите задачу GoogleUpdate"},
DisableHibernate: {Name: "Отключить спящий режим"},
DisableHybridSleep: {Name: "Нет гибридной подвески."},
DisableLockScreen: {Name: "Выключить экран блокировки"},
DisableLowDiskSpaceChecks: {Name: "Отключить проверку нехватки места на диске",Desc: "Улучшите производительность системы за счет оптимизации дисковой подсистемы ввода-вывода."},
Disablememorypagination: {Name: "Отключить подкачку памяти",Desc: "Отключите подкачку памяти, чтобы уменьшить количество дисковых операций ввода-вывода и повысить производительность приложений. `n (можно игнорировать, если физическая память меньше 1 ГБ)"},
DisableMenuShowDelay: {Name: "Отключить отложенное отображение меню",Desc: "Оптимизируйте время отклика экрана вашей системы"},
DisableMicrosoftEdgeUpdateTask: {Name: "Отключить MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Отключить поиск контента в облаке MSA",Desc: "Отключите обнаружение облачного содержимого для вашей учетной записи Microsoft."},
DisableMSDefender: {Name: "Отключить Защитник Майкрософт",Desc: "1 Нажмите, чтобы включить или выключить Microsoft Defender. `nВаш компьютер перезагрузится автоматически."},
DisableOfferSuggestions: {Name: "Отключить предложения купонов"},
DisablePersonalizedAdsStoreApps: {Name: "Отказ от приложений магазина пользовательских объявлений"},
DisablePrefetchParameters: {Name: "Не используйте параметры предварительной загрузки",Desc: "Продлите срок службы вашего SSD, отключив параметры предварительной загрузки."},
DisablePrintSpooler: {Name: "Отключить буферизацию печати"},
DisableRecentFiles: {Name: "Отключить недавно использованные файлы"},
DisableRemoteRegAccess: {Name: "Отключить удаленный доступ к реестру",Desc: "Отключить редактирование реестра на удаленных компьютерах"},
DisableScheduledDefrag: {Name: "Отключить запланированную дефрагментацию"},
DisableSettingsAppSuggestions: {Name: "Отключить предложения приложений в настройках"},
DisableShortcutText: {Name: "Отключить текст ярлыка"},
DisableSleep: {Name: "Выключить сон"},
DisableStartMenuAppSuggestions: {Name: "Отключить предложения приложений в меню «Пуск»"},
DisableSyncProviderNotifications: {Name: "Отключить уведомления поставщика синхронизации"},
DisableSystemRestore: {Name: "Отключить восстановление системы"},
DisableTailoredExperiences: {Name: "Отключите персонализированный опыт"},
DisableTipsAndSuggestions: {Name: "Советы и подсказки по отказу от участия"},
DisableTurnOffDisplay: {Name: "Выключить Выключить дисплей"},
DisableVisualStudioTelemetry: {Name: "Отключить телеметрию VisualStudio"},
DisableWCE: {Name: "Отключить расширения WCE",Desc: "Отключить улучшение качества программного обеспечения Windows`n`n – Прокси-сервер: эта задача автоматически проверяет, были ли вы выбраны для участия в программе улучшения качества программного обеспечения Microsoft для сбора и загрузки данных SQM. `n — Microsoft Compatibility Evaluator: собирает информацию о программах. Телеметрия, если вы решите присоединиться к программе улучшения качества программного обеспечения Microsoft."},
DisableWebSearch: {Name: "Отключить просмотр веб-страниц",Desc: "Отключите онлайн-поиск и включайте только веб-результаты Bing вашей учетной записи при поиске на панели задач."},
DisableWebSearchStartMenu: {Name: "Отключить главное меню веб-поиска",Desc: "Отключить поиск в Интернете из меню «Пуск»"},
DisableWindowsFeedback: {Name: "Отключить комментарии Windows"},
DisableWindowsSearch: {Name: "Отключить поиск Windows"},
EnableDarkMode: {Name: "Использовать темный режим"},
Explorer: {Name: "Файловый браузер"},
HideMostUsedApps: {Name: "Скрыть часто используемые приложения",Desc: "Снимите флажок `"Показывать часто используемые приложения`"] в меню `"Пуск`"."},
HideStartMenuAccountNotifications: {Name: "Скрыть уведомления аккаунта",Desc: "Снимите флажок «Показывать уведомления от учетной записи {\}» в меню «Пуск»."},
HideStartMenuRecentlyAdded: {Name: "Скрыть недавно добавленные приложения",Desc: "В меню «Пуск» снимите флажок [`" Показывать недавно добавленные приложения `"]."},
HideStartMenuRecentlyOpened: {Name: "Скрыть недавно открытые элементы",Desc: "В меню «Пуск» снимите флажок {\}Показывать недавно открытые элементы в меню «Пуск», списках перехода и проводнике{\}."},
HideStartMenuRecommendations: {Name: "Скрыть советы",Desc: "Отключите {\}, чтобы видеть предложения меню «Пуск», такие как [{\} советы, ярлыки, новые приложения и многое другое."},
HideWindowsSecurityNoncriticalNotifications: {Name: "Скрыть ненужные уведомления WS",Desc: "Безопасность Windows отображает только важные уведомления. `nЭтот параметр не будет иметь эффекта, если включен параметр [Отклонить все уведомления врача общей практики]."},
HideWindowsSecurityNotifications: {Name: "Скрыть уведомления WS",Desc: "Скрывает все уведомления безопасности Windows."},
HostsEdit_BtnImportFromFile: {Name: "Импорт из файла"},
HostsEdit_BtnImportFromLink: {Desc: "Импортировать из ссылки хоста"},
HostsEdit_BtnReload: {Name: "Перезагрузите файл хостов."},
HostsEdit_BtnResetDefault: {Name: "Восстановить значения по умолчанию"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "сохранить как"},
HostsEdit_TxtSelectLink: {Name: "Выберите ссылку, чтобы импортировать черный список на ваш хост."},
IncreaseIconCache: {Name: "Увеличьте кэш значков",Desc: "Увеличивает кэш системных значков и ускоряет отображение рабочего стола."},
IoPageLockLimit: {Name: "Ограничение блокировки страниц ввода-вывода",Desc: "Улучшите производительность системы за счет оптимизации настроек памяти по умолчанию."},
Link_ClearStartMenu: {Name: "Очистите меню «Пуск»"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Исправлена ​​ошибка, при которой ссылка игнорировала LinkInfo.",Desc: "Не отслеживать соединения оболочки в роуминге"},
MouseHoverTime: {Name: "время наведения",Desc: "Ускоряет отображение превью в окнах панели задач."},
NoInternetOpenWith: {Name: "без Интернета",Desc: "Отключите службу слияния файлов Интернета"},
NoResolveSearch: {Name: "Ваш поиск не был решен.",Desc: "Избегайте использования методов поиска при разрешении ссылок оболочки."},
NoResolveTrack: {Name: "Никаких признаков разрешения",Desc: "Избегайте использования методов трассировки при разрешении ссылок оболочки. `n Этот параметр не позволяет системе распознавать ссылки с использованием отслеживания NTFS."},
NumLockonStartup: {Name: "Блокировать Num при запуске"},
OpenFileExplorerThisPC: {Name: "Откройте проводник на этом компьютере"},
OptimizeNetworkTransfer: {Name: "Оптимизация передачи данных по сети",Desc: "Улучшите производительность передачи за счет оптимизации настроек сети."},
Optimizeprocessorperformance: {Name: "Оптимизация производительности процессора",Desc: "Оптимизируйте производительность процессора для запуска приложений, игр и многого другого. Более нежно."},
OptimizeRefreshPolicy: {Name: "Оптимизация политики обновлений",Desc: "Улучшите производительность системы за счет оптимизации дисковой подсистемы ввода-вывода."},
Optional: {Name: "вариант"},
PackageManager_BtnDisable: {Desc: "Активировать/деактивировать для всех пользователей"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Если вы отмените регистрацию пакета приложений, он не будет автоматически устанавливаться для новых пользователей на устройстве."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Перечисляет пакеты, установленные всеми пользователями."},
PackageManager_Mode: {Desc: "Режим установки: список установленных пакетов. `nНеустановленный режим: список пакетов, которые существуют на компьютере, но не были установлены текущим пользователем."},
Privacy: {Name: "Конфиденциальность"},
ShowExtensions: {Name: "Показать расширения"},
ShowHidden: {Name: "Скрыть вид"},
ShowHiddenSystem: {Name: "Показать скрытые системы"},
ShowThisPC: {Name: "покажи мне этот компьютер"},
ShutdownAcceleration: {Name: "Ускоренное завершение работы",Desc: "Уменьшает простой приложения после закрытия и ускоряет процесс завершения работы."},
SnippingPrintScreen: {Name: "распечатать скриншот"},
StartMenu: {Name: "стартовое меню"},
System: {Name: "система"},
Text_Architecture: "Архитектура",
Text_BackgroundImage: "Изображение на заднем плане",
Text_Cancel: "Отмена",
Text_CheckUpdate: "Проверить обновление",
Text_ClearStartMenu_Confirm: "Вы уверены, что хотите очистить макет меню «Пуск»?`n(Будет создан файл резервной копии `"WinTune_StartMenuLayout_xxxx.json`")",
Text_ClearStartMenu_Done: "Очистить меню «Пуск» Готово!",
Text_Close: "Закрывать",
Text_CommandLine: "Командная строка",
Text_ConnectionFailed: "Соединение с сервером не удалось.",
Text_CurrentVersion: "Текущая версия",
Text_Custom: "Обычай",
Text_DefaultImage: "Изображение по умолчанию",
Text_Delete: "Удалить",
Text_DeprovisionPackage: "Пакет деинициализации",
Text_DeselectAll: "Убрать выделение со всего",
Text_Details: "Подробности",
Text_Disable: "Запрещать",
Text_Disabled: "Неполноценный",
Text_DisableMSDefender0: "Для включения Microsoft Defender требуется перезагрузка компьютера.`nВы уверены, что хотите это сделать?",
Text_DisableMSDefender1: "Для отключения Microsoft Defender требуется перезагрузка компьютера.`nВы уверены, что хотите это сделать?",
Text_DisplayName: "Отображаемое имя",
Text_EffectivePath: "Эффективный путь",
Text_Enable: "Давать возможность",
Text_Enabled: "Включено",
Text_FamilyName: "Фамилия",
Text_FindRegistry: "Найти в реестре",
Text_FullName: "Полное имя",
Text_Homepage: "Домашняя страница",
Text_HR_Optimize: "------- Оптимизировать -------",
Text_HR_Tools: "-------- Инструменты --------",
Text_Install: "Установить",
Text_InstalledAllUsers: "Все пользователи",
Text_InstalledDate: "Дата установки",
Text_InstalledMode: "Установленный режим",
Text_InstalledPath: "Установленный путь",
Text_Name: "Имя",
Text_NewestVersion: "Новейшая версия",
Text_No: "На",
Text_None: "Никто",
Text_NotInstalledMode: "Не установленный режим",
Text_NoUpdate: "Обновление недоступно. Вы используете последнюю версию.",
Text_OK: "ХОРОШО",
Text_OpenTarget: "Целевое местоположение",
Text_Properties: "Характеристики",
Text_PublisherDisplayName: "Издатель",
Text_Save: "Сохранять",
Text_SearchOnline: "Поиск в Интернете",
Text_SelectAll: "Выбрать все",
Text_SignatureKind: "Тип подписи",
Text_Status: "Положение дел",
Text_Target: "Цель",
Text_Type: "Тип",
Text_Uninstall: "Удалить",
Text_Update: "Обновлять",
Text_UpdateFailed: "Обновление не удалось, повторите попытку позже.",
Text_Updating: "Обновлять",
Text_Version: "Версия",
Text_WaitDlg: "Пожалуйста, подождите...",
Text_WhatsNew: "Что нового",
Text_Yes: "Да",
UninstallOneDrive: {Name: "Удалить OneDrive"},
UnpinChat: {Name: "говорить"},
UnpinCopilot: {Name: "второй пилот"},
UnpinCortana: {Name: "Кортана"},
UnpinEdge: {Name: "рог"},
UnpinFileExplorer: {Name: "Файловый браузер"},
UnpinMail: {Name: "публиковать"},
UnpinNewsandInterests: {Name: "новости и интерес"},
UnpinSearch: {Name: "тесты"},
UnpinStore: {Name: "магазин"},
UnpinTaskbar: {Name: "панель задач"},
UnpinTaskView: {Name: "Просмотр задач"},
UnpinWidgets: {Name: "инструмент"},
VerCtrl: {Desc: "Нажмите, чтобы проверить наличие обновлений.",Desc1: "Доступна новая версия `n (нажмите, чтобы узнать подробности)"}
},
tr: {
Name: "Türkçe",
Translator: "mikropsoft",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFyWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wNy0yMlQxODowNDo0MCswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDctMjJUMTg6MTE6MTUrMDc6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDctMjJUMTg6MTE6MTUrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjdlZTVmNWQxLTg0NTUtNjA0Ni1iNWNlLTBkY2ZmMjYyYjY5ZSIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjVkNmFlNTdiLTUzZmMtMDI0MS1iZDZiLTgwNGUxMzRiZjNjMiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjQ5ZGQwYTU4LTBiOTMtODU0ZS1iNmM3LTAzNmRjMmM1MzRkZSI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6NDlkZDBhNTgtMGI5My04NTRlLWI2YzctMDM2ZGMyYzUzNGRlIiBzdEV2dDp3aGVuPSIyMDI0LTA3LTIyVDE4OjA0OjQwKzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuOSAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjdlZTVmNWQxLTg0NTUtNjA0Ni1iNWNlLTBkY2ZmMjYyYjY5ZSIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0yMlQxODoxMToxNSswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PuqD7WAAAAO1SURBVDgRhcFfaJV1HMfx9/f3PM/ZnvNnLbPp3GaaM8oQF11UelGQzgWhIdJVBUaEmpfhTd3UZeCdf4Kom4KSglhFqBhCMcmb0G4CjZwd55ya03bO2TnPeX6/Tx1DWhL1epn42+yy+8mL92BqIgIU0lEUHhcM0SFVgVOW62ikNiFJiJstei/8xG0xdzAJomi9LNoLehaIuM0MDK/YvpJ374BOcgfHAk4Bn7j93kUTsmirgiIJJJBAAgUimW3No8KEjwv7nQ8sFKucggHB0SpWjnjHZufFfzEJARKvNbu7hnusd0xydFhz+YNgUC+WDjZdvCvK2xDHqFYnXJoGZ4CBhOtfgpXL4D23SPgkoavRPlSqze42wG4Oria4ZF2jVD7t5CFJCJMXsN5euna8QLLlGaxSIf92guzjz/Bnz2HlMguFyJHWb4y4kJ+JW4WEPOnahzxyRpicxA2vojz+CcnQIO3r12kdeh81ati6h2FmhlCrY2k3iD8JgjFfKO+LWvMb7dJDj24i6BgIsgw1GpR//J6kr4/ml19T37Idw6BcwdIUt2wpYeYqIIhjrKcHfA7mEDbqgg9PCSHAT10iefkl4r4+8mu/Mb/ndWzRYtyaNbjlQyjLULFI8uoObEkf0SMjaG4OYUgCwpMOGJSEJNTOcSNrEZB9d5L81yos6SPkOf73OWx4FcnOV0jfeoP00w/Jq1VCEJKQhIKGYiFuEyCBABEQIIkOIYQQIgBBQhLin1xAF4OEJEIU0f7hNAGI1j+BDQ7gZ2aQc1CpkJ/9mebB96i/+Tb17S9igwMICBJBIkDVJofXbcI4hgRZGzUalE9PUBgYoPn5F9S3PQ84LC1BsYjrX0q4chVDEMdYTw/KczAjyEatet8D5EnXcZl72swIF6dwq1ZSGj9MYeUK2pcv03r3A2jNo1qD/PgJVKtjaQoSHTLDFL6JstbGaG+pgvlwplXo3mnew6K78b+cJ/voMPn1WezexUQjawk358iPn8BPTUMxRRICBAQzCo3atijLZ+xKuZ+Oxl2Vg81ScVfcbqM4glqdMD0N5gADBVz/UiiVwHs6DGhHMWkWDhXna7tNYIG/COP80OojWVLYHHnP/zLDO0dX1jy6YuramMnocAYY4BDdjdqYeR3wQBBIQhKSkIQkJBEArwDiQNpqjjndwJjFmMWxgJwjyf0e1843BPlxL3kv4SW8hJfwklcI40mWbSj4fI93joVi7iAzzIeTmD0H0SimxwIsN26pYpyKvI46Bf7NH+m1EV7ifPXCAAAAAElFTkSuQmCC",
AUOptions: {Name: "AU Seçenekleri",Desc: "Windows Güncellemelerini İndirmeden Önce Bildir"},
AutoEndTasks: {Name: "Görevleri Otomatik Sonlandır",Desc: "Sistemin çökmesini önlemek için donmuş işlemleri kapat"},
BtnHostsEdit: {Name: "Hosts Düzenle"},
BtnPackageManager: {Name: "UWP Uygulamaları"},
BtnRestartExplorer: {Name: "Explorer'ı Yeniden Başlat"},
BtnStartupManager: {Name: "Başlangıç Yöneticisi"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Dil"},
BtnSys_LoadOptimizeConfig: {Desc: "Optimizasyon yapılandırma dosyasını yükle"},
BtnSys_Minimize: {Desc: "Simge Durumuna Küçült"},
BtnSys_ReloadTab: {Desc: "Bu sekmeyi yeniden yükle"},
BtnSys_SaveImage: {Desc: "Kendi Ekran Görüntüsünü Al ve Görüntü Olarak Kaydet"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Tüm optimizasyon yapılandırmalarını dosyaya kaydet"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Bu sekme için yalnızca optimizasyon yapılandırmasını dosyaya kaydet"},
BtnSys_Search: {Desc: "Optimize Ara"},
BtnSys_Setting: {Desc: "Ayar"},
BtnSys_Theme: {Desc: "Tema"},
ClassicContextMenu: {Name: "Klasik Bağlam Menüsü"},
DiagnosticDataOff: {Name: "Tanılama Verilerini Kapat"},
DisableAADCloudSearch: {Name: "Bulut İçerik Aramasını AAD'den Kapat",Desc: "İş veya Okul Hesabı için Bulut İçerik Aramasını Kapat"},
DisableAdsOnLockScreen: {Name: "Kilitleme Ekranında Reklamları Kapat"},
DisableAeDebug: {Name: "AeDebug'u Devre Dışı Bırak",Desc: "Hata işleme hızını artırmak için hata ayıklayıcıyı devre dışı bırak"},
DisableAnimationEffectMaxMin: {Name: "Maksimum Min Animasyon Efektini Kapat",Desc: "Pencereyi büyütme veya küçültme sırasında animasyon efektini kapat ve pencere yanıt hızını artır"},
DisableAppendCompletion: {Name: "Ek Tamamlamayı Devre Dışı Bırak",Desc: "Satır içi Otomatik Tamamlama (Ek tamamlamayı veya Otomatik doldurma) devre dışı bırak"},
DisableAutoDefragIdle: {Name: "Boşta Otomatik Birleştirmeyi Kapat",Desc: "SSD'nin çalışma ömrünü artırmak için boşta otomatik birleştirmeyi devre dışı bırak"},
DisableAutoInstallationApps: {Name: "Otomatik Uygulama Kurulumunu Kapat"},
DisableAutoplay: {Name: "Otomatik Oynatmayı Kapat",Desc: "Sürücülerdeki “Otomatik Oynat” özelliğini devre dışı bırak ve virüs bulaşmasını önle"},
DisableAutoSuggest: {Name: "Otomatik Öneriyi Devre Dışı Bırak",Desc: "Otomatik Öneriyi (Otomatik tamamlama açılır listesi) devre dışı bırak"},
DisableAutoWindowsUpdates: {Name: "Otomatik Windows Güncellemelerini Kapat",Desc: "Otomatik Güncellemeleri Devre Dışı Bırak"},
DisableBackgroundApps: {Name: "Arka Plan Uygulamalarını Devre Dışı Bırak"},
DisableBootOptimize: {Name: "Önyükleme Optimizasyonunu Kapat",Desc: "Önyükleme sırasında sistem sürücüsünü birleştirmeyi devre dışı bırak ve SSD'nin çalışma ömrünü artır"},
DisableCrashAutoReboot: {Name: "Çökme Sonrası Otomatik Yeniden Başlatmayı Kapat",Desc: "Mavi ekran ölümle karşılaştığında otomatik yeniden başlatmayı devre dışı bırak"},
DisableCustomInking: {Name: "Özel serbest çizimi devre dışı bırak",Desc: "Özel yazma ve giriş sözlüklerini devre dışı bırakın"},
DisableDeviceSearchHistory: {Name: "Yerel Arama Geçmişini Kapat",Desc: "Bu cihazlarda yerel arama geçmişini kapat"},
DisableDiagTrack: {Name: "DiagTrack'i Devre Dışı Bırak",Desc: "DiagTrack - Bağlı Kullanıcı Deneyimleri ve Telemetri hizmeti, uygulama içi ve bağlı kullanıcı deneyimlerini destekleyen özellikleri etkinleştirir.`nAyrıca, bu hizmet, geri bildirim ve teşhis altındaki teşhis ve kullanım gizlilik seçenek ayarları etkin olduğunda (Windows Platformu deneyimini ve kalitesini iyileştirmek için kullanılan) teşhis ve kullanım bilgilerini toplama ve iletme olaylarını yönetir."},
DisabledVBSCodeIntegrity: {Name: "VBS Kod Bütünlüğünü Devre Dışı Bıraktı",Desc: "Kod bütünlüğünün sanallaştırma tabanlı korunmasını devre dışı bırak"},
DisableErrorReporting: {Name: "Hata Raporlamayı Kapat",Desc: "Ekran hata raporlamasını devre dışı bırak ve sistem performansını artır"},
DisableFrequentFolders: {Name: "Sık Kullanılan Klasörleri Devre Dışı Bırak"},
DisableGameBar: {Name: "Oyun Çubuğunu ve Oyun DVR'ını Kapat",Desc: "Oyun DVR özelliği, oyunlarınızı arka planda kaydetmenize olanak tanır.`nOyun Çubuğu'nda bulunur – Oyun DVR özelliğini kullanarak oyun kaydetme ve ekran görüntüsü alma düğmeleri sunar.`nAncak, arka planda video kaydetmesi nedeniyle oyun performansınızı yavaşlatabilir."},
DisableGoogleUpdateTask: {Name: "Google Güncelleme Görevini Kapat"},
DisableHibernate: {Name: "Hazırda Bekletmeyi Kapat"},
DisableHybridSleep: {Name: "Hibrit Uykuyu Kapat"},
DisableLockScreen: {Name: "Kilitleme Ekranını Kapat"},
DisableLowDiskSpaceChecks: {Name: "Düşük Disk Alanı Kontrollerini Kapat",Desc: "Disk G/Ç alt sistemini optimize edin ve sistem performansını artırın"},
Disablememorypagination: {Name: "Bellek Sayfalama'yı Devre Dışı Bırak",Desc: "Bellek sayfalamasını devre dışı bırak ve disk G/Ç'yi azaltarak uygulama performansını artır.`n(Seçenek, fiziksel bellek <1 GB ise göz ardı edilebilir)"},
DisableMenuShowDelay: {Name: "Menü Gösterim Gecikmesini Kapat",Desc: "Sistem ekran yanıt hızını optimize et"},
DisableMicrosoftEdgeUpdateTask: {Name: "Microsoft Edge Güncelleme Görevini Kapat"},
DisableMSACloudSearch: {Name: "MSA için Bulut İçerik Aramasını Kapat",Desc: "Microsoft Hesabı için Bulut İçerik Aramasını Kapat"},
DisableMSDefender: {Name: "Microsoft Defender'ı Kapat",Desc: "Microsoft Defender'ı tek tıkla etkinleştir/devre dışı bırak.`nBilgisayar otomatik olarak yeniden başlatılacaktır."},
DisableOfferSuggestions: {Name: "Öneri Sunmayı Devre Dışı Bırak"},
DisablePersonalizedAdsStoreApps: {Name: "Kişiselleştirilmiş Reklamları Store Uygulamalarında Kapat"},
DisablePrefetchParameters: {Name: "Ön Bellek Parametrelerini Kapat",Desc: "SSD'nin çalışma ömrünü artırmak için önbellek parametrelerini devre dışı bırak"},
DisablePrintSpooler: {Name: "Yazdırma Biriktiricisini Devre Dışı Bırak"},
DisableRecentFiles: {Name: "Son Dosyaları Devre Dışı Bırak"},
DisableRemoteRegAccess: {Name: "Uzaktan Kayıt Defteri Erişimini Devre Dışı Bırak",Desc: "Uzaktaki bir bilgisayardan kayıt defteri değişikliğini devre dışı bırak"},
DisableScheduledDefrag: {Name: "Planlı Birleştirmeyi Devre Dışı Bırak"},
DisableSettingsAppSuggestions: {Name: "Ayarlar Uygulaması Önerilerini Kapat"},
DisableShortcutText: {Name: "Kısayol Metnini Devre Dışı Bırak"},
DisableSleep: {Name: "Uyku Modunu Kapat"},
DisableStartMenuAppSuggestions: {Name: "Başlat Menüsü Uygulama Önerilerini Kapat"},
DisableSyncProviderNotifications: {Name: "Senkronizasyon Sağlayıcı Bildirimlerini Kapat"},
DisableSystemRestore: {Name: "Sistem Geri Yüklemeyi Kapat"},
DisableTailoredExperiences: {Name: "Özel Deneyimleri Kapat"},
DisableTipsAndSuggestions: {Name: "İpuçları ve Önerileri Kapat"},
DisableTurnOffDisplay: {Name: "Ekranı Kapatmayı Devre Dışı Bırak"},
DisableVisualStudioTelemetry: {Name: "VisualStudio Telemetrisini Kapat"},
DisableWCE: {Name: "WCE İyileştirmesini Devre Dışı Bırak",Desc: "Windows Müşteri Deneyimi İyileştirmesini Devre Dışı Bırak`n`n- Proxy: Bu görev, Microsoft Müşteri Deneyimi İyileştirme Programına katıldıysanız otomatik olarak toplama ve iletme işlevini gerçekleştirir.`n- Microsoft Uyumluluk Değerlendirici: Microsoft Müşteri Deneyimi İyileştirme Programına katıldıysanız program telemetri bilgilerini toplar."},
DisableWebSearch: {Name: "Web Aramasını Kapat",Desc: "Görev çubuğunda bir arama yaptığınızda çevrimiçi aramayı kapatın ve yalnızca hesabınız için Bing'den web sonuçlarını içermesini kapatın"},
DisableWebSearchStartMenu: {Name: "Başlat Menüsünde Web Aramasını Kapat",Desc: "Başlat Menüsünde Web Aramasını Kapatır"},
DisableWindowsFeedback: {Name: "Windows Geri Bildirimini Kapat"},
DisableWindowsSearch: {Name: "Windows Aramasını Devre Dışı Bırak"},
EnableDarkMode: {Name: "Karanlık Modu Etkinleştir"},
Explorer: {Name: "Dosya Gezgini"},
HideMostUsedApps: {Name: "En çok kullanılan uygulamaları gizle",Desc: "Başlat menüsünde 'En çok kullanılan uygulamaları göster' seçeneğini kapat"},
HideStartMenuAccountNotifications: {Name: "Hesapla ilgili bildirimleri gizle",Desc: "Başlat menüsünde 'Hesapla ilgili bildirimleri göster' seçeneğini kapat"},
HideStartMenuRecentlyAdded: {Name: "Son eklenen uygulamaları gizle",Desc: "Başlat menüsünde 'Son eklenen uygulamaları göster' seçeneğini kapat"},
HideStartMenuRecentlyOpened: {Name: "Son açılan öğeleri gizle",Desc: "Başlat, Atlama Listeleri ve Dosya Gezgini'nde 'Son açılan öğeleri göster' seçeneğini kapat"},
HideStartMenuRecommendations: {Name: "Önerileri gizle",Desc: "Başlat menüsünde 'İpuçları, kısayollar, yeni uygulamalar ve daha fazlası için önerileri göster' seçeneğini kapat"},
HideWindowsSecurityNoncriticalNotifications: {Name: "Windows Güvenlik Kritik Olmayan Bildirimleri Gizle",Desc: "Windows Güvenliğinden yalnızca kritik bildirimleri göster.`nTüm bildirimleri engelle GP ayarı etkinleştirilmişse, bu ayarın bir etkisi olmayacaktır."},
HideWindowsSecurityNotifications: {Name: "Windows Güvenlik Bildirimlerini Gizle",Desc: "Windows Güvenliğinden gelen tüm bildirimleri gizle."},
HostsEdit_BtnImportFromFile: {Name: "Dosyalardan İçe Aktar"},
HostsEdit_BtnImportFromLink: {Desc: "Bağlantıdan hosts dosyasına içe aktar"},
HostsEdit_BtnReload: {Name: "Hosts dosyasını yeniden yükle"},
HostsEdit_BtnResetDefault: {Name: "Varsayılanı Sıfırla"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Farklı Kaydet"},
HostsEdit_TxtSelectLink: {Name: "İçe aktarma engelleme listesi için bağlantı seçin:"},
IncreaseIconCache: {Name: "Simge Önbelleğini Artır",Desc: "Sistem simge önbelleğini artır ve masaüstü ekranını hızlandır"},
IoPageLockLimit: {Name: "Io Sayfa Kilit Sınırı",Desc: "Sistem performansını artırmak için bellek varsayılan ayarlarını optimize et"},
Link_ClearStartMenu: {Name: "Başlat Menüsünü Temizle"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Bağlantı Çözümleme Bağlantı Bilgilerini Yoksay",Desc: "Dolaşırken Kabuk kısayollarını izlemeyin"},
MouseHoverTime: {Name: "Fare Üzerine Gelme Süresi",Desc: "Görev Çubuğu Pencere Ön İzlemelerinin gösterim hızını artır"},
NoInternetOpenWith: {Name: "İnternetsiz Aç",Desc: "İnternet Dosya İlişkilendirme hizmetini kapat"},
NoResolveSearch: {Name: "Çözüm Aramasını Yapma",Desc: "Kabuk kısayollarını çözerken arama tabanlı yöntemi kullanmayın"},
NoResolveTrack: {Name: "Çözümleme Parçası Yok",Desc: "Kabuk kısayollarını çözerken izleme tabanlı yöntemi kullanmayın.`nBu ayar, sistemin bir kısayolu çözmek için NTFS izleme özelliklerini kullanmasını engeller."},
NumLockonStartup: {Name: "Başlangıçta Num Lock"},
OpenFileExplorerThisPC: {Name: "Dosya Gezgini Bu Bilgisayarı Aç"},
OptimizeNetworkTransfer: {Name: "Ağ Transferini Optimize Et",Desc: "Ağ ayarlarını optimize ederek transfer performansını iyileştirin"},
Optimizeprocessorperformance: {Name: "İşlemci Performansını Optimize Et",Desc: "Uygulamaların, oyunların vb. daha sorunsuz çalışması için işlemci performansını optimize edin"},
OptimizeRefreshPolicy: {Name: "Yenileme Politikasını Optimize Et",Desc: "Sistem performansını artırmak için disk G/Ç alt sistemini optimize edin"},
Optional: {Name: "Opsiyonel"},
PackageManager_BtnDisable: {Desc: "Tüm kullanıcılar için etkinleştir/devre dışı bırak"},
PackageManager_DeprovisionPackage: {Name: "Uygulama Paketinin Kaldırılması",Desc: "Bir uygulama paketini kaldırır, böylece cihazdaki yeni kullanıcılar artık uygulamanın otomatik olarak kurulmasına sahip olmayacaklar."},
PackageManager_InstalledAllUsers: {Name: "Tüm Kullanıcılar",Desc: "Tüm kullanıcılar tarafından yüklenen paketlerin listesini göster"},
PackageManager_Mode: {Desc: "Yüklü Mod: Yüklü paketlerin listesini göster.`nYüklü Değil Modu: Bilgisayarınızda bulunan ancak geçerli kullanıcı tarafından yüklenmeyen paketlerin listesini göster."},
Privacy: {Name: "Gizlilik"},
ShowExtensions: {Name: "Uzantıları Göster"},
ShowHidden: {Name: "Gizli Dosyaları Göster"},
ShowHiddenSystem: {Name: "Gizli Sistem Dosyalarını Göster"},
ShowThisPC: {Name: "Bu Bilgisayarı Göster"},
ShutdownAcceleration: {Name: "Kapanış Hızlandırma",Desc: "Kapanış sırasında uygulama bekleme süresini azaltarak kapanış sürecini iyileştirin"},
SnippingPrintScreen: {Name: "Ekran Görüntüsü Alma"},
StartMenu: {Name: "Başlangıç ​​menüsü"},
System: {Name: "Sistem"},
Text_Architecture: "Mimari",
Text_BackgroundImage: "Arka plan görüntüsü",
Text_Cancel: "İptal",
Text_CheckUpdate: "Güncellemeleri Kontrol Et",
Text_ClearStartMenu_Confirm: "Başlat menüsü düzenini temizlemek istediğinizden emin misiniz?`n(Bir yedek dosya 'WinTune_StartMenuLayout_xxxx.json' oluşturulacak)",
Text_ClearStartMenu_Done: "Başlat Menüsü Temizlendi!",
Text_Close: "Kapat",
Text_CommandLine: "Komut Satırı",
Text_ConnectionFailed: "Sunucuya bağlantı başarısız oldu.",
Text_CurrentVersion: "Geçerli Sürüm",
Text_Custom: "Gelenek",
Text_DefaultImage: "Varsayılan resim",
Text_Delete: "Sil",
Text_DeprovisionPackage: "Uygulama Paketini Kaldır",
Text_DeselectAll: "Tüm Seçimleri Kaldır",
Text_Details: "Ayrıntılar",
Text_Disable: "Devre Dışı Bırak",
Text_Disabled: "Devre Dışı",
Text_DisableMSDefender0: "Microsoft Defender'ı etkinleştirmek bilgisayarın yeniden başlatılmasını gerektirir.`nBu işlemi yapmak istediğinizden emin misiniz?",
Text_DisableMSDefender1: "Microsoft Defender'ı devre dışı bırakmak bilgisayarın yeniden başlatılmasını gerektirir.`nBu işlemi yapmak istediğinizden emin misiniz?",
Text_DisplayName: "Görünen Ad",
Text_EffectivePath: "Etkili Yol",
Text_Enable: "Etkinleştir",
Text_Enabled: "Etkin",
Text_FamilyName: "Aile Adı",
Text_FindRegistry: "Kayıt Defterinde Bul",
Text_FullName: "Tam Adı",
Text_Homepage: "Ana Sayfa",
Text_HR_Optimize: "------- Optimize -------",
Text_HR_Tools: "-------- Araçlar --------",
Text_Install: "Yükle",
Text_InstalledAllUsers: "Tüm Kullanıcılar",
Text_InstalledDate: "kurulum tarihi",
Text_InstalledMode: "Yüklü Mod",
Text_InstalledPath: "Yüklü Yol",
Text_Name: "Adı",
Text_NewestVersion: "En Yeni Sürüm",
Text_No: "Hayır",
Text_None: "Hiçbiri",
Text_NotInstalledMode: "Yüklü Değil Modu",
Text_NoUpdate: "Güncelleme yok. En son sürümü kullanıyorsunuz.",
Text_OK: "Tamam",
Text_OpenTarget: "Hedef Konum",
Text_Properties: "Özellikler",
Text_PublisherDisplayName: "Yayıncı",
Text_Save: "Kaydet",
Text_SearchOnline: "Çevrimiçi Ara",
Text_SelectAll: "Tümünü Seç",
Text_SignatureKind: "İmza Türü",
Text_Status: "Durum",
Text_Target: "Hedef",
Text_Type: "Tür",
Text_Uninstall: "Kaldır",
Text_Update: "Güncelle",
Text_UpdateFailed: "Güncelleme başarısız oldu, lütfen daha sonra tekrar deneyin.",
Text_Updating: "Güncelleniyor",
Text_Version: "Sürüm",
Text_WaitDlg: "Lütfen bekleyin...",
Text_WhatsNew: "Yenilikler",
Text_Yes: "Evet",
UninstallOneDrive: {Name: "OneDrive'ı Kaldır"},
UnpinChat: {Name: "Sohbet"},
UnpinCopilot: {Name: "Copilot"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Edge"},
UnpinFileExplorer: {Name: "Dosya Gezgini"},
UnpinMail: {Name: "Posta"},
UnpinNewsandInterests: {Name: "Haberler ve İlgi Alanları"},
UnpinSearch: {Name: "Arama"},
UnpinStore: {Name: "Mağaza"},
UnpinTaskbar: {Name: "Görev Çubuğundan Kaldır"},
UnpinTaskView: {Name: "Görev Görünümü"},
UnpinWidgets: {Name: "Widget'lar"},
VerCtrl: {Desc: "Güncellemeleri kontrol etmek için tıklayın",Desc1: "Yeni bir sürüm var`n(Detaylar için tıklayın)"}
},
vi: {
Name: "Tiếng Việt",
Translator: "",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFzGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjQtMDctMjZUMTk6MzA6MjIrMDc6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDI0LTA3LTI2VDE5OjQxOjAzKzA3OjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDI0LTA3LTI2VDE5OjQxOjAzKzA3OjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5ZWQ5MGU5Zi1lZjc5LTIyNDctOGM2Mi0xMDI1MWEwMDJkODciIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDplMzVmZjliNS00MjU1LTMzNDgtODk1NC02NWNjNDljMTI0MzciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplMjFlYmM2YS0zMTVlLTJkNDYtYWFiMy05NmFkZjZmY2EwOWIiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmUyMWViYzZhLTMxNWUtMmQ0Ni1hYWIzLTk2YWRmNmZjYTA5YiIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0yNlQxOTozMDoyMiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6OWVkOTBlOWYtZWY3OS0yMjQ3LThjNjItMTAyNTFhMDAyZDg3IiBzdEV2dDp3aGVuPSIyMDI0LTA3LTI2VDE5OjQxOjAzKzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMTEgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PvrLEMYAAAI3SURBVDiNjdS7ctpAFAbgY8QKXVYSSecnSEnvIh32AyRV8ghJmzJUpkjlhqFxhevMxCUFTdL4UTIGFK4iNhba/CsdGQlw7OKzpHP5l8GDSBFRbmOalEhJynVJOQ4p3z9VUraU512yFp7P0r6mZy2Lihl0MFDKE7hGQAxqR5z2splnAoWgxPM6ie8rXF+io2q1/wS6bl+HbTBcItluXR8sZb8caBgZx+km9Xp2sh7MBUAs8Ms9Hap3sJvnpF8uTmlsgiA9cY8Bb5lxoK9hN3Hdhv5HEtIp9rzBAxoPOLHEB4Lv8IPvfe/AnK9iKQexDkShWWoGvFj0GyYH6sFeeJPWntcGlcIXvzbhI1zBF2jDGmL4xrUrnjF5h/cReE73UvZAPRLwBm5AsREMC883PCMKe5ke3eEPqEc+EPsAM1iwGdfyvl/Yy/Ro5bptUCUSCExYgWIrrhHPFHb+Zs4psu1mhIfIcVR61TAcYSm6AARFn+ET319wT7rbed5dIItW+C0uHWewQHGZE/AKfsF7IPYOfsJrnuF53h1EyKIVXgiRaTZmKM5tOyPgGOpA9rZOXDvmGa7r3SUykEMU4ee3hLkQ3Qma01pNTW1LTQ0gK7u3mM01g+8xO0k/gOjqjCh/OSRsIkQ/xNCfF9KzU+zk+3tvm/nREYVCdMZCKC18wnirs8DOk6+veaWiPyWNDeNkWK1eQwxqRzxCL8TMpFpNd54NDHEdwm2lcnprGF/hkrVQOxuhF/LsbuA/X8bVOsv+1EkAAAAASUVORK5CYII=",
AUOptions: {Name: "Tùy chọn AU",Desc: "Đặt Thông báo trước khi tải xuống Windows Updates"},
AutoEndTasks: {Name: "Tự động kết thúc nhiệm vụ",Desc: "Đóng các tiến trình bị đóng băng để tránh sự cố hệ thống"},
BtnHostsEdit: {Name: "Chỉnh sửa Hosts"},
BtnPackageManager: {Name: "Ứng dụng UWP"},
BtnRestartExplorer: {Name: "Khởi động lại Explorer"},
BtnStartupManager: {Name: "Quản lý khởi động"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "Ngôn ngữ"},
BtnSys_LoadOptimizeConfig: {Desc: "Tải tập tin cấu hình tối ưu hóa"},
BtnSys_Minimize: {Desc: "Giảm thiểu"},
BtnSys_ReloadTab: {Desc: "Tải lại tab này"},
BtnSys_SaveImage: {Desc: "Tự chụp và lưu vào ảnh"},
BtnSys_SaveOptimizeConfigAll: {Desc: "Lưu tất cả các cấu hình tối ưu hóa vào tập tin"},
BtnSys_SaveOptimizeConfigTab: {Desc: "Chỉ lưu cấu hình tối ưu hóa tab này vào tệp"},
BtnSys_Search: {Desc: "Tìm kiếm để tối ưu hóa"},
BtnSys_Setting: {Desc: "Cài đặt"},
BtnSys_Theme: {Desc: "Giao diện"},
ClassicContextMenu: {Name: "Menu ngữ cảnh cổ điển"},
DiagnosticDataOff: {Name: "Tắt dữ liệu chẩn đoán"},
DisableAADCloudSearch: {Name: "Tắt AAD tìm kiếm nội dung trên đám mây",Desc: "Tắt Tìm kiếm nội dung trên đám mây cho tài khoản cơ quan hoặc trường học"},
DisableAdsOnLockScreen: {Name: "Tắt quảng cáo trên màn hình khóa"},
DisableAeDebug: {Name: "Tắt AeDebug",Desc: "Tắt trình gỡ lỗi để tăng tốc độ xử lý lỗi"},
DisableAnimationEffectMaxMin: {Name: "Tắt hiệu ứng hoạt hình tối đa tối thiểu",Desc: "Đóng hiệu ứng hoạt ảnh khi phóng to hoặc thu nhỏ cửa sổ để tăng tốc độ phản hồi của cửa sổ"},
DisableAppendCompletion: {Name: "Tắt hoàn thành nối thêm",Desc: "Tắt tính năng Tự động hoàn thành nội tuyến (Thêm hoàn thành hoặc Tự động điền)"},
DisableAutoDefragIdle: {Name: "Vô hiệu tính năng tự động chống phân mảnh",Desc: "Tắt tự động chống phân mảnh khi không hoạt động để tăng tuổi thọ hoạt động của SSD"},
DisableAutoInstallationApps: {Name: "Tắt ứng dụng cài đặt tự động"},
DisableAutoplay: {Name: "Tắt Tự động phát",Desc: "Vô hiệu hóa tính năng “Autoplay” trên ổ đĩa để tránh nhiễm virus"},
DisableAutoSuggest: {Name: "Tắt tính năng tự động đề xuất",Desc: "Tắt Tự động đề xuất (Trình đơn thả xuống tự động hoàn thành)"},
DisableAutoWindowsUpdates: {Name: "Tắt cập nhật Windows tự động",Desc: "Tắt cập nhật tự động"},
DisableBackgroundApps: {Name: "Tắt ứng dụng nền"},
DisableBootOptimize: {Name: "Tắt tối ưu hóa khởi động",Desc: "Vô hiệu hóa ổ đĩa hệ thống chống phân mảnh khi khởi động để tăng tuổi thọ hoạt động của SSD"},
DisableCrashAutoReboot: {Name: "Tắt tính năng tự động khởi động lại sự cố",Desc: "Vô hiệu hóa tự động khởi động lại khi hệ thống gặp màn hình xanh chết chóc"},
DisableCustomInking: {Name: "Vô hiệu hóa viết tay tùy chỉnh",Desc: "Vô hiệu hóa từ điển viết tay và gõ tùy chỉnh"},
DisableDeviceSearchHistory: {Name: "Tắt Lịch sử tìm kiếm cục bộ",Desc: "Tắt Lịch sử tìm kiếm cục bộ trên thiết bị này"},
DisableDiagTrack: {Name: "Tắt DiagTrack",Desc: "DiagTrack - Dịch vụ Đo từ xa và Trải nghiệm người dùng được kết nối hỗ trợ các tính năng hỗ trợ trải nghiệm người dùng được kết nối và trong ứng dụng.`nNgoài ra, dịch vụ này còn quản lý việc thu thập và truyền tải thông tin chẩn đoán và sử dụng theo hướng sự kiện (dùng để cải thiện trải nghiệm và chất lượng của Nền tảng Windows) khi cài đặt tùy chọn chẩn đoán và quyền riêng tư sử dụng được bật trong Phản hồi và Chẩn đoán."},
DisabledVBSCodeIntegrity: {Name: "Tính toàn vẹn của mã VBS bị vô hiệu hóa",Desc: "Vô hiệu hóa tính năng bảo vệ tính toàn vẹn mã dựa trên ảo hóa"},
DisableErrorReporting: {Name: "Tắt báo cáo lỗi",Desc: "Tắt báo cáo lỗi màn hình để cải thiện hiệu suất hệ thống"},
DisableFrequentFolders: {Name: "Tắt thư mục thường xuyên"},
DisableGameBar: {Name: "Tắt Game Bar & Game DVR",Desc: "Tính năng Game DVR cho phép bạn ghi lại quá trình chơi trò chơi của mình ở chế độ nền.`nTính năng này nằm trên Thanh trò chơi – nơi cung cấp các nút để ghi lại quá trình chơi trò chơi và chụp ảnh màn hình bằng tính năng Game DVR.`nNhưng tính năng này có thể làm chậm tốc độ của bạn hiệu suất chơi game bằng cách quay video ở chế độ nền."},
DisableGoogleUpdateTask: {Name: "Tắt GoogleUpdateTask"},
DisableHibernate: {Name: "Tắt chế độ ngủ đông"},
DisableHybridSleep: {Name: "Tắt chế độ ngủ kết hợp"},
DisableLockScreen: {Name: "Tắt màn hình khóa"},
DisableLowDiskSpaceChecks: {Name: "Vô hiệu hóa kiểm tra dung lượng ổ đĩa thấp",Desc: "Tối ưu hóa hệ thống con I/O đĩa để cải thiện hiệu suất hệ thống"},
Disablememorypagination: {Name: "Vô hiệu hóa phân trang bộ nhớ",Desc: "Tắt tính năng phân trang bộ nhớ và giảm I/O ổ đĩa để cải thiện hiệu suất ứng dụng.`n(Có thể bỏ qua tùy chọn nếu bộ nhớ vật lý <1 GB)"},
DisableMenuShowDelay: {Name: "Vô hiệu hóa độ trễ hiển thị menu",Desc: "Tối ưu hóa tốc độ phản hồi của màn hình hệ thống"},
DisableMicrosoftEdgeUpdateTask: {Name: "Vô hiệu hóa MicrosoftEdgeUpdateTask"},
DisableMSACloudSearch: {Name: "Tắt MSA tìm kiếm nội dung trên đám mây",Desc: "Tắt Tìm kiếm nội dung trên đám mây cho Tài khoản Microsoft"},
DisableMSDefender: {Name: "Vô hiệu hóa Microsoft Defender",Desc: "Bật/Tắt Microsoft Defender chỉ bằng 1 cú nhấp chuột.`nNó sẽ tự động khởi động lại máy tính."},
DisableOfferSuggestions: {Name: "Tắt đề xuất ưu đãi"},
DisablePersonalizedAdsStoreApps: {Name: "Tắt các ứng dụng trên StoreApps được cá nhân hóa"},
DisablePrefetchParameters: {Name: "Tắt tham số tìm nạp trước",Desc: "Vô hiệu hóa các tham số tìm nạp trước để tăng tuổi thọ hoạt động của SSD"},
DisablePrintSpooler: {Name: "Tắt bộ đệm máy in"},
DisableRecentFiles: {Name: "Tắt các tệp gần đây"},
DisableRemoteRegAccess: {Name: "Tắt quyền truy cập Reg từ xa",Desc: "Vô hiệu hóa sửa đổi sổ đăng ký từ máy tính từ xa"},
DisableScheduledDefrag: {Name: "Vô hiệu hóa phân mảnh theo lịch trình"},
DisableSettingsAppSuggestions: {Name: "Tắt cài đặt Đề xuất ứng dụng"},
DisableShortcutText: {Name: "Tắt văn bản lối tắt"},
DisableSleep: {Name: "Tắt chế độ ngủ"},
DisableStartMenuAppSuggestions: {Name: "Tắt đề xuất ứng dụng trên menu bắt đầu"},
DisableSyncProviderNotifications: {Name: "Tắt thông báo nhà cung cấp đồng bộ hóa"},
DisableSystemRestore: {Name: "Vô hiệu hóa khôi phục hệ thống"},
DisableTailoredExperiences: {Name: "Vô hiệu hóa trải nghiệm phù hợp"},
DisableTipsAndSuggestions: {Name: "Tắt mẹo và đề xuất"},
DisableTurnOffDisplay: {Name: "Tắt Tắt hiển thị"},
DisableVisualStudioTelemetry: {Name: "Vô hiệu hóa từ xa VisualStudio"},
DisableWCE: {Name: "Vô hiệu hóa cải tiến WCE",Desc: "Tắt tính năng Cải thiện trải nghiệm khách hàng của Windows`n`n- Proxy: Tác vụ này thu thập và tải lên dữ liệu SQM tự động nếu được chọn tham gia Chương trình cải thiện trải nghiệm khách hàng của Microsoft.`n- Trình đánh giá tương thích của Microsoft: Thu thập thông tin đo từ xa của chương trình nếu đã chọn tham gia Chương trình cải thiện trải nghiệm khách hàng của Microsoft."},
DisableWebSearch: {Name: "Tắt tìm kiếm trên web",Desc: "Tắt tìm kiếm trực tuyến và chỉ bao gồm các kết quả web từ Bing cho tài khoản của bạn khi bạn thực hiện tìm kiếm trên thanh tác vụ"},
DisableWebSearchStartMenu: {Name: "Tắt Menu Bắt đầu Tìm kiếm trên Web",Desc: "Tắt Tìm kiếm trên Web trong Menu Bắt đầu"},
DisableWindowsFeedback: {Name: "Vô hiệu hóa phản hồi của Windows"},
DisableWindowsSearch: {Name: "Vô hiệu hóa tìm kiếm Windows"},
EnableDarkMode: {Name: "Bật Chế độ tối"},
Explorer: {Name: "File Explorer"},
HideMostUsedApps: {Name: "Ẩn các ứng dụng được sử dụng nhiều nhất",Desc: "Tắt `"Hiển thị các ứng dụng được sử dụng nhiều nhất`" trên menu Bắt đầu"},
HideStartMenuAccountNotifications: {Name: "Ẩn thông báo liên quan đến tài khoản",Desc: "Tắt `"Hiển thị thông báo liên quan đến tài khoản`" trên menu Bắt đầu"},
HideStartMenuRecentlyAdded: {Name: "Ẩn các ứng dụng được thêm gần đây",Desc: "Tắt `"Hiển thị các ứng dụng đã thêm gần đây`" trên menu Bắt đầu"},
HideStartMenuRecentlyOpened: {Name: "Ẩn các mục đã mở gần đây",Desc: "Tắt `"Hiển thị các mục đã mở gần đây trong Bắt đầu, Danh sách nhảy và File Explorer`" trên menu Bắt đầu"},
HideStartMenuRecommendations: {Name: "Ẩn đề xuất",Desc: "Tắt `"Hiển thị đề xuất về mẹo, lối tắt, ứng dụng mới, v.v.`" trên menu Bắt đầu"},
HideWindowsSecurityNoncriticalNotifications: {Name: "Ẩn thông báo không quan trọng của Bảo mật Windows",Desc: "Chỉ hiển thị các thông báo quan trọng từ Bảo mật Windows.`nNếu cài đặt GP Loại bỏ tất cả thông báo đã được bật thì cài đặt này sẽ không có hiệu lực."},
HideWindowsSecurityNotifications: {Name: "Ẩn thông báo Bảo mật Windows",Desc: "Ẩn tất cả thông báo khỏi Bảo mật Windows."},
HostsEdit_BtnImportFromFile: {Name: "Nhập từ tập tin"},
HostsEdit_BtnImportFromLink: {Desc: "Nhập từ liên kết đến máy chủ"},
HostsEdit_BtnReload: {Name: "Tải lại tập tin máy chủ"},
HostsEdit_BtnResetDefault: {Name: "Trở lại chế độ mặc định"},
HostsEdit_BtnSave: {Name: "Text_Save"},
HostsEdit_BtnSaveAs: {Name: "Lưu thành"},
HostsEdit_TxtSelectLink: {Name: "Chọn liên kết để nhập danh sách chặn vào máy chủ:"},
IncreaseIconCache: {Name: "Tăng bộ nhớ đệm biểu tượng",Desc: "Tăng bộ nhớ đệm biểu tượng hệ thống và tăng tốc độ hiển thị trên màn hình"},
IoPageLockLimit: {Name: "Giới hạn khóa trang Io",Desc: "Tối ưu hóa cài đặt mặc định của bộ nhớ để cải thiện hiệu suất hệ thống"},
Link_ClearStartMenu: {Name: "Xóa Menu Bắt đầu"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "Giải quyết liên kết Bỏ qua LinkInfo",Desc: "Không theo dõi các phím tắt Shell trong quá trình chuyển vùng"},
MouseHoverTime: {Name: "Thời gian di chuột",Desc: "Tăng tốc độ hiển thị của Taskbar Window Previews"},
NoInternetOpenWith: {Name: "Không có Internet Mở bằng",Desc: "Tắt dịch vụ Liên kết tệp Internet"},
NoResolveSearch: {Name: "Không tìm kiếm giải quyết",Desc: "Không sử dụng phương pháp dựa trên tìm kiếm khi giải quyết các phím tắt shell"},
NoResolveTrack: {Name: "Không có bản nhạc giải quyết",Desc: "Không sử dụng phương pháp dựa trên theo dõi khi phân giải các phím tắt shell.`nCài đặt này ngăn hệ thống sử dụng các tính năng theo dõi NTFS để phân giải phím tắt."},
NumLockonStartup: {Name: "Num Lock khi khởi động"},
OpenFileExplorerThisPC: {Name: "Mở File Explorer ThisPC"},
OptimizeNetworkTransfer: {Name: "Tối ưu hóa chuyển mạng",Desc: "Tối ưu hóa cài đặt mạng để cải thiện hiệu suất truyền"},
Optimizeprocessorperformance: {Name: "Tối ưu hóa hiệu suất xử lý",Desc: "Tối ưu hóa hiệu suất xử lý để giúp các ứng dụng, trò chơi, v.v. chạy mượt mà hơn."},
OptimizeRefreshPolicy: {Name: "Tối ưu hóa chính sách làm mới",Desc: "Tối ưu hóa hệ thống con I/O đĩa để cải thiện hiệu suất hệ thống"},
Optional: {Name: "Không bắt buộc"},
PackageManager_BtnDisable: {Desc: "Bật/Tắt cho tất cả người dùng"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "Hủy cấp phép gói ứng dụng để người dùng mới trên thiết bị sẽ không còn cài đặt ứng dụng tự động nữa."},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "Hiển thị danh sách các gói đã cài đặt của tất cả người dùng."},
PackageManager_Mode: {Desc: "Chế độ đã cài đặt: Hiển thị danh sách các gói đã cài đặt.`nChế độ chưa được cài đặt: Hiển thị danh sách có trên máy tính của bạn nhưng chưa được người dùng hiện tại cài đặt."},
Privacy: {Name: "Riêng tư"},
ShowExtensions: {Name: "Hiển thị tiện ích mở rộng"},
ShowHidden: {Name: "Hiển thị ẩn"},
ShowHiddenSystem: {Name: "Hiển thị hệ thống ẩn"},
ShowThisPC: {Name: "Hiển thị PC này"},
ShutdownAcceleration: {Name: "Tăng tốc tắt máy",Desc: "Giảm tình trạng ứng dụng không hoạt động khi tắt máy để cải thiện quá trình tắt máy"},
SnippingPrintScreen: {Name: "Sử dụng Công cụ Cắt để chụp màn hình"},
StartMenu: {Name: "Menu Bắt đầu"},
System: {Name: "Hệ thống"},
Text_Architecture: "Ngành kiến ​​​​trúc",
Text_BackgroundImage: "Hình nền",
Text_Cancel: "Hủy bỏ",
Text_CheckUpdate: "Kiểm tra cập nhật",
Text_ClearStartMenu_Confirm: "Bạn có chắc chắn muốn xóa bố cục menu Bắt đầu không?`n(Tệp sao lưu `"WinTune_StartMenuLayout_xxxx.json`" sẽ được tạo)",
Text_ClearStartMenu_Done: "Xóa StartMenu Xong!",
Text_Close: "Đóng",
Text_CommandLine: "Dòng lệnh",
Text_ConnectionFailed: "Kết nối với máy chủ không thành công.",
Text_CurrentVersion: "Phiên bản hiện tại",
Text_Custom: "Tùy chọn",
Text_DefaultImage: "Hình ảnh mặc định",
Text_Delete: "Xóa bỏ",
Text_DeprovisionPackage: "Hủy cấp phép",
Text_DeselectAll: "Bỏ chọn tất cả",
Text_Details: "Chi tiết",
Text_Disable: "Vô hiệu",
Text_Disabled: "Đã vô hiệu",
Text_DisableMSDefender0: "Việc bật Bộ bảo vệ Microsoft yêu cầu phải khởi động lại máy tính.`nBạn có chắc chắn muốn thực hiện việc này không?",
Text_DisableMSDefender1: "Việc tắt Microsoft Defender yêu cầu khởi động lại máy tính.`nBạn có chắc chắn muốn thực hiện việc này không?",
Text_DisplayName: "Tên hiển thị",
Text_EffectivePath: "Đường dẫn hiệu quả",
Text_Enable: "Cho phép",
Text_Enabled: "Đã cho phép",
Text_FamilyName: "Tên gia đình",
Text_FindRegistry: "Tìm trong Registry",
Text_FullName: "Tên đầy đủ",
Text_Homepage: "Trang chủ",
Text_HR_Optimize: "------- Tối ưu hóa -------",
Text_HR_Tools: "-------- Công cụ --------",
Text_Install: "Cài đặt",
Text_InstalledAllUsers: "Tất cả người dùng",
Text_InstalledDate: "Ngày cài đặt",
Text_InstalledMode: "Chế độ đã cài đặt",
Text_InstalledPath: "Đường dẫn đã cài đặt",
Text_Name: "Tên",
Text_NewestVersion: "Phiên bản mới nhất",
Text_No: "Không",
Text_None: "Không",
Text_NotInstalledMode: "Chế độ chưa được cài đặt",
Text_NoUpdate: "Không có bản cập nhật có sẵn. Bạn đang sử dụng phiên bản mới nhất.",
Text_OK: "Được rồi",
Text_OpenTarget: "Điểm đích",
Text_Properties: "Thuộc tính",
Text_PublisherDisplayName: "Nhà xuất bản",
Text_Save: "Lưu",
Text_SearchOnline: "Tìm kiếm trực tuyến",
Text_SelectAll: "Chọn tất cả",
Text_SignatureKind: "Loại chữ ký",
Text_Status: "Trạng thái",
Text_Target: "Mục tiêu",
Text_Type: "Kiểu",
Text_Uninstall: "Gỡ cài đặt",
Text_Update: "Cập nhật",
Text_UpdateFailed: "Cập nhật không thành công, vui lòng thử lại sau.",
Text_Updating: "Đang cập nhật",
Text_Version: "Phiên bản",
Text_WaitDlg: "Vui lòng chờ...",
Text_WhatsNew: "Có gì mới",
Text_Yes: "Đúng",
UninstallOneDrive: {Name: "Gỡ cài đặt OneDrive"},
UnpinChat: {Name: "Trò chuyện"},
UnpinCopilot: {Name: "Phi công phụ"},
UnpinCortana: {Name: "Cortana"},
UnpinEdge: {Name: "Bờ rìa"},
UnpinFileExplorer: {Name: "Chương trình quản lý dữ liệu"},
UnpinMail: {Name: "Thư"},
UnpinNewsandInterests: {Name: "Tin tức và sở thích"},
UnpinSearch: {Name: "Tìm kiếm"},
UnpinStore: {Name: "Cửa hàng"},
UnpinTaskbar: {Name: "Thanh tác vụ"},
UnpinTaskView: {Name: "Chế độ xem tác vụ"},
UnpinWidgets: {Name: "Widget"},
VerCtrl: {Desc: "Bấm để kiểm tra cập nhật",Desc1: "Đã có phiên bản mới`n(Bấm để xem chi tiết)"}
},
zh_cn: {
Name: "中文（简体）",
Translator: "Jvcon",
Flag: "iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAHYcAAB2HAGnwnjqAAAE7mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSwgMjAyMy8wNi8yNS0yMDowMTo1NSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wMS0yNFQyMjoyOTowMiswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDEtMjVUMTA6NTg6NDgrMDc6MDAiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjQtMDEtMjVUMTA6NTg6NDgrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmVkNWQ2MjVmLTc1MzEtMWE0Ny1iNWFjLTc4MDVmYjIyYjNlNSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDplZDVkNjI1Zi03NTMxLTFhNDctYjVhYy03ODA1ZmIyMmIzZTUiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplZDVkNjI1Zi03NTMxLTFhNDctYjVhYy03ODA1ZmIyMmIzZTUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmVkNWQ2MjVmLTc1MzEtMWE0Ny1iNWFjLTc4MDVmYjIyYjNlNSIgc3RFdnQ6d2hlbj0iMjAyNC0wMS0yNFQyMjoyOTowMiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pl2SEAcAAAOYSURBVDjLhZTNb1VVFMV/+9xz73uvH7YVBYEGUAkRNKmRRIzEMFBLBxpw5syBI5SRJA79A0yYFUmc6H9gSBiAH4kkQqIThZDgxAAWSiGlrbSv771779nLwUOwReJK1mDv7LOyP87eJh5icctz1AMbMHURDkVrUvJ9wDYAxAz4z1ZzNqPCY07s9hi9fuWBRmQdTIIse12WfYr8HYwMIN2JWFOEMSVhp5XC56AL69+HNYac1AzTdZmf9yoekilTApVGc/Iexatt0kLMZByqs+J8isV0SL5GMGqoBSbwQG9g+Ezq2cHsiRJkqGvg4IsZI5/dor6Z0/nueaxwaAiJj7uNxs5hG51CBhjW3fYCmFgphr7oeH6EPwJj0zPUVwuWpzeSbaqwpojjJd4LpJkcrWaE0RqLImU5jU51cnBl4SPDCD1PrJbZRPWMjhQbutiI03p3icZrbVQa8dmSMJooL7eoLjcpXumw8cffibt6pIVISDW9VnakM5BPdJoQennOKq3jFmrGvrzG5quXECLubbN18VeGjs2Rlg2aCRuu8Q7UcxHvgqIjObjoFEPHe9bAZnfvfRvzb30uYk8knvz6Os0DywC0v3qKxU+2Yi0RxmoM8NVAulWQPV0RRhKqDRBYwLHJkJIfUIKwqaa61oDaSHdyBNR3ImkpJ4zVKBnCIINsa9kfihsChCEJww8Eg3FJ1HcDrfcWcYnZF3cz98Yu8olV4kttUifwT0zc02HjT1fI9nSo7/b9D+gaD0IIYNCp5yLzH2xHmSgvNbl7dBwbTJA59e3YL/deYOWbUdJ8hnLdz/Aho6MbCKwQ9WyEwrGGsFFQ16hv95ep9f4ClEbn9AjdY+NkWypsKKF//WuZ3QhyzglwFyqEcuEO7vTtINJfgYEP52keXsS7Rthcoux+HOD9zSc552xm+y6qvPG9LLwZJB6BgCis5agb0ErAmmvj3AyT/xDL3ls2u2UHHuLEamv4t8xrHgd1AhiEwYSSrRUMgWZ7+eWQ0sUQ7/UoltoXi/bKySoLyB3/D6pRo6ImVXroc6e0QN7zk41KF4sUMH9QmXF1fOeZsmgczFLif2FGskCj6p7dcXN+ytTPOvRvBAREs9OesqQTCXDp8UQkdxAnmr3OVNASxiLG4tp7qBDIaz8aqnq/y0+5lFy+XjB50qm8KvcXqT7qIVt7Dx9pvoElv4DZYYiTmPY52nZ/DH9i/BJdZ4O8X9o6/A0kGDN/Gi4umQAAAABJRU5ErkJggg==",
AUOptions: {Name: "AU选项",Desc: "在下载Windows更新前设置通知"},
AutoEndTasks: {Name: "自动结束任务",Desc: "关闭冻结的进程以避免系统崩溃"},
BtnHostsEdit: {Name: "Hosts编辑"},
PackageManager: {Name: "软件管理"},
BtnRestartExplorer: {Name: "重启资源管理器"},
BtnStartupManager: {Name: "自启动管理器"},
BtnSys_Close: {Desc: "Text_Close"},
BtnSys_Language: {Desc: "语言"},
BtnSys_LoadOptimizeConfig: {Desc: "加载优化配置文件"},
BtnSys_Minimize: {Desc: "最小化"},
BtnSys_ReloadTab: {Desc: "重新加载此选项卡"},
BtnSys_SaveImage: {Desc: "截屏并保存为图片"},
BtnSys_SaveOptimizeConfigAll: {Desc: "将所有优化配置保存到文件"},
BtnSys_SaveOptimizeConfigTab: {Desc: "仅保存此标签的优化配置到文件"},
BtnSys_Search: {Desc: "搜索优化"},
BtnSys_Setting: {Desc: "设置"},
BtnSys_Theme: {Desc: "主题"},
ClassicContextMenu: {Name: "经典上下文菜单"},
DiagnosticDataOff: {Name: "诊断数据关闭"},
DisableAADCloudSearch: {Name: "关闭云内容搜索 AAD",Desc: "关闭工作或学校帐户的云内容搜索"},
DisableAdsOnLockScreen: {Name: "禁用锁屏广告"},
DisableAeDebug: {Name: "禁用AeDebug",Desc: "禁用调试器以加快错误处理"},
DisableAnimationEffectMaxMin: {Name: "禁用最大最小动画效果",Desc: "关闭窗口最大化或最小化时的动画效果以加快窗口响应速度"},
DisableAppendCompletion: {Name: "禁用追加完成",Desc: "禁用内联自动完成（追加完成或自动填充）"},
DisableAutoDefragIdle: {Name: "禁用空闲状态下的自动碎片整理",Desc: "闲置时禁用自动碎片整理以延长SSD的使用寿命"},
DisableAutoInstallationApps: {Name: "禁用自动安装应用"},
DisableAutoplay: {Name: "禁用自动播放",Desc: "禁用驱动器上的“自动播放”功能以避免病毒感染"},
DisableAutoSuggest: {Name: "禁用自动建议",Desc: "禁用自动建议（自动完成下拉）"},
DisableAutoWindowsUpdates: {Name: "禁用自动Windows更新",Desc: "禁用自动更新"},
DisableBackgroundApps: {Name: "禁用后台应用"},
DisableBootOptimize: {Name: "禁用启动优化",Desc: "禁用启动时对系统驱动器的碎片整理以延长SSD的使用寿命"},
DisableCrashAutoReboot: {Name: "禁用崩溃自动重启",Desc: "当系统遇到蓝屏死机时禁用自动重启"},
DisableCustomInking: {Name: "禁用自定义墨迹书写",Desc: "禁用自定义墨迹书写和打字词典"},
DisableDeviceSearchHistory: {Name: "关闭本地搜索历史记录",Desc: "在此设备上本地关闭搜索历史记录"},
DisableDiagTrack: {Name: "禁用DiagTrack",Desc: "DiagTrack - 互联用户体验和遥测服务支持支持应用内和互联用户体验的功能。`n此外，此服务还管理事件驱动的诊断和使用信息的收集和传输（用于改善用户的体验和质量） Windows 平台），当在反馈和诊断下启用诊断和使用隐私选项设置时。"},
DisabledVBSCodeIntegrity: {Name: "禁用VBS代码完整性",Desc: "禁用基于虚拟化的代码完整性保护"},
DisableErrorReporting: {Name: "禁用错误报告",Desc: "禁用屏幕错误报告以提高系统性能"},
DisableFrequentFolders: {Name: "禁用常用文件夹"},
DisableGameBar: {Name: "禁用游戏栏和游戏DVR",Desc: "游戏DVR功能允许你在后台记录你的游戏。它位于游戏栏上 - 提供了使用游戏DVR功能记录游戏和截图的按钮。但是，通过在后台录制视频，它可能会降低你的游戏性能。"},
DisableGoogleUpdateTask: {Name: "禁用Google更新任务"},
DisableHibernate: {Name: "禁用休眠"},
DisableHybridSleep: {Name: "禁用混合休眠"},
DisableLockScreen: {Name: "禁用锁屏"},
DisableLowDiskSpaceChecks: {Name: "禁用低磁盘空间检查",Desc: "优化磁盘I/O子系统以提高系统性能"},
Disablememorypagination: {Name: "禁用内存分页",Desc: "禁用内存分页并减少磁盘I/O以提高应用程序性能。`n(如果物理内存<1 GB，此选项可能会被忽略)"},
DisableMenuShowDelay: {Name: "禁用菜单显示延迟",Desc: "优化系统显示的响应速度"},
DisableMicrosoftEdgeUpdateTask: {Name: "禁用Microsoft Edge更新任务"},
DisableMSACloudSearch: {Name: "关闭云内容搜索 MSA",Desc: "关闭 Microsoft 帐户的云内容搜索"},
DisableMSDefender: {Name: "禁用 Microsoft Defender",Desc: "一键启用/禁用 Microsoft Defender。`n它将自动重新启动计算机。"},
DisableOfferSuggestions: {Name: "禁用提供建议"},
DisablePersonalizedAdsStoreApps: {Name: "禁用个性化广告商店应用"},
DisablePrefetchParameters: {Name: "禁用预取参数",Desc: "禁用预取参数以延长SSD的使用寿命"},
DisablePrintSpooler: {Name: "禁用打印服务"},
DisableRecentFiles: {Name: "禁用最近的文件"},
DisableRemoteRegAccess: {Name: "禁用远程注册访问",Desc: "禁止从远程计算机修改注册表"},
DisableScheduledDefrag: {Name: "禁用计划碎片整理"},
DisableSettingsAppSuggestions: {Name: "禁用设置应用建议"},
DisableShortcutText: {Name: "禁用快捷方式文本"},
DisableSleep: {Name: "禁用睡眠"},
DisableStartMenuAppSuggestions: {Name: "禁用开始菜单应用程序建议"},
DisableSyncProviderNotifications: {Name: "禁用同步提供商通知"},
DisableSystemRestore: {Name: "禁用系统还原"},
DisableTailoredExperiences: {Name: "禁用定制体验"},
DisableTipsAndSuggestions: {Name: "禁用提示和建议"},
DisableTurnOffDisplay: {Name: "禁用关闭显示"},
DisableVisualStudioTelemetry: {Name: "禁用VisualStudio遥测"},
DisableWCE: {Name: "禁用WCE改进",Desc: "禁用Windows客户体验改进`n`n- 代理：此任务收集并上传autochk SQM数据，如果选择加入Microsoft客户体验改进计划。`n- Microsoft兼容性评估器：如果选择加入Microsoft客户体验改进计划，将收集程序遥测信息。"},
DisableWebSearch: {Name: "禁用网络搜索",Desc: "当您在任务栏上进行搜索时，禁用在线搜索并仅包含您帐户的 Bing 网络结果"},
DisableWebSearchStartMenu: {Name: "禁用网络搜索开始菜单",Desc: "禁用开始菜单中的网络搜索"},
DisableWindowsFeedback: {Name: "禁用Windows反馈"},
DisableWindowsSearch: {Name: "禁用Windows搜索"},
EnableDarkMode: {Name: "启用暗黑模式"},
Explorer: {Name: "文件管理器"},
HideMostUsedApps: {Name: "隐藏最常用的应用程序",Desc: "关闭“开始”菜单上的`"显示最常用的应用`""},
HideStartMenuAccountNotifications: {Name: "隐藏与帐户相关的通知",Desc: "关闭“开始”菜单上的`"显示帐户相关通知`""},
HideStartMenuRecentlyAdded: {Name: "隐藏最近添加的应用程序",Desc: "关闭“开始”菜单上的`"显示最近添加的应用`""},
HideStartMenuRecentlyOpened: {Name: "隐藏最近打开的项目",Desc: "关闭“开始”菜单上的`"在“开始”、跳转列表和文件资源管理器中显示最近打开的项目`""},
HideStartMenuRecommendations: {Name: "隐藏推荐",Desc: "关闭“开始”菜单上的`"显示提示、快捷方式、新应用等的推荐`""},
HideWindowsSecurityNoncriticalNotifications: {Name: "隐藏 WS 非关键通知",Desc: "仅显示来自 Windows 安全的重要通知。`n如果已启用“禁止所有通知 GP”设置，则此设置将无效。"},
HideWindowsSecurityNotifications: {Name: "隐藏 WS 通知",Desc: "隐藏来自 Windows 安全的所有通知。"},
HostsEdit_BtnImportFromFile: {Name: "从文件导入"},
HostsEdit_BtnImportFromLink: {Name: "从链接导入"},
HostsEdit_BtnReload: {Name: "重新加载主机文件"},
HostsEdit_BtnResetDefault: {Name: "重置默认"},
HostsEdit_BtnSave: {Name: "保存"},
HostsEdit_BtnSaveAs: {Name: "另存为"},
HostsEdit_TxtSelectLink: {Name: "选择将阻止列表导入主机的链接："},
IncreaseIconCache: {Name: "增加图标缓存",Desc: "增加系统图标缓存并加快桌面显示速度"},
IoPageLockLimit: {Name: "I/O页面锁定限制",Desc: "优化内存的默认设置以提高系统性能"},
Link_ClearStartMenu: {Name: "清除开始菜单"},
Link_DeselectAll: {Name: "Text_DeselectAll"},
Link_SelectAll: {Name: "Text_SelectAll"},
LinkResolveIgnoreLinkInfo: {Name: "链接解析忽略链接信息",Desc: "在漫游时不跟踪Shell快捷方式"},
MouseHoverTime: {Name: "鼠标悬停时间",Desc: "加快任务栏窗口预览的显示速度"},
NoInternetOpenWith: {Name: "无互联网打开方式",Desc: "关闭互联网文件关联服务"},
NoResolveSearch: {Name: "无解析搜索",Desc: "在解析shell快捷方式时不使用基于搜索的方法"},
NoResolveTrack: {Name: "无解析轨道",Desc: "解析 shell 快捷方式时不要使用基于跟踪的方法。`n此设置可防止系统使用 NTFS 跟踪功能来解析快捷方式。"},
NumLockonStartup: {Name: "启动时数字锁定"},
OpenFileExplorerThisPC: {Name: "打开文件资源管理器ThisPC"},
OptimizeNetworkTransfer: {Name: "优化网络传输",Desc: "优化网络设置以提高传输性能"},
Optimizeprocessorperformance: {Name: "优化处理器性能",Desc: "优化处理器性能使应用程序、游戏等运行更加流畅。"},
OptimizeRefreshPolicy: {Name: "优化刷新策略",Desc: "优化磁盘I/O子系统以提高系统性能"},
Optional: {Name: "可选"},
PackageManager_BtnDisable: {Desc: "为所有用户启用/禁用"},
PackageManager_DeprovisionPackage: {Name: "Text_DeprovisionPackage",Desc: "取消配置应用程序包，以便设备上的新用户将不再自动安装该应用程序。"},
PackageManager_InstalledAllUsers: {Name: "Text_InstalledAllUsers",Desc: "显示所有用户安装的软件包的列表。"},
PackageManager_Mode: {Desc: "已安装模式：显示已安装软件包的列表。`n未安装模式：显示计算机上但当前用户未安装的列表。"},
Privacy: {Name: "隐私"},
ShowExtensions: {Name: "显示扩展名"},
ShowHidden: {Name: "显示隐藏文件"},
ShowHiddenSystem: {Name: "显示隐藏的系统文件"},
ShowThisPC: {Name: "显示此电脑"},
ShutdownAcceleration: {Name: "关机加速",Desc: "减少关机时的应用程序空闲以改善关机过程"},
SnippingPrintScreen: {Name: "截图打印屏幕"},
StartMenu: {Name: "开始菜单"},
System: {Name: "系统"},
Text_Architecture: "架构",
Text_BackgroundImage: "背景图",
Text_Cancel: "取消",
Text_CheckUpdate: "检查更新",
Text_ClearStartMenu_Confirm: "您确定要清除“开始”菜单布局吗？`n（将创建备份文件 `"WinTune_StartMenuLayout_xxxx.json`"）",
Text_ClearStartMenu_Done: "清除开始菜单 完成！",
Text_Close: "关闭",
Text_CommandLine: "命令行",
Text_ConnectionFailed: "连接到服务器失败。",
Text_CurrentVersion: "当前版本",
Text_Custom: "自定义",
Text_DefaultImage: "默认图片",
Text_Delete: "删除",
Text_DeprovisionPackage: "取消配置包",
Text_DeselectAll: "取消全选",
Text_Details: "详细",
Text_Disable: "禁用",
Text_Disabled: "已禁用",
Text_DisableMSDefender0: "启用 Microsoft Defender 需要重新启动计算机。`n您确定要执行此操作吗？",
Text_DisableMSDefender1: "禁用 Microsoft Defender 需要重新启动计算机。`n您确定要执行此操作吗？",
Text_DisplayName: "显示名称",
Text_EffectivePath: "有效路径",
Text_Enable: "启用",
Text_Enabled: "启用",
Text_FamilyName: "家庭名称",
Text_FindRegistry: "在注册表中查找",
Text_FullName: "全名",
Text_Homepage: "主页",
Text_HR_Optimize: " -  -  - - 优化  -  -  - -",
Text_HR_Tools: " -  -  -  -  工具  -  -  -  - ",
Text_Install: "安装",
Text_InstalledAllUsers: "全部用户",
Text_InstalledDate: "安装日期",
Text_InstalledMode: "已安装模式",
Text_InstalledPath: "安装路径",
Text_Name: "名称",
Text_NewestVersion: "最新版本",
Text_No: "不",
Text_None: "没有任何",
Text_NotInstalledMode: "未安装模式",
Text_NoUpdate: "没有可用的更新。您正在使用最新版本。",
Text_OK: "好的",
Text_OpenTarget: "目标位置",
Text_Properties: "特性",
Text_PublisherDisplayName: "发布者",
Text_Save: "节省",
Text_SearchOnline: "网上搜索",
Text_SelectAll: "全选",
Text_SignatureKind: "签名类型",
Text_Status: "状态",
Text_Target: "目标",
Text_Type: "类型",
Text_Uninstall: "卸载",
Text_Update: "更新",
Text_UpdateFailed: "更新失败，请稍后重试。",
Text_Updating: "更新中",
Text_Version: "版本",
Text_WaitDlg: "请稍等...",
Text_WhatsNew: "什么是新的",
Text_Yes: "是的",
UninstallOneDrive: {Name: "卸载 OneDrive"},
UnpinChat: {Name: "聊天"},
UnpinCopilot: {Name: "副驾驶"},
UnpinCortana: {Name: "科塔娜"},
UnpinEdge: {Name: "边缘"},
UnpinFileExplorer: {Name: "文件管理器"},
UnpinMail: {Name: "邮件"},
UnpinNewsandInterests: {Name: "新闻和兴趣"},
UnpinSearch: {Name: "搜索"},
UnpinStore: {Name: "店铺"},
UnpinTaskbar: {Name: "任务栏"},
UnpinTaskView: {Name: "任务视图"},
UnpinWidgets: {Name: "小部件"},
VerCtrl: {Desc: "点击检查更新",Desc1: "有新版本`n（点击查看详情）"}
}
}
CheckOS() {
If A_Is64bitOS && A_PtrSize==4
MsgBoxError("You need the 64-bit version of the software to run on 64-bit Windows.`n`nhttps://github.com/tranht17/WinTune/releases", 1, "Incompatible")
Else If RegKeyExist("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE")
MsgBoxError("WinPE not supported", 1, "Incompatible")
}
LogError(exception, mode) {
Debug(exception)
try DestroyDlg()
return true
}
ExitFunc(ExitReason, ExitCode) {
UnLoadHive()
}
ArgParse() {
for ,param in A_Args {
App.Param:={}
If InStr(param, "/User=")=1 {
User:=SubStr(param,7)
App.User:=User
} Else If InStr(param, "/LoadConfig=")=1 {
sparam:=SubStr(param,13)
App.Param.LoadConfig:=sparam
} Else If InStr(param, "/SaveConfig")=1 {
If param="/SaveConfig"
sparam:=App.Name "_OptimizeConfig_" A_Now ".json"
Else If InStr(param, "/SaveConfig=")=1
sparam:=SubStr(param,13)
App.Param.SaveConfig:=sparam
}
}
}
ArgProcess() {
If App.HasOwnProp("Param") && ObjOwnPropCount(App.Param) {
If App.Param.HasOwnProp("SaveConfig") {
SaveOptimizeConfigAll(App.Param.SaveConfig)
}
If App.Param.HasOwnProp("LoadConfig") {
LoadOptimizeConfig(App.Param.LoadConfig)
}
ExitApp
}
}
Init() {
If !App.HasOwnProp("User") || !App.User
App.User:=GetActiveUser()
App.UserSID:=LookupAccountName(App.User)
App.UserProfile:=GetUSERPROFILE()
App.HKCU:=GetHKCU()
App.SystemInfo:=GetSystemInfo()
App.LangSelected:=IniRead("config.ini", "General", "Language", "zh_cn")
App.IsWin11:=VerCompare(A_OSVersion, ">=10.0.22000")
}
GetSystemInfo() {
SI:={}
SI.InstallationType:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType")
SI.EditionID:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID")
Return SI
}
RegKeyExist(RegKey) {
sKey:=StrSplit(RegKey, "\")
cKey:=""
Loop (sKey.Length-1)
cKey.=(A_Index=1?"":"\") sKey[A_Index+1]
exists := !DllCall("RegOpenKeyExW", "PTR", NumHK(sKey[1]), "wstr", cKey
, "UINT", 0, "UINT", 131097, "PTR*", &hKey:=0)
DllCall("RegCloseKey", "PTR", hKey)
return exists
}
NumHK(RootKey) {
NumRootKey:=0x80000001
Switch RootKey {
Case "HKEY_CLASSES_ROOT","HKCR": NumRootKey:=0x80000000
Case "HKEY_CURRENT_USER","HKCU": NumRootKey:=0x80000001
Case "HKEY_LOCAL_MACHINE","HKLM": NumRootKey:=0x80000002
Case "HKEY_USERS","HKU": NumRootKey:=0x80000003
Case "HKEY_CURRENT_CONFIG","HKCC": NumRootKey:=0x80000005
}
Return NumRootKey
}
HKCU2HCU(KeyName) {
If InStr(KeyName, "HKEY_CURRENT_USER")=1
KeyName := StrReplace(KeyName, "HKEY_CURRENT_USER", App.HKCU,,,1)
Else If InStr(KeyName, "HKCU")=1
KeyName := StrReplace(KeyName, "HKCU", App.HKCU,,,1)
Return KeyName
}
GetHKCU() {
UnLoadHive()
rHKCU:="HKU\" App.UserSID
If !RegKeyExist(rHKCU) {
HiveFile:=App.UserProfile "\NTUSER.DAT"
If !FileExist(HiveFile)
MsgBoxError("'" HiveFile "' does not exist", 1)
RegLoadKey(HiveFile)
rHKCU:="HKU\DeepOptimize_Hive_tmp"
}
Return rHKCU
}
UnLoadHive() {
If RegKeyExist("HKU\DeepOptimize_Hive_tmp")
RegUnLoadKey()
}
RegLoadKey(HiveFile, HiveName:="DeepOptimize_Hive_tmp", RootKey:="HKU") {
EnablePrivilege("SeRestorePrivilege")
EnablePrivilege("SeBackupPrivilege")
If r:=DllCall("Advapi32.dll\RegLoadKey", "int", NumHK(RootKey), "str", HiveName, "str", HiveFile)
MsgBoxError("(" r ")RegLoadKey: '" HiveFile "'", 1)
Return r
}
RegUnLoadKey(HiveName:="DeepOptimize_Hive_tmp", RootKey:="HKU") {
If r:=DllCall("Advapi32.dll\RegUnLoadKey", "int", NumHK(RootKey), "Str", HiveName) {
If r==5 {
If ProcessExist("regedit.exe") {
ProcessClose "regedit.exe"
RegUnLoadKey(HiveName, RootKey)
} Else {
MsgBoxError('The key "' RootKey '\' HiveName '" is being opened by another application.`nPlease close those applications and click "OK"')
RegUnLoadKey(HiveName, RootKey)
}
} Else
Debug("RegUnLoadKey|Error: " r)
}
Return r
}
EnablePrivilege(Privilege) {
hProc := DllCall("GetCurrentProcess", "UPtr")
If DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", Privilege, "Int64P", &LUID := 0, "UInt")
&& DllCall("Advapi32.dll\OpenProcessToken", "Ptr", hProc, "UInt", 32, "PtrP", &hToken := 0, "UInt") {
TP:=Buffer(16)
NumPut("UInt", 1, TP)
NumPut("UInt64", LUID, TP, 4)
NumPut("UInt", 2, TP, 12)
DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", hToken, "UInt", 0, "Ptr", TP, "UInt", 0, "Ptr", 0, "Ptr", 0, "UInt")
}
LastError := A_LastError
If LastError
Debug("EnablePrivilege|Error: " LastError)
If (hToken)
DllCall("CloseHandle", "Ptr", hToken)
Return LastError
}
EnvGet2(s, ExpandUserProfile:=1) {
r:=RegRead( App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders", s, "")
Return (ExpandUserProfile?StrReplace(r, "%USERPROFILE%", App.UserProfile):r)
}
ExpandEnvironmentStrings(str, ExpandUserProfile:=1) {
str:=ExpandUserProfile?StrReplace(str, "%USERPROFILE%", App.UserProfile):str
cc := DllCall("ExpandEnvironmentStrings", "str", str, "ptr", 0, "uint", 0)
buf := Buffer(cc*2)
DllCall("ExpandEnvironmentStrings", "str", str, "ptr", buf, "uint", cc)
return StrGet(buf)
}
GetUSERPROFILE() {
ProfileListKey:="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
ProfileUserPath := RegRead(ProfileListKey "\" App.UserSID, "ProfileImagePath", "")
If !ProfileUserPath {
Found:=0
Loop Reg, ProfileListKey, "K" {
If InStr(A_LoopRegName, "S-1-5-21-")!=1
Continue
tUser:=LookupAccountSid(A_LoopRegName)
If !tUser.Name
Continue
If App.User=tUser.Name || App.User=tUser.Domain "\" tUser.Name {
If ProfileUserPath := RegRead(ProfileListKey "\" A_LoopRegName, "ProfileImagePath", "") {
App.UserSID:=A_LoopRegName
Found:=1
}
Break
}
}
If !Found {
Debug_LookupAccountName(App.User)
MsgBoxError('"' App.UserSID '" does not exist', 1)
}
}
If !DirExist(ProfileUserPath) {
ProfileUserPath2:=ExpandEnvironmentStrings(ProfileUserPath, 0)
If !DirExist(ProfileUserPath2)
MsgBoxError('"' ProfileUserPath '" does not exist', 1)
Return ProfileUserPath2
}
Return ProfileUserPath
}
GetActiveUser() {
wtsapi32 := DllCall("LoadLibrary", "Str", "wtsapi32.dll", "Ptr")
DllCall("wtsapi32\WTSEnumerateSessionsEx", "Ptr", 0, "UPtr*", 1, "UPtr", 0, "Ptr*", &pSessionInfo:=0, "UPtr*", &wtsSessionCount:=0)
UserName:=""
cbWTS_SESSION_INFO_1:=(A_PtrSize == 8 ? 56 : 32)
Loop wtsSessionCount {
currSessOffset := cbWTS_SESSION_INFO_1 * (A_Index - 1)
currSessOffset += 4, State := NumGet(pSessionInfo, currSessOffset, "UInt")
currSessOffset += 4, SessionId := NumGet(pSessionInfo, currSessOffset, "UInt")
If SessionId && (State == 0) {
If nUserName:=NumGet(pSessionInfo, (currSessOffset += A_PtrSize*3), "Ptr") {
UserName := StrGet(nUserName,, "UTF-16")
}
Break
}
}
DllCall("wtsapi32\WTSFreeMemoryEx", "UPtr", 2, "Ptr", pSessionInfo, "UPtr", wtsSessionCount)
DllCall("FreeLibrary", "Ptr", wtsapi32)
Return UserName
}
Debug_LookupAccountName(UserName) {
r:="Debug_LookupAccountName"
DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "UPtr", 0, "UIntP", &nSizeSID:=0, "Ptr", 0, "UIntP", &nSizeDomain:=0, "PtrP",0)
SID:=Buffer(nSizeSID*=2)
pDomain:=Buffer(nSizeDomain*=2)
DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "UPtr", SID.ptr, "UIntP", &nSizeSID, "Ptr", pDomain, "UIntP", &nSizeDomain, "PtrP", 0)
r.="`nBufferSID-" nSizeSID ": " Bin2Hex(SID, nSizeSID)
DllCall("advapi32\ConvertSidToStringSid", "UPtr", SID.ptr, "PtrP", &pString:=0)
r.="`nSID-" nSizeSID ": " StrGet(pString, "UTF-16")
Debug(r)
}
LookupAccountName(UserName) {
DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "UPtr", 0, "UIntP", 0, "Ptr", 0, "UIntP", &nSizeDomain:=0, "PtrP",0)
nSizeSID:=68
SID:=Buffer(nSizeSID)
pDomain:=Buffer(nSizeDomain*=2)
DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "UPtr", SID.ptr, "UIntP", &nSizeSID, "Ptr", pDomain, "UIntP", &nSizeDomain, "PtrP", 0)
DllCall("advapi32\ConvertSidToStringSid", "UPtr", SID.ptr, "PtrP", &pString:=0)
If !pString
MsgBoxError("User '" UserName "' does not exist", 1)
Return StrGet(pString, "UTF-16")
}
LookupAccountSid(SID) {
r := {}
DllCall("advapi32\ConvertStringSidToSid", "Str", SID, "UPtr*", &pSID:=0)
DllCall("advapi32\LookupAccountSid", "Ptr", 0, "UPtr", pSID, "Ptr", 0, "UIntP", &nSizeName:=0, "Ptr", 0, "UIntP", &nSizeDomain:=0, "PtrP", 0)
pName:=Buffer(nSizeName*=2)
pDomain:=Buffer(nSizeDomain*=2)
if !(DllCall("advapi32\LookupAccountSid", "Ptr", 0, "UPtr", pSID, "Ptr", pName, "UIntP", &nSizeName, "Ptr", pDomain, "UIntP", &nSizeDomain, "PtrP", 0))
return 0
r.Name := StrGet(pName, "UTF-16"), r.Domain := StrGet(pDomain, "UTF-16")
return r
}
GetLang(ItemId, LangType:="Name", LangId:="") {
If !LangId
LangId:=App.LangSelected
Lang:=LangData.%LangId%
r:=""
If Lang.HasOwnProp(ItemId) && Type(Lang.%ItemId%)="String" && Lang.%ItemId%
r:=Lang.%ItemId%
Else If Lang.HasOwnProp(ItemId) && IsObject(Lang.%ItemId%) && Lang.%ItemId%.HasOwnProp(LangType) && Lang.%ItemId%.%LangType%
r:=Lang.%ItemId%.%LangType%
Else If LangId!="en" {
r:=GetLang(ItemId, LangType, "en")
}
If InStr(r, "Text_")==1
r:=GetLang(r)
Else If !r && InStr(LangType, "Desc")!=1
r:=ItemId
Return r
}
GetLangName(ItemId, LangId:="") {
Return GetLang(ItemId, LangType:="Name", LangId)
}
GetLangDesc(ItemId, LangId:="", Ex:="") {
Return GetLang(ItemId, LangType:="Desc" Ex, LangId)
}
GetLangText(ItemId, LangId:="") {
Return GetLang(ItemId, LangType:="Name", LangId)
}
WinHttpResponseText(Link, Method:="GET", Async:=0, WaitForResponseTimeoutInSeconds:=-2, &Status:=0, &StatusText:="") {
whr:=WinHttp(Link, Method, Async, WaitForResponseTimeoutInSeconds, &Status, &StatusText)
c:=whr.responseText
Return c
}
WinHttp(Link, Method:="GET", Async:=0, WaitForResponseTimeoutInSeconds:=-2, &Status:=0, &StatusText:="") {
whr := ComObject("WinHttp.WinHttpRequest.5.1")
whr.Open(Method, Link, Async)
whr.Send()
if Async && WaitForResponseTimeoutInSeconds>-2 {
whr.WaitForResponse(WaitForResponseTimeoutInSeconds)
}
Status:=whr.Status
StatusText:=whr.StatusText
Return whr
}
GoSafeboot() {
RunWait "bcdedit /set {current} safeboot minimal"
Shutdown 6
}
ExitSafeboot() {
RunWait "bcdedit /deletevalue {current} safeboot"
Shutdown 6
}
HideToolTip() {
SetTimer () => ToolTip(), -500
}
RefreshExplorer() {
local Windows := ComObject("Shell.Application").Windows
Windows.Item(ComValue(0x13, 8)).Refresh()
for Window in Windows
if (Window.Name != "Internet Explorer")
Window.Refresh()
}
RestartExplorer() {
ProcessClose "explorer.exe"
}
CheckAdmin() {
if A_Args.Length ==1 && FileExist(A_Args[1]) && SubStr(A_Args[1], -4)=".ahk" {
full_command_line := '/script "' A_Args[1] '"'
} Else
full_command_line := DllCall("GetCommandLine", "str")
if !(A_IsAdmin || RegExMatch(full_command_line, " /restart(?!S)")) {
try {
if A_IsCompiled {
Run '*RunAs "' A_ScriptFullPath '" /restart ' full_command_line
} else
Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '" ' full_command_line
}
ExitApp
}
}
MsgBoxError(iText, IsExitApp:=0, title:="Error") {
MsgBox(iText,title,"Iconx")
If IsExitApp
ExitApp
}
App.MDebug:="x|!"
Debug(iErr:="",iErrEx:="", iErrTitle:="", iMode:="x") {
if !MDebug:=IsSet(App)&&App.HasOwnProp("MDebug")?(App.MDebug="All"?"x|!|i":(App.MDebug=1?"x|!":App.MDebug)):"x|!"
Return
DebugModeRegEx:="i)\A(" MDebug ")\z"
If !(iMode ~= DebugModeRegEx) {
Return
}
static IsLog:=0
LogFile:="深度优化.log"
t:=""
If !IsLog || !FileExist(LogFile) {
t.="=================" (IsSet(App)?" " App.Name " v" App.Ver " ":"================") "================="
t.="`nOSVersion          :" A_OSVersion
t.="`nIs64bitOS          :" A_Is64bitOS
t.="`nInstallationType   :" RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType","")
t.="`nEditionID          :" RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID","")
t.="`n==================================================`n"
IsLog:=1
try FileDelete LogFile
}
t.="`n" FormatTime(A_Now, "[yyyy/MM/dd HH:mm:ss]") " [" iMode "]" (iErrTitle?" [" iErrTitle "] ":" ")
If Type(iErr)="String" {
t.=iErr
If !(("NoMsg" iMode) ~= DebugModeRegEx) {
try Msg(iErr,iErrTitle,"Icon" iMode,1)
}
} Else {
t.=iErrEx?"`n" iErrEx:""
t.="`nMessage            :" iErr.Message
t.="`nExtra              :" iErr.Extra
t.="`nStack              :" iErr.Stack
If !(("NoMsg" iMode) ~= DebugModeRegEx) {
try Msg(iErr.Message,iErrTitle,"Icon" iMode,1)
}
}
FileAppend t, LogFile
}
UninstallPackage(Package, IsAllUsers, IsDeprovision) {
If IsDeprovision
PackageManager.DeprovisionPackageForAllUsers(Package.FamilyName)
If App.User=A_Username || IsAllUsers {
r1:=PackageManager.RemovePackage(Package.FullName, IsAllUsers?0x80000:0)
r:=(r1==1)
If r1==3 {
If A_LastError==0x80073cfa && !App.IsWin11 && IsAllUsers {
r2:=PackageManager.RemovePackage(Package.FullName)
If r2==3 {
Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
}
r:=(r2==1)
} Else
Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
}
} Else {
If r:=PS_RemovePackage(Package.FullName, App.UserSID)
Debug(r)
r:=!r
}
Return r
}
PS_RemovePackage(packageFullName, UserSID:="", removalOptions:="") {
UserParam:=""
If UserSID="All"
UserParam:=" -AllUsers"
Else If UserSID
UserParam:=" -User " UserSID
UserParam.=removalOptions?" " removalOptions:""
Return RunTerminal('Powershell Remove-AppxPackage -Package ' packageFullName UserParam)
}
SaveHostsFile(t) {
HostsTMPPath:=A_Temp "\hosts_tmp_" A_Now
FileAppend t, HostsTMPPath
FileSetAttrib "-R", A_WinDir "\System32\drivers\etc\hosts"
FileMove HostsTMPPath, A_WinDir "\System32\drivers\etc\hosts" , 1
}
LoadHostsFile() {
Return FileRead(A_WinDir "\System32\drivers\etc\hosts")
}
CheckRequires(DataItem) {
If DataItem.HasOwnProp("RequiresWinInstallationType") && DataItem.RequiresWinInstallationType {
IsPassed:=0
Loop Parse, DataItem.RequiresWinInstallationType, "," {
If A_LoopField=App.SystemInfo.InstallationType {
IsPassed:=1
Break
}
}
If !IsPassed
Return 0
}
If DataItem.HasOwnProp("RequiresWinEditionID") && DataItem.RequiresWinEditionID {
IsPassed:=0
Loop Parse, DataItem.RequiresWinEditionID, "," {
If A_LoopField=App.SystemInfo.EditionID {
IsPassed:=1
Break
}
}
If !IsPassed
Return 0
}
If DataItem.HasOwnProp("RequiresWinVer") && DataItem.RequiresWinVer {
IsPassed:=1
Loop Parse, DataItem.RequiresWinVer, "," {
If !VerCompare(A_OSVersion, A_LoopField) {
IsPassed:=0
Break
}
}
If !IsPassed
Return 0
}
Return 1
}
CheckStatusItem(ItemFunc, DataItem) {
If !CheckRequires(DataItem)
Return -1
s:=t:=-1
Loop DataItem.Act.Length {
If DataItem.Act[A_Index].HasOwnProp("Check") && !DataItem.Act[A_Index].Check
Continue
If !CheckRequires(DataItem.Act[A_Index])
s:=-1
Switch DataItem.Act[A_Index].Type
{
Case "Custom": s:=Check%ItemFunc%()
Case "Service": s:=(Service_State(DataItem.Act[A_Index].Name)=DataItem.Act[A_Index].State1)
Case "ScheduleService": s:=CheckScheduleService(DataItem.Act[A_Index])
Case "Power": s:=!Get%DataItem.Act[A_Index].Name%()
Case "RegChange": s:=RegRead(HKCU2HCU(DataItem.Act[A_Index].RegKey), DataItem.Act[A_Index].RegValueName,DataItem.Act[A_Index].RegValue0)=DataItem.Act[A_Index].RegValue1
Case "RegDel":
try {
s:=RegRead(HKCU2HCU(DataItem.Act[A_Index].RegKey), DataItem.Act[A_Index].RegValueName)!=DataItem.Act[A_Index].RegValue0
} Catch as err {
s:=1
}
Case "RegAdd":
Key:=HKCU2HCU(DataItem.Act[A_Index].RegKey)
If DataItem.Act[A_Index].HasOwnProp("RegValue1") {
try {
RegValueName:=DataItem.Act[A_Index].HasOwnProp("RegValueName")?DataItem.Act[A_Index].RegValueName:unset
RegValueDefault:=DataItem.Act[A_Index].HasOwnProp("RegValueDefault")?DataItem.Act[A_Index].RegValueDefault:unset
s:=RegRead(Key, RegValueName?, RegValueDefault?)=DataItem.Act[A_Index].RegValue1
} Catch {
s:=0
}
} Else If DataItem.Act[A_Index].HasOwnProp("RegValueName") {
try {
RegRead(Key, DataItem.Act[A_Index].RegValueName)
s:=1
} Catch {
s:=0
}
} Else {
s:=RegKeyExist(Key)
}
}
If s=0 || s=-2
Break
Else If s=-1 && t=1 {
s:=t
t:=-1
} Else t:=s
}
Return s
}
ProgNow(ItemId, ItemValue, ItemData, silent:=0, Ctr:="") {
Try {
IsRefreshExplorer:=0
IsRestartExplorer:=0
Loop ItemData.Act.Length {
If ItemData.Act[A_Index].HasOwnProp("Check") && ItemData.Act[A_Index].Check
Continue
If ItemData.Act[A_Index].Type="Custom" {
r:=%ItemId%(ItemValue, ItemData.Act[A_Index],silent)
If Ctr && (r=0 || r=1)
Ctr.Value:=r
} Else If ItemData.Act[A_Index].Type="RunTerminal"
RunTerminal(ItemData.Act[A_Index].Value%ItemValue%)
Else
Prog%ItemData.Act[A_Index].Type%(ItemValue,ItemData.Act[A_Index],silent)
If !IsRefreshExplorer && ItemData.Act[A_Index].HasOwnProp("RefreshExplorer")
&& ItemData.Act[A_Index].RefreshExplorer
IsRefreshExplorer:=1
If !IsRestartExplorer && ItemData.Act[A_Index].HasOwnProp("RestartExplorer")
&& (ItemData.Act[A_Index].RestartExplorer==1 || (ItemData.Act[A_Index].RestartExplorer==2 && ItemValue==1))
IsRestartExplorer:=1
}
If IsRefreshExplorer
RefreshExplorer()
} Catch as err {
Debug(err, "Func: " ItemId)
}
}
ProgReg(s, ItemData, silent) {
If (s && ItemData.Type="RegDel") || (!s && ItemData.Type="RegAdd") {
If ItemData.HasOwnProp("LvlKeyDel") && ItemData.LvlKeyDel {
sKey:=StrSplit(HKCU2HCU(ItemData.RegKey), "\")
cKey:=""
Loop (sKey.Length-ItemData.LvlKeyDel+1)
cKey.=(A_Index=1?"":"\") sKey[A_Index]
try RegDeleteKey cKey
}
Else {
try RegDelete HKCU2HCU(ItemData.RegKey), ItemData.RegValueName
}
}
Else If !ItemData.HasOwnProp("RegValueName") && ItemData.HasOwnProp("RegValue" s)
RegWrite ItemData.RegValue%s%, ItemData.RegType, HKCU2HCU(ItemData.RegKey)
Else If !ItemData.HasOwnProp("RegValueName")
RegCreateKey HKCU2HCU(ItemData.RegKey)
Else
RegWrite ItemData.RegValue%s%, ItemData.RegType, HKCU2HCU(ItemData.RegKey), ItemData.RegValueName
}
ProgRegAdd(s, ItemData, silent) {
ProgReg(s, ItemData, silent)
}
ProgRegChange(s, ItemData, silent) {
ProgReg(s, ItemData, silent)
}
ProgRegDel(s, ItemData, silent) {
ProgReg(s, ItemData, silent)
}
ProgService(s, ItemData, silent) {
If ItemData.HasOwnProp("StartType" s)
Service_Change_StartType(ItemData.Name, ItemData.StartType%s%)
If ItemData.HasOwnProp("State" s) {
If ItemData.State%s%=1
Service_Stop(ItemData.Name)
Else ItemData.State%s%=4
Service_Start(ItemData.Name)
}
}
ScheduleServiceConnect() {
static service:= ComObject("Schedule.Service")
service.Connect()
Return service
}
CheckScheduleService(ItemData) {
If SysGet(67) {
Return -1
}
Try {
service:=ScheduleServiceConnect()
r:=!service.GetFolder(ItemData.Location).GetTask(ItemData.TaskName).Enabled
Return r
} Catch {
Return -1
}
}
ProgScheduleService(s, ItemData, silent) {
Try {
service:=ScheduleServiceConnect()
service.GetFolder(ItemData.Location).GetTask(ItemData.TaskName).Enabled:=!s
} Catch {
Return -1
}
}
ProgPower(s, ItemData, silent) {
Set%ItemData.Name%(ItemData.Value%s%)
}
StartMenuLayout(&item, Type:="get", silent:=1) {
s:=0
If VerCompare(A_OSVersion,">=10.0.22000") {
LocalStatePath:=EnvGet2("Local AppData") "\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
StartBinPath:=""
If DirExist(LocalStatePath) {
If FileExist(LocalStatePath "\start.bin") {
StartBinPath:=LocalStatePath "\start.bin"
} Else If FileExist(LocalStatePath "\start2.bin") {
StartBinPath:=LocalStatePath "\start2.bin"
}
}
If Type="get" {
item.VisiblePlaces:=RegRead(App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Start", "VisiblePlaces", "")
If StartBinPath {
f := FileRead(StartBinPath, "RAW")
item.StartBin:=Bin2Hex(f, f.Size)
s:=1
}
} Else If Type="set" {
If item.HasOwnProp("VisiblePlaces") {
RegWrite item.VisiblePlaces, "REG_BINARY", App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Start", "VisiblePlaces"
s:=1
}
If StartBinPath && item.HasOwnProp("StartBin") {
bin:=Hex2Bin(item.StartBin)
FileDelete StartBinPath
FileAppend bin, StartBinPath,"cp0"
s:=1
}
}
} Else If VerCompare(A_OSVersion,">=10.0.16299") {
Loop Reg, App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount", "K" {
If InStr(A_LoopRegName, "$start.suggestions$windows.data.curatedtilecollection.tilecollection") {
If Type="get" {
sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
If sData
item.Suggestions:=sData
s:=1
} Else If Type="set" && item.HasOwnProp("Suggestions") {
RegWrite item.Suggestions, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
s:=1
}
} Else If InStr(A_LoopRegName, "$start.tilegrid$windows.data.curatedtilecollection.tilecollection") {
If Type="get" {
sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
If sData
item.TileGrid:=sData
s:=1
} Else If Type="set" && item.HasOwnProp("TileGrid") {
RegWrite item.TileGrid, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
s:=1
}
} Else If InStr(A_LoopRegName, "$windows.data.unifiedtile.startglobalproperties") {
If Type="get" {
sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
If sData
item.StartGlobalProperties:=sData
s:=1
} Else If Type="set" && item.HasOwnProp("StartGlobalProperties") {
RegWrite item.StartGlobalProperties, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
s:=1
}
}
}
}
If Type="set" && s {
If VerCompare(A_OSVersion, ">=10.0.18362") {
PID:=ProcessClose("StartMenuExperienceHost.exe")
If !ProcessWaitClose(PID , 5000) && !silent
TrayTip GetLangText("Text_ClearStartMenu_Done"), App.Name
} Else
ProcessClose "explorer.exe"
}
Return s
}
CheckUninstallOneDrive() {
OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
If !FileExist(OneDriveSetup) {
OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
If !FileExist(OneDriveSetup) {
OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
If !FileExist(OneDriveSetup)
Return -1
}
}
OneDriveSetupRun:=RegRead(App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup", "")
PreInstall:=!InStr(OneDriveSetupRun, "/uninstall")
If !(OneDriveExist:=FileExist(EnvGet2("Local AppData") "\Microsoft\OneDrive\onedrive.exe")) {
If !(OneDriveExist:=FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
OneDriveExist:=FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
}
}
r:=0
If (!OneDriveExist && !OneDriveSetupRun) || (OneDriveExist && OneDriveSetupRun && !PreInstall)
r:=1
Return r
}
UninstallOneDrive(s,d,silent) {
OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
If !FileExist(OneDriveSetup) {
OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
If !FileExist(OneDriveSetup) {
OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
If !FileExist(OneDriveSetup)
Return -1
}
}
If !(IsPerMachine:=!!FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
IsPerMachine:=!!FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
}
OneDriveSetupCMD:=OneDriveSetup (IsPerMachine?' /allusers':'') (s?' /uninstall':'') ' /silent'
If App.User=GetActiveUser() {
If s
ProcessClose "OneDrive.exe"
RunWait OneDriveSetupCMD
} Else {
try
RegDelete App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDriveSetup"
try
RegDelete App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDrive"
RegWrite OneDriveSetupCMD, "REG_SZ", App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup"
}
}
CheckDisableVisualStudioTelemetry() {
If FileExist(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe")
Return RegRead(App.HKCU "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch",0)
Else {
Return -1
}
}
DisableVisualStudioTelemetry(s,d,silent) {
Ver:=SubStr(RunTerminal(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe -latest -property catalog_productDisplayVersion"), 1,2)
RegWrite s, "REG_DWORD", App.HKCU "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch"
RegWrite !s, "REG_DWORD", "HKLM\Software\WOW6432Node\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
RegWrite !s, "REG_DWORD", App.HKCU "\Software\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
}
CheckDisableSystemRestore() {
Return !RegRead("HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval",0)
}
DisableSystemRestore(s,d,silent) {
If s {
RegWrite '0', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
RegDelete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
RunTerminal(A_Comspec ' /c vssadmin delete shadows /all /quiet')
} Else {
RegWrite '1', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
DeviceID:=""
For CS in ComObjGet("winmgmts:").ExecQuery("SELECT DeviceID FROM Win32_Volume WHERE DriveLetter='" SubStr(A_WinDir, 1, 2) "'") {
DeviceID:=CS.DeviceID
}
RegExMatch(DeviceID, "\\?\\(.*)", &SubPat)
RegWrite Trim(SubPat[0]) ":" DriveGetLabel(SubStr(A_WinDir, 1, 2)) "(" SubStr(A_WinDir, 1, 1) "%3A)", "REG_MULTI_SZ", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
}
}
SaveOptimizeConfigAll(SelectedFile) {
Config:={}
Loop Layout.Length {
If (Layout[A_Index].ID = "" || !Layout[A_Index].HasOwnProp("Items"))
Continue
ItemList:=Layout[A_Index].Items
Loop ItemList.Length {
ItemId:=ItemList[A_Index]
s:=CheckStatusItem(ItemId, Data.%ItemId%)
If s<=-1
Continue
Config.%ItemID%:=s
}
ObjStartMenu:={}
StartMenuLayout(&ObjStartMenu)
Config.StartMenuLayout:=ObjStartMenu
}
try
FileDelete SelectedFile
FileAppend JSON.stringify(Config), SelectedFile
}
LoadOptimizeConfig(SelectedFile, g:="") {
ConfigText:=FileRead(SelectedFile)
Config:=JSON.parse(ConfigText,,False)
For ItemId, ItemValue in Config.OwnProps() {
If ItemId="StartMenuLayout" {
StartMenuLayout(&ItemValue, "set")
} Else {
If !Data.HasOwnProp(ItemID)
Continue
s:=CheckStatusItem(ItemId, Data.%ItemId%)
If s<=-1 || ItemValue=s
Continue
ProgNow(ItemId, ItemValue, Data.%ItemId%, 1)
}
}
If g
NavItem_Click(g)
}
Gdip_Startup()
{
if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
throw Error("Could not load GDI+ library")
}
si := Buffer(A_PtrSize = 4 ? 20:32, 0)
NumPut("uint", 0x2, si)
NumPut("uint", 0x4, si, A_PtrSize = 4 ? 16:24)
DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "Ptr", si, "UPtr", 0)
if (!pToken) {
throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
}
return pToken
}
Gdip_Shutdown(pToken)
{
DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
if (!hModule) {
throw Error("GDI+ library was unloaded before shutdown")
}
if (!DllCall("FreeLibrary", "UPtr", hModule)) {
throw Error("Could not free GDI+ library")
}
return 0
}
Gdip_GraphicsFromImage(pBitmap)
{
DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics:=0)
return pGraphics
}
Gdip_CreateBitmap(Width, Height, Format:=0x26200A)
{
DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", 0, "Int", Format, "UPtr", 0, "UPtr*", &pBitmap:=0)
return pBitmap
}
Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff)
{
DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", &hbm:=0, "Int", Background)
return hbm
}
Gdip_DeleteBrush(pBrush)
{
return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}
Gdip_DisposeImage(pBitmap)
{
return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}
Gdip_DeleteGraphics(pGraphics)
{
return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}
DeleteObject(hObject)
{
return DllCall("DeleteObject", "UPtr", hObject)
}
Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
{
DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
return pBitmap
}
Gdip_BitmapFromScreen(Screen:=0, Raster:="")
{
hhdc := 0
if (Screen = 0) {
_x := DllCall( "GetSystemMetrics", "Int", 76 )
_y := DllCall( "GetSystemMetrics", "Int", 77 )
_w := DllCall( "GetSystemMetrics", "Int", 78 )
_h := DllCall( "GetSystemMetrics", "Int", 79 )
}
else if (SubStr(Screen, 1, 5) = "hwnd:") {
Screen := SubStr(Screen, 6)
if !WinExist("ahk_id " Screen) {
return -2
}
WinGetRect(Screen,,, &_w, &_h)
_x := _y := 0
hhdc := GetDCEx(Screen, 3)
}
else if IsInteger(Screen) {
M := GetMonitorInfo(Screen)
_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
}
else {
S := StrSplit(Screen, "|")
_x := S[1], _y := S[2], _w := S[3], _h := S[4]
}
if (_x = "") || (_y = "") || (_w = "") || (_h = "") {
return -1
}
chdc := CreateCompatibleDC()
hbm := CreateDIBSection(_w, _h, chdc)
obm := SelectObject(chdc, hbm)
hhdc := hhdc ? hhdc : GetDC()
BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
ReleaseDC(hhdc)
pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
SelectObject(chdc, obm)
DeleteObject(hbm)
DeleteDC(hhdc)
DeleteDC(chdc)
return pBitmap
}
Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
{
_p := 0
SplitPath sOutput,,, &extension:=""
if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
return -1
}
extension := "." extension
DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
ci := Buffer(nSize)
DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
if !(nCount && nSize) {
return -2
}
loop nCount {
address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
sString := StrGet(address, "UTF-16")
if !InStr(sString, "*" extension)
continue
pCodec := ci.Ptr+idx
break
}
if !pCodec {
return -3
}
if (Quality != 75) {
Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
if RegExMatch(extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
DllCall("gdiplus\GdipGetEncoderParameterListSize", "UPtr", pBitmap, "UPtr", pCodec, "uint*", &nSize)
EncoderParameters := Buffer(nSize, 0)
DllCall("gdiplus\GdipGetEncoderParameterList", "UPtr", pBitmap, "UPtr", pCodec, "UInt", nSize, "UPtr", EncoderParameters.Ptr)
nCount := NumGet(EncoderParameters, "UInt")
loop nCount
{
elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
{
_p := elem + EncoderParameters.Ptr - pad - 4
NumPut("UInt", Quality, NumGet(NumPut("UInt", 4, NumPut("UInt", 1, _p+0)+20), "UInt"))
break
}
}
}
}
_E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)
return _E ? -5 : 0
}
CreateRect(&Rect, x, y, w, h)
{
Rect := Buffer(16)
NumPut("UInt", x, "UInt", y, "UInt", w, "UInt", h, Rect)
}
CreateDIBSection(w, h, hdc:="", bpp:=32, &ppvBits:=0)
{
hdc2 := hdc ? hdc : GetDC()
bi := Buffer(40, 0)
NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)
hbm := DllCall("CreateDIBSection"
, "UPtr", hdc2
, "UPtr", bi.Ptr
, "UInt", 0
, "UPtr*", &ppvBits
, "UPtr", 0
, "UInt", 0, "UPtr")
if (!hdc) {
ReleaseDC(hdc2)
}
return hbm
}
CreateCompatibleDC(hdc:=0)
{
return DllCall("CreateCompatibleDC", "UPtr", hdc)
}
SelectObject(hdc, hgdiobj)
{
return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}
GetDC(hwnd:=0)
{
return DllCall("GetDC", "UPtr", hwnd)
}
GetDCEx(hwnd, flags:=0, hrgnClip:=0)
{
return DllCall("GetDCEx", "UPtr", hwnd, "UPtr", hrgnClip, "Int", flags)
}
ReleaseDC(hdc, hwnd:=0)
{
return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}
DeleteDC(hdc)
{
return DllCall("DeleteDC", "UPtr", hdc)
}
GetMonitorInfo(MonitorNum)
{
Monitors := MDMF_Enum()
for k,v in Monitors {
if (v.Num = MonitorNum) {
return v
}
}
}
MDMF_Enum(HMON := "") {
static EnumProc := CallbackCreate(MDMF_EnumProc)
static Monitors := Map()
if (HMON = "") {
Monitors := Map("TotalCount", 0)
if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", ObjPtr(Monitors), "Int")
return False
}
return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
Monitors := ObjFromPtrAddRef(ObjectAddr)
Monitors[HMON] := MDMF_GetInfo(HMON)
Monitors["TotalCount"]++
if (Monitors[HMON].Primary) {
Monitors["Primary"] := HMON
}
return true
}
MDMF_GetInfo(HMON) {
MIEX := Buffer(40 + (32 << !!1))
NumPut("UInt", MIEX.Size, MIEX)
if DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX.Ptr, "Int") {
return {Name:      (Name := StrGet(MIEX.Ptr + 40, 32))
, Num:       RegExReplace(Name, ".*(\d+)$", "$1")
, Left:      NumGet(MIEX, 4, "Int")
, Top:       NumGet(MIEX, 8, "Int")
, Right:     NumGet(MIEX, 12, "Int")
, Bottom:    NumGet(MIEX, 16, "Int")
, WALeft:    NumGet(MIEX, 20, "Int")
, WATop:     NumGet(MIEX, 24, "Int")
, WARight:   NumGet(MIEX, 28, "Int")
, WABottom:  NumGet(MIEX, 32, "Int")
, Primary:   NumGet(MIEX, 36, "UInt")}
}
return False
}
WinGetRect( hwnd, &x:="", &y:="", &w:="", &h:="" ) {
Ptr := A_PtrSize ? "UPtr" : "UInt"
CreateRect(&winRect, 0, 0, 0, 0)
DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
x := NumGet(winRect,  0, "UInt")
y := NumGet(winRect,  4, "UInt")
w := NumGet(winRect,  8, "UInt") - x
h := NumGet(winRect, 12, "UInt") - y
}
BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
{
return DllCall("gdi32\BitBlt"
, "UPtr", dDC
, "Int", dx
, "Int", dy
, "Int", dw
, "Int", dh
, "UPtr", sDC
, "Int", sx
, "Int", sy
, "UInt", Raster ? Raster : 0x00CC0020)
}
Gdip_BitmapFromBase64(&Base64)
{
if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", 0, "UInt*", &DecLen:=0, "UPtr", 0, "UPtr", 0)) {
return -1
}
Dec := Buffer(DecLen, 0)
if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", Dec.Ptr, "UInt*", &DecLen, "UPtr", 0, "UPtr", 0)) {
return -2
}
if !(pStream := DllCall("shlwapi\SHCreateMemStream", "UPtr", Dec.Ptr, "UInt", DecLen, "UPtr")) {
return -3
}
DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "UPtr", pStream, "Ptr*", &pBitmap:=0)
ObjRelease(pStream)
return pBitmap
}
Gdip_CreateARGBHBITMAPFromBitmap(&pBitmap) {
DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", &width:=0)
DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", &height:=0)
hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
bi := Buffer(40, 0)
NumPut(
"UInt",     40,
"UInt",    	width,
"Int",  	-height,
"ushort",   1,
"ushort",   32,
bi)
hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", bi.Ptr, "UInt", 0, "ptr*", &pBits:=0, "ptr", 0, "UInt", 0, "ptr")
obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")
Rect := Buffer(16, 0)
NumPut(
"UInt",   width,
"UInt",  height,
Rect, 8)
BitmapData := Buffer(16+2*A_PtrSize, 0)
NumPut(
"UInt",     width,
"UInt",    height,
"Int",  4 * width,
"Int",    0xE200B,
"ptr",      pBits,
BitmapData)
DllCall("gdiplus\GdipBitmapLockBits"
,    "ptr", pBitmap
,    "ptr", Rect.Ptr
,   "UInt", 5
,    "Int", 0xE200B
,    "ptr", BitmapData.Ptr)
DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", BitmapData.Ptr)
DllCall("SelectObject", "ptr", hdc, "ptr", obm)
DllCall("DeleteDC",     "ptr", hdc)
return hbm
}
Gdip_CreateHICONFromBitmap(pBitmap) {
DllCall("gdiplus\GdipCreateHICONFromBitmap", "UPtr", pBitmap, "UPtr*", &hIcon:=0)
return hIcon
}
Gdip_CreateTextureBrush(pBitmap, WrapMode:=1, x:=0, y:=0, w:="", h:="") {
if !(w && h) {
DllCall("gdiplus\GdipCreateTexture", "UPtr", pBitmap, "Int", WrapMode, "UPtr*", &pBrush:=0)
} else {
DllCall("gdiplus\GdipCreateTexture2", "UPtr", pBitmap, "Int", WrapMode, "Float", x, "Float", y, "Float", w, "Float", h, "UPtr*", &pBrush:=0)
}
return pBrush
}
Class ToolTipOptions {
Static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
Static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4)
Static OWP := 0
Static ToolTips := Map()
Static BkgColor := ""
Static TxtColor := ""
Static Icon := ""
Static Title := ""
Static HFONT := 0
Static Margins := ""
Static Call(*) => False
Static Init() {
If (This.OWP = 0) {
This.BkgColor := ""
This.TxtColor := ""
This.Icon := ""
This.Title := ""
This.Margins := ""
If (A_PtrSize = 8)
This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
Else
This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
OnExit(ToolTipOptions._EXIT_, -1)
Return This.OWP
}
Else
Return False
}
Static Reset() {
If (This.OWP != 0) {
For HWND In This.ToolTips.Clone()
DllCall("DestroyWindow", "Ptr", HWND)
This.ToolTips.Clear()
If This.HFONT
DllCall("DeleteObject", "Ptr", This.HFONT)
This.HFONT := 0
If (A_PtrSize = 8)
DllCall("User32.dll\SetClassLongPtrW", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
Else
DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
This.OWP := 0
Return True
}
Else
Return False
}
Static SetColors(BkgColor := "", TxtColor := "") {
This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
BGR(Color, Default := "") {
Static HTML := {AQUA:   0xFFFF00, BLACK: 0x000000, BLUE:   0xFF0000, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x000080, NAVY:    0x800000, OLIVE: 0x008080,
PURPLE: 0x800080, RED:   0x0000FF, SILVER: 0xC0C0C0, TEAL:    0x808000, WHITE: 0xFFFFFF,
YELLOW: 0x00FFFF}
If HTML.HasProp(Color)
Return HTML.%Color%
If (Color Is String) && IsXDigit(Color) && (StrLen(Color) = 6)
Color := Integer("0x" . Color)
If IsInteger(Color)
Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
Return Default
}
}
Static SetFont(FntOpts := "", FntName := "") {
Static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr")
Static LOGFONTW := 0
If (FntOpts = "") && (FntName = "") {
If This.HFONT
DllCall("DeleteObject", "Ptr", This.HFONT)
This.HFONT := 0
LOGFONTW := 0
}
Else {
If (LOGFONTW = 0) {
LOGFONTW := Buffer(92, 0)
DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
}
HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
If (FntOpts != "") {
For Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
Switch StrUpper(Opt) {
Case "BOLD":      NumPut("Int", 700, LOGFONTW, 16)
Case "ITALIC":    NumPut("Char",  1, LOGFONTW, 20)
Case "UNDERLINE": NumPut("Char",  1, LOGFONTW, 21)
Case "STRIKE":    NumPut("Char",  1, LOGFONTW, 22)
Case "NORM":      NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
Default:
O := StrUpper(SubStr(Opt, 1, 1))
V := SubStr(Opt, 2)
Switch O {
Case "C":
Continue
Case "Q":
If !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
NumPut("Char", Integer(V), LOGFONTW, 26)
Case "S":
If !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
Case "W":
If !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
Throw ValueError("Option W must be an integer between 1 and 1000!", -1, V)
NumPut("Int", Integer(V), LOGFONTW, 16)
Default:
Throw ValueError("Invalid font option!", -1, Opt)
}
}
}
}
NumPut("Char", 1, "Char", 4, "Char", 0, LOGFONTW, 23)
NumPut("Char", 0, LOGFONTW, 27)
If (FntName != "")
StrPut(FntName, LOGFONTW.Ptr + 28, 32)
If !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
Throw OSError()
If This.HFONT
DllCall("DeleteObject", "Ptr", This.HFONT)
This.HFONT := HFONT
}
}
Static SetMargins(L := 0, T := 0, R := 0, B := 0) {
If ((L + T + R + B) = 0)
This.Margins := 0
Else {
This.Margins := Buffer(16, 0)
NumPut("Int", L, "Int", T, "Int", R, "Int", B, This.Margins)
}
}
Static SetTitle(Title := "", Icon := "") {
Switch {
Case (Title = "") && (Icon != ""):
This.Icon := Icon
This.Title := " "
Case (Title != "") && (Icon = ""):
This.Icon := 0
This.Title := Title
Default:
This.Icon := Icon
This.Title := Title
}
}
Static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
Switch uMsg {
Case 0x0411:
If This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
If (This.BkgColor != "")
SendMessage(1043, This.BkgColor, 0, hWnd)
If (This.TxtColor != "")
SendMessage(1044, This.TxtColor, 0, hWnd)
If This.HFONT
SendMessage(0x30, This.HFONT, 0, hWnd)
If (Type(This.Margins) = "Buffer")
SendMessage(1050, 0, This.Margins.Ptr, hWnd)
If (This.Icon != "") || (This.Title != "")
SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)
This.ToolTips[hWnd] := 1
}
Case 0x0001:
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
This.ToolTips[hWnd] := 0
Case 0x0002:
If This.ToolTips.Has(hWnd)
This.ToolTips.Delete(hWnd)
}
r:=0
If This.OWP
r:=DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
Return r
}
Static _EXIT_(*) {
If (ToolTipOptions.OWP != 0)
ToolTipOptions.Reset()
}
}
Class PicSwitch Extends Gui.Text {
Static __New() {
Gui.Prototype.AddPicSwitch:=this.AddPicSwitch
}
Static AddPicSwitch(Options:="", sText:="", iValue:=0, SOptions:="") {
hPic:=SOptions && SOptions.Has("SHeight")?SOptions["SHeight"]:20
wPic:=SOptions && SOptions.Has("SWidth")?SOptions["SWidth"]:20
TextOpt:=""
PicOpt:=""
Loop parse, Options, A_Space A_Tab {
If SubStr(A_LoopField,1,1) = 'w' && IsNumber(n:=SubStr(A_LoopField,2)) {
TextOpt.=" w" n-wPic-3
} Else If SubStr(A_LoopField,1,1) = 'x' {
PicOpt.=" " A_LoopField
} Else If SubStr(A_LoopField,1,1) = 'y' {
PicOpt.=" " A_LoopField
} Else {
TextOpt.=" " A_LoopField
}
}
ctlPic:=this.AddPic("BackgroundTrans" PicOpt " w" wPic " h" hPic)
ctlPic.GetPos(&X, &Y)
ctlTxt:=this.AddText("BackgroundTrans yp 0x200" TextOpt " h" hPic,sText)
ctlEnabled:=ctlTxt.Enabled
ctlVisible:=ctlTxt.Visible
ctlPic.Enabled:=ctlEnabled
ctlPic.Visible:=ctlVisible
ctlTxt.base:=PicSwitch.Prototype
ctlTxt.SPic:=ctlPic
ctlTxt._Value:=iValue
ctlTxt._Enabled:=ctlEnabled
ctlTxt._Visible:=ctlVisible
ctlTxt.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
ctlPic.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
ctlTxt.SOpt:=Map()
If SOptions
ctlTxt.SOpt:=SOptions
If !ctlTxt.SOpt.Has("SWidth")
ctlTxt.SOpt["SWidth"]:=wPic
If !ctlTxt.SOpt.Has("SHeight")
ctlTxt.SOpt["SHeight"]:=hPic
ctlTxt.RefreshStatusIcon
return ctlTxt
}
Type => "PicSwitch"
Value {
get => this._Value
set {
if (this._Value!=value) {
this._Value:=value
this.RefreshStatusIcon
}
Return value
}
}
Enabled	{
get => this._Enabled
set {
if (this._Enabled!=value) {
super.Enabled:=value
this.SPic.Enabled:=value
this._Enabled:=value
this.RefreshStatusIcon
}
Return value
}
}
Visible	{
get => this._Visible
set {
if (this._Visible!=value) {
super.Visible:=value
this.SPic.Visible:=value
this._Visible:=value
}
Return value
}
}
Move(X?, Y?, W?, H?) {
wSPic:=this.SOpt["SWidth"]
hSPic:=this.SOpt["SHeight"]
If IsSet(H) {
wSPic+=(H-hSPic)
this.SOpt["SHeight"]:=H
this.SOpt["SWidth"]:=wSPic
}
this.SPic.Move(X?, Y?, IsSet(H)?wSPic:unset, H?)
this.SPic.GetPos(&wX)
super.Move((IsSet(X)||IsSet(H))?(wX+wSPic+3):unset, Y?, IsSet(W)?W-wSPic-3:unset, H?)
}
GetPos(&X?, &Y?, &W?, &H?) {
this.SPic.GetPos(&X, &Y, &sW)
super.GetPos(,, &tW, &H)
W:=sW+tW+3
}
_ClickChangeValue(*) {
this._Value:=!this._Value
this.RefreshStatusIcon
}
RefreshStatusIcon(*) {
this.SPic.GetPos(&sX,, &sW, &sH)
If sW!=this.SOpt["SWidth"] {
this.SPic.Move(,, this.SOpt["SWidth"])
super.Move(sX+this.SOpt["SWidth"]+3)
}
If sH!=this.SOpt["SHeight"] {
this.Move(,,, this.SOpt["SHeight"])
}
nOpt:="Value" this._Value (this._Enabled?"":"Disabled") "Icon"
this.SPic.Value:=(this.SOpt.Has(nOpt) && this.SOpt[nOpt])?this.SOpt[nOpt]:""
}
}
CreateGui() {
App.MainFont:="Segoe UI Semibold"
App.MainFontSize:="9"
App.IconFont:=App.IsWin11?"Segoe Fluent Icons":"Segoe MDL2 Assets"
App.ThemeSelected:=IniRead("config.ini", "General", "Theme", "Modern")
App.TabLangLoaded:= {}
App.CurrentTabCtrls:=[]
g:=Gui("-Caption",App.Name)
g.SetFont("s" App.MainFontSize+2 " c" Themes.%App.ThemeSelected%.TextColor, App.MainFont)
g.BackColor:=Themes.%App.ThemeSelected%.BackColor
ToolTipOptions.Init()
ToolTipOptions.SetMargins(5, 5, 5, 5)
ToolTipOptions.SetColors("0x" Themes.%App.ThemeSelected%.BackColor, "0x" Themes.%App.ThemeSelected%.TextColor)
SetMenuTheme()
NavSelectW:=120, NavSelectH:=32
PanelX:=20, PanelY:=50, PanelW:=1040, PanelH:=570
pToken:=Gdip_Startup()
BGImageCtrl:=g.AddPic("vBGImage BackgroundTrans x0 y0")
TopRowY := 8
g.AddPic("vNavBGHover Hidden BackgroundTrans xm ym" TopRowY)
g.AddPic("vNavBGActive Hidden BackgroundTrans xm ym" TopRowY)
g.SetFont("s12" ,App.IconFont)
BtnSys_Close:=g.AddText('vBtnSys_Close BackgroundTrans x' PanelX+PanelW-32 ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE8BB))
BtnSys_Close.SetFont("s14 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_Close.OnEvent("Click",Gui_Close)
BtnSys_Minimize:=g.AddText('vBtnSys_Minimize BackgroundTrans x' PanelX+PanelW-70 ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE921))
BtnSys_Minimize.SetFont("s14 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_Minimize.OnEvent("Click",(*)=>g.Minimize())
BtnSysX := PanelX+PanelW-70-5
BtnSys_ReloadTab:=g.AddText('vBtnSys_ReloadTab BackgroundTrans x' (BtnSysX-=35) ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE72C))
BtnSys_ReloadTab.SetFont("s13 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_ReloadTab.OnEvent("Click",(*)=>NavItem_Click(g))
g.AddText("vHRDot_3 x" (BtnSysX-=8) " ym" TopRowY+14 " w4 h4 0x200 Center c" Themes.%App.ThemeSelected%.HrColor,"●")
BtnSys_Search:=g.AddText('vBtnSys_Search BackgroundTrans x' (BtnSysX-=30) ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE721))
BtnSys_Search.SetFont("s13 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_Search.OnEvent("Click",(*)=>NavItem_Click(g,6))
g.AddText("vHRDot_2 x" (BtnSysX-=8) " ym" TopRowY+14 " w4 h4 0x200 Center c" Themes.%App.ThemeSelected%.HrColor,"●")
BtnSys_LoadOptimizeConfig:=g.AddText('vBtnSys_LoadOptimizeConfig BackgroundTrans x' (BtnSysX-=30) ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE8E5))
BtnSys_LoadOptimizeConfig.SetFont("s13 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_LoadOptimizeConfig.OnEvent("Click",BtnSys_LoadOptimizeConfig_Click)
BtnSys_SaveOptimizeConfigAll:=g.AddText('vBtnSys_SaveOptimizeConfigAll BackgroundTrans x' (BtnSysX-=35) ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE74E))
BtnSys_SaveOptimizeConfigAll.SetFont("s13 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_SaveOptimizeConfigAll.OnEvent("Click",BtnSys_SaveOptimizeConfigAll_Click)
BtnSys_SaveOptimizeConfigTab:=g.AddText('vBtnSys_SaveOptimizeConfigTab BackgroundTrans Hidden x' (BtnSysX-=35) ' ym' TopRowY ' w32 h32 0x200 Center',Chr(0xE792))
BtnSys_SaveOptimizeConfigTab.SetFont("s13 c" Themes.%App.ThemeSelected%.TextColor, App.IconFont)
BtnSys_SaveOptimizeConfigTab.OnEvent("Click",BtnSys_SaveOptimizeConfigTab_Click)
g.OnEvent("Close",Gui_Close)
Gui_Close(*) {
If App.HasOwnProp("HwndPopup") && App.HwndPopup {
WinClose(App.HwndPopup)
}
IniWrite g.NavSelected, "config.ini", "General", "LastTab"
ExitApp
}
g.AddPic('vBGPanel BackgroundTrans w' PanelW ' h' PanelH ' x' PanelX ' y' PanelY)
SetBGNavSelect(g,NavSelectW,NavSelectH)
SetBGPanel(g,PanelW,PanelH)
Gdip_Shutdown(pToken)
g.SetFont("s" App.MainFontSize+2 " bold c" Themes.%App.ThemeSelected%.TextColor, App.MainFont)
x:=20
y:=TopRowY
Loop Layout.Length {
ItemID:=Layout[A_Index].ID
If (ItemID = "")
Continue
NavItem:=Layout[A_Index]
If NavItem.HasOwnProp("hr") && NavItem.hr {
g.AddText("vNavHRText_" A_Index " BackgroundTrans center w" NavSelectW " x" x " ym" y " c" Themes.%App.ThemeSelected%.HrColor)
x+=(NavSelectW+12)
}
If NavItem.HasOwnProp("Icon") || NavItem.HasOwnProp("Icon10") {
aIcon:=g.AddPic("BackgroundTrans h20 w20 x" (x+6) " ym" (y+6))
aIcon.Value:=(!App.IsWin11 && NavItem.HasOwnProp("Icon10") && NavItem.Icon10)?NavItem.Icon10:NavItem.Icon
}
NavItemBG:=g.AddText("Background" Themes.%App.ThemeSelected%.BackColorPanel " 0x200 h" NavSelectH " w" NavSelectW " x" x " ym" y " vNavItemBG_" A_Index (NavItem.HasOwnProp("Hidden")?" Hidden":""))
NavItemText:=g.AddText("BackgroundTrans 0x200 Center h" NavSelectH " w" NavSelectW " x" x " ym" y " vNavItem_" A_Index (NavItem.HasOwnProp("Hidden")?" Hidden":""))
If !NavItem.HasOwnProp("Hidden") {
SetNavLang(g, A_Index)
x+=(NavSelectW+8)
}
If NavItem.HasOwnProp("Fn") && NavItem.Fn {
Fn:=NavItem.Fn
If NavItem.HasOwnProp("NotSelected") && NavItem.NotSelected
FnClick:=%Fn%.Bind(g, A_Index)
Else
FnClick:=NavItem_Click.Bind(g, A_Index)
NavItemText.OnEvent("Click", FnClick)
}
}
g.SetFont("norm s" App.MainFontSize)
NavItem_Click(g, IniRead("config.ini", "General", "LastTab", 1))
g.Show
App.HwndMain:=g.Hwnd
FrameShadow(g.hWnd)
}
NavItem_Click(g:="", NavIndex:=0, *) {
If !g && App.HasOwnProp("HwndMain") && App.HwndMain
g:=GuiFromHwnd(App.HwndMain)
If NavIndex {
g["NavItem_" NavIndex].GetPos(&x, &y)
If g["NavBGActive"].Visible {
g["NavBGActive"].GetPos(&xA, &yA)
If x=xA && y=yA
Return
g["NavBGHover"].Visible:=False
g["NavBGActive"].Visible:=False
}
g["NavBGActive"].Move(x, y)
g["NavBGActive"].Visible:=True
g.NavSelected:=NavIndex
CurrentTabCtrls:=App.CurrentTabCtrls
Loop CurrentTabCtrls.Length {
g[CurrentTabCtrls[A_Index]].Visible:=False
}
}
%Layout[g.NavSelected].Fn%(g, g.NavSelected)
}
WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
static PrevHwnd:=0
if (Hwnd != PrevHwnd) {
ResetNormal()
PrevHwnd := Hwnd
CurrControl := GuiCtrlFromHwnd(Hwnd)
If currControl {
thisGui := currControl.Gui
If currControl.Type="PicSwitch" || InStr(currControl.Name, "Link_")=1 {
currControl.SetFont("c" Themes.%App.ThemeSelected%.TextColorHover)
} Else If InStr(currControl.Name, "BtnSys_")=1 {
If currControl.Type="Text"
currControl.SetFont("c" Themes.%App.ThemeSelected%.TextColorHover)
currControl.Opt("Background" Themes.%App.ThemeSelected%.BackColorNavSelect)
} Else If InStr(currControl.Name, "NavItem_")=1 {
currControl.GetPos(&x, &y)
thisGui["NavBGHover"].Move(x, y)
thisGui["NavBGHover"].Visible := true
}
Lang:=LangData.%App.LangSelected%
If !currControl.Name || !GetLangDesc(currControl.Name)
Return
ToolTipOptions.SetTitle((Title:=GetLangName(currControl.Name))!=currControl.Name?Title:"")
SetTimer(CheckHoverControl, 50)
SetTimer(DisplayToolTip, -600)
}
}
ResetNormal() {
ToolTip()
tControl := GuiCtrlFromHwnd(PrevHwnd)
If tControl {
If tControl.Type="PicSwitch" || InStr(tControl.Name, "Link_")=1 {
tControl.SetFont("c" Themes.%App.ThemeSelected%.TextColor)
} Else If InStr(tControl.Name, "BtnSys_")=1 {
If tControl.Type="Text"
tControl.SetFont("c" Themes.%App.ThemeSelected%.TextColor)
tControl.Opt("BackgroundTrans")
} Else If InStr(tControl.Name, "NavItem_")=1 {
tGui := tControl.Gui
tGui["NavBGHover"].Visible := false
}
}
}
CheckHoverControl(){
If hwnd != prevHwnd {
SetTimer(DisplayToolTip, 0), SetTimer(CheckHoverControl, 0)
}
}
DisplayToolTip(){
ToolTip(HardWrapText(GetLangDesc(currControl.Name,,currControl.HasOwnProp("ToolTipEx")?currControl.ToolTipEx:""), 100))
SetTimer(CheckHoverControl, 0)
}
}
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
If App.HwndMain==hwnd {
thisGui := GuiFromHwnd(hwnd)
If thisGui {
PostMessage 0xA1, 2
DestroyDlg()
}
}
}
WM_WINDOWPOSCHANGED(wParam,lParam,msg,hwnd) {
If IsSet(App) && App.HasOwnProp("HwndMain") && App.HwndMain && App.HwndMain==hwnd
&& App.HasOwnProp("HwndMsg") && App.HwndMsg {
g:=GuiFromHwnd(App.HwndMain)
g2:=GuiFromHwnd(App.HwndMsg)
g.GetPos(&gX, &gY, &gW, &gH)
g2.GetPos(,,&g2W, &g2H)
g2.Move(gX+8, gY+gH-g2H-8)
}
}
ON_EN_SETFOCUS(wParam,lParam,msg,hwnd) {
static EM_SETSEL   := 0x00B1
static EN_SETFOCUS := 0x0100
critical
if ((wParam >> 16) = EN_SETFOCUS) {
DllCall("user32\PostMessage", "ptr", lParam, "uint", EM_SETSEL, "ptr", -1, "ptr", 0)
}
}
CreateWaitDlg(g) {
g.GetPos(&X, &Y, &W, &H)
g2:=CreateDlg(g)
tWidth:=300,tHeight:=20
g2.AddText("Center 0x200 h" tHeight " w" tWidth,GetLangText("Text_WaitDlg")).SetFont("s10")
g2.Show("x" X+(W-tWidth)/2 " y" Y+(H-tHeight)/2)
Return g2
}
CreateDlg(g, gDisabled:=1, bg:="", TextColor:="", HwndName:="HwndPopup") {
DestroyDlg(gDisabled, HwndName)
g2:=Gui("-Caption +Owner" g.Hwnd)
FrameShadow(g2.hWnd)
g2.SetFont("c" (TextColor?TextColor:Themes.%App.ThemeSelected%.TextColor), App.MainFont)
g2.BackColor:=bg?bg:Themes.%App.ThemeSelected%.BackColor
If gDisabled
g.Opt("+Disabled")
App.%HwndName%:=g2.hWnd
Return g2
}
ShowDlg(g, g2, Mode:=1, Ctr:="") {
g.GetPos(&gX, &gY, &gW, &gH)
g2.Show("Hide")
g2.GetPos(,, &g2W, &g2H)
X:=gX
Y:=gY
Switch Mode {
Case 1:
X+=(gW-g2W)/2
Y+=(gH-g2H)/2
Case 2:
g["BGPanel"].GetPos(&pX, &pY, &pW, &pH)
X+=pX+(pW-g2W)/2
Y+=pY+(pH-g2H)/2
Case 3:
g["BGPanel"].GetPos(&pX,, &pW)
X+=pX+(pW-g2W)/2
Y+=(gH-g2H)/2
Case 4:
Ctr.GetPos(&cX,&cY,&cW,&cH)
X+=cX-(g2W-cW)/2
Y+=cY+cH+6
}
g2.Show("x" X " y" Y)
}
DestroyDlg(gDisabled:=1, HwndName:="HwndPopup") {
If App.HasOwnProp("PreventDestroyDlg")
Return
If gDisabled && App.HasOwnProp("HwndMain") && App.HwndMain && g:=GuiFromHwnd(App.HwndMain)
g.Opt("-Disabled")
If App.HasOwnProp(HwndName) && App.%HwndName% {
If WinExist(App.%HwndName%)
WinClose
App.DeleteProp(HwndName)
}
}
SetPreventDestroyDlg(MilliSeconds:=0) {
If MilliSeconds<=0 {
SetTimer , 0
App.DeleteProp("PreventDestroyDlg")
} Else {
App.PreventDestroyDlg:=1
SetTimer SetPreventDestroyDlg, -MilliSeconds
}
}
Msg(args*) {
tMsg:=MsgUI.Bind(args*)
SetTimer tMsg, -1
}
MsgUI(MsgText, MsgTitle:="", Mode:="Icon!", IsViewLogFile:=0, DestroyMsgTime:=5000) {
If !App.HasOwnProp("HwndMain") || !App.HwndMain
Return
g:=GuiFromHwnd(App.HwndMain)
BGColor:=TextColor:=Icon:=""
Switch Mode {
Case "!", "Icon!":
BGColor:="F2C40C"
TextColor:="FFFFFF"
If Mode="Icon!"
Icon:=0xE783
Case "x", "Iconx":
BGColor:="D42525"
TextColor:="FFFFFF"
If Mode="IconX"
Icon:=0xEA39
Default:
BGColor:=Themes.%App.ThemeSelected%.TextColorHover
TextColor:="FFFFFF"
If Mode="Icon?"
Icon:=0xE9CE
Else If Mode="Iconi"
Icon:=0xE946
Else If Mode="Iconv"
Icon:=0xE930
}
g2:=CreateDlg(g, 0, BGColor, TextColor, "HwndMsg")
If Icon
g2.AddText("w24 h24 ",Chr(Icon)).SetFont("s18", App.IconFont)
If MsgTitle {
g2.SetFont("s" App.MainFontSize+2 " bold")
g2.AddText("yp ",MsgTitle)
g2.MarginY:=0
}
g2.SetFont("s" App.MainFontSize+1 " norm")
g2.AddText((MsgTitle || !Icon?"":" yp"),MsgText)
If IsViewLogFile {
}
g.GetPos(&gX, &gY, &gW, &gH)
g2.MarginY:=6
BtnSys_Close2:=g2.AddText('vBtnSys_Close2 x' gW-16-36 ' ym w30 h20 0x200 Center Border',Chr(0xE10A))
BtnSys_Close2.SetFont("s11",App.IconFont)
BtnSys_Close2.Opt("-Border")
BtnSys_Close2.OnEvent("Click",DestroyMsg)
g2.Show("Hide w" gW-16)
WinSetTransparent 240, g2
g2.GetPos(&g2X, &g2Y, &g2W, &g2H)
g2.Show("x" gX+8 " y" gY+gH-g2H-8)
SetTimer DestroyMsg, -DestroyMsgTime
}
DestroyMsg(*) {
SetTimer DestroyMsg, 0
DestroyDlg(0, "HwndMsg")
}
BtnSys_SaveOptimizeConfigTab_Click(Ctr, *) {
g:=Ctr.Gui
HideToolTip()
g.Opt("+OwnDialogs")
SelectedFile := FileSelect("S16", App.Name "_OptimizeTabConfig_" A_Now ".json", "Save a file")
If SelectedFile {
Config:={}
CurrentTabCtrls:=App.CurrentTabCtrls
Loop CurrentTabCtrls.Length {
ItemID:=CurrentTabCtrls[A_Index]
If g[ItemID].Type="PicSwitch" && Data.HasOwnProp(ItemID)
Config.%ItemID%:=g[ItemID].Value
}
If Layout[g.NavSelected].ID="StartMenu" {
ObjStartMenu:={}
StartMenuLayout(&ObjStartMenu)
Config.StartMenuLayout:=ObjStartMenu
}
try
FileDelete SelectedFile
FileAppend JSON.stringify(Config), SelectedFile
}
g.Opt("-OwnDialogs")
}
BtnSys_SaveOptimizeConfigAll_Click(Ctr, *) {
g:=Ctr.Gui
g.Opt("+OwnDialogs")
HideToolTip()
SelectedFile := FileSelect("S16", App.Name "_OptimizeConfig_" A_Now ".json", "Save a file")
If SelectedFile {
SaveOptimizeConfigAll(SelectedFile)
}
g.Opt("-OwnDialogs")
}
BtnSys_LoadOptimizeConfig_Click(Ctr, *) {
g:=Ctr.Gui
g.Opt("+OwnDialogs")
HideToolTip()
SelectedFile := FileSelect(3, , "Open a file", "Optimize Config File (*.json)")
If SelectedFile {
g2:=CreateWaitDlg(g)
LoadOptimizeConfig(SelectedFile, g)
DestroyDlg()
}
g.Opt("-OwnDialogs")
}
BtnSys_SaveImage_Click(Ctr, *) {
g:=Ctr.Gui
g.Opt("+OwnDialogs")
HideToolTip()
SelectedFile := FileSelect("s16" , A_WorkingDir "\" App.Name "_" A_Now ".png", "Save Image", "Image File (*.png)")
if SelectedFile {
g.GetPos(&x, &y, &w, &h)
pToken := Gdip_Startup()
Sleep 200
snap := Gdip_BitmapFromScreen(x+1 "|" y+1 "|" w-2 "|" h-2)
Gdip_SaveBitmapToFile(snap, SelectedFile)
Gdip_DisposeImage(snap)
Gdip_Shutdown(pToken)
}
g.Opt("-OwnDialogs")
}
SetBGNavSelect(g, W:=0, H:=0, R:=8) {
Static sPathX:=W,sPathY:=H,sRounded:=R
If W>0
sPathX:=W
If H>0
sPathY:=H
If sPathX<=0 || sPathY<=0
Return
CreateBGNavSelect(g["NavBGHover"], g["NavBGActive"], sPathX, sPathY ,sRounded)
}
CreateBGNavSelect(NavBGHover, NavBGActive, sPathX, sPathY ,sRounded) {
pBitmap := Gdip_CreateBitmap(sPathX, sPathY)
pGraphics := Gdip_GraphicsFromImage(pBitmap)
Gdip_SetSmoothing(pGraphics)
PathX := PathY := 0
Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, sPathX, sPathY, sRounded, "0x" Themes.%App.ThemeSelected%.BackColorNavSelect)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
NavBGHover.Value:="HBITMAP:" hBitmap
DeleteObject(hBitmap)
PathX := 0, PathX2 := 3, Rounded := 2
PathY := sPathY/4
PathY2 := PathY+sPathY/2
Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, 0xFF4CC2FF)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
NavBGActive.Value:="HBITMAP:" hBitmap
DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
}
SetBGPanel(g, W:=0, H:=0, R:=12, BW:=1) {
Static sPathX:=W,sPathY:=H,sRounded:=R,BorderWidth:=BW
If W>0
sPathX:=W
If H>0
sPathY:=H
If sPathX<=0 || sPathY<=0
Return
pBitmap := Gdip_CreateBitmap(sPathX, sPathY)
pGraphics := Gdip_GraphicsFromImage(pBitmap)
Gdip_SetSmoothing(pGraphics)
DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", pGraphics, "UInt", "0xFF" Themes.%App.ThemeSelected%.BackColor)
PathX := PathY := 0
Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, sPathX, sPathY, sRounded, "0x" Themes.%App.ThemeSelected%.BorderColorPanel)
PathX := PathY := BorderWidth, PathX2 := sPathX-BorderWidth, PathY2 := sPathY-BorderWidth, Rounded := sRounded-BorderWidth
Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, "0x" Themes.%App.ThemeSelected%.BackColorPanel)
DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", 10, "Int", 10, "uint*", &ARGB:=0)
hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
g["BGPanel"].Value:="HBITMAP:" hBitmap
DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
Themes.%App.ThemeSelected%.BackColorPanelRGB:=Format("{:X}", ARGB & 0x00FFFFFF)
}
Gdip_CreateARGBHBITMAPFromBase64(base64Value) {
pBitmap:=Gdip_BitmapFromBase64(&base64Value)
hBitmap:=Gdip_CreateARGBHBITMAPFromBitmap(&pBitmap)
Gdip_DisposeImage(pBitmap)
Return hBitmap
}
Gdip_FillRoundedRectanglePath(pGraphics, X, Y, X2, Y2, R, Color) {
DllCall("Gdiplus.dll\GdipCreatePath", "Int", 0, "UPtr*", &pPath:=0)
PathAddRoundedRect(pPath, X, Y, X2, Y2, R)
DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", Color, "Ptr*", &pBrush:=0)
DllCall("Gdiplus.dll\GdipFillPath", "Ptr", pGraphics, "Ptr", pBrush, "Ptr", pPath)
DllCall("Gdiplus.dll\GdipDeletePath", "Ptr", pPath)
DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush)
}
PathAddRoundedRect(Path, X1, Y1, X2, Y2, R) {
D := (R * 2), X2 -= D, Y2 -= D
DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X1, "Float", Y1, "Float", D, "Float", D, "Float", 180, "Float", 90)
DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X2, "Float", Y1, "Float", D, "Float", D, "Float", 270, "Float", 90)
DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X2, "Float", Y2, "Float", D, "Float", D, "Float", 0, "Float", 90)
DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X1, "Float", Y2, "Float", D, "Float", D, "Float", 90, "Float", 90)
Return DllCall("Gdiplus.dll\GdipClosePathFigure", "Ptr", Path)
}
Gdip_SetSmoothing(pGraphics) {
DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", pGraphics, "UInt", 4)
DllCall("Gdiplus.dll\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", 7)
DllCall("Gdiplus.dll\GdipSetCompositingQuality", "Ptr", pGraphics, "UInt", 4)
DllCall("Gdiplus.dll\GdipSetRenderingOrigin", "Ptr", pGraphics, "Int", 0, "Int", 0)
DllCall("Gdiplus.dll\GdipSetPixelOffsetMode", "Ptr", pGraphics, "UInt", 4)
}
FrameShadow(HGui) {
DllCall("dwmapi\DwmIsCompositionEnabled","IntP",&_ISENABLED:=0)
if !_ISENABLED
DllCall("SetClassLong" (A_PtrSize=8?"Ptr":""),"UInt",HGui,"Int",-26,"Int",DllCall("GetClassLong" (A_PtrSize=8?"Ptr":""),"UInt",HGui,"Int",-26)|0x20000)
else {
_MARGINS:=Buffer(16,0)
NumPut("UInt",1,_MARGINS,0)
NumPut("UInt",1,_MARGINS,4)
NumPut("UInt",1,_MARGINS,8)
NumPut("UInt",1,_MARGINS,12)
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", HGui, "UInt", 2, "Int*", 2, "UInt", 4)
DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", HGui, "Ptr", _MARGINS)
}
}
SetCtrlTheme(Ctr) {
Theme:=Themes.%App.ThemeSelected%
IsCtrDark:=Theme.CtrDark
Mode_Explorer  := (IsCtrDark ? "DarkMode_Explorer"  : "Explorer" )
Mode_CFD       := (IsCtrDark ? "DarkMode_CFD"       : "CFD"      )
Mode_ItemsView := (IsCtrDark ? "DarkMode_ItemsView" : "ItemsView")
Mode:=""
If Ctr.Type="Text" && (InStr(Ctr.Name, "NavHRText_")=1) {
Ctr.Opt("BackgroundTrans c" Theme.HrColor)
} Else If Ctr.Type="Text" && (InStr(Ctr.Name, "HRLine_")=1) {
Ctr.Opt("Background" Theme.HrColor " c" Theme.HrColor)
} Else If Ctr.Type="Text" || Ctr.Type="PicSwitch" {
Ctr.Opt("BackgroundTrans c" Theme.TextColor)
} Else If Ctr.Type="DDL" {
Mode:=Mode_CFD
} Else If Ctr.Type!="Pic" {
Ctr.Opt("Background" Theme.BackColorPanelRGB " c" Theme.TextColor)
If Ctr.Type!="CheckBox"
Mode:=Mode_Explorer
Else If Ctr.Type="ListView"
Mode:=Mode_ItemsView
}
If Mode
DllCall("uxtheme\SetWindowTheme", "ptr", Ctr.hwnd, "str", Mode, "ptr", 0)
}
SetMenuTheme() {
uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
DllCall(SetPreferredAppMode, "Int", Themes.%App.ThemeSelected%.CtrDark?2:3)
DllCall(FlushMenuThemes)
}
GetLangTextWithIcon(LangId) {
IconText:=""
switch LangId {
case "Text_Enable": IconText:=Chr(0xE001)
case "Text_Disable": IconText:=Chr(0xF140)
case "Text_Install": IconText:=Chr(0xE118)
case "Text_Delete", "Text_Uninstall": IconText:=Chr(0xEA39)
case "Text_OpenTarget": IconText:=Chr(0xED25)
case "Text_FindRegistry": IconText:=Chr(0xE74C)
case "Text_SearchOnline": IconText:=Chr(0xF6FA)
case "Text_Details": IconText:=Chr(0xE946)
}
Return (IconText?IconText " ":"") GetLangText(LangId)
}
SetNavLang(g, i) {
g["NavItem_" i].Text:=GetLangName(Layout[i].ID)
If Layout[i].HasOwnProp("hr") && Layout[i].hr
g["NavHRText_" i].Text:=GetLangText(Layout[i].hr)
}
SetNavLangAll(g) {
Loop Layout.Length {
ItemID:=Layout[A_Index].ID
If (ItemID = "")
Continue
SetNavLang(g, A_Index)
}
}
HardWrapText(TextToWrap, LengthLim) {
Static RegExDelimiters := "(\||\*|\!|\]|\[|\\|\/|\.|\=|\:|\;|\?|\@|\-|\_|\)|\(|\{|\}|\s)"
LengthLim := Round(LengthLim)
if (LengthLim<2)
return TextToWrap
if (StrLen(TextToWrap) <= LengthLim + 1)
return TextToWrap
thisIndex := hasMatchedRegEx := offsetu := 0
whereHasMatched := newLinez := ""
Loop Parse, TextToWrap {
thisIndex++
newLinez .= A_LoopField
If A_LoopField="`r" || A_LoopField="`n"
thisIndex := hasMatchedRegEx := 0
If RegExMatch(A_LoopField, RegExDelimiters) {
hasMatchedRegEx := 1
whereHasMatched := A_Index
}
If thisIndex=LengthLim && hasMatchedRegEx=1 {
newLinez := ST_Insert("`n", newLinez, whereHasMatched + offsetu)
offsetu++
thisIndex := hasMatchedRegEx := 0
} Else If thisIndex=LengthLim {
newLinez .= "`n"
thisIndex := hasMatchedRegEx := 0
}
}
return newLinez
}
ST_Insert(insert,input,pos:=1) {
Length := StrLen(input)
((pos > 0) ? (pos2 := pos - 1) : (((pos = 0) ? (pos2 := StrLen(input),Length := 0) : (pos2 := pos))))
output := SubStr(input, 1, pos2) . insert . SubStr(input, pos, Length)
If (StrLen(output) > StrLen(input) + StrLen(insert))
((Abs(pos) <= StrLen(input)/2) ? (output := SubStr(output, 1, pos2 - 1) . SubStr(output, pos + 1, StrLen(input)))
: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2) . SubStr(output, pos - StrLen(insert), StrLen(input))))
Return output
}
CreatePopupTheme(Ctr, *) {
Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
g:=Ctr.Gui
g.GetPos(&xG,&yG)
g2:=CreateDlg(g, 0, Themes.%App.ThemeSelected%.TextColorHover)
g2.SetFont("s" App.MainFontSize+1)
x:=80
For k,v In Themes.OwnProps() {
ThemeColorBtn:=g2.AddText('vTheme_Color_' k ' c' v.BackColor ' x' x ' y' 6 ' w30 h30',App.ThemeSelected=k?Chr(0xEC61):Chr(0xE91F))
ThemeColorBtn.SetFont("s" (App.ThemeSelected=k?22:20),App.IconFont)
ThemeColorBtn.OnEvent("Click", Theme_Color_Click)
x+=38
}
Theme_Color_Click(Ctr, *) {
ThemeClicked:=SubStr(Ctr.Name,13)
If ThemeClicked=App.ThemeSelected
Return
PrevCtr:=Ctr.Gui["Theme_Color_" App.ThemeSelected]
App.ThemeSelected:=ThemeClicked
SetTheme(g, Themes.%App.ThemeSelected%)
PrevCtr.Text:=Chr(0xE91F)
PrevCtr.SetFont("s20")
Ctr.Text:=Chr(0xEC61)
Ctr.SetFont("s22")
IniWrite App.ThemeSelected, "config.ini", "General", "Theme"
}
BGImage:=IniRead("config.ini", "Gui", "BGImage", 0)
g2.SetFont("cFFFFFF")
g2.AddText("xm",GetLangText("Text_BackgroundImage") ":")
g2.AddRadio("vSetting_BGImage_Radio w80 h25" (BGImage==0?" Checked":""), GetLangText("Text_None")).OnEvent("Click",BGImage_Radio_None_Click)
g2.AddRadio("yp h25" (BGImage==1?" Checked":""), GetLangText("Text_DefaultImage")).OnEvent("Click",BGImage_Radio_Default_Click)
IsCustomBGImage:=(BGImage&&BGImage!=0&&BGImage!=1?1:0)
g2.AddRadio("w80 h25 xm" (IsCustomBGImage?" Checked":""), GetLangText("Text_Custom")).OnEvent("Click",BGImage_Radio_Custom_Click)
BGImageEdit:=g2.AddEdit("w200 h25 ReadOnly -Wrap r1 yp c202020" (IsCustomBGImage?"":" Disabled"), (IsCustomBGImage?BGImage:""))
BtnSelectImage:=g2.AddButton("yp h25 Background" Themes.%App.ThemeSelected%.TextColorHover (IsCustomBGImage?"":" Disabled"), "...")
BtnSelectImage.OnEvent("Click",BtnSelectImage_Click)
BGImage_Radio_None_Click(*) {
BtnSelectImage.Enabled:=False
BGImageEdit.Enabled:=False
BGImageEdit.Value:=""
IniWrite 0, "config.ini", "Gui", "BGImage"
}
BGImage_Radio_Default_Click(*) {
BtnSelectImage.Enabled:=False
BGImageEdit.Enabled:=False
BGImageEdit.Value:=""
IniDelete "config.ini", "Gui", "BGImage"
}
BGImage_Radio_Custom_Click(*) {
BtnSelectImage.Enabled:=True
BGImageEdit.Enabled:=True
}
BtnSelectImage_Click(*) {
g.Opt("+Disabled")
g2.Opt("+OwnDialogs")
HideToolTip()
SelectedFile := FileSelect(3, , "Open a image", "")
If SelectedFile {
BGImageEdit.Value:=SelectedFile
IniWrite SelectedFile, "config.ini", "Gui", "BGImage"
}
g2.Opt("-OwnDialogs")
g.Opt("-Disabled")
}
tX:=xG+xCtr-(343-wCtr)/2
tY:=yG+yCtr+hCtr+6
g2.Show("x" tX " y" tY)
If WinWaitNotActive(g2)
DestroyDlg
}
SetTheme(g, Theme) {
g.BackColor:=Theme.BackColor
g.SetFont("c" Theme.TextColor)
ToolTipOptions.SetColors("0x" Theme.BackColor, "0x" Theme.TextColor)
pToken:=Gdip_Startup()
SetBGNavSelect(g)
SetBGPanel(g)
Gdip_Shutdown(pToken)
SetMenuTheme()
For Hwnd, GuiCtrlObj in g {
SetCtrlTheme(GuiCtrlObj)
}
}
CreatePopupLang(Ctr, *) {
g:=Ctr.Gui
g2:=CreateDlg(g, 0)
NavSelectW:=200, NavSelectH:=30
g2.AddPic("Hidden vNavBGHover xm")
g2.AddPic("vNavBGActive Hidden xm")
pToken:=Gdip_Startup()
CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)
SpaceName:="            "
for k,v in LangData.OwnProps() {
y:=(A_Index-1)*34
hFlag:=Gdip_CreateARGBHBITMAPFromBase64(v.Flag)
Flag:=g2.AddPic("BackgroundTrans h20 w20 xm8 ym" y+6, "HBITMAP:" hFlag)
DeleteObject(hFlag)
NavItem:=g2.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y " vNavItem_" k, SpaceName v.Name)
NavItem.OnEvent("Click", Lang_Code_Click)
}
Gdip_Shutdown(pToken)
g2["NavItem_" App.LangSelected].GetPos(&xNavItem, &yNavItem)
g2["NavBGActive"].Move(xNavItem, yNavItem)
g2["NavBGActive"].Visible:=True
Lang_Code_Click(Ctr, *) {
LangClicked:=SubStr(Ctr.Name,9)
If LangClicked=App.LangSelected {
DestroyDlg(0)
Return
}
App.LangSelected:=LangClicked
App.TabLangLoaded:= {}
SetNavLangAll(g)
pToken:=Gdip_Startup()
hFlag:=Gdip_CreateARGBHBITMAPFromBase64(LangData.%App.LangSelected%.Flag)
g["BtnSys_Language"].Value:="HBITMAP:" hFlag
DeleteObject(hFlag)
Gdip_Shutdown(pToken)
IniWrite LangClicked, "config.ini", "General", "Language"
DestroyDlg(0)
NavItem_Click(g)
}
ShowDlg(g, g2, 4, Ctr)
If WinWaitNotActive(g2)
DestroyDlg
}
OptimizeTab(g, NavIndex) {
Static sXCBT,sYCBT
WICB:=20,SpaceItem:=16,C:=App.LangSelected~="en|zh_cn"?3:2
IsSearchTab:=Layout[NavIndex].ID="Search"?1:0
If IsSearchTab {
g["NavBGActive"].Visible:=0
}
g["BGPanel"].GetPos(&PanelX, &PanelY, &PanelW)
try {
g["HRLine_1"].Visible:=1
} Catch {
sXCBT:=PanelX
sYCBT:=PanelY
Link_ClearStartMenu:=g.AddText("vLink_ClearStartMenu BackgroundTrans w150 h20 Hidden x" sXCBT+16 " y" (sYCBT+16))
Link_ClearStartMenu.SetFont("underline")
Link_ClearStartMenu.OnEvent("Click",Link_ClearStartMenu_Click)
Link_SelectAll:=g.AddText("vLink_SelectAll Hidden BackgroundTrans w100 h20 x" sXCBT+(PanelW-160)/2 " y" (sYCBT+=12))
Link_SelectAll.SetFont("s" App.MainFontSize+1 " underline")
Link_SelectAll.OnEvent("Click",Link_SelectAll_Click)
Link_DeselectAll:=g.AddText("vLink_DeselectAll Hidden BackgroundTrans w100 h20 yp")
Link_DeselectAll.SetFont("s" App.MainFontSize+1 " underline")
Link_DeselectAll.OnEvent("Click",Link_DeselectAll_Click)
EditSearch:=g.AddEdit("vEditSearch Hidden w300 x" (sXCBT+(PanelW-300)/2) " y" sYCBT)
SetCtrlTheme(EditSearch)
EditSearch.OnEvent("Change",ShowListBySearch)
g.AddText("vHRLine_1 x" (sXCBT+(PanelW-400)/2) " y" (sYCBT+=30) " w400 h1 Background" Themes.%App.ThemeSelected%.HrColor)
sXCBT+=SpaceItem
sYCBT+=SpaceItem
}
sWCBT:=(PanelW-SpaceItem)/C-SpaceItem
If Layout[NavIndex].ID="StartMenu"
g["Link_ClearStartMenu"].Visible:=1
CurrentTabCtrls:=Array()
If IsSearchTab {
g["EditSearch"].Visible:=1
g["EditSearch"].Focus()
ShowListBySearch
CurrentTabCtrls.Push "EditSearch"
If !App.TabLangLoaded.HasOwnProp(NavIndex) {
SendMessage(0x1501, 1, StrPtr(GetLangDesc("BtnSys_Search")), g["EditSearch"].hwnd)
App.TabLangLoaded.%NavIndex%:=1
}
} Else {
g["Link_SelectAll"].Visible:=1
g["Link_DeselectAll"].Visible:=1
ShowListByLayout
CurrentTabCtrls.Push "Link_ClearStartMenu"
CurrentTabCtrls.Push "Link_SelectAll"
CurrentTabCtrls.Push "Link_DeselectAll"
If !App.TabLangLoaded.HasOwnProp(NavIndex) {
Loop CurrentTabCtrls.Length {
tCtrlID:=CurrentTabCtrls[A_Index]
g[tCtrlID].Text:=GetLangName(tCtrlID)
}
App.TabLangLoaded.%NavIndex%:=1
}
}
CurrentTabCtrls.Push "HRLine_1"
App.CurrentTabCtrls:=CurrentTabCtrls
ShowListBySearch(*) {
static sCtrls:=[]
If sCtrls.Length {
Loop sCtrls.Length
g[sCtrls[A_Index]].Visible:=0
sCtrls:=[]
}
SearchText:=g["EditSearch"].Value
If !SearchText {
App.CurrentTabCtrls:=["EditSearch"]
Return
}
x:=sXCBT
y:=sYCBT
w:=sWCBT
i:=0
Loop Layout.Length {
If !Layout[A_Index].ID || !Layout[A_Index].HasOwnProp("Items")
Continue
Items:=Layout[A_Index].Items
Loop Items.Length {
ItemId:=Items[A_Index]
If SearchText=ItemId
|| ((ItemName:=GetLangName(ItemId)) && ItemName!=ItemId && InStr(ItemName, SearchText))
|| ((ItemDesc:=GetLangDesc(ItemId)) && ItemDesc && InStr(ItemDesc, SearchText)) {
If ShowCB(ItemId,&x,&y,w,&i,&sCtrls)
g[ItemId].Text:=GetLangName(ItemId)
If i>=C*16
Break 2
}
}
}
CurrentTabCtrls:=sCtrls.Clone()
CurrentTabCtrls.Push "EditSearch"
App.CurrentTabCtrls:=CurrentTabCtrls
}
ShowListByLayout() {
i:=0
x:=sXCBT
y:=sYCBT
w:=sWCBT
ItemList:=Layout[NavIndex].Items
Loop ItemList.Length {
ItemId:=ItemList[A_Index]
ShowCB(ItemId,&x,&y,w,&i,&CurrentTabCtrls)
}
}
ShowCB(ItemId,&x,&y,w,&i, &sCtrls) {
CtrlVisibled:=0
try {
If g[ItemId].Name!=ItemId
Throw UnsetItemError()
s:=CheckStatusItem(ItemId, Data.%ItemId%)
If s>=0 {
g[ItemId].Value:=s
CtrlVisibled:=1
If !App.TabLangLoaded.HasOwnProp(NavIndex)
g[ItemId].Visible:=False
}
} catch UnsetItemError {
CtrlVisibled:=CreateCB(g,ItemId, w)
} catch as err {
Debug(err)
} Finally {
If CtrlVisibled {
i++
If i=1 {
} Else If Mod(i,C)=1
y+=30,x-=((C-1)*(SpaceItem+w))
Else
x+=(SpaceItem+w)
g[ItemId].Move(x, y, w)
g[ItemId].Visible:=True
sCtrls.Push ItemId
}
}
Return CtrlVisibled
}
CreateCB(g,ItemId, W) {
s:=CheckStatusItem(ItemId, Data.%ItemId%)
If s<=-1
Return 0
Static m:=Map()
If m.Count=0 {
m["SWidth"]:=20
m["SHeight"]:=20
pToken:=Gdip_Startup()
hValue1Icon:=Gdip_CreateARGBHBITMAPFromBase64('iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKaWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNC0wNy0zMFQwODo0MzoyNyswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDctMzBUMDg6NDM6MjcrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmU2Mzg1NDA3LWM5NzItNWQ0Yy1hMjIwLWM2YmE3YjQyYTM1ZiIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjZiMDFlOTljLTE0YjEtODc0YS1iYTQ0LTAxZDk2MGQxN2M4OCIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgdGlmZjpPcmllbnRhdGlvbj0iMSIgdGlmZjpYUmVzb2x1dGlvbj0iNzIwMDAwLzEwMDAwIiB0aWZmOllSZXNvbHV0aW9uPSI3MjAwMDAvMTAwMDAiIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiIGV4aWY6Q29sb3JTcGFjZT0iNjU1MzUiIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSIzODUiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSIzODUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgc3RFdnQ6d2hlbj0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo2NDM2M2UyYS0xOGYxLTg5NDYtODVjMy1mNDY1NTlkNjE0NTUiIHN0RXZ0OndoZW49IjIwMjQtMDctMzBUMDg6MjU6MjArMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjNiYTA2NWIwLWQ2OTktYzk0OC04YzkyLWUxN2Q4ZjRiMmZlYyIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0zMFQwODo0MzoyNyswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AgdG8gaW1hZ2UvcG5nIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJkZXJpdmVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJjb252ZXJ0ZWQgZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZTYzODU0MDctYzk3Mi01ZDRjLWEyMjAtYzZiYTdiNDJhMzVmIiBzdEV2dDp3aGVuPSIyMDI0LTA3LTMwVDA4OjQzOjI3KzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMTEgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozYmEwNjViMC1kNjk5LWM5NDgtOGM5Mi1lMTdkOGY0YjJmZWMiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZjBlYTdlZWYtZGRmYi1jNTQ3LTliMjItNjE5MzdjNzhlOWYyIiBzdFJlZjpvcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6ZjBlYTdlZWYtZGRmYi1jNTQ3LTliMjItNjE5MzdjNzhlOWYyIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+zEE+wAAAAUlJREFUOBFjYFjxholc/P//fwYQBrIZgXgCEDcyUMEwOyD+AMT/gdgMJCAGxGuB+AdUkBD+jGRYMZI4D1gMyNgMFbgFxGcIYJBaTqhhPUiGyUHFmEDELyC+CsTMRHiVAYo7kQxzgBsGNRAkeJgIwxihhuUhGVaBFCk4DYRpxOY6ZyTDDkLVMqKoQzOQAQuGiQsA8Teo+t9AzAc1rAmXgYzQGO8G4jlQ1yAbfBTJdWFQsV4oH6uBIHYqWhJxxxJuu5AsOYzPQJAANxD7I2m+hRZuf4FYCCkoCBoIs7kdR6LOg8ozEmsgsqGf0Ax7iBZRRBsISzZz0Qz0wpKciDIQW5q7jMV1JBkIc+V+IH4JxLo4EjtWA0F5+QqefMuBwzBQ3r8GKn3QDdwGteUGEaUNMr4B1bcB3UBpqKG/iCwPYfgXtDgTRzeQiZoYAGmMGsR7MoJVAAAAAElFTkSuQmCC')
hValue0Icon:=Gdip_CreateARGBHBITMAPFromBase64('iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAJm2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNC0wNy0zMFQwNzo1ODoxNCswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDctMzBUMDc6NTg6MTQrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjE5YmUzYTUyLTI4MTktNGU0Ny04YWFlLTM3ZWIzNWJmNTMwZiIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmJiYWY2MGEwLTkyMzctMjU0Ni04OTZhLTZiYWNmMTE5MjUxMiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgdGlmZjpPcmllbnRhdGlvbj0iMSIgdGlmZjpYUmVzb2x1dGlvbj0iNzIwMDAwLzEwMDAwIiB0aWZmOllSZXNvbHV0aW9uPSI3MjAwMDAvMTAwMDAiIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiIGV4aWY6Q29sb3JTcGFjZT0iNjU1MzUiIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSIzODUiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSIzODUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgc3RFdnQ6d2hlbj0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoxNDA1NjcwZS01NjZkLWZjNDYtODgyOS02MWQ2ZGI3YTg3MWEiIHN0RXZ0OndoZW49IjIwMjQtMDctMzBUMDc6NTg6MTQrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xMSAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNvbnZlcnRlZCIgc3RFdnQ6cGFyYW1ldGVycz0iZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iZGVyaXZlZCIgc3RFdnQ6cGFyYW1ldGVycz0iY29udmVydGVkIGZyb20gYXBwbGljYXRpb24vdm5kLmFkb2JlLnBob3Rvc2hvcCB0byBpbWFnZS9wbmciLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjE5YmUzYTUyLTI4MTktNGU0Ny04YWFlLTM3ZWIzNWJmNTMwZiIgc3RFdnQ6d2hlbj0iMjAyNC0wNy0zMFQwNzo1ODoxNCswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjExIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MTQwNTY3MGUtNTY2ZC1mYzQ2LTg4MjktNjFkNmRiN2E4NzFhIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgc3RSZWY6b3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pv+Vn28AAAB6SURBVDgRY/j//z8DNTED1Q1kWPGGDYiXAfF/MvBaIOZBN3AtVPItEN8iAb+E6tuNbiBI8AUQM5CB74P0YzPwCpkGnsBl4C0yDTw/auCogYPZQKrnlOdkGngXm4HboIY+gnqBWHwfqu8wuoHcQLyBzPJwOxAL0bTEBgBZ4n0V0qf7fgAAAABJRU5ErkJggg==')
Gdip_Shutdown(pToken)
m["Value1Icon"]:="HBITMAP:*" hValue1Icon
m["Value0Icon"]:="HBITMAP:*" hValue0Icon
}
ThisCheckBox := g.AddPicSwitch("Hidden x0 y0 0x80 w" W " v" ItemId,"",,m)
g[ItemId].OnEvent("Click",CB_Click)
g[ItemId].SPic.OnEvent("Click",(*)=>CB_Click(g[ItemId],""))
g[ItemId].Value:=s
Return 1
}
CB_Click(Ctr,Info) {
g:=Ctr.Gui
g2:=CreateWaitDlg(g)
ProgNowCtr(Ctr,Data.%Ctr.Name%)
DestroyDlg()
}
Link_SelectAll_Click(Ctr,Info) {
Select_Click(Ctr, 1)
}
Link_DeselectAll_Click(Ctr,Info) {
Select_Click(Ctr, 0)
}
Select_Click(Ctr, ID) {
g:=Ctr.Gui
g2:=CreateWaitDlg(g)
CurrentTabCtrls:=App.CurrentTabCtrls
Loop CurrentTabCtrls.Length {
If g[CurrentTabCtrls[A_Index]].Type="PicSwitch" && g[CurrentTabCtrls[A_Index]].Value!=ID {
g[CurrentTabCtrls[A_Index]].Value:=ID
ProgNowCtr(g[CurrentTabCtrls[A_Index]],Data.%CurrentTabCtrls[A_Index]%,1)
}
}
DestroyDlg()
}
ProgNowCtr(Ctr, ItemData,silent:=0) {
ProgNow(Ctr.Name, Ctr.Value, ItemData, silent, Ctr)
}
Link_ClearStartMenu_Click(Ctr,Info) {
g:=Ctr.Gui
g2:=CreateDlg(g)
a:=g2.AddText("w400 h22 xm0 Center", "~~~~~ " GetLangName("Link_ClearStartMenu") " ~~~~~").SetFont("s" App.MainFontSize+1)
g2.AddPic("xm16 y+24 Icon95", "imageres.dll")
a:=g2.AddText("x+16 yp-4 w320 h64", GetLangText("Text_ClearStartMenu_Confirm"))
btn_Yes:=g2.AddButton("xp y+16 w100", GetLangText("Text_Yes"))
btn_Yes.OnEvent("Click",Link_ClearStartMenu_Yes_Click)
SetCtrlTheme(btn_Yes)
btn_No:=g2.AddButton("yp w100", GetLangText("Text_No"))
btn_No.OnEvent("Click",(*)=>DestroyDlg())
SetCtrlTheme(btn_No)
ShowDlg(g, g2)
Link_ClearStartMenu_Yes_Click(Ctr,Info) {
g2:=CreateWaitDlg(g)
Config:={}
CurrentTabCtrls:=App.CurrentTabCtrls
Loop CurrentTabCtrls.Length {
ItemID:=CurrentTabCtrls[A_Index]
If g[ItemID].Type="PicSwitch" && Data.HasOwnProp(ItemID)
Config.%ItemID%:=g[ItemID].Value
}
ObjStartMenu:=Object()
StartMenuLayout(&ObjStartMenu)
Config.StartMenuLayout:=ObjStartMenu
FileAppend JSON.stringify(Config), App.Name "_StartMenuLayout_" A_Now ".json"
item:={
StartBin:"E27AE14B01FC4D1B9C00810BDE6E51854E5A5F47005BB1498A5C92AF9084F95ED76A61CE8F3CDA01200D00005CF6EE792CDF05E1BA2B6325C41A5F10E7E459FAA111B337AA5218595C3BDC8D317AAE0769ADAB884CBA8F80C54C6D265B46C2CDFCEE6E32348B12BEA7598230B0C26464C9D9C99AE14773EE81485428E603AB0C92098EBF08F90BFCEA33FF98F64768705911AA73B66C2710C53350D6A1F8D48868C3527CBE63C523A3092741568F61AA343C2E1BCA02846DE66A0AA46F4A03DA952739DCE16A0A1D851F2773974F5F0A16A8B37F3942F178D040C48123BC53DFDD9ED01E3542F0BAE6418BB06459220E9963759787BE4D96ED4895F09FE108340261447C8248D7A4BB6D5DB30F9C3282E8ACC2A746684930BBC4F8209D80D28868FA3F2AB8B3BDAD7E6CCB08F1B4A457F0B16824CB5E875BFCDB81602B081D8D6C4EF6F048144D30FBDC730E3744909429946404B95FE489AF0384120362882D413A50E4E4743CD324D2C7B1CA133E059418AE4BA4EA764EBEA360678362D6262C9EB9EDEE642A5D12A65922C1CC47E2DCC5AEAB081858DFA2A173DDC9C420EB6181887175D7D207D5E10309D7C95FE815270E6ACEE99704EFAC110D9DC3A6727FFDE85F97014ABECBD48600C9A207DE37BA5501BE5A96A8CC745DDB10E00997FAE31D0D2E2515897EDB008B3030C77A89FF56BFD785C4F7234DC52A202DBE598679876AC333E68B9E3B8303DD1A2006A0D657ED2D733E2E14CFDDAF06DEB93C87AA35A3B001FA65374A707A6982D3330186A9C9C357A656EA3038EAB2F94F1E5D5F9F2E214E1F823F02BC76A33ACD5C8E63F53298CD2814DE867656C9675FF5DBC1A69C819A77A35B9D12B47051668804CC9A0F7227F30599D9BA89F9AB55B45DB2C3EBF23D68D54AA9A4E4F1E45215AC5B9024B890B8E6C0D5F46A0387E09F0F6E29BC3F4159FD091F1BF1F41F19D8D93A7C8B3C60AFA29BA83E239CAE8610123F214187F1F1766090C426CB3D3BF8096F57AFBE6E7973DF820DE3A3B52458D0B0DB4EFB2D617DB6ADC067A33089A9B9E15A6DB1D40D086C591DE0795237FE87DFCFA539A08BAF1D9E4616C90FA9E3F21D6935C67BDDC4FC33F08B92D22A9F39BEE04F23C73C26E1A687A81A7CDB15B0C0BE8C4514C9239BE79BFF69945D160FC71F15EA80CEE63BDB84D4FE32CF82A028D69ADD7243E2909C0178FF6415A6D49129998E52C3DB0AE6F808CD85D5FE3A84F85EEAA398DC4E6409B60E96A3C33D6ABC6461D32281CE55ADD4993B08B0A78D903D91B60E9793DA0D8CC62E0F8F71B2D61D774E4E8CE7A9775B0832E1E7EE22B07F8EF6BBA264642CA1BF3EE69620E9AC05BD5CCD3C7945BAB1F02D5C0186F29C9798B693D1C996BCC9C10943F09C73B56A64D2EA819F6F6581C330A1E36D491A9E0BB94E2927815453BFD119857771B3C4F041C5FE3BE484D91C272B8E1EA05F7F62DF5DC83E7F8DC602029BF53990D52A7122E3E34C8367DA120213DF11FEC43212C0C8546ACB11D9F4120B94D5E4C75608BD49CA19D9F4DE5006DFB5C293273925C6A1A15D7371DE5997A95586F0427FE799AF3BA83E944EC5D489B6DA6C399CB06AAACA11B3B5FAFB5415F8762C27582B11A7DEA46F2DFEB4DF071B142D9C47AE0AA031AB721FA03F1952EF87BBE9438A2A95A7F198F4DFF765DBEFE0C01D30759ECE96E1C365A9B7D33C4814D76A35F67ACC6B7BF8E43E3DC9C3B66062B129919FEEB35E63C778A51B10E9319C422C4733359435B6972DB4BA0604F107AC3F782BA29D18002BE2837F26E074A9EED0182909826C726812B7407F3138A22886A13256A2B3041494734A6C96636E1057FAE533E5264B8BCC3749376F9DCA257F26CC70D71538696355545964DD28614410746528220504E8F4BF4D92AEC3C4CFD9A8AA5B29D247A5B2AB2271A082B2E5DD2E8DBDF51A2C64D545661A9BE5B3707CBE507DF57D331B2467843ABE723837F8907224576BF52F6E4F5640AB419D88E1729345635154F9A688AF32EA177A43E6EB5C5B7A51FBAA23939B66F6F854D6416DADED2BBF3D2A7E58A3B52243AC5B2E28844246A08EE2AB47ECC06E4B7DC2F212395411FB623381C6E86D1BBBC7D0107935472BC4377A6A142BED025E37786B545040D940AA14F585C3C6FD475FDCCD1ACC9E9BDE7B60B3C12FCDC7A0EEC1816C1B16B88B1C07C13345FE62C3D704C72AA3CDCA88942CD39DF0842B70D6B6BC3214BDD9A3B40F5D167924DEB43E987C1B1F1438F3952F904E64270A12E0FA2D6C7C468F3DA68FF6110C6913F7492DFC806BB432E11C51A6B5E2D1FC901448A8DA54B3B42F6B60801B936107F9E220962F8F20D04370A2831B3D9B42F7007023F9C87DA8D1C7559D81568977B6E9040F867968DF91EF79FD6367D7E54B7AAEE4199431C29F2DFCF3046FACEC6C39608290CB6D48366CB6AA9BF9CBCF1994A61E8E1403D1105B5B16A3758C51CEE915403DB135623F564E3A32E828E7435110B87ED80EAC43F717F57290D9D1E3C79760A57654F822F80F292D3A2A10D2C11BFB19E4665D8BE2840F231D74A0BCD9B6E667696404F54462A9A1ECFB1FBE4E64A50EB4625C801F9A3B2CDA627B078CAD5C1E527CDFF38C1EFE1106CBA813C4B315D2EC0BE6BDE7E2E12638E8F2BEBD25930EF7916C6E11FFDC5A5F280AD0655EAF6E0656C6D5F899A317891EB8FADDA57C171483D28CFE8BCD4376234080D73EA18056F811C8DBD1F7DD7696E58B1FB68E853F13294A92C73AF9BCD16A502D3CD27EE0DC359DF4CE5F08306D672D86A086E3A1260368A1F56B9CAAF4A244AF296FBF4ADE073B6A42BF5F62C30F0DAC8477D122414623E800EA12BF21E0BCE435EC933211029BE58540140D03A5C35B74970DC66D26C0C340297EF9831D079028DD1D2F442B2ED8A914C11BF55381BA8E91CE80CCC27B4C381B69AD64F70A6F733E5C894C4ECAA8CD4938E76CE35773910C39BC0181232E530E4CB4ECCFAC78D594ECE0A1CBE6795E7BC8815AACF6F5C7EA7493C3ED2B55E11F00A2C47168244A9E36E1DCCF86FCDCF2AA03A452E1869D33B253A7FD4BE5A6302883BCD8DC7E377F4C2C4329F8136C6AD06CB7D4F10BDFBA2BA206D8C8634423B0C7F096AE6BFBE7ED6465846568867C85D74415B834789A1CAF4E7DCFDFE0C065125E0498564B8CC0C12562B6674618FC5EF7613170AE9834931E973BA9F7E27C4AADC93148E43C15684DDAA5DEE36EABDDDC4A457B4A854B4ECCCB71FF873E44F0D1016D767A75232A101F9C691E37378D081E4AD76D0EEC1443AD198447CD07A7873946297F1755ACBA2D33F6331A2E9029C225B0B8995E5DE1845865E97D00FF7AAE873C370995F246372410314062DE2CE3BFB1A87D5A45804B5E9F927638812186D8DD66F94E603EDAD7B318DFF270DB342CF1F8257A4F6A391B4E5144BC5B1E6419EF34AE9C6C0BEE591626548BF077F56CAD8C349E4350F1A006872DC3EF948E344EF3D0A5D537E00B8EC775E6DFA43EC55F162FAF9DF2E24E99C5941A0C1D098DEFF4BBC77FE20BEA4528D6BAD2D7CAB7A5E228D2CAB81E4842896BC0D647BEB1B5698DC804F68A8EA96595E6A3BC90A441EC486FB1B09D4C56C46AEE92CE5A0549CDC32759E850C143EE46CC78A448AD58DC5AA20A9CCEF1559DB940DB2DD436A8FF920AC537B334D9B0AE192ACE93EA3FE242EA47DEF97ED989A8CD9F5425BD62C67B63A5FFDFCFF4E73CDF3F1F7768D1DE13C1428134D0D27B21C5E57045CDD8041B4A86070090957EF9F1A4137B326100577406826AEE74C99FBF53469ABCCC2D7180C643D4660F111D72730675A903FC2A3A4AE61002FF139CE562330C1C9256EE5E4EAFDE3218792DCCE9002409C56ABBFDF6BB4A558903730995CDEB53173C1D5F019C10AEF45D0D23A863F3E0E2BAFF81134EF97558032184C258FB077B67DE07381C959476675F2A5A901B0ADF9F03D975E67FBB15F3CD5EC4DFA921F3C860DBF954362BC89D48C929A070F49F37A9BB79A9E43731052D70507F8266B75981917B734B14DB9C25E3BA22BC9D9D591BD25C1956D190DBE6EB5FB7FBEE27F05EFED485706B92FC1018381A712D27DFAED9B6174D59760B4A18DC3BE58E4E5537E8872D57A9A61D4884704F64CE9443221DD6A6AF6E935B0088C602F26EEABF5860A08BB24DEBFBEF695C07B2690C0736DF6063FFB23DDBAF2A1C03902FFEB7809F6ED5DFEB6F67CC13E3FF0A2A0749FACF2B625788FF9060737DC6CAEAFBF80F476F4D1586591179404972853240FD8E0497F97761B7B08CCA395B968DA08DA3D2BF445F768574A72C61CAEBCFA548EAFE40719587F6D76D7BBCF4417EBBEEF6A73505F9E5C5EE23D41F0D202E68A9E10060A18E61E33457DE179FC21FCE2DA9E7254D8B161789BD6425EC1E4E01A11FCE88B7F83F4594AC9D39A2F84A60723713DF34375A5A62DA4D38757555122E66AC676733BC555306844C31E5ED6BD1990255F5B6E0035B2DF1D7A1F1C330BC7114D52904F4A0CC61E7B9E1E49C409C7FA2781C2141AB3BD21F54E34374BA27CB6ADB2690FA314D93119132EB2175734D8933630C560C24DBE044BDA5BBADCD3C4F82C72F88282D4D74A2F078574E199AF6CB52B622475E7E637D70B650FC2557930F10C369CEAFF9EDC2E155FEDBC9A0F5B610ECD1985D973BC9900D0BF9D64E7FBF8644D952F474822F8F533E28FC349D2B36EF542025A9D8C0ADC2A4596E2BFD629448BB24A0E2913F174D2CF5419764BA6E58DEE0BBC1CEE9697875AE6D759F096E082EE388",
Suggestions: "020000005ecce65175f1d80100000000434201000a0a00ca32000000",
TileGrid: "020000006bc38df82ff8d80100000000434201000a0a00d0140cca3200e22c01010000",
}
StartMenuLayout(&item, "set", 0)
DestroyDlg()
}
}
}
BtnHostsEdit_Click(g, NavIndex) {
Hosts:=LoadHostsFile()
CurrentTabCtrls:=[	"HostsEdit" ,
"HostsEdit_BtnImportFromFile",
"HostsEdit_EditLink",
"HostsEdit_BtnImportFromLink",
"HostsEdit_BtnSaveAs",
"HostsEdit_BtnSave",
"HostsEdit_TxtSelectLink",
"HostsEdit_TreeViewSelectLink",
"HostsEdit_BtnResetDefault",
"HostsEdit_BtnReload"]
try {
g["HostsEdit"].Value:=Hosts
g["HostsEdit_BtnSave"].Enabled:=False
Loop CurrentTabCtrls.Length {
g[CurrentTabCtrls[A_Index]].Visible:=True
}
} catch {
g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
HostsEdit:=g.AddEdit("h" PanelH-12 " w" PanelW-320-24 " -wrap x" sXCBT+6 " y" sYCBT+6 " vHostsEdit")
HostsEdit.Value:=Hosts
HostsEdit.OnEvent("Change",HostsEdit_Change)
HostsEdit_Change(*) {
g["HostsEdit_BtnSave"].Enabled:=True
}
HostListData:=[
{Author: "crazy-max", Source: "github.com/crazy-max/WindowsSpyBlocker", Items:[
{Name: "Windows spying and tracking IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"},
{Name: "Windows spying and tracking IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy_v6.txt"},
{Name: "Windows update IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update.txt"},
{Name: "Windows update IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update_v6.txt"},
{Name: "Windows extra IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra.txt"},
{Name: "Windows extra IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra_v6.txt"}
]
},
{Author: "StevenBlack", Source: "github.com/StevenBlack/hosts", Items:[
{Name: "All block lists", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"},
{Name: "Adware + Malware", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"},
{Name: "Adware + Malware + Fakenews", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"},
{Name: "Fakenews Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"},
{Name: "Adware + Malware + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts"},
{Name: "Gambling Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"},
{Name: "Adware + Malware + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"},
{Name: "Porn Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts"},
{Name: "Adware + Malware + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts"},
{Name: "Social Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social-only/hosts"},
{Name: "Adware + Malware + Fakenews + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts"},
{Name: "Fakenews + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-only/hosts"},
{Name: "Adware + Malware + Fakenews + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn/hosts"},
{Name: "Fakenews + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-only/hosts"},
{Name: "Adware + Malware + Fakenews + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social/hosts"},
{Name: "Fakenews + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social-only/hosts"},
{Name: "Adware + Malware + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"},
{Name: "Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-only/hosts"},
{Name: "Adware + Malware + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts"},
{Name: "Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social-only/hosts"},
{Name: "Adware + Malware + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social/hosts"},
{Name: "Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social-only/hosts"},
{Name: "Adware + Malware + Fakenews + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"},
{Name: "Fakenews + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-only/hosts"},
{Name: "Adware + Malware + Fakenews + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts"},
{Name: "Fakenews + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social-only/hosts"},
{Name: "Adware + Malware + Fakenews + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social/hosts"},
{Name: "Fakenews + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social-only/hosts"},
{Name: "Adware + Malware + Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts"},
{Name: "Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social-only/hosts"},
{Name: "Fakenews + Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social-only/hosts"},
]
}
]
g.AddText("yp w320 Section vHostsEdit_TxtSelectLink")
ImageListID := IL_Create(2)
IL_Add(ImageListID, "shell32.dll", 4)
IL_Add(ImageListID, "shell32.dll", 14)
TV := g.AddTreeView("w320 h300 vHostsEdit_TreeViewSelectLink ImageList" ImageListID)
TV.OnEvent("Click",TreeViewSelectLink_Click)
TV.OnEvent("ItemExpand",TreeViewSelectLink_ItemExpand)
ObjectF:={}
Loop HostListData.Length {
i:=A_Index
P1:=TV.Add(HostListData[i].Source,,"Icon1")
Items:=HostListData[i].Items
Loop Items.Length {
P1C1:=TV.Add(Items[A_Index].Name, P1,"Icon2")
ObjectF.%P1C1%:={SourceID:i,ItemID:A_Index}
}
}
TreeViewSelectLink_Click(GuiCtrlObj, Info) {
sID:=TV.GetSelection()
If ObjectF.HasOwnProp(sID) {
SourceID:=ObjectF.%sID%.SourceID
ItemID:=ObjectF.%sID%.ItemID
EditLink.Value:=HostListData[SourceID].Items[ItemID].Link
ControlSend "^{End}", EditLink
g["HostsEdit_BtnImportFromLink"].Enabled:=True
}
}
TreeViewSelectLink_ItemExpand(GuiCtrlObj, Item, Expanded) {
GuiCtrlObj.Visible:=False
GuiCtrlObj.Visible:=True
}
BtnImportFromLink := g.AddButton("xs Disabled vHostsEdit_BtnImportFromLink", "«")
BtnImportFromLink.OnEvent("Click",(*)=>BtnImportFromLink_Click(g))
BtnImportFromLink_Click(g) {
CreateWaitDlg(g)
Try {
spy:=WinHttpResponseText(g["HostsEdit_EditLink"].Value,,,, &Status, &StatusText)
If Status==200 {
g["HostsEdit"].Value.="`n" spy "`n"
g["HostsEdit_EditLink"].Value:=""
g["HostsEdit_BtnImportFromLink"].Enabled:=False
g["HostsEdit_BtnSave"].Enabled:=True
ControlSend "^{End}", g["HostsEdit"]
} Else {
Msg(StatusText,"Hosts Edit","Icon!")
}
} Catch as err {
Msg(err.Message,"Hosts Edit","Icon!")
} Finally {
DestroyDlg()
}
}
EditLink:=g.AddEdit("yp w290 -wrap vHostsEdit_EditLink")
EditLink.OnEvent("Change",EditLink_Change)
EditLink_Change(*) {
g["HostsEdit_BtnImportFromLink"].Enabled:=!!EditLink.Value
}
BtnImportFromFile := g.AddButton("xs y+24 w140 h40 vHostsEdit_BtnImportFromFile")
BtnImportFromFile.OnEvent("Click",BtnImportFromFile_Click)
BtnImportFromFile_Click(*) {
files := FileSelect("M3", A_WorkingDir, "Select block list to hosts file")
Loop files.Length {
Hosts:=FileRead(files[A_Index])
g["HostsEdit"].Value.="`n`n### " files[A_Index] "`n" Hosts
ControlSend "^{End}", g["HostsEdit"]
}
If files.Length {
g["HostsEdit_BtnSave"].Enabled:=True
}
}
BtnSaveAs := g.AddButton("yp w140 h40 vHostsEdit_BtnSaveAs")
BtnSaveAs.OnEvent("Click",BtnSaveAs_Click)
BtnSaveAs_Click(*) {
sfile := FileSelect("S16", "hosts_" A_Now, "Save As")
If sfile {
try FileDelete sfile
FileAppend g["HostsEdit"].Value, sfile
}
}
BtnReload := g.AddButton("xs w140 h40 vHostsEdit_BtnReload")
BtnReload.OnEvent("Click",BtnReload_Click)
BtnReload_Click(*) {
g["HostsEdit"].Value:=LoadHostsFile()
ControlSend "^{End}", g["HostsEdit"]
g["HostsEdit_BtnSave"].Enabled:=False
}
BtnResetDefault := g.AddButton("yp w140 h40 vHostsEdit_BtnResetDefault")
BtnResetDefault.OnEvent("Click",BtnResetDefault_Click)
BtnResetDefault_Click(*) {
g["HostsEdit"].Value:='
(
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
)'
ControlSend "^{End}", g["HostsEdit"]
g["HostsEdit_BtnSave"].Enabled:=True
}
BtnSave := g.AddButton("Disabled xs w140 h60 vHostsEdit_BtnSave")
BtnSave.OnEvent("Click",BtnSave_Click)
BtnSave.SetFont("s" App.MainFontSize+2)
BtnSave_Click(*) {
SaveHostsFile(HostsEdit.Value)
BtnSave.Enabled:=False
}
Loop CurrentTabCtrls.Length {
SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
}
}
If !App.TabLangLoaded.HasOwnProp(NavIndex) || !App.TabLangLoaded.%NavIndex% {
Loop CurrentTabCtrls.Length {
tCtrlID:=CurrentTabCtrls[A_Index]
If tCtrlID!="HostsEdit_BtnImportFromLink" && (g[tCtrlID].Type="Button" || g[tCtrlID].Type="Text")
g[tCtrlID].Text:=GetLangName(tCtrlID)
}
App.TabLangLoaded.%NavIndex%:=1
}
App.CurrentTabCtrls:=CurrentTabCtrls
}
BtnStartupManager_Click(g, NavIndex) {
static LVWidth
CurrentTabCtrls:=[	"StartupManager_BtnDisable" ,
"StartupManager_BtnDelete",
"StartupManager_BtnOpenTarget",
"StartupManager_BtnFindRegistry",
"StartupManager_BtnSearchOnline",
"StartupManager_LV"]
try {
Loop CurrentTabCtrls.Length {
If CurrentTabCtrls[A_Index]!="StartupManager_LV"
g[CurrentTabCtrls[A_Index]].Enabled:=False
g[CurrentTabCtrls[A_Index]].Visible:=True
}
} Catch {
g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
g.SetFont("s11",App.IconFont)
a:=g.AddButton("vStartupManager_BtnDisable w130 Disabled x" sXCBT+6 " y" sYCBT+6)
a.OnEvent("Click",(*)=>StartupManager_FnRun(1))
a:=g.AddButton("vStartupManager_BtnDelete yp w130 Disabled")
a.OnEvent("Click",(*)=>StartupManager_FnRun(6))
a:=g.AddButton("vStartupManager_BtnOpenTarget yp w190 Disabled")
a.OnEvent("Click",(*)=>StartupManager_FnRun(3))
a:=g.AddButton("vStartupManager_BtnFindRegistry yp w160 Disabled")
a.OnEvent("Click",(*)=>StartupManager_FnRun(4))
a:=g.AddButton("vStartupManager_BtnSearchOnline yp w145 Disabled")
a.OnEvent("Click",(*)=>StartupManager_FnRun(5))
LVWidth:=PanelW-12
g.SetFont("s" App.MainFontSize+1,App.MainFont)
LVStartupManager:=g.AddListView("vStartupManager_LV -Multi w" LVWidth " h" PanelH-46 " x" sXCBT+6 " y" sYCBT+40, ["","","","","Type","StatusId"])
LVStartupManager.OnEvent("Click",LVStartupManager_Click)
LVStartupManager.OnEvent("ContextMenu",LVStartupManager_ContextMenu)
g.SetFont("s" App.MainFontSize,App.MainFont)
Loop CurrentTabCtrls.Length {
SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
}
}
LVStartupManager:=g["StartupManager_LV"]
If !App.TabLangLoaded.HasOwnProp(NavIndex) || !App.TabLangLoaded.%NavIndex% {
m:=Map("StartupManager_BtnDisable", "Text_Disable" ,
"StartupManager_BtnDelete", "Text_Delete" ,
"StartupManager_BtnOpenTarget", "Text_OpenTarget" ,
"StartupManager_BtnFindRegistry", "Text_FindRegistry" ,
"StartupManager_BtnSearchOnline", "Text_SearchOnline"
)
For k, v in m {
g[k].Text:=GetLangTextWithIcon(v)
}
LVStartupManager.ModifyCol(1, , GetLangText("Text_Name"))
LVStartupManager.ModifyCol(2, , GetLangText("Text_Status"))
LVStartupManager.ModifyCol(3, , GetLangText("Text_CommandLine"))
LVStartupManager.ModifyCol(4, , GetLangText("Text_Target"))
App.TabLangLoaded.%NavIndex%:=1
}
ImageListID := IL_Create(20)
LVStartupManager.SetImageList(ImageListID)
IL_Add(ImageListID, "imageres.dll", 3)
IL_Add(ImageListID, "imageres.dll", 12)
IL_Add(ImageListID, "imageres.dll", 4)
LVStartupManager.ModifyCol(1, 28/100*LVWidth)
LVStartupManager.ModifyCol(2, 12/100*LVWidth)
LVStartupManager.ModifyCol(3, 60/100*LVWidth-2)
LVStartupManager.ModifyCol(4, 0)
LVStartupManager.ModifyCol(5, 0)
LVStartupManager.ModifyCol(6, 0)
LVStartupManager.Delete()
StartupType:=[
{Type: "Registry", LongType: "Registry_HKCU_Run", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
{Type: "Registry", LongType: "Registry_HKCU_RunOnce", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce"},
{Type: "Registry", LongType: "Registry_HKCU_RunPolicies", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"},
{Type: "Registry", LongType: "Registry_HKLM_Run", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
{Type: "Registry", LongType: "Registry_HKLM_Run32", RunKey: "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"},
{Type: "Registry", LongType: "Registry_HKLM_RunOnce", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"},
{Type: "Registry", LongType: "Registry_HKLM_RunOnce32", RunKey: "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce"},
{Type: "Registry", LongType: "Registry_HKLM_RunPolicies", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"},
{Type: "Folder", LongType: "Folder_Startup", RunKey: EnvGet2("Startup"), StartupApprovedKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
{Type: "Folder", LongType: "Folder_StartupCommon", RunKey: A_StartupCommon, StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
{Type: "UWPApp", LongType: "Registry_HKCU_Run", FamilyName: "Microsoft.549981C3F5F10_8wekyb3d8bbwe", RunKey: "CortanaStartupId", CheckStartTerminalOnLoginTask: 1},
{Type: "UWPApp", LongType: "Registry_HKCU_Run", FamilyName: "Microsoft.WindowsTerminal_8wekyb3d8bbwe", RunKey: "StartTerminalOnLoginTask"}
]
Loop StartupType.Length {
iType:=StartupType[A_Index].Type
%iType%Load(LVStartupManager, A_Index, StartupType[A_Index])
}
App.CurrentTabCtrls:=CurrentTabCtrls
FolderLoad(LV, sId, sItem) {
sPath:=sItem.RunKey
StartupApprovedKey:=sItem.StartupApprovedKey
Loop Files, sPath "\*.*" {
If A_LoopFileName="desktop.ini"
Continue
If A_LoopFileExt="LNK" {
FileGetShortcut A_LoopFilePath, &rTarget, &OutDir, &rArgs, &OutDesc, &rIcon, &rIconNum, &OutRunState
rCommandLine:=rTarget " " rArgs
IconIndex := IL_Add(ImageListID, rIcon?rIcon:rTarget, rIconNum?rIconNum:1)
IconIndex := IconIndex?IconIndex:2
} Else {
rTarget:=A_LoopFilePath
rCommandLine:=A_LoopFilePath
IconIndex:=1
If InStr(FileExist(rTarget), "D")
IconIndex := 3
Else {
IconIndex := IL_Add(ImageListID, rTarget, 1)
IconIndex := IconIndex?IconIndex:2
}
}
HexReg:=RegRead(StartupApprovedKey, A_LoopFileName, "")
ItemStatus:=""
If HexReg
ItemStatus:=SubStr(HexReg, 1, 2)+0
ItemStatusText:=""
If ItemStatus && Mod(ItemStatus, 2)
ItemStatusText:=GetLangText("Text_Disabled")
Else
ItemStatusText:=GetLangText("Text_Enabled")
LV.Add("Icon" IconIndex, A_LoopFileName, ItemStatusText, rCommandLine, rTarget, sId, ItemStatus)
}
}
RegistryLoad(LV, sId, sItem) {
RunKey:=sItem.RunKey
Loop Reg, RunKey {
v:=RegRead()
ItemStatus:=""
ItemStatusText:=GetLangText("Text_Enabled")
If sItem.HasOwnProp("StartupApprovedKey") && sItem.StartupApprovedKey {
StartupApprovedKey:=sItem.StartupApprovedKey
HexReg:=RegRead(StartupApprovedKey, A_LoopRegName, "")
If HexReg
ItemStatus:=SubStr(HexReg, 1, 2)+0
Else
ItemStatus:=2
If Mod(ItemStatus, 2)
ItemStatusText:=GetLangText("Text_Disabled")
}
try {
rTarget:=FindTarget(v, &attr:="")
} catch Error as err {
Debug(err,"CommandLine: " v)
}
IconIndex:=1
If attr="D"
IconIndex := 3
Else If attr="AE" {
IconIndex := IL_Add(ImageListID, rTarget, 1)
IconIndex := IconIndex?IconIndex:2
}
LV.Add("Icon" IconIndex, A_LoopRegName, ItemStatusText, v, rTarget, sId, ItemStatus)
}
}
UWPAppLoad(LV, sId, sItem) {
Packages:=PackageManager.FindPackagesByPackageFamilyName(sItem.FamilyName)
If !Packages.Length
Return
RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" sItem.FamilyName "\" sItem.RunKey
State:=RegRead(RunKey, "State", 0)
If sItem.HasOwnProp("CheckStartTerminalOnLoginTask") && sItem.CheckStartTerminalOnLoginTask {
If !RegRead(RunKey, "UserEnabledStartupOnce", 0)
State:=1
}
ItemStatusText:=GetLangText("Text_Disabled")
If State==2
ItemStatusText:=GetLangText("Text_Enabled")
IconIndex := IL_Add(ImageListID, Packages[1].Logo)
LV.Add("Icon" IconIndex, Packages[1].DisplayName, ItemStatusText, , , sId, State)
}
FindTarget(InPath, &rFileAttr) {
If !InPath
Return
StartPos:=1
tmpTarget:=""
while (fpo:=RegexMatch(InPath, '[^" ]+|"([^"]*)"', &m, StartPos)) {
if A_Index!=1
tmpTarget.=' '
tmpTarget.=m[1]?m[1]:m[]
If InStr(tmpTarget, "%")
tmpTarget:=ExpandEnvironmentStrings(tmpTarget)
If InStr(FileExist(tmpTarget), "D") {
rFileAttr:="D"
Return tmpTarget
} Else If InStr(FileExist(tmpTarget), "A") || InStr(FileExist(tmpTarget), "N") {
SplitPath tmpTarget, &rFileName
rFileAttr:="A"
If SubStr(rFileName, -4)=".exe"
rFileAttr.="E"
Return tmpTarget
}
StartPos := fpo + StrLen(m[])
}
}
LVStartupManager_Click(GuiCtrlObj, Item) {
If Item {
iTarget:=GuiCtrlObj.GetText(Item , 4)
iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
g["StartupManager_BtnOpenTarget"].Enabled:=!!iTarget
g["StartupManager_BtnFindRegistry"].Enabled:=(iType=="Registry")
g["StartupManager_BtnSearchOnline"].Enabled:=True
IsUWPApp:=(iType=="UWPApp")
iStatus:=GuiCtrlObj.GetText(Item , 6)
If (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
bStatusText:="Text_Enable"
} Else
bStatusText:="Text_Disable"
g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
If IsUWPApp
g["StartupManager_BtnDisable"].Enabled:=True
Else
g["StartupManager_BtnDisable"].Enabled:=!!iStatus
g["StartupManager_BtnDelete"].Enabled:=!IsUWPApp
} Else {
DisableAllBtn()
}
}
LVStartupManager_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
If Item<=255
DisableAllBtn()
If Item<=0 || Item>255
Return
MyMenu := Menu()
iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
IsUWPApp:=(iType=="UWPApp")
iStatus:=GuiCtrlObj.GetText(Item , 6)
bStatusText:=""
If (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
bStatusText:="Text_Enable"
} Else
bStatusText:="Text_Disable"
g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
If IsUWPApp
g["StartupManager_BtnDisable"].Enabled:=True
Else
g["StartupManager_BtnDisable"].Enabled:=!!iStatus
MyMenu.Add(GetLangText(bStatusText), RunItem)
MyMenu.Add(GetLangText("Text_Properties"), RunItem)
MyMenu.Add(GetLangText("Text_OpenTarget"), RunItem)
MyMenu.Add(GetLangText("Text_FindRegistry"), RunItem)
MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
MyMenu.Add(GetLangText("Text_Delete"), RunItem)
If !iStatus && !IsUWPApp
MyMenu.Disable("1&")
iTarget:=GuiCtrlObj.GetText(Item , 4)
If iTarget {
g["StartupManager_BtnOpenTarget"].Enabled:=True
} Else {
MyMenu.Disable("2&")
MyMenu.Disable("3&")
}
IsRegistry:=(iType=="Registry")
If IsRegistry {
g["StartupManager_BtnFindRegistry"].Enabled:=True
} Else {
MyMenu.Disable("4&")
}
g["StartupManager_BtnSearchOnline"].Enabled:=True
If IsUWPApp {
g["StartupManager_BtnDelete"].Enabled:=False
MyMenu.Disable("6&")
} Else
g["StartupManager_BtnDelete"].Enabled:=True
MyMenu.Show
RunItem(ItemName, ItemPos, MyMenu) {
StartupManager_FnRun(ItemPos)
}
}
StartupManager_FnRun(ItemPos) {
LV:=g["StartupManager_LV"]
i:=LV.GetNext()
If ItemPos=1 {
iStatus:=LV.GetText(i , 6)
iType:=StartupType[LV.GetText(i , 5)].Type
IsUWPApp:=(iType=="UWPApp")
If IsUWPApp {
If iStatus!=2 {
iStatusText:="Text_Enabled"
bStatusText:="Text_Disable"
iStatus:=2
RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" StartupType[LV.GetText(i , 5)].FamilyName "\" StartupType[LV.GetText(i , 5)].RunKey
RegWrite 1, "REG_DWORD", RunKey, "UserEnabledStartupOnce"
} Else {
iStatusText:="Text_Disabled"
bStatusText:="Text_Enable"
iStatus:=1
}
RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" StartupType[LV.GetText(i , 5)].FamilyName "\" StartupType[LV.GetText(i , 5)].RunKey
RegWrite iStatus, "REG_DWORD", RunKey, "State"
} Else {
sHex:=""
If iStatus && Mod(iStatus, 2) {
If iStatus=3 {
iStatus:=2
} Else {
iStatus:=6
}
sHex.="0" iStatus "0000000000000000000000"
iStatusText:="Text_Enabled"
bStatusText:="Text_Disable"
} Else {
If !iStatus || iStatus=2 {
iStatus:=3
} Else {
iStatus:=7
}
sHex.="0" iStatus "000000" "004012B7D233B201"
iStatusText:="Text_Disabled"
bStatusText:="Text_Enable"
}
RegWrite sHex, "REG_BINARY", StartupType[LV.GetText(i , 5)].StartupApprovedKey, LV.GetText(i , 1)
}
g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
LV.Modify(i,,, GetLangText(iStatusText),,,,iStatus)
Return
} Else If ItemPos=6 {
iType:=StartupType[LV.GetText(i , 5)].Type
If iType=="Registry" {
try RegDelete StartupType[LV.GetText(i , 5)].RunKey, LV.GetText(i , 1)
} Else {
f:=StartupType[LV.GetText(i , 5)].RunKey "\" LV.GetText(i , 1)
If InStr(FileExist(f), "D") {
try DirDelete f, true
} Else {
try FileDelete f
}
}
try RegDelete StartupType[LV.GetText(i , 5)].StartupApprovedKey, LV.GetText(i , 1)
LV.Delete(i)
DisableAllBtn()
Return
} Else If ItemPos=2 {
runAsParam:="properties " LV.GetText(i, 4)
} Else If ItemPos=3 {
runAsParam:="explorer.exe /select, " LV.GetText(i, 4)
} Else If ItemPos=4 {
RegWrite StartupType[LV.GetText(i , 5)].RunKey, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey"
runAsParam:="regedit.exe"
} Else If ItemPos=5 {
SplitPath LV.GetText(i, 4), &rFileName
runAsParam:="https://www.google.com/search?q=" LV.GetText(i, 1) " " rFileName
}
try Run(runAsParam)
}
DisableAllBtn() {
g["StartupManager_BtnDisable"].Enabled:=False
g["StartupManager_BtnDelete"].Enabled:=False
g["StartupManager_BtnOpenTarget"].Enabled:=False
g["StartupManager_BtnFindRegistry"].Enabled:=False
g["StartupManager_BtnSearchOnline"].Enabled:=False
}
}
BtnPackageManager_Click(g, NavIndex) {
static LVWidth
CurrentTabCtrls:=[	"PackageManager_BtnDisable" ,
"PackageManager_BtnUninstallChecked",
"PackageManager_BtnUninstall",
"PackageManager_BtnSearchOnline",
"PackageManager_BtnDetails",
"PackageManager_Mode",
"PackageManager_InstalledAllUsers",
"PackageManager_DeprovisionPackage",
"PackageManager_LV"]
try {
Loop CurrentTabCtrls.Length {
If InStr(CurrentTabCtrls[A_Index], "PackageManager_Btn")
g[CurrentTabCtrls[A_Index]].Enabled:=False
g[CurrentTabCtrls[A_Index]].Visible:=True
}
} Catch {
g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
xTop:=sXCBT+8
yTop:=sYCBT+8
a:=g.AddDDL("vPackageManager_Mode w200 Section x" xTop " y" yTop)
a.OnEvent("Change",SwichInstalled)
b:=g.AddCheckbox("vPackageManager_InstalledAllUsers yp w150")
b.OnEvent("Click",SwichInstalled)
g.AddCheckbox("vPackageManager_DeprovisionPackage yp w200")
g.SetFont("s11",App.IconFont)
a:=g.AddButton("vPackageManager_BtnUninstallChecked w150 Disabled xs")
a.OnEvent("Click",(*)=>PackageManager_FnRun(1))
a:=g.AddButton("vPackageManager_BtnUninstall yp w150 Disabled")
a.OnEvent("Click",(*)=>PackageManager_FnRun(2))
a:=g.AddButton("vPackageManager_BtnDisable yp w146 Disabled")
a.OnEvent("Click",(*)=>PackageManager_FnRun(3))
a:=g.AddButton("vPackageManager_BtnSearchOnline yp w160 Disabled")
a.OnEvent("Click",(*)=>PackageManager_FnRun(4))
a:=g.AddButton("vPackageManager_BtnDetails yp w146 Disabled")
a.OnEvent("Click",(*)=>PackageManager_FnRun(5))
g.SetFont("s" App.MainFontSize+1,App.MainFont)
LVWidth:=PanelW-16
LVPackageManager:=g.AddListView("vPackageManager_LV -Multi Sort Checked xs w" LVWidth " h" PanelH-66-16, ["","","","","","Id",""])
LVPackageManager.OnEvent("Click",LVPackageManager_Click)
LVPackageManager.OnEvent("DoubleClick",LVPackageManager_DoubleClick)
LVPackageManager.OnEvent("ContextMenu",LVPackageManager_ContextMenu)
LVPackageManager.OnEvent("ItemCheck",LVPackageManager_ItemCheck)
g.SetFont("s" App.MainFontSize,App.MainFont)
Loop CurrentTabCtrls.Length {
SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
}
}
If !App.TabLangLoaded.HasOwnProp(NavIndex) || !App.TabLangLoaded.%NavIndex% {
LVPackageManager:=g["PackageManager_LV"]
g["PackageManager_Mode"].Delete()
g["PackageManager_Mode"].Add([GetLangText("Text_InstalledMode"),GetLangText("Text_NotInstalledMode")])
g["PackageManager_Mode"].Choose(1)
g["PackageManager_Mode"].Opt("Redraw")
g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (0)"
g["PackageManager_InstalledAllUsers"].Text:=GetLangName("PackageManager_InstalledAllUsers")
g["PackageManager_DeprovisionPackage"].Text:=GetLangName("PackageManager_DeprovisionPackage")
m:=Map("PackageManager_BtnUninstall", "Text_Uninstall" ,
"PackageManager_BtnDisable", "Text_Disable" ,
"PackageManager_BtnDetails", "Text_Details" ,
"PackageManager_BtnSearchOnline", "Text_SearchOnline")
For k, v in m {
g[k].Text:=GetLangTextWithIcon(v)
}
LVPackageManager.ModifyCol(1, , GetLangText("Text_Name"))
LVPackageManager.ModifyCol(2, , GetLangText("Text_Status"))
LVPackageManager.ModifyCol(3, , GetLangText("Text_Version"))
LVPackageManager.ModifyCol(4, , GetLangText("Text_Architecture"))
LVPackageManager.ModifyCol(5, , GetLangText("Text_PublisherDisplayName"))
LVPackageManager.ModifyCol(7, , GetLangText("Text_FamilyName"))
App.TabLangLoaded.%NavIndex%:=1
}
LoadLV()
App.CurrentTabCtrls:=CurrentTabCtrls
LoadLV(*) {
LVPackageManager:=g["PackageManager_LV"]
LVPackageManager.ModifyCol(1, 38/100*LVWidth)
LVPackageManager.ModifyCol(2, 12/100*LVWidth)
LVPackageManager.ModifyCol(3, 17/100*LVWidth)
LVPackageManager.ModifyCol(4, 10/100*LVWidth)
LVPackageManager.ModifyCol(5, 23/100*LVWidth-2)
LVPackageManager.ModifyCol(6, 0)
LVPackageManager.ModifyCol(7, 0)
ImageListID := IL_Create(20)
LVPackageManager.SetImageList(ImageListID)
LVPackageManager.Delete()
IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
Mode:=g["PackageManager_Mode"].Value
rList:=PackageManager.FindPackages(IsAllUsers?"All":App.UserSID)
PackagesList(rList)
Loop rList.Length {
If (Mode==1 && PackageManager.CheckInstallUser(rList[A_Index].FullName, App.UserSID)
&& !RegKeyExist("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\" App.UserSID "\" rList[A_Index].FullName))
|| (Mode==2 && (PackageManager.CheckInstallUser(rList[A_Index].FullName, "S-1-5-18", 1)
|| !PackageManager.CheckInstallUser(rList[A_Index].FullName, App.UserSID))) {
Try {
IconIndex := IL_Add(ImageListID, rList[A_Index].Logo, 1)
aDisplay:=DisplayArchitecture(rList[A_Index].Architecture)
sDisplay:=DisplayStatus(rList[A_Index])
LVPackageManager.Add("Icon" IconIndex, rList[A_Index].DisplayName, sDisplay, rList[A_Index].Version, aDisplay, rList[A_Index].PublisherDisplayName, A_Index, rList[A_Index].FamilyName)
} Catch Error as err {
Debug(err, "FullName :" rList[A_Index].FullName)
}
}
}
}
SwichInstalled(Ctr, *) {
If Ctr.Name="PackageManager_Mode" {
If Ctr.Value==1 {
g["PackageManager_InstalledAllUsers"].Value:=0
g["PackageManager_InstalledAllUsers"].Enabled:=1
} Else If Ctr.Value==2 {
g["PackageManager_InstalledAllUsers"].Value:=1
g["PackageManager_InstalledAllUsers"].Enabled:=0
}
}
g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (0)"
g["PackageManager_BtnUninstallChecked"].Enabled:=False
SwichAllBtn(0)
LoadLV()
}
LVPackageManager_ItemCheck(GuiCtrlObj, Item, Checked) {
Reload_BtnCountChecked()
}
LVPackageManager_Click(GuiCtrlObj, Item) {
If Item {
LVPackageManager.Modify(Item, "Select")
id := LVPackageManager.GetText(Item,6)
aList:=PackagesList()
If aList[id].Disabled {
bStatusText:=GetLangTextWithIcon("Text_Enable")
} Else {
bStatusText:=GetLangTextWithIcon("Text_Disable")
}
g["PackageManager_BtnDisable"].Text:=bStatusText
}
SwichAllBtn(!!Item)
}
LVPackageManager_DoubleClick(GuiCtrlObj, Item) {
If Item {
CreateDetailDlg(Item)
}
}
LVPackageManager_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
iSelected:=g["PackageManager_LV"].GetNext()
If iSelected {
MyMenu := Menu()
iCount:=LVCheckedCount()
MyMenu.Add(GetLangText("Text_Uninstall") " (" iCount ")", RunItem)
If !iCount
MyMenu.Disable("1&")
MyMenu.Add(GetLangText("Text_Uninstall"), RunItem)
id := LVPackageManager.GetText(iSelected,6)
aList:=PackagesList()
If aList[id].Disabled {
iStatusText:="Text_Enable"
} Else {
iStatusText:="Text_Disable"
}
g["PackageManager_BtnDisable"].Text:=GetLangTextWithIcon(iStatusText)
MyMenu.Add(GetLangText(iStatusText), RunItem)
MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
MyMenu.Add(GetLangText("Text_Details"), RunItem)
MyMenu.Add(GetLangText("Text_SelectAll"), (*)=> LVPackageManager.Modify(0, "Check") Reload_BtnCountChecked())
MyMenu.Add(GetLangText("Text_DeselectAll"), (*)=> LVPackageManager.Modify(0, "-Check") Reload_BtnCountChecked())
Mode:=g["PackageManager_Mode"].Value
If Mode=2 && App.User=A_Username {
MyMenu.Add(GetLangText("Text_Install") " (" iCount ")", RunItem)
If !iCount
MyMenu.Disable("8&")
MyMenu.Add(GetLangText("Text_Install"), RunItem)
}
MyMenu.Show
RunItem(ItemName, ItemPos, MyMenu) {
PackageManager_FnRun(ItemPos)
}
}
SwichAllBtn(!!iSelected)
}
PackageManager_FnRun(ItemPos) {
LVPackageManager:=g["PackageManager_LV"]
iSelected:=LVPackageManager.GetNext()
id := LVPackageManager.GetText(iSelected,6)
aList:=PackagesList()
If ItemPos=1 {
g2:=CreateWaitDlg(g)
IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
RowNumber := 0
t:=""
Loop {
RowNumber := LVPackageManager.GetNext(RowNumber,"c")
if not RowNumber
break
cid := LVPackageManager.GetText(RowNumber,6)
r:=UninstallPackage(aList[cid], IsAllUsers, g["PackageManager_DeprovisionPackage"].Value)
If r {
LVPackageManager.Delete(RowNumber)
RowNumber--
Reload_BtnCountChecked()
}
}
SwichAllBtn(0)
DestroyDlg()
} Else If ItemPos=2 {
g2:=CreateWaitDlg(g)
IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
r:=UninstallPackage(aList[id], IsAllUsers, g["PackageManager_DeprovisionPackage"].Value)
If r {
LVPackageManager.Delete(iSelected)
Reload_BtnCountChecked()
}
SwichAllBtn(0)
DestroyDlg()
} Else If ItemPos=3 {
iDisabled:=aList[id].Disabled
If iDisabled {
PackageManager.ClearPackageStatus(aList[id].FullName, 8)
iStatusText:="Text_Enabled"
bStatusText:="Text_Disable"
} Else {
PackageManager.SetPackageStatus(aList[id].FullName, 8)
iStatusText:="Text_Disabled"
bStatusText:="Text_Enable"
}
LVPackageManager.Modify(iSelected, , , GetLangText(iStatusText))
g["PackageManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
} Else If ItemPos=4 {
If aList[id].SignatureKind=3
runAsParam:="https://apps.microsoft.com/search?query=" aList[id].DisplayName
Else
runAsParam:="https://www.google.com/search?q=" aList[id].DisplayName
try Run(runAsParam)
} Else If ItemPos=5 {
CreateDetailDlg(iSelected)
} Else If ItemPos=8 {
g2:=CreateWaitDlg(g)
IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
RowNumber := 0
t:=""
Loop {
RowNumber := LVPackageManager.GetNext(RowNumber,"c")
if not RowNumber
break
cid := LVPackageManager.GetText(RowNumber,6)
If PackageManager.RegisterPackageByFullName(aList[cid].FullName)=1 {
LVPackageManager.Delete(RowNumber)
RowNumber--
Reload_BtnCountChecked()
}
}
SwichAllBtn(0)
DestroyDlg()
} Else If ItemPos=9 {
g2:=CreateWaitDlg(g)
If PackageManager.RegisterPackageByFullName(aList[id].FullName)=1 {
LVPackageManager.Delete(iSelected)
Reload_BtnCountChecked()
}
SwichAllBtn(0)
DestroyDlg()
}
}
Reload_BtnCountChecked() {
iCount:=LVCheckedCount()
g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (" iCount ")"
g["PackageManager_BtnUninstallChecked"].Enabled:=!!iCount
}
LVCheckedCount() {
iCount:=0
RowNumber := 0
Loop {
RowNumber := g["PackageManager_LV"].GetNext(RowNumber, "C")
if not RowNumber
break
iCount++
}
Return iCount
}
SwichAllBtn(s) {
g["PackageManager_BtnUninstall"].Enabled:=s
g["PackageManager_BtnDisable"].Enabled:=s
g["PackageManager_BtnSearchOnline"].Enabled:=s
g["PackageManager_BtnDetails"].Enabled:=s
}
CreateDetailDlg(Item) {
g2:=CreateDlg(g)
a:=g2.AddText("w500 h22 xm0 Center", "~~~~~ " GetLangText("Text_Details") " ~~~~~").SetFont("s" App.MainFontSize+2)
aShowList:=["DisplayName"
, "FamilyName"
, "FullName"
, "PublisherDisplayName"
, "InstalledDate"
, "Architecture"
, "Version"
, "SignatureKind"
, "Status"
, "InstalledPath"
, "EffectivePath"
]
id := LVPackageManager.GetText(Item,6)
aList:=PackagesList()
g2.SetFont("s" App.MainFontSize+1)
Loop aShowList.Length {
tID:=aShowList[A_Index]
a:=g2.AddText("w100 h16 xm0", GetLangText("Text_" tID))
If tID="Status"
s:=DisplayStatus(aList[id])
Else If tID="Architecture" || tID="SignatureKind"
s:=Display%tID%(aList[id].%tID%)
Else If tID="InstalledDate" {
try s:=FormatTime(aList[id].%tID%, "ShortDate")
} Else
s:=aList[id].%tID%
b:=g2.AddEdit("-vscroll -E0x200 ReadOnly w400 yp Background"  Themes.%App.ThemeSelected%.BackColor, s)
}
btn_OK:=g2.AddButton("xm200 w100", GetLangText("Text_OK"))
btn_OK.OnEvent("Click",(*)=>DestroyDlg())
SetCtrlTheme(btn_OK)
btn_OK.Focus()
ShowDlg(g, g2, 3)
}
PackagesList(iArray?) {
Static pl:=Array()
If IsSet(iArray)
pl:=iArray
Return pl
}
DisplayStatus(item) {
s:=""
If item.VerifyIsOK {
s:=GetLangText("Text_Enabled")
} Else If item.Disabled {
s:=GetLangText("Text_Disabled")
}
Return s
}
DisplayArchitecture(ArchitectureID) {
Return (ArchitectureID=9)?"x64":(ArchitectureID=11)?"Neutral":(ArchitectureID=0)?"x86":ArchitectureID
}
DisplaySignatureKind(SignatureKindID) {
Return (SignatureKindID=0)?"None":(SignatureKindID=1)?"Developer":(SignatureKindID=2)?"Enterprise":(SignatureKindID=3)?"Store":(SignatureKindID=4)?"System":SignatureKindID
}
}
CreatePackageManagerPreSaveDlg(g) {
g2:=CreateDlg(g)
tWidth:=400
g2.AddText("w" tWidth " h22 xm0 Center", "~~~~~ Pre-Save"  " ~~~~~").SetFont("s" App.MainFontSize+2)
PreSaveAct:=g2.AddDDL("w200 Choose1", ["Uninstall", "Disable", "Deprovision"])
SetCtrlTheme(PreSaveAct)
PreSaveAct.OnEvent("Change", PreSaveAct_Change)
PreSaveAct_Change(GuiCtrlObj, Info) {
CB_InstalledAllUsers.Enabled:=(GuiCtrlObj.Value==1)
CB_DeprovisionPackage.Enabled:=(GuiCtrlObj.Value!=3)
}
CB_InstalledAllUsers:=g2.AddCheckbox("w100 y+20 Checked" g["PackageManager_InstalledAllUsers"].Value, GetLangText("Text_InstalledAllUsers"))
CB_DeprovisionPackage:=g2.AddCheckbox("yp w200 Checked" g["PackageManager_DeprovisionPackage"].Value, GetLangText("Text_DeprovisionPackage"))
g2.AddText("w200 xm0 y+20", "FamilyName list:")
Edit_PreSave:=g2.AddEdit("w" tWidth " r10 -Wrap")
SetCtrlTheme(Edit_PreSave)
LVPackageManager:=g["PackageManager_LV"]
RowNumber := 0
Loop {
RowNumber := LVPackageManager.GetNext(RowNumber,"c")
if not RowNumber
break
Edit_PreSave.Value.= LVPackageManager.GetText(RowNumber,7) '`n'
}
btn_Save:=g2.AddButton("xm96 w100", GetLangText("Text_Save"))
btn_Save.OnEvent("Click",Save_Click)
SetCtrlTheme(btn_Save)
Save_Click(*) {
g2.Opt("+OwnDialogs")
SelectedFile := FileSelect("S16", App.Name "_OptimizeTabConfig_" A_Now ".json", "Save a file")
If SelectedFile {
Config:={}
ObjPackageManager:={}
ObjPackageManager.Act:=PreSaveAct.Text
If CB_InstalledAllUsers.Enabled && CB_InstalledAllUsers.Value
ObjPackageManager.AllUsers:=1
If CB_DeprovisionPackage.Enabled && CB_DeprovisionPackage.Value
ObjPackageManager.Deprovision:=1
Items:=Array()
Loop Parse, Edit_PreSave.Value, "`n" {
t:=Trim(A_LoopField)
If t
Items.Push t
}
ObjPackageManager.FamilyNames := Items
Config.PackageManager:=[ObjPackageManager]
try
FileDelete SelectedFile
FileAppend JSON.stringify(Config), SelectedFile
DestroyDlg()
}
g2.Opt("-OwnDialogs")
}
btn_Cancel:=g2.AddButton("yp w100", GetLangText("Text_Cancel"))
btn_Cancel.OnEvent("Click",(*)=>DestroyDlg())
SetCtrlTheme(btn_Cancel)
g.GetPos(&X, &Y, &W, &H)
g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
g2.Show("x" X+sXCBT+(PanelW-tWidth)/2-12 " y" Y+130)
}
CheckUpdate(g:="") {
    return
}
CheckOS
CheckAdmin
OnError LogError
OnExit ExitFunc
ArgParse
Init
ArgProcess
OnMessage 0x0111, ON_EN_SETFOCUS
CreateGui
OnMessage 0x0200, WM_MOUSEMOVE
OnMessage 0x0201, WM_LBUTTONDOWN
OnMessage 0x47, WM_WINDOWPOSCHANGED