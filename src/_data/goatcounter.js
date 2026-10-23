import Fetch from "@11ty/eleventy-fetch";

export default async function () {
  return await Fetch("https://gc.zgo.at/count.js", {
    duration: "1d", // save for 1 day
    type: "text", // raw JS, written out by js/count.njk
  });
}
