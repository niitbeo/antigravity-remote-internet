# Antigravity Remote Extension

Remote dashboard for Antigravity/VS Code so you can send prompts and control approvals from phone or another device.

Author: Nguyen Le Truong

## What it does

- Runs local relay server inside extension host (`HTTP + WebSocket`)
- Web dashboard for remote control:
  - Send prompt
  - Switch session
  - Stop current run
  - Toggle auto-accept step/terminal
- Realtime stream (messages, changed files, activity)
- Pairing by tokenized URL + QR
- Supports both:
  - LAN mode
  - Internet mode via HTTPS public URL (Tailscale Funnel / Cloudflare Tunnel)

## Commands

- `Antigravity Remote: Start Relay`
- `Antigravity Remote: Stop Relay`
- `Antigravity Remote: Show Connect Info`
- `Antigravity Remote: Show Pairing QR`
- `Antigravity Remote: Reset Pairing Token`

## Settings

- `antigravityRemote.host` (default: `0.0.0.0`)
- `antigravityRemote.port` (default: `4317`)
- `antigravityRemote.autoStart` (default: `true`)
- `antigravityRemote.publicBaseUrl` (default: empty)

## Quick Start (LAN)

1. Install VSIX
2. Run command: `Antigravity Remote: Start Relay`
3. Run: `Show Pairing QR` or `Show Connect Info`
4. Open URL on phone in same Wi-Fi

## Internet Mode (HTTPS)

Use this when device and host are in different networks.

### Recommended: Tailscale Funnel (stable URL)

1. Install Tailscale and login
2. Run:

```powershell
"C:\Program Files\Tailscale\tailscale.exe" funnel --bg 4317
"C:\Program Files\Tailscale\tailscale.exe" serve status --json
```

3. Copy HTTPS domain from output, for example:

`https://desktop-acj3j98.taildbe444.ts.net`

4. Set:

```json
"antigravityRemote.publicBaseUrl": "https://desktop-acj3j98.taildbe444.ts.net"
```

5. Restart relay:
- `Stop Relay`
- `Start Relay`

6. Run `Show Pairing QR` or `Show Connect Info` and use the HTTPS link with token.

### Alternative: Cloudflare Tunnel (quick but URL may rotate)

1. Install `cloudflared`
2. Run helper script:

```powershell
npm.cmd run internet:auto
```

This script will:
- start tunnel
- detect `https://...trycloudflare.com`
- update `antigravityRemote.publicBaseUrl`

Then restart relay.

## Build / Package

```powershell
npm install
npm run build
npm run package
```

Latest packaged file in this repo workflow:

- `antigravity-remote-mvp-0.0.43.vsix`

## Install VSIX

In Antigravity/VS Code:

1. Open Extensions panel
2. `...` menu -> `Install from VSIX...`
3. Choose `antigravity-remote-mvp-0.0.43.vsix`
4. Reload window

## Notes about model display

When selecting model from remote web config, execution model is applied through LS API.
On some Antigravity builds, the small model label in IDE panel may not update immediately even though execution model is already changed.

## Security

- Never share full token URL publicly
- Use ACL/Access policy on your tunnel layer
- Reset token any time with `Reset Pairing Token`

## Troubleshooting

### QR still shows LAN URL

- Ensure `antigravityRemote.publicBaseUrl` is set in the correct app settings profile (Antigravity/Cursor/Code)
- Restart relay after changing settings
- Re-open QR panel (old panel keeps old URL)

### Cloudflare error 1033 / 530

- Tunnel expired or disconnected
- Re-run `npm.cmd run internet:auto`
- Prefer Tailscale Funnel for stable production URL

### Remote config resets after F5

Current builds persist remote preferences (model/planner/auto-accept) in browser localStorage and sync them back to server after reconnect.
