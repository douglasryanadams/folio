import { getPhotoKeys } from "./s3-client.js";
import { ERROR_CODE } from "./error.js";

function itemWithText(text) {
  const item = document.createElement("li");
  item.textContent = text;
  return item;
}

async function loadGallery() {
  const gallery = document.getElementById("gallery");

  let keys;
  try {
    keys = await getPhotoKeys();
  } catch (error) {
    gallery.replaceChildren(itemWithText(error.message));
    return;
  }

  if (keys.length === 0) {
    gallery.replaceChildren(itemWithText(`${ERROR_CODE.g002}, Code: g002`));
    return;
  }

  // Lists folders of images
  const folders = [...new Set([...keys.map((key) => key.split("/")[0])])];

  gallery.replaceChildren(
    ...folders.map((folder) => {
      const item = document.createElement("div");
      const link = document.createElement("a");
      link.href = `/${folder}.html`;
      link.text = folder;
      item.append(link);
      return item;
    }),
  );
}

//   gallery.replaceChildren(
//     ...keys.map((key) => {
//       const item = document.createElement("div");
//       const img = document.createElement("img");
//       img.src = `/media/${key}`;
//       img.alt = key;
//       img.loading = "lazy";
//       item.appendChild(img);
//       return item;
//     }),
//   );
// }

loadGallery();
