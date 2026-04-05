import type { Annotation } from "./types";

/**
 * Parses a `# @action group:GROUP [exec:CMD] title:TITLE` comment line.
 *
 * Rules:
 * - `group:` value must have no spaces (use slashes for hierarchy, e.g. i3/navigation)
 * - `exec:` is optional; its value extends until ` title:` or end of string
 * - `title:` must be last — its value consumes the rest of the line
 * - Returns null if line is not an @action comment or has no title
 *
 * Examples:
 *   # @action group:screenshots title:Screenshot selection to clipboard
 *   # @action group:kitty/tabs exec:kitty --new-window title:New window
 */
export function parseAnnotation(line: string): Annotation | null {
  const m = line.match(/^#\s*@action\s+(.*)/);
  if (!m) return null;

  const rest = m[1].trim();
  if (!rest) return null;

  const group = rest.match(/\bgroup:(\S+)/)?.[1] ?? "other";

  // exec: value extends until " title:" or end of string
  const execMatch = rest.match(/\bexec:(.*?)(?=\s+title:|$)/s);
  const explicitExec = execMatch?.[1]?.trim() || undefined;

  // title: consumes everything after the last "title:" keyword
  const titleMatch = rest.match(/\btitle:(.*)/s);
  const title = titleMatch?.[1]?.trim();

  if (!title) return null;

  return { group, title, exec: explicitExec };
}
