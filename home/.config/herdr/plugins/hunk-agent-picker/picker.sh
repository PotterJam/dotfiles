#!/bin/sh
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
workspace=${HUNK_PICKER_WORKSPACE:-${HERDR_WORKSPACE_ID:-}}
if [ -z "$workspace" ]; then
  workspace=$("$herdr" api snapshot | jq -r '.result.snapshot.focused_workspace_id // empty')
fi
[ -n "$workspace" ] || exit 1

target=$("$herdr" agent list | jq -r --arg workspace "$workspace" '
  .result.agents[]
  | select(.workspace_id == $workspace)
  | [.pane_id, .agent, .agent_status, .terminal_title_stripped, .foreground_cwd]
  | @tsv
' | fzf --prompt='send Hunk comments to> ' \
  --header='agent   status   title   directory' --delimiter='\t' --with-nth=2.. |
  cut -f1)

[ -n "$target" ] || exit 0
exec "$herdr" agent prompt "$target" \
  "Use the hunk-review skill. Address my comments please"
