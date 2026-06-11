# WinTune 去壳版 (noVMP)

去除了 VMProtect 壳和卡密验证的 WinTune (深度优化) v2.7.5。

## 功能

Windows 系统优化工具，支持：
- **系统优化** - 禁用游戏栏、后台应用、自动碎片整理等
- **隐私保护** - 禁用诊断跟踪、广告、遥测等
- **资源管理器** - 显示隐藏文件、扩展名、此电脑等
- **开始菜单** - 隐藏推荐、最近添加等
- **可选功能** - 深色模式、经典右键菜单、禁用休眠等
- **包管理** - 卸载/禁用 UWP 应用

## 文件说明

| 文件 | 说明 |
|------|------|
| `noVMP.zip` | 去壳版可执行文件（解压后直接运行） |
| `shenDu_clean.ahk` | 清洗后的 AHK v2 源码 |
| `patch_direct.ps1` | 补丁脚本（用于原始 `深度优化.exe`） |
| `config.ini` | 配置文件（UTF-16LE） |

## 使用方法

1. 下载 `noVMP.zip` 并解压
2. 右键以管理员身份运行 `noVMP.exe`
3. 首次运行会弹出 AHK 警告框，点击 **Continue** 即可
4. 程序会请求管理员权限，点击"是"
5. 进入主界面后可自由使用各项优化功能

> ⚠️ **注意**：首次运行必须以管理员身份运行，否则程序会自动退出。

## 构建说明

### 从源码编译

需要安装 [AutoHotkey v2](https://www.autohotkey.com/)：

```bash
# 编译为 exe
"AHK安装目录\Compiler\Ahk2Exe.exe" /in "shenDu_clean.ahk" /out "noVMP.exe"
```

### 从原始文件修补

如果你有原始的 `深度优化.exe`（带 VMProtect 壳），可以使用补丁脚本：

```powershell
# 在 PowerShell 中运行（需要管理员权限）
.\patch_direct.ps1
```

## 技术细节

- **原始保护**：VMProtect 壳 + 自定义卡密验证
- **去除方法**：
  1. 提取并清洗 AHK v2 源码（去除混淆和壳层保护）
  2. 修补 `CheckAdmin()` 函数（移除 UAC 强制重启）
  3. 修补 `CheckUpdate()` 函数（移除自动更新检查）
  4. 重新编译为无壳可执行文件

- **源码来源**：从 `深度优化.exe` 反编译提取，经 AI 辅助清洗和修补
- **AHK 版本**：AutoHotkey v2.0

## 致谢

- [WinTune](https://github.com/tranht17/WinTune) - 原始开源项目
- AutoHotkey - 脚本语言和编译器

## 免责声明

本项目仅供学习和研究目的。请支持原作者，如需正式使用请购买正版授权。