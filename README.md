# cli-statusline

The Claude Code status line from the Windows workstation, kept here so it can be installed identically on other machines.

![statusline](docs/statusline.png)

Five pills, left to right: **model** (pink), **session cost** (amber, text turns dark red at $5+), **ctx** with a 7-cell braille gradient bar and percentage (green, dark red at 80%+), **5h** rate-limit window with the same bar (blue, dark red at 80%+), **7d** window percentage (purple). Colors are fixed 24-bit values; they do not follow the terminal theme.

## Install

Requires Python 3 (stdlib only) on PATH.

Windows (PowerShell):

```powershell
git clone https://github.com/gabz147/cli-statusline.git
cd cli-statusline
.\install.ps1
```

macOS / Linux / WSL:

```bash
git clone https://github.com/gabz147/cli-statusline.git
cd cli-statusline
./install.sh
```

Both copy `statusline.py` to `~/.claude/statusline.py` and set this in `~/.claude/settings.json` (other settings are preserved):

```json
"statusLine": { "type": "command", "command": "\"<path to python>\" \"<home>/.claude/statusline.py\"" }
```

Restart Claude Code afterwards. The terminal needs a font with braille glyphs (Nerd Fonts and most monospace fonts have them) and 24-bit color support.

## Tweaking

Everything is at the top of `statusline.py`:

- `MODEL_BG`, `COST_BG`, `CTX_BG`, `FIVE_BG`, `SEVEN_BG`: pill background RGB
- `FG` / `WARN_FG`: normal and warning text colors
- `GRAD`: the bar glyph ramp; `bar_w` in `main()` is the bar width (7)
- `LCAP` / `RCAP`: empty by default (flat pills); set to Powerline half-circles or arrows for rounded caps

## Cache file

The script writes `~/.claude/statusline-cache.json` (last model, cost, context %, 5h/7d usage with reset deadlines, `usage_schema: 2`) so the pills stay populated between Claude Code updates that omit fields. On the origin machine the Windhawk Island mod reads that file; nothing else depends on it.
