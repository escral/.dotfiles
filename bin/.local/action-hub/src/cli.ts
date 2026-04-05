import { mkdirSync, writeFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";

import { I3Driver } from "./drivers/i3";
import { KittyDriver } from "./drivers/kitty";
import { PlainJsonDriver } from "./drivers/plain-json";
import { merge, validate } from "./merge";
import { formatForRofi } from "./format-rofi";

const CACHE_DIR = join(homedir(), ".cache", "action-hub");

async function main() {
  const drivers = [
    new I3Driver(process.env.I3_CONFIG),
    new KittyDriver(process.env.KITTY_CONFIG),
    new PlainJsonDriver(process.env.ACTION_HUB_JSON_DIR),
  ];

  const lists = await Promise.all(drivers.map((d) => d.extract()));
  const actions = validate(merge(...lists));
  const lines = formatForRofi(actions);

  mkdirSync(CACHE_DIR, { recursive: true });
  writeFileSync(join(CACHE_DIR, "actions.json"), JSON.stringify(actions, null, 2));
  writeFileSync(join(CACHE_DIR, "rofi-lines.txt"), lines.join("\n"));

  console.log(`action-hub: ${actions.length} actions written to ${CACHE_DIR}`);
}

main().catch((err) => {
  console.error("action-hub:", err);
  process.exit(1);
});
