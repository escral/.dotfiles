export type ActionSource = "i3" | "kitty" | "json";

export interface Action {
  id: number;
  title: string;
  group: string;
  exec: string;
  keys?: string[];
  source: ActionSource;
}

export interface Annotation {
  group: string;
  title: string;
  exec?: string; // overrides derived exec when present
}

export interface Driver {
  extract(): Promise<Action[]>;
}
