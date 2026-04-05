import { existsSync, readFileSync } from "fs";
import { homedir } from "os";
import type { Action, Driver } from "../types";
import { parseAnnotation } from "../annotation";

function expandHome(p: string): string {
  return p.startsWith("~") ? homedir() + p.slice(1) : p;
}

/**
 * Reads kitty_mod from the config (e.g. `kitty_mod ctrl+shift`).
 * Falls back to "ctrl+shift" (kitty's compiled-in default).
 */
function parseKittyMod(content: string): string {
  const m = content.match(/^\s*kitty_mod\s+(\S+)/m);
  return m ? m[1].toLowerCase() : "ctrl+shift";
}

/**
 * Resolves `kitty_mod` token in a key string to its actual value.
 * e.g. "kitty_mod+enter" → "ctrl+shift+enter"
 */
function resolveKittyKey(key: string, kittyMod: string): string {
  return key.replace(/kitty_mod/gi, kittyMod);
}

/**
 * Kitty driver.
 *
 * Kitty key bindings run inside the terminal process, so they cannot be
 * meaningfully replayed from an external launcher without remote-control.
 * Therefore exec: must be supplied explicitly in the @action annotation.
 * Bindings without exec: in their annotation are silently skipped.
 *
 * kitty_mod is resolved automatically (defaults to ctrl+shift).
 *
 * Example annotation:
 *   # @action group:kitty/tabs exec:kitty --new-window title:New window
 *   map kitty_mod+enter new_window_with_cwd
 */
export class KittyDriver implements Driver {
  constructor(
    private configPath: string = expandHome("~/.config/kitty/kitty.conf")
  ) {}

  async extract(): Promise<Action[]> {
    if (!existsSync(this.configPath)) return [];

    const content = readFileSync(this.configPath, "utf8");
    const kittyMod = parseKittyMod(content);
    const lines = content.split("\n");
    const actions: Action[] = [];
    let idCounter = 0;
    let pending: ReturnType<typeof parseAnnotation> | null = null;

    for (const raw of lines) {
      const line = raw.trim();

      if (line.match(/^#\s*@action/)) {
        pending = parseAnnotation(line);
        continue;
      }

      if (line.startsWith("#") || !line) {
        pending = null;
        continue;
      }

      if (pending === null) continue;

      const mapMatch = line.match(/^map\s+(\S+)\s+(.*)/);
      if (mapMatch && pending.exec) {
        const rawKey = mapMatch[1];
        actions.push({
          id: idCounter++,
          title: pending.title,
          group: pending.group,
          exec: pending.exec,
          keys: [resolveKittyKey(rawKey, kittyMod)],
          source: "kitty",
        });
      }

      pending = null;
    }

    return actions;
  }
}
