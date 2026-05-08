# Changelog

## 2026.5.7-2

- Fix Home Assistant ingress blank page by adding an internal nginx proxy
- Translate Home Assistant `X-Ingress-Path` to Hermes dashboard `X-Forwarded-Prefix`
- Keep Hermes dashboard on loopback and expose ingress on port `9119`

## 2026.5.7-1

- Initial Home Assistant add-on scaffold
- Wraps `nousresearch/hermes-agent:v2026.5.7`
- Uses Home Assistant add-on `/data` as Hermes home
- Exposes Hermes dashboard through Home Assistant ingress
