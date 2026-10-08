export default function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("css");
  eleventyConfig.addPassthroughCopy("static");
  eleventyConfig.addPassthroughCopy("media" );
  // In `--serve`, serve passthrough files straight from source instead of copying them.
  eleventyConfig.setServerPassthroughCopyBehavior("passthrough");

  // Keep output filenames as written (about.html -> /about.html) instead of
  // Eleventy's default pretty URLs (about.html -> /about/index.html).
  eleventyConfig.addGlobalData("permalink", () => {
    return (data) =>
      `${data.page.filePathStem}.${data.page.outputFileExtension}`;
  });

  return {
    dir: { input: "src", output: "_site" },
    // Treat .html pages as Nunjucks templates (front matter + layouts work in them).
    htmlTemplateEngine: "njk",
  };
}
