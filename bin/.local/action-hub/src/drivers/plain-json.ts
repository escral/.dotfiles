import { existsSync, readdirSync, readFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";
import type { Action, Driver } from "../types";

interface RawAction {
  title: string;
  group?: string;
  exec: string;
  keys?: string[];
}

/**
 * Reads custom actions from JSON files in ~/.config/action-hub/actions.d/.
 * Each file may contain a single action object or an array of action objects.
 * The `exec` and `title` fields are required; everything else is optional.
 *
 * Example file:
 *   [
 *     { "group": "system", "title": "Toggle night light", "exec": "redshift -O 4500" },
 *     { "group": "system", "title": "Reset night light",  "exec": "redshift -x" }
 *   ]
 */
export class PlainJsonDriver implements Driver {
  constructor(
    private actionsDir: string = join(
      homedir(),
      ".config",
      "action-hub",
      "actions.d"
    )
  ) {}

  async extract(): Promise<Action[]> {
    if (!existsSync(this.actionsDir)) return [];

    const files = readdirSync(this.actionsDir).filter((f) =>
      f.endsWith(".json")
    );
    const actions: Action[] = [];
    let idCounter = 0;

    for (const file of files) {
      let raw: RawAction[];
      try {
        const content = readFileSync(join(this.actionsDir, file), "utf8");
        const parsed = JSON.parse(content);
        raw = Array.isArray(parsed) ? parsed : [parsed];
      } catch {
        console.warn(`action-hub: skipping invalid JSON: ${file}`);
        continue;
      }

      for (const entry of raw) {
        if (!entry.title || !entry.exec) continue;
        actions.push({
          id: idCounter++, // re-assigned in merge step
          title: entry.title,
          group: entry.group ?? "other",
          exec: entry.exec,
          keys: entry.keys,
          source: "json",
        });
      }
    }

    return actions;
  }
}
