(function () {
  var root = document.documentElement;

  /* Переключатель темы: запоминаем выбор, по умолчанию — системная. */
  var themeToggle = document.querySelector("[data-theme-toggle]");
  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      root.setAttribute("data-theme", next);
      try {
        localStorage.setItem("theme", next);
      } catch (e) {}
    });
  }

  /* Мобильное меню разделов. */
  var sideNav = document.querySelector("[data-side-nav]");
  if (sideNav) {
    var sideToggle = sideNav.querySelector("[data-side-nav-toggle]");
    sideToggle.addEventListener("click", function () {
      var open = sideNav.getAttribute("data-open") === "true";
      sideNav.setAttribute("data-open", String(!open));
      sideToggle.setAttribute("aria-expanded", String(!open));
    });
  }

  /* Подсветка активного раздела в оглавлении страницы. */
  var toc = document.querySelector(".page-toc");
  if (!toc) return;

  var links = Array.prototype.slice.call(toc.querySelectorAll("a[href^='#']"));
  var headings = Array.prototype.slice.call(
    document.querySelectorAll(".page-body h2[id], .page-body h3[id]")
  );
  if (!links.length || !headings.length) return;

  function activate(id) {
    links.forEach(function (link) {
      link.classList.toggle("is-active", link.getAttribute("href") === "#" + id);
    });
  }

  function onScroll() {
    var current = headings[0];
    for (var i = 0; i < headings.length; i += 1) {
      if (headings[i].getBoundingClientRect().top <= 120) current = headings[i];
    }
    if (current) activate(current.id);
  }

  var scheduled = false;
  window.addEventListener(
    "scroll",
    function () {
      if (scheduled) return;
      scheduled = true;
      window.requestAnimationFrame(function () {
        scheduled = false;
        onScroll();
      });
    },
    { passive: true }
  );

  links.forEach(function (link) {
    link.addEventListener("click", function () {
      activate(link.getAttribute("href").slice(1));
    });
  });

  onScroll();
})();
