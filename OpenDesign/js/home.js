(() => {
  const app = window.HUAHUOJI;
  let posts = app.posts;
  const feedGrid = document.querySelector("#feedGrid");
  const searchInput = document.querySelector("#searchInput");

  if (!feedGrid || !searchInput) return;

  function renderPosts(filter = "") {
    posts = app.getPosts();
    const keyword = filter.trim().toLowerCase();
    const list = posts.filter((post) => {
      const text = `${post.title} ${post.author} ${post.copy}`.toLowerCase();
      return text.includes(keyword);
    });

    if (!list.length) {
      feedGrid.innerHTML = `
        <div class="placeholder-card" style="grid-column: 1 / -1; min-height: 320px;">
          <div class="placeholder-inner">
            <h2>没有找到相关灵感</h2>
            <p>换一个关键词试试，比如胶片、窗边光或拼贴。</p>
          </div>
        </div>
      `;
      return;
    }

    const columns = [[], []];
    const heights = [0, 0];

    list.forEach((post, index) => {
      const originalIndex = posts.indexOf(post);
      const targetColumn = heights[0] <= heights[1] ? 0 : 1;
      columns[targetColumn].push({ post, index, originalIndex });
      heights[targetColumn] += app.postHeightWeight(post);
    });

    feedGrid.innerHTML = columns.map((column) => `
      <div class="feed-column">
        ${column.map(({ post, index, originalIndex }) => `
          <article class="post-card" tabindex="0" role="link" data-open="${originalIndex}" aria-label="打开：${app.escapeHTML(post.title)}">
            <div class="art ${post.size}" data-style="${post.style}">
              <div class="mini-scene"><div class="scene-card" style="--tilt:${index % 2 ? 5 : -5}deg"></div></div>
            </div>
            <div class="post-body">
              <h3 class="post-title">${app.escapeHTML(post.title)}</h3>
              <div class="post-meta">
                <span class="author"><span class="avatar"></span><span>${app.escapeHTML(post.author)}</span></span>
                <button class="like-btn ${post.liked ? "liked" : ""}" type="button" data-like="${originalIndex}" aria-label="收藏 ${app.escapeHTML(post.title)}">${app.heartIcon()}<span>${post.likes}</span></button>
              </div>
            </div>
          </article>
        `).join("")}
      </div>
    `).join("");
  }

  function activateScreen(screenId) {
    document.querySelectorAll(".tab[data-tab]").forEach((item) => {
      item.classList.toggle("active", item.dataset.tab === screenId);
    });
    document.querySelectorAll(".screen").forEach((screen) => {
      screen.classList.toggle("active", screen.id === screenId);
    });
  }

  function openDetail(index) {
    window.location.href = `detail.html?id=${index}`;
  }

  function togglePostLike(index) {
    app.toggleLike(posts, index);
    renderPosts(searchInput.value);
  }

  feedGrid.addEventListener("click", (event) => {
    const like = event.target.closest("[data-like]");
    if (like) {
      event.stopPropagation();
      togglePostLike(Number(like.dataset.like));
      return;
    }
    const opener = event.target.closest("[data-open]");
    if (opener) openDetail(Number(opener.dataset.open));
  });

  feedGrid.addEventListener("keydown", (event) => {
    if (event.key !== "Enter" && event.key !== " ") return;
    const opener = event.target.closest("[data-open]");
    if (!opener) return;
    event.preventDefault();
    openDetail(Number(opener.dataset.open));
  });

  document.querySelectorAll(".tab[data-tab]").forEach((tab) => {
    tab.addEventListener("click", () => activateScreen(tab.dataset.tab));
  });

  document.querySelectorAll(".channel").forEach((channel) => {
    channel.addEventListener("click", () => {
      document.querySelectorAll(".channel").forEach((item) => item.classList.remove("active"));
      channel.classList.add("active");
      const label = channel.textContent.trim();
      searchInput.value = label === "今日灵感" ? "" : label;
      renderPosts(searchInput.value);
    });
  });

  searchInput.addEventListener("input", (event) => renderPosts(event.target.value));
  renderPosts();
})();
