#!/usr/bin/env bash
set -euo pipefail

if ! command -v hunk &>/dev/null; then
    npm install -g --prefix "$HOME/.local" hunkdiff >/dev/null 2>&1
fi

HUNK_GW_IP="$(getent hosts host.docker.internal 2>/dev/null | awk 'NR == 1 { print $1 }' || true)"
if [ -n "$HUNK_GW_IP" ]; then
    if ! sudo iptables -C OUTPUT -p tcp --dport 47657 -d "$HUNK_GW_IP" -j ACCEPT 2>/dev/null; then
        sudo iptables -I OUTPUT 1 -p tcp --dport 47657 -d "$HUNK_GW_IP" -j ACCEPT
    fi
else
    if ! sudo iptables -C OUTPUT -p tcp --dport 47657 -j ACCEPT 2>/dev/null; then
        sudo iptables -I OUTPUT 1 -p tcp --dport 47657 -j ACCEPT
    fi
fi

touch "$CLAUDE_ENV_FILE"
grep -qxF 'export HUNK_MCP_HOST=host.docker.internal' "$CLAUDE_ENV_FILE" 2>/dev/null ||
    echo 'export HUNK_MCP_HOST=host.docker.internal' >> "$CLAUDE_ENV_FILE"
grep -qxF 'export HUNK_MCP_UNSAFE_ALLOW_REMOTE=1' "$CLAUDE_ENV_FILE" 2>/dev/null ||
    echo 'export HUNK_MCP_UNSAFE_ALLOW_REMOTE=1' >> "$CLAUDE_ENV_FILE"
