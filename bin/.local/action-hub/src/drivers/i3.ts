import { existsSync, readFileSync } from "fs";
import { resolve, dirname } from "path";
import { homedir } from "os";
import type { Action, Driver } from "../types";
import { parseAnnotation } from "../annotation";

function expandHome(p: string): string {
  return p.startsWith("~") ? homedir() + p.slice(1) : p;
}

function resolveVars(text: string, vars: Map<string, string>): string {
  let result = text;
  // Sort by key length descending to avoid partial replacements ($wsMainCode before $ws)
  const sorted = [...vars.entries()].sort((a, b) => b[0].length - a[0].length);
  for (const [k, v] of sorted) {
    result = result.replaceAll(`$${k}`, v);
  }
  return result;
}

/**
 * Derives exec string from an i3 binding command.
 * - `exec [--no-startup-id] CMD`  → run CMD directly
 * - any other i3 command          → wrap in `i3-msg 'CMD'`
 */
function deriveExec(command: string): string {
  const execMatch = command.match(/^exec\s+(?:--no-startup-id\s+)?("(.+)"|(.+))/s);
  if (execMatch) {
    return (execMatch[2] ?? execMatch[3]).trim();
  }
  const escaped = command.replace(/'/g, "'\\''");
  return `i3-msg '${escaped}'`;
}

interface ParsedFile {
  lines: Array<{ line: string }>;
}

function parseFile(
  filePath: string,
  vars: Map<string, string>,
  visited: Set<string>
): ParsedFile {
  if (visited.has(filePath)) return { lines: [] };
  visited.add(filePath);
  if (!existsSync(filePath)) return { lines: [] };

  const content = readFileSync(filePath, "utf8");
  const rawLines = content.split("\n");
  const allLines: Array<{ line: string }> = [];

  for (const raw of rawLines) {
    const line = raw.trim();

    // set $VAR VALUE  (strip surrounding quotes from value)
    const setMatch = line.match(/^set\s+\$(\S+)\s+(.+)/);
    if (setMatch) {
      const val = setMatch[2].replace(/^["']|["']$/g, "").trim();
      vars.set(setMatch[1], val);
      continue;
    }

    // include PATH  (follow recursively)
    const includeMatch = line.match(/^include\s+(.+)/);
    if (includeMatch) {
      const raw = expandHome(includeMatch[1].trim());
      const includePath = resolve(dirname(filePath), raw);
      const sub = parseFile(includePath, vars, visited);
      allLines.push(...sub.lines);
      continue;
    }

    allLines.push({ line });
  }

  return { lines: allLines };
}

export class I3Driver implements Driver {
  constructor(
    private configPath: string = expandHome("~/.config/i3/config")
  ) {}

  async extract(): Promise<Action[]> {
    const vars = new Map<string, string>();
    const visited = new Set<string>();
    const { lines } = parseFile(this.configPath, vars, visited);

    const actions: Action[] = [];
    let idCounter = 0;
    let pending: ReturnType<typeof parseAnnotation> | null = null;

    for (const { line } of lines) {
      // @action annotation — store and continue
      if (line.match(/^#\s*@action/)) {
        pending = parseAnnotation(line);
        continue;
      }

      // Any other comment or blank line — clear pending
      if (line.startsWith("#") || !line) {
        pending = null;
        continue;
      }

      // Non-comment line without pending annotation — skip
      if (pending === null) continue;

      const resolved = resolveVars(line, vars);
      const bindMatch = resolved.match(/^bindsym\s+(\S+)\s+(.+)/);
      if (bindMatch) {
        const keys = [bindMatch[1]];
        const command = bindMatch[2].trim();
        const exec = pending.exec ?? deriveExec(command);
        if (exec) {
          actions.push({
            id: idCounter++,
            title: pending.title,
            group: pending.group,
            exec,
            keys,
            source: "i3",
          });
        }
      }

      // Consume annotation regardless of whether binding matched
      pending = null;
    }

    return actions;
  }
}
