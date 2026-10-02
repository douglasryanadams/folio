const IMAGE_EXTENSIONS = /\.(jpe?g|png|gif|webp|svg)$/i;

async function loadGallery() {
  const gallery = document.getElementById("gallery");

  let xml;
  try {
    const response = await fetch("/media/");
    xml = await response.text();
  } catch {
    gallery.replaceChildren(itemWithText("Could not load photos."));
    return;
  }

  const keys = [...xml.matchAll(/<Key>([^<]+)<\/Key>/g)]
    .map((match) => match[1])
    .filter((key) => IMAGE_EXTENSIONS.test(key))
    .sort();

  if (keys.length === 0) {
    gallery.replaceChildren(itemWithText("No photos yet."));
    return;
  }

  gallery.replaceChildren(
    ...keys.map((key) => {
      const item = document.createElement("li");
      const img = document.createElement("img");
      img.src = `/media/${key}`;
      img.alt = key;
      img.loading = "lazy";
      item.appendChild(img);
      return item;
    }),
  );
}

function itemWithText(text) {
  const item = document.createElement("li");
  item.textContent = text;
  return item;
}

loadGallery();
