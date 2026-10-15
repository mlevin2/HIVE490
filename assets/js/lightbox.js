(function () {
  var dialog = document.getElementById('lightbox');
  if (!dialog || typeof dialog.showModal !== 'function') return;

  var img = document.getElementById('lightbox-img');
  var caption = document.getElementById('lightbox-caption');
  var closeBtn = document.getElementById('lightbox-close');

  function open(sourceImg) {
    img.src = sourceImg.currentSrc || sourceImg.src;
    img.alt = sourceImg.alt || '';
    var text = sourceImg.title || sourceImg.alt || '';
    caption.textContent = text;
    caption.hidden = !text;
    dialog.showModal();
  }

  function close() {
    dialog.close();
    img.src = '';
  }

  document.querySelectorAll('.post__content img').forEach(function (el) {
    el.addEventListener('click', function () {
      open(el);
    });
  });

  closeBtn.addEventListener('click', close);

  // Clicking the backdrop (the <dialog> element itself, outside the
  // inner content box) should close it too.
  dialog.addEventListener('click', function (event) {
    if (event.target === dialog) close();
  });
})();
