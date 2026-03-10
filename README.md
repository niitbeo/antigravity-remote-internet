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
- Hỗ trợ 2 chế độ:
  - LAN (cùng mạng)
  - Internet qua HTTPS public (Tailscale Funnel / Cloudflare Tunnel)

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
- `antigravityRemote.publicBaseUrl` (mặc định rỗng)

## Khởi động nhanh (LAN)

1. Cài VSIX
2. Chạy lệnh `Antigravity Remote: Start Relay`
3. Chạy `Show Pairing QR` hoặc `Show Connect Info`
4. Mở link trên điện thoại cùng Wi-Fi

## Chế độ Internet (HTTPS)

Dùng khi thiết bị điều khiển và máy host ở 2 mạng khác nhau.

### Khuyến nghị: Tailscale Funnel (URL ổn định)

1. Cài Tailscale và đăng nhập
2. Chạy:

```powershell
"C:\Program Files\Tailscale\tailscale.exe" funnel --bg 4317
"C:\Program Files\Tailscale\tailscale.exe" serve status --json
```

3. Lấy domain HTTPS trong output, ví dụ:

`https://desktop-acj3j98.taildbe444.ts.net`

4. Set vào settings:

```json
"antigravityRemote.publicBaseUrl": "https://desktop-acj3j98.taildbe444.ts.net"
```

5. Restart relay:
- `Stop Relay`
- `Start Relay`

6. Chạy `Show Pairing QR` hoặc `Show Connect Info`, dùng link HTTPS có token.

### Phương án khác: Cloudflare Tunnel (nhanh nhưng URL dễ đổi)

1. Cài `cloudflared`
2. Chạy script helper:

```powershell
npm.cmd run internet:auto
```

Script sẽ:
- mở tunnel
- lấy `https://...trycloudflare.com`
- tự cập nhật `antigravityRemote.publicBaseUrl`

Sau đó restart relay.

## Build / Đóng gói

```powershell
npm install
npm run build
npm run package
```

Phiên bản VSIX mới nhất hiện tại:

- `antigravity-remote-mvp-0.0.43.vsix`

## Cài VSIX

Trong Antigravity/VS Code:

1. Mở Extensions
2. `...` -> `Install from VSIX...`
3. Chọn `antigravity-remote-mvp-0.0.43.vsix`
4. Reload window

## Ghi chú về model

Khi chọn model trong dashboard, extension gửi model đó qua LS API để thực thi.
Trên một số bản Antigravity, badge model nhỏ trong IDE có thể chưa đổi ngay dù model thực thi đã đổi đúng.

## Bảo mật

- Không chia sẻ công khai link token đầy đủ
- Bật lớp bảo vệ ở tầng tunnel (ACL/Access)
- Có thể reset token bất kỳ lúc nào bằng `Reset Pairing Token`

## Xử lý lỗi thường gặp

### QR vẫn ra link LAN

- Kiểm tra `antigravityRemote.publicBaseUrl` đã set đúng profile settings đang dùng (Antigravity/Cursor/Code)
- Đổi settings xong phải restart relay
- Đóng QR panel cũ rồi mở lại (panel cũ giữ URL cũ)

### Cloudflare lỗi 1033 / 530

- Tunnel hết hạn hoặc rớt
- Chạy lại `npm.cmd run internet:auto`
- Nên dùng Tailscale Funnel cho URL ổn định lâu dài

### F5 xong config bị reset

Các bản mới đã lưu model/planner/auto-accept trong localStorage và tự sync lại sau khi reconnect.
