# Hermes Agent Add-on

![Hermes Agent Home Assistant Add-on](logo.png)

Run Hermes Agent inside Home Assistant with a native add-on wrapper around the official upstream image.

Highlights:
- Home Assistant ingress for the Hermes dashboard
- browser terminal access through the `Open Terminal` button or `/terminal/`
- persistent Hermes state stored in the add-on private `/data` directory
- support for `amd64` and `aarch64`
- pinned to `nousresearch/hermes-agent:v2026.5.7`
