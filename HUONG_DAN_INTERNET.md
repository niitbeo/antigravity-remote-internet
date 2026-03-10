# Hướng dẫn Internet (Tailscale-only)

Mục tiêu: máy host chạy Antigravity + extension, thiết bị khác mạng vẫn điều khiển được qua HTTPS.

## Cài đặt nhanh

Chạy:

```powershell
npm.cmd run internet:auto
```

hoặc double-click:

`scripts\\auto-tailscale.bat`

## Script làm gì?

- Cài Tailscale nếu chưa có
- Yêu cầu login Tailscale nếu cần
- Bật Funnel port `4317`
- Tự set `antigravityRemote.publicBaseUrl` vào settings

## Sau khi script chạy xong

Trong Antigravity:

1. `Stop Relay`
2. `Start Relay`
3. `Show Pairing QR`

QR đúng sẽ ra domain:

`https://<host>.<tailnet>.ts.net/?token=...`
