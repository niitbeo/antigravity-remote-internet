# Antigravity Remote Extension

Extension điều khiển Antigravity/VS Code từ xa qua web dashboard (điện thoại hoặc máy khác).

Tác giả: Nguyễn Lê Trường

## Tính năng

- Chạy relay server ngay trong extension host (`HTTP + WebSocket`)
- Dashboard web để điều khiển từ xa:
  - Gửi prompt
  - Chuyển session
  - Dừng phiên đang chạy
  - Bật/tắt auto-accept step và terminal
- Stream realtime: tin nhắn, file thay đổi, activity log
- Pairing bằng URL có token + QR
- Chế độ Internet chuẩn: **Tailscale Funnel (HTTPS ổn định)**

## Lệnh

- `Antigravity Remote: Start Relay`
- `Antigravity Remote: Stop Relay`
- `Antigravity Remote: Show Connect Info`
- `Antigravity Remote: Show Pairing QR`
- `Antigravity Remote: Reset Pairing Token`

## Cấu hình

- `antigravityRemote.host` (mặc định: `0.0.0.0`)
- `antigravityRemote.port` (mặc định: `4317`)
- `antigravityRemote.autoStart` (mặc định: `true`)
- `antigravityRemote.publicBaseUrl` (URL HTTPS public từ Tailscale Funnel)

## Cài nhanh Internet (Tailscale-only)

### Cách 1: 1-click bằng file BAT

Chạy file:

`scripts\\auto-tailscale.bat`

File này sẽ:
1. Cài Tailscale (nếu chưa có)
2. Đăng nhập Tailscale (nếu chưa login)
3. Bật Funnel port `4317`
4. Tự ghi `antigravityRemote.publicBaseUrl` vào settings của:
   - Antigravity
   - Cursor
   - VS Code

### Cách 2: chạy lệnh npm

```powershell
npm.cmd run internet:auto
```

Hoặc chạy script trực tiếp:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\auto-tailscale.ps1
```

## Bật relay sau khi setup

Trong Antigravity:
1. `Antigravity Remote: Stop Relay`
2. `Antigravity Remote: Start Relay`
3. `Show Pairing QR` hoặc `Show Connect Info`

Kết quả đúng: link phải là `https://<host>.<tailnet>.ts.net/?token=...`

## Build / Đóng gói

```powershell
npm install
npm run build
npm run package
```

VSIX hiện tại:

- `antigravity-remote-mvp-0.0.44.vsix`

## Cài VSIX

1. Mở Extensions
2. `...` -> `Install from VSIX...`
3. Chọn file `.vsix`
4. Reload window

## Ghi chú model

Model được áp dụng qua LS API theo lựa chọn trên dashboard.
Một số bản IDE có thể chưa đổi badge model tức thì dù model thực thi đã đổi đúng.

## Bảo mật

- Không chia sẻ công khai link token đầy đủ
- Dùng ACL trong Tailscale admin để giới hạn truy cập
- Có thể reset token bằng `Reset Pairing Token`

## Lỗi thường gặp

### QR vẫn ra LAN

- Kiểm tra `antigravityRemote.publicBaseUrl` trong profile settings đang dùng
- Đổi settings xong phải restart relay
- Đóng panel QR cũ rồi mở lại

### F5 xong config bị reset

Bản mới đã lưu model/planner/auto-accept trong localStorage và tự sync lại khi reconnect.
