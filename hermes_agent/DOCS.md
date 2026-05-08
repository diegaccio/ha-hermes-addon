# Hermes Agent

## What this add-on does

This add-on runs [Hermes Agent](https://github.com/NousResearch/hermes-agent) inside Home Assistant using the official upstream Docker image.

The ingress entry page provides:
- a custom landing page
- an embedded terminal in the lower section
- a button that opens the full Hermes dashboard
- Hermes state is stored in the add-on private `/data` directory
- the Hermes gateway API stays internal to the container
- nginx terminates the internal ingress connection on `9119` and forwards to the Hermes dashboard on `127.0.0.1:9120`
- the root startup wrapper reads Home Assistant's `/data/options.json` before Hermes drops to the non-root `hermes` user

## Storage layout

Hermes uses the add-on private persistent directory:
- `/data/config.yaml`
- `/data/.env`
- `/data/SOUL.md`
- `/data/sessions/`
- `/data/memories/`
- `/data/skills/`
- `/data/logs/`
- `/data/workspace/`

## Configuration

### `timezone`

Timezone for the container environment.

### `model_provider`

Hermes provider value written to `config.yaml`.

Supported values in this first release:
- `auto`
- `openrouter`
- `anthropic`
- `gemini`
- `custom`

### `model_name`

Default Hermes model written to `config.yaml`.

Examples:
- `google/gemini-2.5-flash`
- `anthropic/claude-sonnet-4.6`
- `openai/gpt-5.4`

### `model_base_url`

Optional custom OpenAI-compatible base URL.

Use this when `model_provider` is `custom`, for example:
- `http://host.docker.internal:11434/v1`
- `http://host.docker.internal:1234/v1`

### API keys

The add-on currently supports these secret fields:
- `openrouter_api_key`
- `google_api_key`
- `anthropic_api_key`
- `openai_api_key`

They are written into the managed section of `/data/.env` on startup.

### `enable_dashboard_tui`

Enable Hermes' in-browser chat tab inside the dashboard.

Default: `false`

### `enable_terminal`

Enable a browser terminal for the add-on shell.

Default: `true`

When enabled, the terminal is available behind Home Assistant ingress at:
- `<addon ingress url>/terminal/`

The shell runs as the non-root `hermes` user inside the add-on container.

### `gateway_timeout`

Sets `agent.gateway_timeout` in Hermes `config.yaml`.

Set `0` to disable idle timeout.

## Notes

- This add-on pins Hermes to `v2026.5.7`.
- Supported Home Assistant architectures are `amd64` and `aarch64`.
- The ingress root page is a custom launcher with an embedded terminal.
- The full Hermes dashboard is exposed under `/dashboard/` behind ingress.
- A small internal nginx proxy translates Home Assistant's `X-Ingress-Path` header to the `X-Forwarded-Prefix` header expected by the Hermes dashboard SPA.
- The internal Hermes API server is enabled on loopback so the dashboard can talk to the gateway.

## Custom endpoint examples

### Ollama on the Home Assistant host

- `model_provider`: `custom`
- `model_name`: `llama3.1`
- `model_base_url`: `http://host.docker.internal:11434/v1`
- `openai_api_key`: `none`

### LM Studio on another machine

- `model_provider`: `custom`
- `model_name`: `qwen2.5-coder`
- `model_base_url`: `http://192.168.1.20:1234/v1`
- `openai_api_key`: `none`
