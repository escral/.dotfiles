import { readdirSync, readFileSync, statSync } from "fs";
import { join } from "path";
import { homedir } from "os";
import type { Action, Driver } from "../types";
import { parseAnnotation } from "../annotation";

const HEAD_LINES = 80;

/**
 * Derives a shell command from the shebang on line 1.
 * Falls back to `bash` if unknown.
 */
function deriveExecFromShebang(shebangLine: string, basename: string): string {
  const path = `$HOME/.local/scripts/${basename}`;
  const m = shebangLine.match(/^#!\s*(.+)/);
  if (!m) return `bash ${path}`;

  const rest = m[1].trim().toLowerCase();
  if (rest.includes("zsh")) return `zsh ${path}`;
  if (rest.includes("bash")) return `bash ${path}`;
  if (rest.includes("sh")) return `sh ${path}`;
  return `bash ${path}`;
}

/**
 * Scans `~/.local/scripts` (or `ACTION_HUB_SCRIPTS_DIR`) for executable files
 * that contain a `# @action` comment in the first N lines — same format as i3.
 *
 * If `exec:` is omitted, the command is derived from the shebang (`bash` / `zsh` / `sh`
 * plus `$HOME/.local/scripts/<name>`). Use `exec:...` when you need a terminal wrapper
 * or a different launch command.
 */
export class ScriptsDriver implements Driver {
  private readonly scriptsDir: string;

  constructor(scriptsDir?: string) {
    this.scriptsDir =
      scriptsDir ?? join(homedir(), ".local", "scripts");
  }

  async extract(): Promise<Action[]> {
    let names: string[];
    try {
      names = readdirSync(this.scriptsDir);
    } catch {
      return [];
    }

    const actions: Action[] = [];
    let idCounter = 0;

    for (const name of names) {
      if (name.startsWith(".")) continue;

      const fullPath = join(this.scriptsDir, name);
      try {
        if (!statSync(fullPath).isFile()) continue;
      } catch {
        continue;
      }

      let content: string;
      try {
        content = readFileSync(fullPath, "utf8");
      } catch {
        continue;
      }

      const lines = content.split("\n");
      const head = lines.slice(0, HEAD_LINES);
      const shebangLine = head[0] ?? "";
      const actionLine = head.find((l) => l.match(/^#\s*@action\b/));
      if (!actionLine) continue;

      const ann = parseAnnotation(actionLine);
      if (!ann) continue;

      const exec =
        ann.exec?.trim() ??
        deriveExecFromShebang(shebangLine, name);

      actions.push({
        id: idCounter++,
        title: ann.title,
        group: ann.group,
        exec,
        source: "scripts",
      });
    }

    return actions;
  }
}
