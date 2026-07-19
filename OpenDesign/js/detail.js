(() => {
  const app = window.HUAHUOJI;
  const posts = app.posts;
  const params = new URLSearchParams(window.location.search);
  const requestedIndex = Number(params.get("id") || 0);
  const postIndex = Number.isInteger(requestedIndex) && posts[requestedIndex] ? requestedIndex : 0;
  const post = posts[postIndex];

  const detailSheet = document.querySelector(".detail-sheet");
  const detailHero = document.querySelector("#detailHero");
  const detailTitle = document.querySelector("#detailTitle");
  const detailAuthor = document.querySelector("#detailAuthor");
  const detailAuthorTop = document.querySelector("#detailAuthorTop");
  const detailAuthorBio = document.querySelector("#detailAuthorBio");
  const detailLikes = document.querySelector("#detailLikes");
  const detailCopy = document.querySelector("#detailCopy");
  const detailTags = document.querySelector("#detailTags");
  const detailTime = document.querySelector("#detailTime");
  const detailCommentCount = document.querySelector("#detailCommentCount");
  const detailCommentAction = document.querySelector("#detailCommentAction");
  const detailComments = document.querySelector("#detailComments");
  const detailLikeAction = document.querySelector("#detailLikeAction");
  const closeDetail = document.querySelector("#closeDetail");

  function renderNoteComments() {
    const comments = app.commentsFor(post);
    detailCommentCount.textContent = `${comments.length} 条`;
    detailCommentAction.textContent = comments.length;
    detailComments.innerHTML = comments.map((comment) => `
      <div class="comment-row">
        <span class="avatar"></span>
        <div>
          <strong>${app.escapeHTML(comment.name)}</strong>
          <p>${app.escapeHTML(comment.text)}</p>
          <time>${app.escapeHTML(comment.time)}</time>
        </div>
      </div>
    `).join("");
  }

  function syncLikeState() {
    detailLikes.textContent = post.likes;
    detailLikeAction.classList.toggle("liked", Boolean(post.liked));
    detailLikeAction.setAttribute("aria-label", post.liked ? "取消喜欢" : "喜欢");
  }

  function renderDetail() {
    const tags = app.noteTagsFor(post);
    detailHero.dataset.style = post.style;
    detailTitle.textContent = post.title;
    detailAuthor.textContent = post.author;
    detailAuthorTop.textContent = post.author;
    detailAuthorBio.textContent = `${tags[0].replace("#", "")} · 摄影 / 插画创作者`;
    detailCopy.textContent = post.copy;
    detailTags.innerHTML = tags.map((tag) => `<span>${app.escapeHTML(tag)}</span>`).join("");
    detailTime.textContent = `${postIndex + 1} 小时前 · 花火记`;
    renderNoteComments();
    syncLikeState();
    detailSheet.scrollTop = 0;
  }

  detailLikeAction.addEventListener("click", () => {
    app.toggleLike(posts, postIndex);
    syncLikeState();
  });

  closeDetail.addEventListener("click", () => {
    window.location.href = "index.html";
  });

  renderDetail();
})();
