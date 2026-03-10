# Tự động setup Internet bằng Tailscale

## Chạy bằng BAT (dễ nhất)

Mở file:

`scripts\\auto-tailscale.bat`

## Chạy bằng PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auto-tailscale.ps1
```

## Tham số

- Đổi port relay:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auto-tailscale.ps1 -Port 5555
```

- Chỉ cập nhật 1 file settings cụ thể:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auto-tailscale.ps1 -SettingsPath "$env:APPDATA\Antigravity\User\settings.json"
```

- Không tự cài Tailscale:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auto-tailscale.ps1 -SkipInstall
```
