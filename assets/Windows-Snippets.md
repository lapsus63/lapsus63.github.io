# Windows Snippets

### Enable Verr Num on boot

```cmd
@echo off

REM set VERR NUM ON at start
reg.exe ADD "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /f /v "InitialKeyboardIndicators" /t REG_SZ /d 2

pause
```

### Use  clipboard

```cmd
REM Paste clipboard content :
powershell -command "Get-Clipboard"
REM store result to clipboard 
command | clip
```

### ipconfig cache cleaner

```cmd
ipconfig /registerdns
ipconfig /release
ipconfig /renew
netsh winsock reset

pause
```

### Enable RAM compression

```cmd
REM Enable RAM compression (Windows 10+), with PowerShell
Get-MMAgent
Enable-MMAgent MemoryCompression
```
