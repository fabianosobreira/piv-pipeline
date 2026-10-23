// Fills the shell in index.html from a locale constant (i18n/<locale>.js):
// picks the locale from the browser, renders the content blocks, applies the
// data-i18n strings, and wires the nav, the copy buttons and the language switch.
(function () {
  'use strict';

  const LOCALES = { 'en-US': MANUAL_EN_US, 'pt-BR': MANUAL_PT_BR };
  const DEFAULT_LOCALE = 'en-US';
  const COPY_RESET_MS = 1600;

  let current = null;

  // ---------- locale ----------

  // ?lang= wins (it is what the language switch writes); otherwise the first
  // browser language that matches a locale, by full tag and then by base
  // language; otherwise en-US.
  function detectLocale() {
    const forced = new URLSearchParams(location.search).get('lang');
    if (forced && LOCALES[forced]) return forced;

    const codes = Object.keys(LOCALES);
    const prefs = navigator.languages && navigator.languages.length
      ? navigator.languages
      : [navigator.language || ''];

    for (const tag of prefs) {
      const lower = tag.toLowerCase();
      const exact = codes.find((code) => code.toLowerCase() === lower);
      if (exact) return exact;
      const base = lower.split('-')[0];
      const sameBase = codes.find((code) => code.toLowerCase().split('-')[0] === base);
      if (sameBase) return sameBase;
    }
    return DEFAULT_LOCALE;
  }

  function lookup(locale, path) {
    return path.split('.').reduce((node, key) => (node == null ? node : node[key]), locale);
  }

  // ---------- inline marks ----------

  const ESCAPES = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (ch) => ESCAPES[ch]);
  }

  // `code` is pulled out first so the marks inside it stay literal.
  function inline(text) {
    const codes = [];
    let html = escapeHtml(text).replace(/`([^`]+)`/g, (_, code) => {
      codes.push(code);
      return '\u0000' + (codes.length - 1) + '\u0000';
    });
    html = html
      .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<a href="$2">$1</a>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^*]+)\*/g, '<em>$1</em>');
    return html.replace(/\u0000(\d+)\u0000/g, (_, i) => '<code>' + codes[i] + '</code>');
  }

  // ---------- blocks ----------

  function renderBlocks(blocks, ui) {
    return (blocks || []).map((block) => {
      const render = BLOCKS[block.type];
      if (!render) throw new Error('manual.js: unknown block type "' + block.type + '"');
      return render(block, ui);
    }).join('');
  }

  const BLOCKS = {
    p: (b) => '<p>' + inline(b.text) + '</p>',

    list: (b) => {
      const tag = b.ordered ? 'ol' : 'ul';
      const lead = b.lead ? '<p class="list-lead">' + inline(b.lead) + '</p>' : '';
      const items = b.items.map((item) => '<li>' + inline(item) + '</li>').join('');
      return lead + '<' + tag + ' class="' + (b.ordered ? 'rules' : 'bullets') + '">' + items + '</' + tag + '>';
    },

    callout: (b) =>
      '<aside class="callout">' +
        '<p class="callout-title">' + inline(b.title) + '</p>' +
        '<p>' + inline(b.text) + '</p>' +
      '</aside>',

    code: (b, ui) =>
      '<div class="code-block">' +
        '<pre><code>' + escapeHtml(b.text) + '</code></pre>' +
        '<button class="copy-button" type="button" data-copy>' + escapeHtml(ui.copy) + '</button>' +
      '</div>',

    table: (b) => {
      const head = b.head.map((cell) => '<th scope="col">' + inline(cell) + '</th>').join('');
      const rows = b.rows.map((row) =>
        '<tr>' + row.map((cell) => '<td>' + inline(cell) + '</td>').join('') + '</tr>'
      ).join('');
      return '<div class="table-wrap" tabindex="0">' +
        '<table><thead><tr>' + head + '</tr></thead><tbody>' + rows + '</tbody></table>' +
      '</div>';
    },

    chain: (b) =>
      '<div class="chain">' + b.phases.map((phase) =>
        '<div class="chain-phase" data-phase="' + escapeHtml(phase.phase) + '">' +
          '<p class="chain-label">' + inline(phase.label) + '</p>' +
          '<ol class="chain-steps">' + phase.skills.map((id) =>
            '<li><a class="chip" href="#' + escapeHtml(id) + '">' + escapeHtml(id) + '</a></li>'
          ).join('') + '</ol>' +
          (phase.note ? '<p class="chain-note">' + inline(phase.note) + '</p>' : '') +
        '</div>'
      ).join('') + '</div>',

    skill: (b, ui) =>
      '<article class="skill reveal" id="' + escapeHtml(b.id) + '">' +
        '<header class="skill-head">' +
          '<p class="skill-kicker">' + inline(b.kicker) + '</p>' +
          '<h3 class="skill-name">' + escapeHtml(b.name || b.id) + '</h3>' +
        '</header>' +
        '<p class="skill-summary">' + inline(b.summary) + '</p>' +
        '<dl class="skill-fields">' + b.fields.map((field) =>
          '<div class="field">' +
            '<dt>' + inline(field.label) + '</dt>' +
            '<dd>' + (field.items
              ? '<ul class="bullets">' + field.items.map((item) => '<li>' + inline(item) + '</li>').join('') + '</ul>'
              : inline(field.text)) +
            '</dd>' +
          '</div>'
        ).join('') + '</dl>' +
        (b.notes ? '<div class="skill-notes">' + renderBlocks(b.notes, ui) + '</div>' : '') +
      '</article>',

    walkthrough: (b) =>
      '<div class="walk">' + b.groups.map((group) =>
        '<div class="walk-group">' +
          '<ol class="walk-steps" start="' + group.steps[0].n + '">' + group.steps.map((step) =>
            '<li class="walk-step">' +
              '<span class="walk-n" aria-hidden="true">' + step.n + '</span>' +
              '<div class="walk-body">' +
                '<code class="walk-cmd">' + escapeHtml(step.cmd) + '</code>' +
                '<p class="walk-text">' + inline(step.text) + '</p>' +
              '</div>' +
            '</li>'
          ).join('') + '</ol>' +
          '<p class="walk-note">' + inline(group.note) + '</p>' +
        '</div>'
      ).join('') + '</div>',

    faq: (b) =>
      '<div class="faq">' + b.items.map((item) =>
        '<div class="faq-item">' +
          '<h3>' + inline(item.q) + '</h3>' +
          '<p>' + inline(item.a) + '</p>' +
        '</div>'
      ).join('') + '</div>',
  };

  function renderSection(section, ui) {
    const phase = section.phase ? ' data-phase="' + escapeHtml(section.phase) + '"' : '';
    return '<section class="section reveal" id="' + escapeHtml(section.id) + '"' + phase + '>' +
      '<h2 class="section-title">' + inline(section.title) + '</h2>' +
      renderBlocks(section.blocks, ui) +
    '</section>';
  }

  function renderNav(items) {
    return items.map((item) => {
      if (item.group) return '<li class="nav-group">' + inline(item.group) + '</li>';
      const cls = item.skill ? ' class="is-skill"' : '';
      return '<li><a href="' + escapeHtml(item.href) + '"' + cls + '>' + inline(item.label) + '</a></li>';
    }).join('');
  }

  function renderLangSwitch(code, ui) {
    return Object.keys(LOCALES).map((key) =>
      '<button type="button" lang="' + key + '" data-lang="' + key + '" aria-pressed="' + (key === code) + '">' +
        escapeHtml(ui.languages[key]) +
      '</button>'
    ).join('');
  }

  // ---------- apply ----------

  function slot(name) {
    return document.querySelector('[data-slot="' + name + '"]');
  }

  function applyStrings(locale) {
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const value = lookup(locale, el.getAttribute('data-i18n'));
      if (value != null) el.innerHTML = inline(value);
    });
    document.querySelectorAll('[data-i18n-attr]').forEach((el) => {
      el.getAttribute('data-i18n-attr').split(';').forEach((pair) => {
        const [attr, path] = pair.split(':').map((s) => s.trim());
        const value = lookup(locale, path);
        if (attr && value != null) el.setAttribute(attr, value);
      });
    });
  }

  function render(code) {
    const locale = LOCALES[code];
    current = code;

    document.documentElement.lang = locale.lang;
    document.title = locale.meta.title;
    document.querySelector('meta[name="description"]').setAttribute('content', locale.meta.description);

    applyStrings(locale);
    slot('nav').innerHTML = renderNav(locale.nav);
    slot('lang').innerHTML = renderLangSwitch(code, locale.ui);
    slot('sections').innerHTML = locale.sections.map((s) => renderSection(s, locale.ui)).join('');    setMenuOpen(document.body.classList.contains('nav-open'));
    updateActive();
  }

  // ---------- scrolling ----------

  function targets() {
    return Array.from(document.querySelectorAll('.section[id], .skill[id]'));
  }

  function scrollToElement(el, viewportTop) {
    const margin = parseFloat(getComputedStyle(el).scrollMarginTop) || 0;
    const top = el.getBoundingClientRect().top + window.scrollY - (viewportTop == null ? margin : viewportTop);
    window.scrollTo({ top: top, behavior: 'instant' });
  }

  // The active target is the last one whose top has crossed a third of the viewport.
  function activeTarget() {
    const line = window.innerHeight / 3;
    let active = null;
    for (const el of targets()) {
      if (el.getBoundingClientRect().top <= line) active = el;
      else break;
    }
    return active;
  }

  function updateActive() {
    const active = activeTarget();
    const id = active ? active.id : null;
    document.querySelectorAll('.nav a').forEach((a) => {
      const on = id !== null && a.getAttribute('href') === '#' + id;
      a.classList.toggle('is-active', on);
      if (on) a.setAttribute('aria-current', 'location');
      else a.removeAttribute('aria-current');
    });
  }

  let ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => { ticking = false; updateActive(); });
  }

  // ---------- reveal ----------

  function setupReveal() {
    if (!('IntersectionObserver' in window) || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    document.documentElement.classList.add('has-reveal');
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-in');
        observer.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -8% 0px' });
    document.querySelectorAll('.reveal').forEach((el) => {
      if (el.getBoundingClientRect().top < window.innerHeight) el.classList.add('is-in');
      else observer.observe(el);
    });
  }

  // ---------- menu ----------

  function setMenuOpen(open) {
    const ui = LOCALES[current].ui;
    const button = document.querySelector('[data-menu-toggle]');
    document.body.classList.toggle('nav-open', open);
    button.setAttribute('aria-expanded', String(open));
    button.querySelector('[data-menu-label]').textContent = open ? ui.menuClose : ui.menuOpen;
  }

  // ---------- events ----------

  function switchLanguage(code) {
    if (code === current || !LOCALES[code]) return;
    // Keep the reader on the same section across the re-render.
    const anchor = activeTarget();
    const offset = anchor ? anchor.getBoundingClientRect().top : 0;
    const anchorId = anchor ? anchor.id : null;

    render(code);
    document.querySelectorAll('.reveal').forEach((el) => el.classList.add('is-in'));

    const url = new URL(location.href);
    url.searchParams.set('lang', code);
    history.replaceState(null, '', url);

    const again = anchorId && document.getElementById(anchorId);
    if (again) scrollToElement(again, offset);
    const pressed = document.querySelector('[data-lang="' + code + '"]');
    if (pressed) pressed.focus();
  }

  function copyCode(button) {
    const ui = LOCALES[current].ui;
    const text = button.parentElement.querySelector('code').textContent;
    const done = (label, state) => {
      button.textContent = label;
      button.dataset.state = state;
      clearTimeout(button._reset);
      button._reset = setTimeout(() => {
        button.textContent = LOCALES[current].ui.copy;
        delete button.dataset.state;
      }, COPY_RESET_MS);
    };
    if (!navigator.clipboard) return done(ui.copyFailed, 'error');
    navigator.clipboard.writeText(text).then(
      () => done(ui.copied, 'ok'),
      () => done(ui.copyFailed, 'error')
    );
  }

  function wireEvents() {
    document.addEventListener('click', (event) => {
      const lang = event.target.closest('[data-lang]');
      if (lang) return switchLanguage(lang.dataset.lang);

      const copy = event.target.closest('[data-copy]');
      if (copy) return copyCode(copy);

      if (event.target.closest('[data-menu-toggle]')) {
        return setMenuOpen(!document.body.classList.contains('nav-open'));
      }
      if (event.target.closest('[data-menu-close]') || event.target.closest('.sidebar a')) {
        setMenuOpen(false);
      }
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && document.body.classList.contains('nav-open')) {
        setMenuOpen(false);
        document.querySelector('[data-menu-toggle]').focus();
      }
    });

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
  }

  // ---------- boot ----------

  function boot() {
    render(detectLocale());
    wireEvents();
    document.body.classList.remove('is-loading');

    // The content did not exist when the browser tried the hash; jump now,
    // before the reveal reads which blocks are already in view.
    const hashTarget = location.hash && document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (hashTarget) scrollToElement(hashTarget);
    setupReveal();
  }

  boot();
})();
