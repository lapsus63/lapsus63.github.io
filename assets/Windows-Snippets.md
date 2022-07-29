# Windows Snippets

### Enable Verr Num on boot

```cmd
@echo off

REM set VERR NUM ON at start
reg.exe ADD "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /f /v "InitialKeyboardIndicators" /t REG_SZ /d 2

pause
```

### ipconfig cache cleaner

```cmd
ipconfig /registerdns
ipconfig /release
ipconfig /renew
netsh winsock reset

pause
```
