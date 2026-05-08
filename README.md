# Hermes Agent Home Assistant Add-on

Home Assistant add-on repository for running Hermes Agent inside Home Assistant.

GitHub repository:
- `https://github.com/diegaccio/ha-hermes-addon`

Current add-on:
- `hermes_agent`: minimal ingress-first wrapper around the official `nousresearch/hermes-agent:v2026.5.7` image

Status:
- scaffolded for local/Home Assistant builds
- pinned to Hermes `v2026.5.7`
- targets `amd64` and `aarch64`

## Install in Home Assistant

1. Open Home Assistant.
2. Go to `Settings -> Add-ons -> Add-on Store`.
3. Open the three-dot menu and choose `Repositories`.
4. Add this repository URL:
   - `https://github.com/diegaccio/ha-hermes-addon`
5. Refresh the Add-on Store if needed.
6. Open the `Hermes Agent` add-on.
7. Click `Install`.

## First start

1. Open the add-on `Configuration` tab.
2. Set at least:
   - `model_provider`
   - `model_name`
   - the matching API key field for your provider
3. Click `Save`.
4. Start the add-on.
5. Open `Show in sidebar` or the add-on page to access the Hermes dashboard through Home Assistant ingress.

## Notes

- Supported architectures: `amd64`, `aarch64`
- Hermes state is stored in the add-on private `/data` directory
- The dashboard is exposed through Home Assistant ingress on port `9119`
- The internal Hermes API stays bound to loopback inside the container

## Add-on docs

Detailed add-on options are documented in:
- `hermes_agent/DOCS.md`
