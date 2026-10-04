import { expect, test, mock, spyOn, afterEach } from "bun:test";
import { getPhotoKeys } from "../js/s3-client.js";

afterEach(() => mock.restore());

test("gallery getPhotos returns list of photo keys", async () => {
  const s3xml = await Bun.file(
    new URL("./data/s3FakeResponse.xml", import.meta.url),
  ).text();
  spyOn(globalThis, "fetch").mockResolvedValue(new Response(s3xml));

  const keys = await getPhotoKeys();
  expect(keys).toEqual(["test/test_001.jpg", "test/test_002.jpg"]);
});
