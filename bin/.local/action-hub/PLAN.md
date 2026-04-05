# Action hub

An action catalog and launcher. The core idea is **actions, not hotkeys**: each entry has a title, group, and an executable command. Hotkeys are optional metadata — harvested from i3/kitty configs when annotated — not the primary concept. Rofi is the UI; selecting an entry runs its stored command.

## Layout

```
bin/.local/action-hub/      # Bun/TypeScript: parsers, types, merge logic, emit JSON
bin/.local/scripts/         # Bash only:
  action-refresh-catalog    #   thin wrapper that calls `bun run parse-actions`
  action-selector           #   reads pre-built JSON, feeds rofi, executes chosen action
```

i3 binds `$mod+?` to `action-selector`. That script never touches Bun — it must stay fast.

## Config annotation format

A single-line `@action` comment immediately above the binding. Bindings without it are ignored entirely.

```
# @action group:i3/navigation title:Focus window left
bindsym $mod+h focus left

# @action group:screenshots title:Screenshot selection to clipboard
bindsym Print exec --no-startup-id maim --select | xclip …
```

Fields:
- `group` — slash-separated path used as a display prefix (`i3/navigation`, `volume`, `screenshots`, etc.)
- `title` — human label shown in Rofi
- No hand-written ids; the parser assigns a numeric id at extraction time

## Drivers

- **i3** — reads `~/.config/i3/config`, follows `include` directives recursively, resolves `set $var` substitutions, extracts annotated `bindsym`/`bindcode` lines.
- **Kitty** — reads `kitty.conf`, extracts annotated `map` lines. Kitty bindings run inside the terminal; the `exec` field may need a `kitty @` remote-control command for actions triggered from outside.
- **Plain JSON** — globs `~/.config/action-hub/actions.d/*.json` for custom actions with no binding (e.g. scripts, one-off commands). Same schema, no `keys` field required.

## Pipeline

```
config files + JSON fragments
    → drivers (per source type)
    → merge (by source priority, later JSON overrides earlier)
    → validate (exec must be non-empty)
    → emit: actions.json  (full data)  +  rofi-lines.txt  (preformatted display)
```

The preformatted file contains tab-separated `display\tid` pairs so `action-selector` does zero formatting at runtime — just pipes the file to rofi and resolves the chosen id in `actions.json`.

## Commands

- **`bun run parse-actions`** — full pipeline: parse all sources, write `actions.json` and `rofi-lines.txt` to a known location (e.g. `~/.cache/action-hub/`).
- **`action-refresh-catalog`** — bash wrapper around the above; call manually or hook into i3 reload.
- **`action-selector`** — bash: regenerate cache if missing, pipe `rofi-lines.txt` into rofi, look up chosen id in `actions.json`, run `exec` via `sh -c`.

## TypeScript shape (rough)

```ts
type Action = {
  id: number;
  title: string;
  group: string;           // e.g. "i3/navigation"
  exec: string;
  keys?: string[];         // resolved key chord(s), display only
  source: "i3" | "kitty" | "json";
};

interface Driver {
  name: string;
  extract(paths: string[]): Action[];
}
```

## Notes

- **Grouping in Rofi** is purely visual: display strings are prefixed with the group path (`i3/navigation › Focus left`). No collapsible sections — Rofi is a flat searchable list, which is fine.
- Kitty `exec` semantics from outside the terminal need to be settled per action; default can be `kitty @ send-text` or `kitty @ launch`, documented in the annotation.
- Keep the TypeScript focused: `types.ts`, `merge.ts`, `cli.ts`, `drivers/i3.ts`, `drivers/kitty.ts`, `drivers/plain-json.ts`.
