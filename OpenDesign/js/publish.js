(() => {
  const app = window.HUAHUOJI;
  const photoGrid = document.querySelector("#photoGrid");
  const photoAdd = document.querySelector("#photoAdd");
  const photoInput = document.querySelector("#photoInput");
  const postTitleInput = document.querySelector("#postTitleInput");
  const postDetailInput = document.querySelector("#postDetailInput");
  const titleCounter = document.querySelector("#titleCounter");
  const detailCounter = document.querySelector("#detailCounter");
  const publishPost = document.querySelector("#publishPost");
  const saveDraft = document.querySelector("#saveDraft");
  const draftState = document.querySelector("#draftState");
  const cancelPublish = document.querySelector("#cancelPublish");
  const uploadedPhotos = [];

  function renderPhotoGrid() {
    const tiles = uploadedPhotos.map((photo, index) => `
      <div class="photo-tile">
        <img src="${photo.url}" alt="${app.escapeHTML(photo.name)}" />
        <button class="photo-remove" type="button" data-remove-photo="${index}" aria-label="删除图片">×</button>
      </div>
    `).join("");
    photoGrid.innerHTML = `${tiles}
      <button class="photo-add" type="button" id="photoAdd" aria-label="添加图片">
        <span class="photo-add-inner">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M12 5v14M5 12h14"/>
          </svg>
          添加图片
        </span>
      </button>
    `;
    photoGrid.querySelector("#photoAdd").addEventListener("click", () => photoInput.click());
  }

  function updateComposeState(message = "草稿") {
    const titleBytes = app.titleByteLength(postTitleInput.value);
    titleCounter.textContent = `${titleBytes}/40B`;
    titleCounter.classList.toggle("over", titleBytes > 40);
    detailCounter.textContent = `${postDetailInput.value.length}`;
    const canPublish = uploadedPhotos.length > 0 && titleBytes > 0 && titleBytes <= 40 && postDetailInput.value.trim().length > 0;
    publishPost.disabled = !canPublish;
    draftState.textContent = message;
  }

  function handleFiles(files) {
    Array.from(files).forEach((file) => {
      if (!file.type.startsWith("image/")) return;
      uploadedPhotos.push({
        name: file.name.replace(/[<>"]/g, ""),
        url: URL.createObjectURL(file)
      });
    });
    renderPhotoGrid();
    updateComposeState("已存草稿");
  }

  photoAdd.addEventListener("click", () => photoInput.click());
  photoInput.addEventListener("change", (event) => {
    handleFiles(event.target.files);
    photoInput.value = "";
  });

  photoGrid.addEventListener("click", (event) => {
    const remove = event.target.closest("[data-remove-photo]");
    if (!remove) return;
    const [photo] = uploadedPhotos.splice(Number(remove.dataset.removePhoto), 1);
    if (photo) URL.revokeObjectURL(photo.url);
    renderPhotoGrid();
    updateComposeState("已存草稿");
  });

  postTitleInput.addEventListener("input", () => {
    const trimmed = app.trimTitleToLimit(postTitleInput.value);
    if (trimmed !== postTitleInput.value) postTitleInput.value = trimmed;
    updateComposeState("编辑中");
  });
  postDetailInput.addEventListener("input", () => updateComposeState("编辑中"));
  saveDraft.addEventListener("click", () => updateComposeState("已存草稿"));
  publishPost.addEventListener("click", () => {
    draftState.textContent = "已发布";
    publishPost.textContent = "发布成功";
    setTimeout(() => {
      publishPost.textContent = "发布";
      window.location.href = "index.html";
    }, 700);
  });
  cancelPublish.addEventListener("click", () => {
    window.location.href = "index.html";
  });

  renderPhotoGrid();
  updateComposeState();
})();
