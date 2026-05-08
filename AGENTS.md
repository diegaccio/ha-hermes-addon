# AGENTS.md

## Repo shape
- This repo is a Home Assistant add-on repository, not the Hermes source repo.
- Root metadata is `repository.yaml`.
- The only add-on currently present is `hermes_agent/`.

## Add-on entrypoints
- Add-on metadata lives in `hermes_agent/config.yaml`.
- Image build is `hermes_agent/Dockerfile`.
- Root startup wrapper is `hermes_agent/run.sh`; non-root runtime handoff is `hermes_agent/addon-run.sh`.
- User-facing add-on docs are `hermes_agent/DOCS.md`; keep them aligned with `config.yaml` and `run.sh`.

## Runtime assumptions that matter
- The add-on wraps the official upstream image `nousresearch/hermes-agent:v2026.5.7`; do not silently switch to `latest`.
- Supported Home Assistant architectures are only `amd64` and `aarch64`.
- `HERMES_HOME` is set to `/data`, so Hermes state is intentionally stored in the add-on private persistent directory, not `/opt/data`.
- `run.sh` runs as the container entrypoint specifically so it can read Home Assistant's root-owned `/data/options.json` before the upstream Hermes entrypoint drops privileges.
- `run.sh` generates/updates `/data/config.yaml` and a managed block inside `/data/.env` from `/data/options.json` on every startup.
- `run.sh` must hand off to `/opt/hermes/docker/entrypoint.sh /addon-run.sh`; `addon-run.sh` then runs as the non-root `hermes` user after upstream bootstrap and dashboard startup.
- The dashboard is always enabled for Home Assistant ingress, but Hermes itself listens on `127.0.0.1:9120`; nginx owns ingress port `9119` and forwards `X-Ingress-Path` as `X-Forwarded-Prefix`.
- The internal Hermes API server is intentionally enabled on `127.0.0.1` only so the dashboard can talk to the gateway without exposing the API externally.

## Editing rules for this repo
- When changing add-on options, update all three together: `hermes_agent/config.yaml`, `hermes_agent/run.sh`, and `hermes_agent/translations/en.yaml`.
- If an option is documented, also update `hermes_agent/DOCS.md`.
- Preserve the managed `.env` block markers in `run.sh`:
  - `# BEGIN HA-HERMES-ADDON`
  - `# END HA-HERMES-ADDON`
- `gateway_timeout: 0` is a meaningful value and must not be collapsed back to the default.

## Verification
- Shell syntax check:
  - `bash -n hermes_agent/run.sh`
- Build the wrapper image from the add-on directory:
  - `docker build --platform linux/amd64 -t ha-hermes-addon-test:local .`
  - run from `hermes_agent/`
- There is no verified CI workflow in this repo yet; do not assume lint/test automation exists.

## Current known gaps
- `icon.png` and `logo.png` are still missing from `hermes_agent/`; add them if you need a complete Home Assistant add-on package.
- Real ingress behavior still needs validation in a live Home Assistant environment; if dashboard ingress fails, the likely follow-up is a small proxy layer rather than a redesign of the add-on structure.
- Terminal access is provided through `ttyd` on internal port `7681`, proxied at the ingress subpath `/terminal/` when `enable_terminal` is true.
