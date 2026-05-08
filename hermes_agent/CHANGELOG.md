# Changelog

## 2026.5.7-12

- Fix the `/dashboard/` ingress route by stripping the dashboard prefix before proxying to Hermes

## 2026.5.7-11

- Keep the custom ingress launcher page as the add-on root and move the full Hermes dashboard to `/dashboard/`

## 2026.5.7-10

- Replace the root ingress view with a custom launcher page containing an embedded terminal and a button to open the full Hermes dashboard

## 2026.5.7-9

- Render the dashboard `Open Terminal` button via startup-injected JavaScript so it appears reliably with the SPA

## 2026.5.7-8

- Add the `Open Terminal` button by patching the upstream dashboard HTML at startup

## 2026.5.7-7

- Add an `Open Terminal` button to the dashboard when the terminal route is enabled

## 2026.5.7-6

- Redirect `/terminal` to `/terminal/` so Home Assistant ingress reaches the web terminal reliably

## 2026.5.7-5

- Add optional browser terminal access through ingress at `/terminal/`

## 2026.5.7-4

- Fix Home Assistant ingress `Invalid Host header` errors by forcing a loopback Host header through the internal nginx proxy

## 2026.5.7-3

- Fix Home Assistant startup by reading root-owned `/data/options.json` before Hermes drops privileges
- Split startup into a root wrapper (`run.sh`) and non-root runtime handoff (`addon-run.sh`)

## 2026.5.7-2

- Fix Home Assistant ingress blank page by adding an internal nginx proxy
- Translate Home Assistant `X-Ingress-Path` to Hermes dashboard `X-Forwarded-Prefix`
- Keep Hermes dashboard on loopback and expose ingress on port `9119`

## 2026.5.7-1

- Initial Home Assistant add-on scaffold
- Wraps `nousresearch/hermes-agent:v2026.5.7`
- Uses Home Assistant add-on `/data` as Hermes home
- Exposes Hermes dashboard through Home Assistant ingress
