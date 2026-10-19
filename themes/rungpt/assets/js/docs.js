(function () {
  var nav = document.querySelector("[data-docs-nav]");
  if (nav) {
    var toggle = nav.querySelector("[data-docs-nav-toggle]");
    toggle.addEventListener("click", function () {
      var open = nav.getAttribute("data-open") === "true";
      nav.setAttribute("data-open", String(!open));
      toggle.setAttribute("aria-expanded", String(!open));
    });
  }

  var toc = document.querySelector(".docs-toc__body");
  if (!toc) return;

  var links = Array.prototype.slice.call(toc.querySelectorAll("a[href^='#']"));
  var headings = Array.prototype.slice.call(
    document.querySelectorAll(".docs-main h2[id], .docs-main h3[id]")
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
