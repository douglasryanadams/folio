import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";

test("built photography.html exists and has the expected title", () => {
  const html = readFileSync("_site/photography.html", "utf8");
  expect(html).toContain("<title>Douglas Adams</title>");
});
