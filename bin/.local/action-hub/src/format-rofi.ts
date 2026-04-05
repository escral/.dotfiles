import type { Action } from "./types";

// Map raw modifier names to nicer display names
const MOD_NAMES: Record<string, string> = {
  Mod4: "Win",
  Mod1: "Alt",
  Mod2: "Mod2",
  Mod3: "Mod3",
  Mod5: "Mod5",
  Control: "Ctrl",
  // kitty_mod is resolved by the kitty driver before reaching here
};

function escapeMarkup(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/**
 * Formats a key chord with Pango markup:
 *   modifiers rendered in muted gray, main key in normal color.
 *   e.g. "Mod4+Shift+Return" → "<span …>Win+Shift+</span>Return"
 */
function formatKeyMarkup(key: string): string {
  const parts = key.split("+");
  if (parts.length === 1) return escapeMarkup(key);

  const mods = parts
    .slice(0, -1)
    .map((m) => escapeMarkup(MOD_NAMES[m] ?? m));
  const mainKey = escapeMarkup(parts[parts.length - 1]);

  return `<span foreground="#949cbb">${mods.join("+")}</span>+${mainKey}`;
}

/**
 * Formats actions into aligned Pango-markup strings for rofi -dmenu -markup-rows.
 *
 * Columns (space-padded on plain-text widths, markup added after):
 *   GROUP (muted)   TITLE   KEY(S) (modifiers muted)
 *
 * lines[i] corresponds to actions[i] — rofi -format i gives a direct index.
 */
export function formatForRofi(actions: Action[]): string[] {
  if (actions.length === 0) return [];

  const maxGroup = Math.max(...actions.map((a) => a.group.length));

  return actions.map((a) => {
    const groupMarkup = `<span foreground="#949cbb">${escapeMarkup(a.group.padEnd(maxGroup))}</span>`;
    const keyMarkup = a.keys?.map(formatKeyMarkup).join(", ") ?? "";
    const title = escapeMarkup(a.title.padEnd(40));

    return keyMarkup
      ? `${groupMarkup}  ${title}  ${keyMarkup}`
      : `${groupMarkup}  ${title}`;
  });
}
