#!/bin/bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"
HERMES_DATA_DIR="/data"
WORKSPACE_DIR="${HERMES_DATA_DIR}/workspace"
INTERNAL_API_KEY_FILE="${HERMES_DATA_DIR}/.ha_api_server_key"
HERMES_PYTHON="/opt/hermes/.venv/bin/python"
HERMES_WEB_INDEX="/opt/hermes/hermes_cli/web_dist/index.html"

if [ ! -f "${OPTIONS_FILE}" ]; then
  echo "Missing ${OPTIONS_FILE}"
  exit 1
fi

mkdir -p "${WORKSPACE_DIR}"
mkdir -p "${HERMES_DATA_DIR}/nginx/body" "${HERMES_DATA_DIR}/nginx/proxy" "${HERMES_DATA_DIR}/nginx/fastcgi" "${HERMES_DATA_DIR}/nginx/uwsgi" "${HERMES_DATA_DIR}/nginx/scgi"

if [ ! -f "${INTERNAL_API_KEY_FILE}" ]; then
  "${HERMES_PYTHON}" - <<'PY'
from pathlib import Path
import secrets

path = Path('/data/.ha_api_server_key')
path.write_text(secrets.token_hex(32) + '\n', encoding='utf-8')
path.chmod(0o600)
PY
fi

if [ -f "${HERMES_WEB_INDEX}" ]; then
  "${HERMES_PYTHON}" - <<'PY'
from pathlib import Path
import re

index_path = Path('/opt/hermes/hermes_cli/web_dist/index.html')
marker = 'ha-hermes-terminal-link'
html = index_path.read_text(encoding='utf-8')
script = '''<script id="ha-hermes-terminal-link">(function(){
  function ensureTerminalLink(){
    if (document.getElementById('ha-hermes-terminal-link-anchor')) return;
    var anchor = document.createElement('a');
    anchor.id = 'ha-hermes-terminal-link-anchor';
    anchor.href = 'terminal/';
    anchor.textContent = 'Open Terminal';
    anchor.style.position = 'fixed';
    anchor.style.right = '20px';
    anchor.style.bottom = '20px';
    anchor.style.zIndex = '2147483647';
    anchor.style.padding = '10px 14px';
    anchor.style.borderRadius = '999px';
    anchor.style.background = '#111827';
    anchor.style.color = '#ffffff';
    anchor.style.textDecoration = 'none';
    anchor.style.font = '600 14px/1.2 system-ui,-apple-system,sans-serif';
    anchor.style.boxShadow = '0 8px 24px rgba(0,0,0,.25)';
    document.body.appendChild(anchor);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', ensureTerminalLink, { once: true });
  } else {
    ensureTerminalLink();
  }
  window.addEventListener('load', ensureTerminalLink, { once: true });
})();</script>'''
html = re.sub(r'<a[^>]*>Open Terminal</a>', '', html)
html = re.sub(r'<script id="ha-hermes-terminal-link">.*?</script>', '', html, flags=re.S)
if marker not in html and '</body>' in html:
    html = html.replace('</body>', f'{script}</body>', 1)
    index_path.write_text(html, encoding='utf-8')
PY
fi

"${HERMES_PYTHON}" - <<'PY'
from pathlib import Path
import json
import re

import yaml

home = Path('/data')
options = json.loads((home / 'options.json').read_text(encoding='utf-8'))
config_path = home / 'config.yaml'
env_path = home / '.env'

config = {}
if config_path.exists():
    loaded = yaml.safe_load(config_path.read_text(encoding='utf-8'))
    if isinstance(loaded, dict):
        config = loaded

timezone = str(options.get('timezone') or 'UTC').strip() or 'UTC'
model_provider = str(options.get('model_provider') or 'auto').strip() or 'auto'
model_name = str(options.get('model_name') or 'google/gemini-2.5-flash').strip() or 'google/gemini-2.5-flash'
model_base_url = str(options.get('model_base_url') or '').strip()
gateway_timeout_raw = options.get('gateway_timeout')
gateway_timeout = 1800 if gateway_timeout_raw in (None, '') else int(gateway_timeout_raw)

model = config.setdefault('model', {})
model['provider'] = model_provider
model['default'] = model_name
if model_base_url:
    model['base_url'] = model_base_url
else:
    model.pop('base_url', None)

terminal = config.setdefault('terminal', {})
terminal['backend'] = 'local'
terminal['cwd'] = '/data/workspace'
terminal['timeout'] = 180
terminal['lifetime_seconds'] = 300

agent = config.setdefault('agent', {})
agent['gateway_timeout'] = gateway_timeout

display = config.setdefault('display', {})
display['compact'] = True

config_text = yaml.safe_dump(config, sort_keys=False, allow_unicode=False)
config_path.write_text(config_text, encoding='utf-8')

managed = {
    'TZ': timezone,
    'OPENROUTER_API_KEY': str(options.get('openrouter_api_key') or '').strip(),
    'GOOGLE_API_KEY': str(options.get('google_api_key') or '').strip(),
    'GEMINI_API_KEY': str(options.get('google_api_key') or '').strip(),
    'ANTHROPIC_API_KEY': str(options.get('anthropic_api_key') or '').strip(),
    'OPENAI_API_KEY': str(options.get('openai_api_key') or '').strip(),
}

begin = '# BEGIN HA-HERMES-ADDON'
end = '# END HA-HERMES-ADDON'
existing = ''
if env_path.exists():
    existing = env_path.read_text(encoding='utf-8')

pattern = re.compile(r'\n?# BEGIN HA-HERMES-ADDON\n.*?# END HA-HERMES-ADDON\n?', re.S)
existing = re.sub(pattern, '\n', existing).rstrip()

managed_lines = [begin]
for key, value in managed.items():
    if value:
        escaped = value.replace('\\', '\\\\').replace('"', '\\"')
        managed_lines.append(f'{key}="{escaped}"')
managed_lines.append(end)

parts = []
if existing:
    parts.append(existing)
parts.append('\n'.join(managed_lines))
env_path.write_text('\n\n'.join(parts).rstrip() + '\n', encoding='utf-8')
PY

TZ="$("${HERMES_PYTHON}" - <<'PY'
import json
from pathlib import Path

options = json.loads(Path('/data/options.json').read_text(encoding='utf-8'))
print((options.get('timezone') or 'UTC'))
PY
)"
export TZ
export HERMES_DASHBOARD=1
export HERMES_DASHBOARD_HOST=127.0.0.1
export HERMES_DASHBOARD_PORT=9120
export API_SERVER_ENABLED=true
export API_SERVER_HOST=127.0.0.1
export API_SERVER_KEY="$(tr -d '\r\n' < "${INTERNAL_API_KEY_FILE}")"

ENABLE_DASHBOARD_TUI="$("${HERMES_PYTHON}" - <<'PY'
import json
from pathlib import Path

options = json.loads(Path('/data/options.json').read_text(encoding='utf-8'))
print('true' if options.get('enable_dashboard_tui') else 'false')
PY
)"

ENABLE_TERMINAL="$("${HERMES_PYTHON}" - <<'PY'
import json
from pathlib import Path

options = json.loads(Path('/data/options.json').read_text(encoding='utf-8'))
print('true' if options.get('enable_terminal', True) else 'false')
PY
)"

if [ "${ENABLE_DASHBOARD_TUI}" = "true" ]; then
  export HERMES_DASHBOARD_TUI=1
fi

export ENABLE_TERMINAL

exec /opt/hermes/docker/entrypoint.sh /addon-run.sh
