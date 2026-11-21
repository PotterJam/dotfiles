#!/bin/sh
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
message="Use the hunk-review skill. Address my comments please"
workspace=${HERDR_ACTIVE_WORKSPACE_ID:?HERDR_ACTIVE_WORKSPACE_ID is required}
agent_list=$("$herdr" agent list)
agent_count=$(printf '%s\n' "$agent_list" | jq -r --arg workspace "$workspace" \
  '[.result.agents[] | select(.workspace_id == $workspace)] | length')

case "$agent_count" in
  0) exit 1 ;;
  1)
    target=$(printf '%s\n' "$agent_list" | jq -r --arg workspace "$workspace" \
      '.result.agents[] | select(.workspace_id == $workspace) | .pane_id')
    exec "$herdr" agent prompt "$target" "$message"
    ;;
  *)
    exec "$herdr" plugin pane open --plugin local.hunk-agent-picker \
      --entrypoint picker --env "HUNK_PICKER_WORKSPACE=$workspace" --focus
    ;;
esac
