import { ERROR_CODE } from "./error.js";

const S3_NAMESPACE = "http://s3.amazonaws.com/doc/2006-03-01/";
const IMAGE_EXTENSIONS = /\.(jpe?g|png|gif|webp|svg)$/i;

async function getPhotoKeys() {
  let xml;
  try {
    const response = await fetch("/media/");
    xml = await response.text();
  } catch {
    throw Error(`${ERROR_CODE.g003}, Code: g003`);
  }

  const dom = new DOMParser().parseFromString(xml, "application/xml");
  if (dom.querySelector("parsererror")) {
    throw Error(`${ERROR_CODE.g001}, Code: g001`);
  }

  const keys = [...dom.getElementsByTagNameNS(S3_NAMESPACE, "Key")]
    .map((element) => element.textContent)
    .filter((key) => IMAGE_EXTENSIONS.test(key));

  return keys;
}

export { getPhotoKeys };
