# Antigravity Remote Extension

Tiện ích điều khiển Antigravity từ xa qua mạng LAN.

Tác giả: Nguyễn Lê Trường

## Tính năng

- Chạy relay server nội bộ (`HTTP + WebSocket`) trong extension host
- Dashboard web tren mobile de:
  - Gửi prompt
  - Accept/reject agent step
  - Accept/reject terminal command
  - Chuyển session đang hoạt động
- Giám sát session realtime qua `antigravity-sdk`
- Pair bằng URL token + lệnh hiển thị QR
- Chỉ báo trạng thái trên status bar (`AG Remote: on/off/error`)
- Giữ nguyên chế độ LAN và hỗ trợ chế độ Internet qua URL public HTTPS

## Lệnh

- `Antigravity Remote: Start Relay`
- `Antigravity Remote: Stop Relay`
- `Antigravity Remote: Show Connect Info`
- `Antigravity Remote: Show Pairing QR`
- `Antigravity Remote: Reset Pairing Token`

## Cài đặt

- `antigravityRemote.host` (mặc định `0.0.0.0`)
- `antigravityRemote.port` (mặc định `4317`)
- `antigravityRemote.autoStart` (mặc định `true`)
- `antigravityRemote.publicBaseUrl` (mặc định rỗng, dùng cho Internet mode)

## Chế độ Internet (giữ sườn LAN)

1. Chạy relay bình thường trên máy chính.
2. Dùng Tailscale Funnel hoặc Cloudflare Tunnel để có URL HTTPS public.
3. Điền URL đó vào `antigravityRemote.publicBaseUrl`.
4. Chạy `Antigravity Remote: Start Relay`.
5. Mở `Show Connect Info` để copy link Internet đã gắn token.

Lưu ý:
- LAN vẫn hoạt động song song như cũ.
- Nên bật lớp bảo mật ngoài (Tailscale ACL / Cloudflare Access).

## Phát triển

```bash
npm install
npm run build
```

Chạy extension trong Extension Development Host:

1. Mở thư mục này bằng Antigravity/VS Code
2. Nhấn `F5` (dùng `.vscode/launch.json`)
3. Trong host window, chạy `Antigravity Remote: Start Relay`
4. Chạy `Antigravity Remote: Show Pairing QR` hoặc `Show Connect Info`

## Đóng gói VSIX

```bash
npm run package
```

Sau đó cài file `.vsix` được tạo vào Antigravity/VS Code.

## Tải VSIX

- Bản mới nhất: `antigravity-remote-mvp-0.0.36.vsix`
- Link tải trực tiếp:
  `https://github.com/niitbeo/antigravity-remote-internet/raw/main/antigravity-remote-mvp-0.0.36.vsix`

## Bảo mật

- Relay định hướng LAN và được gate bằng token
- Có thể reset token bất kỳ lúc nào bằng lệnh `Reset Pairing Token`
- Chỉ dùng trong mạng Wi-Fi tin cậy

## Giới hạn hiện tại

- Chưa có push notification
- Chưa có queued approval inbox UI
- Chưa có audit history lưu lâu dài
