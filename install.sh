#!/usr/bin/env bash
# Installs statusline.py into ~/.claude and points Claude Code's statusLine at it (macOS / Linux / WSL).
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
claude_dir="$HOME/.claude"
mkdir -p "$claude_dir"
target="$claude_dir/statusline.py"
cp "$repo/statusline.py" "$target"
chmod +x "$target"

python="$(command -v python3 || command -v python || true)"
[ -n "$python" ] || { echo "Python 3 not found on PATH; install it, then re-run." >&2; exit 1; }

settings="$claude_dir/settings.json"
[ -s "$settings" ] || echo '{}' > "$settings"
cp "$settings" "$settings.bak-statusline"
"$python" - "$settings" "$python" "$target" <<'EOF'
import json, sys
path, python, target = sys.argv[1:4]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data["statusLine"] = {"type": "command", "command": f'"{python}" "{target}"'}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
EOF
echo "statusline.py -> $target"
echo "settings.json statusLine -> \"$python\" \"$target\""
echo "Restart Claude Code to see it."
