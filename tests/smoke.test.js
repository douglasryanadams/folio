import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";

test("index.html exists and has the expected title", () => {
  const html = readFileSync("index.html", "utf8");
  expect(html).toContain("<title>Folio</title>");
});
