function enableClick() {
  if (window.innerWidth <= 505) {
    return;
  }

  function dismissLightbox() {
    const lightboxes = document.getElementsByClassName("lightbox");
    for (const lightbox of lightboxes) {
      lightbox.remove();
    }

    const lightboxCovers = document.getElementsByClassName("lightbox-cover");
    for (const lightboxCover of lightboxCovers) {
      lightboxCover.remove();
    }

    document.body.removeEventListener("click", dismissLightbox);
  }

  function clickGalleryImage(event) {
    const existingLightboxes = document.getElementsByClassName("lightbox");
    for (const lightbox of existingLightboxes) {
      lightbox.remove();
    }

    const lightbox = document.createElement("div");
    lightbox.classList.add("lightbox");
    lightbox.id = "lightbox";

    const lightboxImg = document.createElement("img");
    lightboxImg.classList.add("lightbox-img");
    lightboxImg.src = event.target.getAttribute("src");
    lightbox.appendChild(lightboxImg);

    const lightboxCover = document.createElement("div");
    lightboxCover.classList.add("lightbox-cover");
    lightboxCover.addEventListener("click", dismissLightbox);

    document.body.appendChild(lightbox);
    document.body.appendChild(lightboxCover);
  }

  const figures = document.querySelectorAll("img");
  for (const figure of figures) {
    figure.addEventListener("click", clickGalleryImage);
  }
}

enableClick();
