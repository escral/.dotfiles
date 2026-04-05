import type { Action } from "./types";

/**
 * Flattens multiple action lists into one and re-assigns sequential ids.
 * Priority: later lists win on display (json overrides extracted), but since
 * we have no deduplication by title yet, all actions are kept and ids are
 * simply sequential starting from 0.
 */
export function merge(...actionLists: Action[][]): Action[] {
  return actionLists.flat().map((action, i) => ({ ...action, id: i }));
}

/** Drops actions that are missing either exec or title. */
export function validate(actions: Action[]): Action[] {
  return actions.filter((a) => a.exec?.trim() && a.title?.trim());
}
