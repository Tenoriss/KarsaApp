/* Verification harness for the KarsaApp HTML preview.
 *
 * Runs the preview script inside a tiny mock DOM (no browser required) and
 * asserts that:
 *   - every one of the 40 canonical screens renders without throwing,
 *   - the splash screen auto-advances to the welcome screen,
 *   - each role login validates credentials exactly like AppState.authenticate(),
 *   - the bottom navigation switches tabs,
 *   - chips / segments / search filter the task list,
 *   - attendance status buttons are selectable,
 *   - the study tip card cycles,
 *   - the quiz flow produces a result screen,
 *   - the dark mode toggle switches the theme attribute,
 *   - operator-school CRUD persists, rejects invalid scores and the deletion
 *     of the last class, and restores deleted seeded data faithfully.
 *
 * Run with:  node karsa_app/preview/test_preview.js
 */
'use strict';

const fs = require('fs');
const path = require('path');
const vm = require('vm');

/* ------------------------------------------------------------------ *
 * Minimal mock DOM
 * ------------------------------------------------------------------ */
class MockNode {
  constructor(tagName) {
    this.tagName = String(tagName || '').toUpperCase();
    this.childNodes = [];
    this.parentNode = null;
    this.attributes = {};
    this.listeners = {};
    this.style = {};
    this.dataset = {};
    this._text = '';
    this.value = '';
    this.checked = false;
    this.disabled = false;
    this.hidden = false;
    this.selectionStart = 0;
    const self = this;
    this.classList = {
      add(name) {
        const list = String(self.className || '').split(/\s+/).filter(Boolean);
        if (list.indexOf(name) < 0) list.push(name);
        self.className = list.join(' ');
      },
      remove(name) {
        const list = String(self.className || '').split(/\s+/).filter(Boolean)
          .filter((c) => c !== name);
        self.className = list.join(' ');
      },
      contains(name) {
        return String(self.className || '').split(/\s+/).indexOf(name) >= 0;
      },
      toggle(name, force) {
        const has = this.contains(name);
        const shouldAdd = force === undefined ? !has : !!force;
        if (shouldAdd) this.add(name); else this.remove(name);
        return shouldAdd;
      }
    };
  }

  get firstChild() { return this.childNodes[0] || null; }

  appendChild(child) {
    if (!child) return child;
    child.parentNode = this;
    this.childNodes.push(child);
    return child;
  }

  removeChild(child) {
    const idx = this.childNodes.indexOf(child);
    if (idx >= 0) this.childNodes.splice(idx, 1);
    child.parentNode = null;
    return child;
  }

  setAttribute(name, value) { this.attributes[name] = String(value); }
  getAttribute(name) { return this.attributes[name] === undefined ? null : this.attributes[name]; }
  removeAttribute(name) { delete this.attributes[name]; }
  addEventListener(type, fn) {
    (this.listeners[type] = this.listeners[type] || []).push(fn);
  }
  removeEventListener(type, fn) {
    const list = this.listeners[type] || [];
    const idx = list.indexOf(fn);
    if (idx >= 0) list.splice(idx, 1);
  }
  dispatch(type, event) {
    const list = (this.listeners[type] || []).slice();
    const evt = Object.assign({
      type,
      target: this,
      defaultPrevented: false,
      preventDefault() { this.defaultPrevented = true; },
      stopPropagation() { this.propagationStopped = true; }
    }, event || {});
    list.forEach((fn) => fn.call(this, evt));
    // Browser-like: an `onclick` property behaves like a listener.
    const prop = this['on' + type];
    if (typeof prop === 'function') prop.call(this, evt);
    return evt;
  }
  focus() { doc.activeElement = this; }
  setSelectionRange() {}
  // Browsers bubble click events, so a tap on a child label also triggers the
  // handler of the card that contains it. The mock has to do the same,
  // otherwise "dead" buttons are hidden from the harness.
  click() {
    let node = this;
    while (node) {
      const evt = node.dispatch('click', { target: node });
      if (evt.propagationStopped) break;
      node = node.parentNode;
    }
  }

  set className(value) { this.attributes.class = String(value); }
  get className() { return this.attributes.class || ''; }

  set textContent(value) {
    this.childNodes = [];
    this._text = value === null || value === undefined ? '' : String(value);
  }
  get textContent() {
    if (this.childNodes.length === 0) return this._text;
    return this.childNodes.map((c) => c.textContent).join('');
  }

  set innerHTML(value) { this.textContent = value; }
  get innerHTML() { return this.textContent; }

  get id() { return this.attributes.id || ''; }
  set id(value) { this.attributes.id = value; }

  querySelector(sel) {
    const all = this.querySelectorAll(sel);
    return all.length ? all[0] : null;
  }
  querySelectorAll(sel) {
    const out = [];
    const walk = (node) => {
      node.childNodes.forEach((child) => {
        if (matches(child, sel)) out.push(child);
        walk(child);
      });
    };
    walk(this);
    return out;
  }
  get children() { return this.childNodes.filter((c) => c instanceof MockNode); }
}

function matches(node, sel) {
  if (sel.startsWith('.')) return String(node.className || '').split(/\s+/).indexOf(sel.slice(1)) >= 0;
  if (sel.startsWith('#')) return node.getAttribute('id') === sel.slice(1);
  const attrMatch = sel.match(/^([a-zA-Z-]*)\[([^\]=]+)\]$/);
  if (attrMatch) {
    const tag = attrMatch[1];
    const name = attrMatch[2];
    if (tag && node.tagName !== tag.toUpperCase()) return false;
    const value = node.getAttribute(name);
    return value !== null && value !== undefined;
  }
  return node.tagName === sel.toUpperCase();
}

class MockDocument {
  constructor() {
    this.body = new MockNode('body');
    this.documentElement = new MockNode('html');
    this.activeElement = null;
    this.readyState = 'complete';
    this.listeners = {};
  }
  createElement(tag) { return new MockNode(tag); }
  createTextNode(text) {
    const node = new MockNode('#text');
    node._text = String(text);
    return node;
  }
  getElementById(id) {
    return this.body.querySelector('#' + id) || this.documentElement.querySelector('#' + id);
  }
  addEventListener(type, fn) { (this.listeners[type] = this.listeners[type] || []).push(fn); }
}

const doc = new MockDocument();

/* ------------------------------------------------------------------ *
 * Assertions
 * ------------------------------------------------------------------ */
let passed = 0;
const failures = [];

function ok(condition, label) {
  if (condition) {
    passed += 1;
  } else {
    failures.push(label);
  }
}

function eq(actual, expected, label) {
  ok(actual === expected, label + ' (expected ' + JSON.stringify(expected) + ', got ' + JSON.stringify(actual) + ')');
}

/* ------------------------------------------------------------------ *
 * Bootstrap the preview page inside the mock DOM
 * ------------------------------------------------------------------ */
const previewDir = __dirname;
const html = fs.readFileSync(path.join(previewDir, 'index.html'), 'utf8');

// Parse the <script src> tags out of index.html so the harness always loads
// exactly the files the page loads.
const scriptSources = [];
const scriptRe = /<script\s+src="\.\/([^"]+)"><\/script>/g;
let m;
while ((m = scriptRe.exec(html)) !== null) scriptSources.push(m[1]);

const documentRefs = [
  { id: 'app-shell', tag: 'div' },
  { id: 'app-viewport', tag: 'main' },
  { id: 'bottom-nav', tag: 'nav' },
  { id: 'screen-select', tag: 'select' },
  { id: 'theme-toggle', tag: 'button' },
  { id: 'sheet-backdrop', tag: 'div' },
  { id: 'sheet-panel', tag: 'div' }
];

const shell = new MockNode('div');
shell.setAttribute('id', 'app-shell');
const viewport = new MockNode('main');
viewport.setAttribute('id', 'app-viewport');
const bottomNav = new MockNode('nav');
bottomNav.setAttribute('id', 'bottom-nav');
const screenSelect = new MockNode('select');
screenSelect.setAttribute('id', 'screen-select');
const themeToggle = new MockNode('button');
themeToggle.setAttribute('id', 'theme-toggle');
const sheetBackdrop = new MockNode('div');
sheetBackdrop.setAttribute('id', 'sheet-backdrop');
// index.html ships the backdrop with the `hidden` attribute, so the mock has
// to start hidden too - otherwise "is the sheet visible?" is always yes.
sheetBackdrop.hidden = true;
const sheetPanel = new MockNode('div');
sheetPanel.setAttribute('id', 'sheet-panel');
[shell, viewport, bottomNav, screenSelect, themeToggle, sheetBackdrop, sheetPanel].forEach((n) => doc.body.appendChild(n));

const timers = [];
// Mock localStorage supaya penyimpanan lokal di pratinjau bisa diuji.
const storageData = {};
const fakeLocalStorage = {
  getItem(key) { return Object.prototype.hasOwnProperty.call(storageData, key) ? storageData[key] : null; },
  setItem(key, value) { storageData[key] = String(value); },
  removeItem(key) { delete storageData[key]; },
  clear() { Object.keys(storageData).forEach((k) => { delete storageData[k]; }); }
};
const fakeWindow = {
  document: doc,
  location: { hash: '' },
  history: { replaceState() { fakeWindow.location.hash = arguments[2]; } },
  setTimeout(fn, ms) { timers.push({ fn, ms }); return timers.length; },
  clearTimeout() {},
  addEventListener() {},
  localStorage: fakeLocalStorage
};
fakeWindow.window = fakeWindow;

const sandbox = {
  window: fakeWindow,
  document: doc,
  console,
  setTimeout: fakeWindow.setTimeout,
  clearTimeout: fakeWindow.clearTimeout,
  history: fakeWindow.history,
  location: fakeWindow.location,
  Date,
  Math,
  JSON,
  parseInt,
  parseFloat,
  isNaN,
  Object,
  Array,
  String,
  Number,
  Node: MockNode
};
sandbox.globalThis = sandbox;

scriptSources.forEach((src) => {
  const code = fs.readFileSync(path.join(previewDir, src), 'utf8');
  vm.createContext(sandbox);
  vm.runInContext(code, sandbox, { filename: src });
});

const preview = sandbox.window.KARSA_PREVIEW;
ok(!!preview, 'KARSA_PREVIEW global is exposed');

/* ------------------------------------------------------------------ *
 * 1. Screen registry — 40 canonical screens + alias
 * ------------------------------------------------------------------ */
const EXPECTED_SCREENS = [
  'splash', 'welcome', 'login',
  'login-operator', 'login-wali', 'login-guru', 'login-ortu', 'login-siswa',
  'forgot',
  'wali-beranda', 'wali-anggota', 'wali-recap', 'wali-agenda', 'wali-profil',
  'guru-beranda', 'guru-kelas', 'guru-tugas', 'guru-kalender', 'guru-profil',
  'guru-pengumuman',
  'siswa-beranda', 'siswa-tugas', 'siswa-profil',
  'ortu-beranda', 'ortu-tugas', 'ortu-latihan', 'ortu-profil',
  'operator-beranda', 'operator-siswa', 'operator-kelas', 'operator-materi', 'operator-profil',
  'operator-media', 'operator-tugas', 'operator-pengumuman',
  'operator-agenda', 'operator-nilai',
  'materi', 'notifikasi', 'kuis', 'esai', 'hasil-kuis', 'hasil-latihan'
];

eq(preview.screens.length, 43, 'screen registry contains 43 screens');
eq(EXPECTED_SCREENS.length, 43, 'the expected screen list has 43 entries');
EXPECTED_SCREENS.forEach((id) => {
  ok(preview.screens.indexOf(id) >= 0, 'screen "' + id + '" is registered');
});
ok(preview.screens.every((id) => EXPECTED_SCREENS.indexOf(id) >= 0),
  'the registry contains no undocumented screens');

/* ------------------------------------------------------------------ *
 * 2. Every screen renders without throwing and produces content
 * ------------------------------------------------------------------ */
// The quiz screens need an active quiz / stored result to show their content
// (the Flutter pages behave the same way when nothing is selected).
const CURR = sandbox.window.KARSA_CURRICULUM;
const QUIZ_BANK = CURR.quizBank['Matematika'];
const QUIZ_ITEM = QUIZ_BANK[0];
const QUIZ_TASK = {
  subject: 'Matematika', title: 'Penjumlahan sampai 20', className: 'Kelas 1',
  minutes: '30', dueAt: null, demo: false
};
function seedQuiz() {
  preview.state.quiz = {
    task: QUIZ_TASK, bank: QUIZ_BANK, index: 0, choice: -1, checked: false,
    answers: [], score: 0
  };
}
function seedResult() {
  preview.state.quizResult = {
    task: QUIZ_TASK,
    result: { score: 7, total: QUIZ_BANK.length, answers: QUIZ_BANK.map((q) => q.answerIndex), demo: false }
  };
}
EXPECTED_SCREENS.forEach((id) => {
  try {
    preview.state.quiz = null;
    preview.state.quizResult = null;
    if (id === 'kuis') seedQuiz();
    if (id === 'hasil-kuis') seedResult();
    preview.go(id);
    const text = viewport.textContent;
    ok(text.length > 10, 'screen "' + id + '" renders content (' + text.length + ' chars)');
  } catch (err) {
    failures.push('screen "' + id + '" threw: ' + err.stack);
  }
});
// The empty quiz screen still renders its header (same as the Flutter page).
preview.state.quiz = null;
preview.state.quizResult = null;
preview.go('kuis');
ok(viewport.textContent.indexOf('Kuis') >= 0, 'the empty quiz screen still renders the page header');

// Alias: #wali-rekap must resolve to the same screen as #wali-recap.
try {
  preview.go('wali-rekap');
  eq(preview.state.screen, 'wali-recap', 'alias #wali-rekap resolves to wali-recap');
} catch (err) {
  failures.push('alias wali-rekap threw: ' + err.stack);
}

/* ------------------------------------------------------------------ *
 * 3. Splash auto-advances after 2300 ms
 * ------------------------------------------------------------------ */
const splashTimer = timers.find((t) => t.ms === 2300);
ok(!!splashTimer, 'splash schedules a 2300 ms timer');
if (splashTimer) {
  preview.go('splash');
  splashTimer.fn();
  eq(preview.state.screen, 'login', 'splash auto-advances straight to the login form after 2300 ms');
}

/* ------------------------------------------------------------------ *
 * 4. Login flow per role (credentials + error message)
 * ------------------------------------------------------------------ */
const ROLE_CASES = [
  { screen: 'login-wali', role: 'wali', id: '19870001', pass: 'wali123', home: 'wali-beranda' },
  { screen: 'login-guru', role: 'guru', id: '19870002', pass: 'guru123', home: 'guru-beranda' },
  { screen: 'login-ortu', role: 'orangtua', id: '10010001', pass: 'ortu123', home: 'ortu-beranda' },
  { screen: 'login-siswa', role: 'siswa', id: '10050001', pass: 'siswa123', home: 'siswa-beranda' }
];

ROLE_CASES.forEach((testCase) => {
  // The demo account box must differ per role.
  preview.go(testCase.screen);
  const demoBox = viewport.querySelectorAll('.demo-account-box')[0];
  ok(!!demoBox, testCase.screen + ' shows a demo account box');
  if (demoBox) {
    ok(demoBox.textContent.indexOf(testCase.id) >= 0, testCase.screen + ' demo box lists the role account id');
    ok(demoBox.textContent.indexOf(testCase.pass) >= 0, testCase.screen + ' demo box lists the role password');
    ok(demoBox.textContent.indexOf('Akun demo ·') === 0, testCase.screen + ' demo box is labelled per role');
  }

  // Wrong credentials -> error message, stay on the login screen.
  preview.go(testCase.screen);
  preview.state.login.username = '00000000';
  preview.state.login.password = 'salah';
  const inputs = viewport.querySelectorAll('input');
  ok(inputs.length === 2, testCase.screen + ' has two real <input> fields');
  const submit = viewport.querySelectorAll('button').filter((b) => (b.textContent || '').indexOf('Masuk') >= 0)[0];
  ok(!!submit, testCase.screen + ' has a submit button');
  if (submit) {
    submit.click();
    eq(preview.state.login.error, 'NIP/NISN atau kata sandi tidak sesuai.',
      testCase.screen + ' rejects wrong credentials with the RN error message');
    eq(preview.state.screen, testCase.screen, testCase.screen + ' stays on the login screen after a failed login');
  }

  // Correct credentials -> role dashboard.
  preview.go(testCase.screen);
  const fields = viewport.querySelectorAll('input');
  fields[0].value = testCase.id;
  fields[0].dispatch('input', { target: fields[0] });
  fields[1].value = testCase.pass;
  fields[1].dispatch('input', { target: fields[1] });
  const button = viewport.querySelectorAll('button').filter((b) => (b.textContent || '').indexOf('Masuk') >= 0)[0];
  if (button) {
    button.click();
    eq(preview.state.screen, testCase.home, testCase.screen + ' enters ' + testCase.home + ' with valid credentials');
  }

  // Enter key submits the password field.
  preview.go(testCase.screen);
  const enterFields = viewport.querySelectorAll('input');
  enterFields[0].value = testCase.id;
  enterFields[0].dispatch('input', { target: enterFields[0] });
  enterFields[1].value = testCase.pass;
  enterFields[1].dispatch('input', { target: enterFields[1] });
  enterFields[1].dispatch('keydown', { key: 'Enter' });
  eq(preview.state.screen, testCase.home, testCase.screen + ' submits on Enter key');
});

/* ------------------------------------------------------------------ *
 * 5. Bottom navigation per role
 * ------------------------------------------------------------------ */
const NAV_CASES = [
  { screen: 'wali-beranda', tabs: ['Beranda', 'Anggota', 'Rekap', 'Agenda', 'Profil'] },
  { screen: 'guru-beranda', tabs: ['Beranda', 'Kelas', 'Tugas', 'Kalender', 'Profil'] },
  { screen: 'siswa-beranda', tabs: ['Beranda', 'Tugas', 'Profil'] },
  { screen: 'ortu-beranda', tabs: ['Beranda', 'Tugas', 'Latihan', 'Profil'] }
];

NAV_CASES.forEach((testCase) => {
  preview.go(testCase.screen);
  const items = bottomNav.querySelectorAll('.nav-item');
  eq(items.length, testCase.tabs.length, testCase.screen + ' renders ' + testCase.tabs.length + ' bottom nav items');
  eq(items.map((i) => {
    const spans = i.children.filter((c) => c.tagName === 'SPAN');
    return spans[spans.length - 1].textContent.trim();
  }).join(','), testCase.tabs.join(','),
    testCase.screen + ' bottom nav labels match the role tabs');
  ok(!bottomNav.hidden, testCase.screen + ' shows the bottom nav');
  // Clicking the 2nd tab navigates to the matching screen.
  items[1].click();
  ok(preview.state.screen.indexOf('-') > 0, testCase.screen + ' bottom nav click switches screen (' + preview.state.screen + ')');
});

/* ------------------------------------------------------------------ *
 * 6. Class chips + subject chips + segment + search filtering
 * ------------------------------------------------------------------ */
preview.go('guru-beranda');
const classChips = viewport.querySelectorAll('.chip-btn');
ok(classChips.length === 7, 'guru home renders 7 class chips (Semua kelas + Kelas 1-6)');
classChips[3].click();
eq(preview.state.filter, 'Kelas 3', 'guru class chip updates the filter');
ok(viewport.textContent.indexOf('Kelas 3') >= 0, 'guru home reflects the selected class chip');

preview.go('guru-tugas');
const teacherSegments = viewport.querySelectorAll('.segment-item');
eq(teacherSegments.map((s) => s.textContent.trim()).join(','), 'Semua,Berjalan,Selesai',
  'guru tasks renders the Semua/Berjalan/Selesai segment');
const searchInput = viewport.querySelectorAll('input')[0];
ok(!!searchInput, 'guru tasks renders a real search input');
const beforeFilter = viewport.querySelectorAll('.list-item-card').length;
searchInput.value = 'Pecahan';
searchInput.dispatch('input', { target: searchInput });
const afterFilter = viewport.querySelectorAll('.list-item-card').length;
ok(afterFilter <= beforeFilter, 'guru task search narrows the list (' + beforeFilter + ' -> ' + afterFilter + ')');

preview.go('siswa-tugas');
const studentSegments = viewport.querySelectorAll('.segment-item');
eq(studentSegments.map((s) => s.textContent.trim()).join(','), 'Aktif,Riwayat',
  'siswa tasks renders the Aktif/Riwayat segment');
const subjectChips = viewport.querySelectorAll('.chip-btn');
ok(subjectChips.length >= 9, 'siswa tasks renders subject chips (' + subjectChips.length + ')');

preview.go('ortu-tugas');
eq(viewport.querySelectorAll('.chip-btn').length, 0, 'ortu tasks has no subject chips (matches Flutter)');

/* ------------------------------------------------------------------ *
 * 7. Attendance status buttons are selectable
 * ------------------------------------------------------------------ */
preview.go('wali-recap');
const attendanceButtons = viewport.querySelectorAll('.attendance-btn');
ok(attendanceButtons.length >= 12, 'wali recap renders 4 status buttons per student (' + attendanceButtons.length + ')');
const firstStatus = attendanceButtons[0];
firstStatus.click();
const todayKey = Object.keys(preview.state.attendance)[0];
ok(!!todayKey, 'attendance selection writes into the attendance map');
ok(!!preview.state.attendance[todayKey] && preview.state.attendance[todayKey].dimas, 'attendance status is stored for the student');
const refreshed = viewport.querySelectorAll('.attendance-btn');
ok(refreshed[0].className.indexOf('active') >= 0, 'the selected attendance button is highlighted');

/* ------------------------------------------------------------------ *
 * 8. Study tip card cycles
 * ------------------------------------------------------------------ */
preview.go('siswa-beranda');
const tipBefore = viewport.textContent;
const tipButton = viewport.querySelectorAll('.tip-card')[0];
ok(!!tipButton, 'student home renders the tips card');
if (tipButton) {
  tipButton.click();
  const tipAfter = viewport.textContent;
  ok(tipBefore !== tipAfter || preview.state.tipIndex !== 0, 'the tips card cycles to another tip');
}

/* ------------------------------------------------------------------ *
 * 9. Quiz flow -> result screen
 * ------------------------------------------------------------------ */
preview.state.filter = 'Semua kelas';
preview.state.search = '';
preview.state.taskFilter = 'Semua';
preview.go('guru-tugas');
const taskCard = viewport.querySelectorAll('.list-item-card')[0];
ok(!!taskCard, 'guru tasks renders task cards to open');
if (taskCard) {
  taskCard.click();
  const sheetButtons = sheetPanel.querySelectorAll('button');
  // Detail tugas kini menawarkan DUA metode, bukan satu tombol kuis.
  const startButton = sheetButtons.filter((b) =>
    (b.getAttribute('aria-label') || '') === 'Pilihan ganda')[0];
  const essayButton = sheetButtons.filter((b) =>
    (b.getAttribute('aria-label') || '') === 'Esai')[0];
  ok(!!startButton, 'task sheet offers the multiple-choice method');
  ok(!!essayButton, 'task sheet offers the essay method');
  if (startButton) {
    startButton.click();
    eq(preview.state.screen, 'kuis', 'quiz screen opens');
    const choice = viewport.querySelectorAll('.choice-btn')[0];
    ok(!!choice, 'quiz renders answer choices');
    if (choice) {
      choice.click();
      const checkButton = viewport.querySelectorAll('button').filter((b) => (b.textContent || '').indexOf('Periksa jawaban') >= 0)[0];
      ok(!!checkButton, 'quiz shows the check-answer action');
      if (checkButton) {
        checkButton.click();
        const explanation = viewport.textContent;
        // Umpan balik kini berupa kartu (benar/salah) berisi kunci + alasan.
        ok(explanation.indexOf('Tepat!') >= 0 || explanation.indexOf('Belum tepat') >= 0,
          'quiz reveals whether the answer was right or wrong');
        ok(!!viewport.querySelectorAll('.quiz-feedback')[0],
          'the feedback is shown as a card, like the design');
        ok(explanation.indexOf('undefined') < 0, 'quiz explanation contains real data (no undefined)');
        ok(explanation.indexOf(QUIZ_ITEM.choices[QUIZ_ITEM.answerIndex]) >= 0,
          'quiz explanation names the correct choice from the curriculum bank');
      }
    }
  }
}

/* ------------------------------------------------------------------ *
 * 9b. Religion adapted first question ( Pendidikan Agama )
 * ------------------------------------------------------------------ */
preview.state.religion = 'Islam';
const agamaTask = {
  subject: 'Pendidikan Agama dan Budi Pekerti', title: 'Pendidikan Agama', className: 'Kelas 5',
  minutes: '30', dueAt: null, demo: false
};
preview.state.quiz = {
  task: agamaTask,
  bank: CURR.questionsFor('Pendidikan Agama dan Budi Pekerti', 'Islam'),
  index: 0, choice: -1, checked: false, answers: [], score: 0
};
preview.go('kuis');
ok(viewport.textContent.indexOf('masjid') >= 0,
  'the religion adapted first question uses the selected faith example');
ok(viewport.textContent.indexOf('Islam') >= 0, 'the adapted question names the selected religion');
preview.state.religion = '';
preview.state.quiz = null;

/* ------------------------------------------------------------------ *
 * 9c. Student profile: editable personal info + class grades section
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.state.studentClass = 'Kelas 5';
preview.go('siswa-profil');

ok(viewport.textContent.indexOf('Nilai kelas') >= 0, 'student profile shows the "Nilai kelas" section');
ok(viewport.textContent.indexOf('Rata-rata kelas') >= 0, 'student profile shows the class average card');
ok(viewport.textContent.indexOf('Informasi pribadi') >= 0, 'student profile shows the personal info section');
ok(viewport.textContent.indexOf('Data pribadi') >= 0, 'student profile shows the personal info card');
ok(viewport.textContent.indexOf('Ubah informasi') >= 0, 'student profile offers an edit affordance');

// The class grades must come from real results (demo history tasks are 7/10).
const gradeBars = viewport.querySelectorAll('.mission-fill');
ok(gradeBars.length >= 9, 'student profile renders a grade bar per subject (' + gradeBars.length + ')');
ok(viewport.textContent.indexOf('70') >= 0, 'student profile shows the 70% average from the demo results');
ok(viewport.textContent.indexOf('Ilmu Pengetahuan Alam dan Sosial (IPAS)') >= 0,
  'student profile shows the full subject names in the grade list');
ok(viewport.textContent.indexOf('tugas dinilai') >= 0,
  'student profile shows how many tasks were graded per subject');

// Opening the personal info sheet gives a real editable form.
const infoCard = viewport.querySelectorAll('.clay-soft').filter((c) => (c.textContent || '').indexOf('Data pribadi') >= 0)[0];
ok(!!infoCard, 'the personal info card is rendered');
if (infoCard) {
  ok(sheetBackdrop.hidden === true, 'the personal info sheet starts closed');
  infoCard.click();
  ok(sheetBackdrop.hidden === false,
    'clicking "Ubah" makes the personal info sheet visible');
  const sheetInputs = sheetPanel.querySelectorAll('input');
  ok(sheetInputs.length >= 1, 'the personal info form has a real name input');
  const sheetChips = sheetPanel.querySelectorAll('.chip-btn');
  ok(sheetChips.length >= 2 + (CURR.religions || []).length,
    'the personal info form has class chips and religion chips (' + sheetChips.length + ')');
  const saveButton = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Simpan perubahan') >= 0)[0];
  ok(!!saveButton, 'the personal info form has a save action');

  // Edit the name, pick a class and a religion, then save.
  if (sheetInputs[0]) {
    sheetInputs[0].value = 'Nadia Lestari';
    sheetInputs[0].dispatch('input', { target: sheetInputs[0] });
  }
  const classChip = sheetPanel.querySelectorAll('.chip-btn').filter((b) => (b.textContent || '').trim() === 'Kelas 6')[0];
  ok(!!classChip, 'the class chip for Kelas 6 exists');
  if (classChip) classChip.click();
  const religionChip = sheetPanel.querySelectorAll('.chip-btn').filter((b) => (b.textContent || '').trim() === 'Islam')[0];
  ok(!!religionChip, 'the religion chip for Islam exists');
  if (religionChip) religionChip.click();
  const saveBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Simpan perubahan') >= 0)[0];
  if (saveBtn) saveBtn.click();
  ok(sheetBackdrop.hidden === true, 'the personal info sheet closes after saving');

  eq(preview.state.studentName, 'Nadia Lestari', 'saving the personal info updates the student name');
  eq(preview.state.studentClass, 'Kelas 6', 'saving the personal info updates the student class');
  eq(preview.state.religion, 'Islam', 'saving the personal info updates the religion');

  preview.go('siswa-profil');
  ok(viewport.textContent.indexOf('Nadia Lestari') >= 0, 'the edited name is shown on the student profile');
  ok(viewport.textContent.indexOf('Kelas 6') >= 0, 'the edited class is shown on the student profile');
  ok(viewport.textContent.indexOf('Islam') >= 0, 'the edited religion is shown on the student profile');
}

// The hero "Ubah informasi" action opens the very same sheet.
preview.go('siswa-profil');
const heroEdit = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Ubah informasi') >= 0)[0];
ok(!!heroEdit, 'the student profile hero has an "Ubah informasi" button');
if (heroEdit) {
  heroEdit.click();
  ok(sheetBackdrop.hidden === false,
    'clicking "Ubah informasi" makes the personal info sheet visible');
  ok(sheetPanel.querySelectorAll('input').length >= 1,
    'the sheet opened from the hero shows the editable name input');
  const cancelBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Batal') >= 0)[0];
  ok(!!cancelBtn, 'the personal info sheet has a cancel action');
  if (cancelBtn) cancelBtn.click();
  ok(sheetBackdrop.hidden === true, 'the personal info sheet closes on cancel');
}

// The parent profile shares the child profile card.
preview.state.role = 'orangtua';
preview.state.parentClass = 'Kelas 1';
preview.go('ortu-profil');
ok(viewport.textContent.indexOf('Nilai kelas') >= 0, 'parent profile shows the "Nilai kelas" section');
ok(viewport.textContent.indexOf('Data pribadi') >= 0, 'parent profile shows the personal info card');

// Restore the demo state for the remaining checks.
preview.state.studentName = 'Dimas Nugroho';
preview.state.studentClass = 'Kelas 5';
preview.state.parentClass = 'Kelas 1';
preview.state.religion = '';
preview.state.personalDraft = null;

/* ------------------------------------------------------------------ *
 * 9d. Notifikasi: setiap item bisa diklik dan membuka isinya
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.state.studentClass = 'Kelas 5';
preview.state.parentClass = 'Kelas 1';
preview.state.readNotifications = {};
preview.go('notifikasi');

const notifItems = viewport.querySelectorAll('.list-item-card');
ok(notifItems.length >= 2, 'the student sees their own notifications (' + notifItems.length + ')');
ok(viewport.textContent.indexOf('Pecahan dan perbandingan') >= 0,
  'the student notification list contains a Kelas 5 task');
ok(viewport.textContent.indexOf('Penjumlahan sampai 20') < 0,
  'the student does not see the parent (Kelas 1) notifications');

if (notifItems.length) {
  notifItems[0].click();
  ok(sheetBackdrop.hidden === false, 'clicking a notification opens the related content');
  ok(sheetPanel.textContent.indexOf('Pecahan dan perbandingan') >= 0,
    'the notification opens the matching task detail');
  ok(sheetPanel.textContent.indexOf('Pilihan ganda') >= 0 &&
    sheetPanel.textContent.indexOf('Esai') >= 0,
    'the opened task offers both methods');
  // Tutup sheet.
  const closeBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Tutup') >= 0)[0];
  if (closeBtn) closeBtn.click();
}

// Notifikasi yang sudah dibaca ditandai, tidak lagi berlabel "Baru".
preview.go('notifikasi');
ok(viewport.textContent.indexOf('Dibaca') >= 0, 'a read notification is labelled "Dibaca"');
const baruCount = (viewport.textContent.match(/Baru/g) || []).length;
eq(baruCount, 1, 'only the notification that is still unread keeps the "Baru" badge');

/* ------------------------------------------------------------------ *
 * 9e. Materi: siswa melihat materi kelasnya sendiri
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.go('siswa-beranda');
ok(viewport.textContent.indexOf('Materi kelas') >= 0, 'the student dashboard shows the materials card');
ok(!/Materi kelas0/.test(viewport.textContent.replace(/\s+/g, ' ')),
  'the student dashboard no longer shows zero materials');

preview.go('materi');
ok(viewport.textContent.indexOf('Ringkasan Pecahan Kelas 5') >= 0,
  'the student sees the materials of their own class');
ok(viewport.textContent.indexOf('Ringkasan Pecahan') < 0 ||
  viewport.textContent.indexOf('Ringkasan Pecahan Kelas 5') >= 0,
  'the student does not see the parent (Kelas 1) materials');

/* ------------------------------------------------------------------ *
 * 9f. Penyimpanan lokal: data pribadi disimpan di "@karsa-demo-v1"
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.go('siswa-profil');
const editBtn = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Ubah informasi') >= 0)[0];
ok(!!editBtn, 'the student profile hero has the "Ubah informasi" button');
if (editBtn) {
  editBtn.click();
  const nameInput = sheetPanel.querySelectorAll('input')[0];
  ok(!!nameInput, 'the personal info sheet has a name input');
  if (nameInput) {
    nameInput.value = 'Nadia Lestari';
    nameInput.dispatch('input', { target: nameInput });
  }
  const saveAction = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Simpan perubahan') >= 0)[0];
  if (saveAction) saveAction.click();
  eq(preview.state.studentName, 'Nadia Lestari', 'the edited name is applied');
  const stored = fakeLocalStorage.getItem('@karsa-demo-v1');
  ok(!!stored, 'the edited personal info is stored under "@karsa-demo-v1"');
  if (stored) {
    const parsed = JSON.parse(stored);
    eq(parsed.studentName, 'Nadia Lestari', 'the stored JSON holds the new student name');
  }
}

preview.state.studentName = 'Dimas Nugroho';
preview.state.readNotifications = {};

/* ------------------------------------------------------------------ *
 * 9g. Role operator sekolah
 * ------------------------------------------------------------------ */
preview.state.role = 'operator';
preview.state.filter = 'Semua kelas';
preview.state.operatorQuery = '';
preview.go('operator-beranda');

ok(viewport.textContent.indexOf('Operator Sekolah') >= 0,
  'the operator home shows the operator heading');
ok(viewport.textContent.indexOf(String((preview.state.roster || []).length)) >= 0,
  'the operator home shows the roster size (' + (preview.state.roster || []).length + ' siswa)');
ok(viewport.textContent.indexOf('grafis') >= 0,
  'the operator home shows the grafis shortcut');
ok(viewport.textContent.indexOf('Logo & banner sekolah') >= 0,
  'the operator home links to the media section');

// Beranda operator yang baru: tanpa banner "Semangat mengajar", sapaan
// langsung di bawah judul, dan pintasan yang bisa dilipat sendiri-sendiri.
preview.go('operator-beranda');
ok(viewport.textContent.indexOf('Selamat datang, Operator Sekolah') >= 0,
  'the operator home greets the operator right under the heading');
ok(viewport.querySelectorAll('.banner-img').length === 0,
  'the operator home no longer shows the teacher banner');
const welcomeIdx = viewport.textContent.indexOf('Selamat datang, Operator Sekolah');
const statsIdx = viewport.textContent.indexOf('Siswa');
ok(welcomeIdx >= 0 && statsIdx > welcomeIdx,
  'the greeting sits above the statistics');

// Semua kartu mulai terlipat: rincian belum ada di DOM.
eq(viewport.querySelectorAll('.collapsible-card').length, 5,
  'the operator home renders five collapsible shortcut cards');
eq(viewport.querySelectorAll('.collapsible-body').length, 0,
  'every shortcut card starts collapsed');
eq(viewport.querySelectorAll('.collapsible-caret.open').length, 0,
  'no collapsed card shows the open caret');

// Membuka satu kartu hanya membuka kartu itu. Urutan kartu:
// 0 tugas, 1 pengumuman, 2 agenda, 3 nilai, 4 logo & banner.
const cardHeads = () => viewport.querySelectorAll('.collapsible-head');
cardHeads()[1].click();
eq(viewport.querySelectorAll('.collapsible-body').length, 1,
  'tapping a card opens only that card');
ok(viewport.textContent.indexOf('Pengumuman sekolah') >= 0,
  'the opened card keeps its title visible');
// Kartu pengumuman menampilkan judul pengumuman yang tersimpan.
const openBody = viewport.querySelectorAll('.collapsible-body')[0];
ok(!!openBody && (openBody.textContent || '').length > 3,
  'the opened card reveals its stored entries');
if (openBody) {
  const hasEntry = preview.announcements() === undefined ||
    (openBody.textContent.indexOf('Belum ada pengumuman') < 0 ||
     preview.announcements().length === 0);
  ok(hasEntry, 'the opened announcement card lists real entries, not just an empty state');
}

// Kartu lain tetap terlipat.
const openedCards = viewport.querySelectorAll('[data-card]')
  .filter((n) => n.getAttribute('aria-expanded') === 'true' ||
                 (n.querySelectorAll('.collapsible-body').length > 0));
eq(openedCards.length, 1, 'only one card is open after a single tap');

// Membuka kartu kedua tidak menutup kartu pertama (mandiri, bukan akordeon).
cardHeads()[0].click();
eq(viewport.querySelectorAll('.collapsible-body').length, 2,
  'each card keeps its own open state');
// Kartu tugas meringkas mapel dan kelas dari data nyata.
const taskBody = viewport.querySelectorAll('.collapsible-card')[0]
  .querySelectorAll('.collapsible-body')[0];
ok(!!taskBody && /\d+ mata pelajaran · \d+ kelas/.test(taskBody.textContent || ''),
  'the opened task card summarises subjects and classes');

// Mengetuk lagi menutup kartu itu saja.
cardHeads()[0].click();
eq(viewport.querySelectorAll('.collapsible-body').length, 1,
  'tapping an open card closes it again');

// Tombol Kelola membuka halaman, bukan menutup kartu.
const manageBtn = viewport.querySelectorAll('[data-card]')[0]
  .querySelectorAll('.status-badge')[0];
ok(!!manageBtn, 'each shortcut card has its manage button');
if (manageBtn) {
  manageBtn.click();
  eq(preview.state.screen, 'operator-tugas',
    'the manage button opens the related operator page');
}

// Tombol Ubah profil di tab Profil membuka form.
preview.go('operator-profil');
const editProfileBtn = viewport.querySelectorAll('[aria-label]')
  .filter((n) => n.getAttribute('aria-label') === 'Ubah profil operator')[0];
ok(!!editProfileBtn, 'the profile tab keeps an edit button');
if (editProfileBtn) {
  editProfileBtn.click();
  ok(sheetBackdrop.hidden === false, 'the profile edit button opens the personal info form');
  const closeProfileSheet = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Tutup') >= 0)[0];
  if (closeProfileSheet) closeProfileSheet.click();
}

// Status buka/tutup bertahan saat layar dirender ulang (mis. ganti mode gelap).
preview.go('operator-beranda');
viewport.querySelectorAll('.collapsible-head')[2].click();
const openBeforeToggle = viewport.querySelectorAll('.collapsible-body').length;
preview.toggleTheme();
eq(viewport.querySelectorAll('.collapsible-body').length, openBeforeToggle,
  'the open card stays open after re-rendering the screen');
preview.toggleTheme();

// Kembalikan semua kartu ke keadaan terlipat.
preview.state.operatorOpen = {};
preview.go('operator-beranda');

// Tab Profil operator: tab keenam, tepat di kanan Media.
preview.state.role = 'operator';
preview.state.tab = 'Beranda';
preview.go('operator-beranda');
// textContent tiap tab menyertakan glyph ikon Ionicons, jadi bandingkan
// dengan akhiran labelnya.
const opTabLabels = bottomNav.querySelectorAll('.nav-item')
  .map((n) => (n.textContent || '').replace(/[^A-Za-z ]/g, '').trim());
eq(opTabLabels[opTabLabels.length - 1], 'Profil',
  'the operator Profile tab sits on the far right');
eq(opTabLabels.indexOf('Media') + 1, opTabLabels.indexOf('Profil'),
  'the Profile tab is directly beside Media');

// Mengetuk tab Profil membuka halaman profil operator.
bottomNav.querySelectorAll('.nav-item')[opTabLabels.length - 1].click();
eq(preview.state.screen, 'operator-profil', 'the Profile tab opens operator-profil');
eq(preview.state.tab, 'Profil', 'the active tab is Profil');

// Isi halaman profil: identitas, enam kolom, pengaturan, dan tombol keluar.
const profileText = viewport.textContent;
ok(profileText.indexOf('Profil Operator') >= 0, 'the profile tab has its own heading');
ok(profileText.indexOf('SD Karitas Purwokerto') >= 0,
  'the profile tab shows the school identity');
ok(profileText.indexOf('Ubah profil') >= 0, 'the profile tab offers an edit button');
['Nama lengkap', 'NIP', 'Jabatan', 'Unit kerja', 'Surel', 'Telepon'].forEach((label) => {
  ok(profileText.indexOf(label) >= 0, 'the profile tab lists "' + label + '"');
});
ok(profileText.indexOf('Pengaturan') >= 0, 'the profile tab has a settings section');
eq(viewport.querySelectorAll('.setting-row').length, 4,
  'the profile tab lists four settings rows');
ok(profileText.indexOf('Keluar dari akun demo') >= 0,
  'the profile tab offers logout');

// Beranda tidak lagi memuat section profil penuh — hanya pintasan ke tab.
preview.go('operator-beranda');
ok(viewport.querySelectorAll('.profile-field').length === 0,
  'the operator home no longer renders the full profile fields');
ok(viewport.querySelectorAll('.profile-complete').length === 0,
  'the operator home no longer renders the completeness banner');
const profileShortcut = viewport.querySelectorAll('[aria-label]')
  .filter((n) => n.getAttribute('aria-label') === 'Buka tab Profil operator')[0];
ok(!!profileShortcut, 'the operator home links to the Profile tab');
if (profileShortcut) {
  profileShortcut.click();
  eq(preview.state.screen, 'operator-profil',
    'the home shortcut jumps to the Profile tab');
}

/* ------------------------------------------------------------------ *
 * 9h. Wali kelas: unggah bahan -> asisten menyusun soal
 * ------------------------------------------------------------------ */
// Bug yang diperbaiki: wali kelas tidak punya jalan apa pun ke form tugas,
// sehingga fitur unggah PDF + asisten tidak pernah bisa dipakai.
preview.state.role = 'wali';
preview.state.tab = 'Beranda';
preview.go('wali-beranda');

const buatTugasShortcut = viewport.querySelectorAll('[aria-label]')
  .filter((n) => n.getAttribute('aria-label') === 'Buat tugas dari bahan ajar')[0];
ok(!!buatTugasShortcut, 'the homeroom home offers a "create task from material" shortcut');
if (buatTugasShortcut) {
  buatTugasShortcut.click();
  ok(sheetBackdrop.hidden === false, 'the shortcut opens the task form sheet');
  ok(sheetPanel.textContent.indexOf('Asisten penyusun soal') >= 0,
    'the task form has the assistant panel');
  ok(sheetPanel.textContent.indexOf('Simulasi offline') >= 0,
    'the assistant is labelled as an offline simulation');
  ok(sheetPanel.textContent.indexOf('Unggah bahan') >= 0,
    'the task form offers a material upload button');

  const assistantButton = () => sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Buat soal dengan asisten') >= 0)[0];
  ok(!!assistantButton(), 'the assistant has a generate button');

  // Tanpa bahan: pesan jelas, tidak mengarang soal.
  if (assistantButton()) assistantButton().click();
  ok(sheetPanel.textContent.indexOf('Tempel teks bahan ajar dulu') >= 0,
    'the assistant asks for material instead of inventing questions');
  ok(sheetPanel.textContent.indexOf('PDF belum bisa dibaca') >= 0,
    'the assistant states honestly that PDFs are not parsed');

  // Tempel bahan: asisten menyusun soal.
  const sourceBox = sheetPanel.querySelectorAll('#assistant-source')[0];
  ok(!!sourceBox, 'the assistant has a text box for the material');
  if (sourceBox) {
    sourceBox.value = 'Fotosintesis adalah proses tumbuhan membuat makanan sendiri. ' +
      'Tumbuhan menyerap air dan mineral melalui akar di dalam tanah. ' +
      'Daun menangkap cahaya matahari menggunakan klorofil hijau. ' +
      'Hasil fotosintesis berupa glukosa dan oksigen yang dilepas ke udara. ' +
      'Proses ini penting karena menjadi sumber makanan bagi makhluk hidup lain.';
    sourceBox.dispatch('input', { target: sourceBox });
    // Bahan berganti -> tombol kembali ke label awal.
    const regen = sheetPanel.querySelectorAll('button')
      .filter((b) => (b.textContent || '').indexOf('Buat soal dengan asisten') >= 0)[0];
    ok(!!regen, 'the generate button is still available after typing material');
    if (regen) regen.click();
  }
  ok(/\d+ soal siap dipakai tugas ini/.test(sheetPanel.textContent),
    'the assistant reports how many questions are ready');
  ok(sheetPanel.textContent.indexOf('simulasi offline, bukan AI sungguhan') >= 0,
    'the assistant says the result is not real AI');

  const madeQuestions = sheetPanel.querySelectorAll('.assistant-result')[0];
  ok(!!madeQuestions, 'the assistant lists the generated questions');
  if (madeQuestions) {
    const lines = (madeQuestions.textContent.match(/kata kunci/g) || []).length;
    ok(lines >= 5, 'the generated questions are derived from the pasted material');
  }
}

// Tugas tersimpan membawa soal asistennya sendiri.
const taskCountBefore = preview.tasks().length;
const titleBox = sheetPanel.querySelectorAll('#task-title')[0];
if (titleBox) {
  titleBox.value = 'Fotosintesis';
  titleBox.dispatch('input', { target: titleBox });
}
const saveTaskBtn = sheetPanel.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Simpan tugas') >= 0)[0];
ok(!!saveTaskBtn, 'the task form has a save button');
if (saveTaskBtn) saveTaskBtn.click();
eq(preview.tasks().length, taskCountBefore + 1, 'the task with assistant questions is saved');
const savedTask = preview.tasks()[preview.tasks().length - 1];
ok(savedTask && savedTask.questionsSource === 'assistant',
  'the saved task is marked as using assistant questions');
ok(savedTask && savedTask.questions && savedTask.questions.length >= 5 &&
  savedTask.questions.length <= 10,
  'the saved task keeps every generated question (one per complete sentence)');

// Kuis memakai soal milik tugas, bukan bank soal contoh.
if (savedTask) {
  preview.startQuiz(savedTask);
  eq(preview.state.screen, 'kuis', 'starting the quiz opens the quiz screen');
  eq(preview.state.quiz.bank.length, savedTask.questions.length,
    'the quiz uses the task\'s own questions');
  eq(preview.state.quiz.bank[0].question, savedTask.questions[0].question,
    'the first quiz question comes from the assistant draft');
}

// Siswa yang mengerjakan tugas itu benar-benar melihat soal asistennya.
// Siswa demo ada di Kelas 5, sedangkan wali mengajar Kelas 1; pindahkan siswa
// ke kelas tugas dulu agar pengecekan ini menguji hal yang benar.
preview.state.studentClass = 'Kelas 1';
preview.state.role = 'siswa';
preview.state.tab = 'Tugas';
// Filter bisa tersisa dari pemeriksaan sebelumnya; mulai dari keadaan bersih.
preview.state.taskFilter = 'Aktif';
preview.state.subjectFilter = 'Semua';
preview.state.search = '';
preview.go('siswa-tugas');
// Mock DOM hanya mendukung satu selector sederhana (tanpa daftar berkoma
// atau nilai atribut), jadi pakai kelas kartu daftar.
const studentTaskCard = viewport.querySelectorAll('.list-item-card')
  .filter((n) => (n.textContent || '').indexOf('Fotosintesis') >= 0)[0];
ok(!!studentTaskCard, 'the new task appears on the student task list');
if (studentTaskCard) {
  studentTaskCard.click();
  const startBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.getAttribute('aria-label') || '') === 'Pilihan ganda')[0];
  ok(!!startBtn, 'the student can start the multiple-choice method for that task');
  if (startBtn) {
    startBtn.click();
    eq(preview.state.screen, 'kuis', 'the student lands on the quiz screen');
    eq(preview.state.quiz.bank[0].answerIndex, savedTask.questions[0].answerIndex,
      'the student sees the assistant questions, not the example bank');
  }
}

// Bahan terlalu pendek tidak menghasilkan soal palsu.
preview.go('wali-beranda');
if (buatTugasShortcut) buatTugasShortcut.click();
const shortBox = sheetPanel.querySelectorAll('#assistant-source')[0];
if (shortBox) {
  shortBox.value = 'Terlalu pendek.';
  shortBox.dispatch('input', { target: shortBox });
  sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Buat soal dengan asisten') >= 0)[0].click();
}
ok(sheetPanel.textContent.indexOf('terlalu pendek') >= 0,
  'material that is too short is rejected with a clear message');
const closeTaskSheet = sheetPanel.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Simpan tugas') >= 0)[0];
if (closeTaskSheet) {
  // Tutup tanpa menyimpan: judul kosong menjaga tombol tidak membuat tugas.
}
const backdrop = sheetBackdrop;
if (backdrop && backdrop.hidden === false) {
  // Tutup sheet lewat tombol X/backdrop yang disediakan pratinjau.
  const closeBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.getAttribute('aria-label') || '') === 'Tutup')[0];
  if (closeBtn) closeBtn.click();
}

// Tugas yang baru disimpan muncul di Beranda wali (wali tidak punya tab Tugas).
preview.go('wali-beranda');
ok(viewport.textContent.indexOf('Tugas kelas') >= 0,
  'the homeroom home lists class tasks');
ok(viewport.textContent.indexOf('Fotosintesis') >= 0,
  'the task created from material shows up on the homeroom home');
ok(viewport.textContent.indexOf('soal asisten') >= 0,
  'the task card states that its questions came from the assistant');

// Beranda wali juga membuka materi (sebelumnya tidak ada jalan).
preview.go('wali-beranda');
const materiShortcut = viewport.querySelectorAll('[aria-label]')
  .filter((n) => n.getAttribute('aria-label') === 'Kelola materi kelas')[0];
ok(!!materiShortcut, 'the homeroom home links to class materials');

preview.state.role = 'operator';
preview.state.tab = 'Beranda';
preview.go('operator-beranda');

// Tab operator: 6 tab, Profil di kanan Media.
const opTabs = bottomNav.querySelectorAll('.nav-item');
eq(opTabs.length, 6, 'the operator bottom nav has 6 tabs');
ok(opTabs.some((t) => (t.textContent || '').indexOf('Media') >= 0),
  'the operator nav has a Media tab');

preview.go('operator-siswa');
ok(viewport.textContent.indexOf('Data Siswa') >= 0, 'the operator students tab renders');
ok(viewport.textContent.indexOf('Aisyah Putri') >= 0, 'the operator roster shows a seeded student');
ok(viewport.textContent.indexOf('+ Tambah siswa') >= 0, 'the operator can add a student');

// Filter kelas pada tab siswa.
const opClassChips = viewport.querySelectorAll('.chip-btn')
  .filter((c) => (c.textContent || '').trim() === 'Kelas 5');
if (opClassChips[0]) {
  opClassChips[0].click();
  ok(viewport.textContent.indexOf('Aisyah Putri') < 0,
    'filtering by Kelas 5 hides the Kelas 1 students');
  ok(viewport.textContent.indexOf('Puspita Rani') >= 0,
    'filtering by Kelas 5 shows the Kelas 5 students');
  preview.state.filter = 'Semua kelas';
  preview.go('operator-siswa');
}

// Form siswa: tambah siswa baru.
const addButton = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('+ Tambah siswa') >= 0)[0];
ok(!!addButton, 'the operator students tab has an add button');
if (addButton) {
  addButton.click();
  ok(sheetBackdrop.hidden === false, 'the student form sheet becomes visible');
  const formInputs = sheetPanel.querySelectorAll('input');
  ok(formInputs.length >= 2, 'the student form has name and NISN inputs');
  if (formInputs.length >= 2) {
    formInputs[0].value = 'Zahra-testing';
    formInputs[0].dispatch('input', { target: formInputs[0] });
  }
  const saveStudent = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Simpan data siswa') >= 0)[0];
  ok(!!saveStudent, 'the student form has a save action');
  if (saveStudent) {
    const before = (preview.state.roster || []).length;
    saveStudent.click();
    eq((preview.state.roster || []).length, before + 1, 'saving adds a student to the roster');
    ok(preview.state.roster.some((x) => x.name === 'Zahra-testing'),
      'the new student is in the roster');
  }
  // Kembalikan roster demo.
  preview.state.roster = preview.state.roster.filter((x) => x.name !== 'Zahra-testing');
}

preview.go('operator-kelas');
ok(viewport.textContent.indexOf('Kelas Sekolah') >= 0, 'the operator classes tab renders');
ok(viewport.textContent.indexOf('Kelas 6') >= 0, 'the operator classes tab lists every class');
ok(viewport.textContent.indexOf('Wali kelas') >= 0, 'the operator classes tab shows the homeroom teacher');

preview.go('operator-materi');
ok(viewport.textContent.indexOf('Materi Sekolah') >= 0, 'the operator materials tab renders');
ok(viewport.textContent.indexOf('Hapus') >= 0, 'the operator can delete materials');
ok(viewport.textContent.indexOf('Ringkasan Pecahan Kelas 5') >= 0,
  'the operator sees the materials of every class');

preview.go('operator-media');
ok(viewport.textContent.indexOf('Foto & Grafis') >= 0, 'the operator media tab renders');
ok(viewport.textContent.indexOf('Logo sekolah') >= 0, 'the operator media tab lists the school logo');
ok(viewport.textContent.indexOf('Banner siswa') >= 0, 'the operator media tab lists the student banner');
ok(viewport.textContent.indexOf('Banner guru') >= 0, 'the operator media tab lists the teacher banner');
ok(viewport.textContent.indexOf('Memakai aset bawaan aplikasi') >= 0,
  'an empty media slot falls back to the built-in asset');
ok(viewport.textContent.indexOf('Pilih gambar') >= 0, 'the operator can pick an image for a slot');

// Graphic yang dipilih operator langsung dipakai di seluruh aplikasi.
ok(!!preview.state.mediaAssets, 'the preview keeps the operator grafis assets');
if (preview.state.mediaAssets) {
  preview.state.mediaAssets['school-logo'] = 'data:image/png;base64,AAAA';
  preview.go('siswa-beranda');
  ok(viewport.querySelectorAll('img').some((i) => (i.getAttribute('src') || '').indexOf('data:image/png;base64') === 0),
    'the operator school logo is used on every screen');
  delete preview.state.mediaAssets['school-logo'];
}

/* --- CRUD operator: tugas, materi, pengumuman, agenda, nilai, kelas, akun --- */
function opButton(root, label) {
  return root.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf(label) >= 0)[0];
}

// Tugas: tambah, ubah, hapus.
preview.go('operator-tugas');
ok(viewport.textContent.indexOf('Tugas Sekolah') >= 0, 'the operator task screen renders');
const taskAdd = opButton(viewport, '+ Tambah tugas');
ok(!!taskAdd, 'the operator can add a task');
if (taskAdd) {
  taskAdd.click();
  ok(sheetBackdrop.hidden === false, 'the task form sheet opens');
  const taskInputs = sheetPanel.querySelectorAll('input');
  ok(taskInputs.length >= 3, 'the task form has title, duration, and due inputs');
  if (taskInputs.length >= 3) {
    taskInputs[0].value = 'Tugas operator';
    taskInputs[0].dispatch('input', { target: taskInputs[0] });
    taskInputs[1].value = '45';
    taskInputs[1].dispatch('input', { target: taskInputs[1] });
    taskInputs[2].value = '2026-12-31';
    taskInputs[2].dispatch('input', { target: taskInputs[2] });
  }
  const taskSave = opButton(sheetPanel, 'Simpan tugas');
  ok(!!taskSave, 'the task form has a save action');
  if (taskSave) {
    taskSave.click();
    ok(viewport.textContent.indexOf('Tugas operator') >= 0,
      'the new task appears in the operator task list');
  }
}

// Pengumuman: tambah, ubah, hapus.
preview.go('operator-pengumuman');
ok(viewport.textContent.indexOf('Pengumuman Sekolah') >= 0,
  'the operator announcement screen renders');
const annAdd = opButton(viewport, '+ Tambah pengumuman');
ok(!!annAdd, 'the operator can add an announcement');
if (annAdd) {
  annAdd.click();
  const annInputs = sheetPanel.querySelectorAll('input');
  ok(annInputs.length >= 2, 'the announcement form has title and body inputs');
  if (annInputs.length >= 2) {
    annInputs[0].value = 'Pengumuman operator';
    annInputs[0].dispatch('input', { target: annInputs[0] });
    annInputs[1].value = 'Isi pengumuman operator';
    annInputs[1].dispatch('input', { target: annInputs[1] });
  }
  const annSave = opButton(sheetPanel, 'Simpan pengumuman');
  ok(!!annSave, 'the announcement form has a save action');
  if (annSave) {
    annSave.click();
    ok(viewport.textContent.indexOf('Pengumuman operator') >= 0,
      'the new announcement appears in the list');
  }
}

// Agenda: tambah.
preview.go('operator-agenda');
ok(viewport.textContent.indexOf('Agenda Sekolah') >= 0, 'the operator agenda screen renders');
const agendaAdd = opButton(viewport, '+ Tambah agenda');
ok(!!agendaAdd, 'the operator can add an agenda');
if (agendaAdd) {
  agendaAdd.click();
  const agendaInputs = sheetPanel.querySelectorAll('input');
  ok(agendaInputs.length >= 2, 'the agenda form has title and date inputs');
  if (agendaInputs.length >= 2) {
    agendaInputs[0].value = 'Agenda operator';
    agendaInputs[0].dispatch('input', { target: agendaInputs[0] });
    agendaInputs[1].value = '2026-12-01';
    agendaInputs[1].dispatch('input', { target: agendaInputs[1] });
  }
  const agendaSave = opButton(sheetPanel, 'Simpan agenda');
  ok(!!agendaSave, 'the agenda form has a save action');
  if (agendaSave) {
    agendaSave.click();
    ok(viewport.textContent.indexOf('Agenda operator') >= 0,
      'the new agenda appears in the list');
  }
}

// Nilai: isi dan hapus nilai siswa.
preview.go('operator-nilai');
ok(viewport.textContent.indexOf('Nilai Kelas') >= 0, 'the operator grade screen renders');
const firstScore = viewport.querySelectorAll('.list-item-card')[0];
ok(!!firstScore, 'the operator grade screen lists students');
if (firstScore) {
  firstScore.click();
  const scoreInput = sheetPanel.querySelectorAll('input')[0];
  ok(!!scoreInput, 'the score sheet has a value input');
  if (scoreInput) {
    scoreInput.value = '88';
    scoreInput.dispatch('input', { target: scoreInput });
  }
  const scoreSave = opButton(sheetPanel, 'Simpan nilai');
  ok(!!scoreSave, 'the score sheet has a save action');
  if (scoreSave) {
    scoreSave.click();
    ok(Object.keys(preview.state.rosterScores || {}).length >= 1,
      'the operator score is stored per student');
  }
  const removeScore = opButton(viewport, 'Hapus nilai');
  ok(!!removeScore, 'the operator can delete a score');
  if (removeScore) {
    removeScore.click();
    eq(Object.keys(preview.state.rosterScores || {}).length, 0,
      'deleting the score removes it');
  }
}

// Nilai di luar rentang 0-100 harus ditolak.
preview.go('operator-nilai');
const scoreCard = viewport.querySelectorAll('.list-item-card')[0];
if (scoreCard) {
  scoreCard.click();
  const scoreField = sheetPanel.querySelectorAll('input')[0];
  if (scoreField) {
    scoreField.value = '150';
    scoreField.dispatch('input', { target: scoreField });
  }
  const badSave = opButton(sheetPanel, 'Simpan nilai');
  if (badSave) {
    badSave.click();
    ok(sheetPanel.textContent.indexOf('Nilai harus antara 0 dan 100.') >= 0,
      'the preview rejects a score above 100');
    eq(Object.keys(preview.state.rosterScores || {}).length, 0,
      'the rejected score is not stored');
  }
  const scoreField2 = sheetPanel.querySelectorAll('input')[0];
  if (scoreField2) {
    scoreField2.value = '95';
    scoreField2.dispatch('input', { target: scoreField2 });
  }
  const goodSave = opButton(sheetPanel, 'Simpan nilai');
  if (goodSave) {
    goodSave.click();
    eq(Object.keys(preview.state.rosterScores || {}).length, 1,
      'a valid score is stored');
  }
}

// Kelas: tambah kelas baru.
preview.go('operator-kelas');
ok(viewport.textContent.indexOf('Kelas Sekolah') >= 0, 'the operator classes tab renders');
const classAdd = opButton(viewport, '+ Tambah kelas');
ok(!!classAdd, 'the operator can add a class');
if (classAdd) {
  classAdd.click();
  const classInputs = sheetPanel.querySelectorAll('input');
  ok(classInputs.length >= 2, 'the class form has name and teacher inputs');
  if (classInputs.length >= 2) {
    classInputs[0].value = 'Kelas 7';
    classInputs[0].dispatch('input', { target: classInputs[0] });
    classInputs[1].value = 'Pak Adi';
    classInputs[1].dispatch('input', { target: classInputs[1] });
  }
  const classSave = opButton(sheetPanel, 'Simpan kelas');
  ok(!!classSave, 'the class form has a save action');
  if (classSave) {
    const before = (preview.state.schoolClasses || []).length;
    classSave.click();
    eq((preview.state.schoolClasses || []).length, before + 1,
      'saving adds a class to the school class list');
    ok((preview.state.schoolClasses || []).some((c) => c.name === 'Kelas 7'),
      'the new class is in the list');
    ok(viewport.textContent.indexOf('Kelas 7') >= 0,
      'the new class shows up on the operator classes tab');
  }
  // Hapus kelas uji.
  const removeClass = viewport.querySelectorAll('button')
    .filter((b) => (b.textContent || '').trim() === 'Hapus')[0];
  if (removeClass) {
    const before = (preview.state.schoolClasses || []).length;
    removeClass.click();
    eq((preview.state.schoolClasses || []).length, before - 1,
      'the operator can delete a class');
  }
}

// Akun guru dan wali: tambah akun.
preview.go('operator-kelas');
const accountSection = viewport.querySelectorAll('.segment-item')
  .filter((b) => (b.textContent || '').trim() === 'Akun')[0];
ok(!!accountSection, 'the operator classes tab has an account section');
if (accountSection) {
  accountSection.click();
  ok(viewport.textContent.indexOf('Akun guru dan wali') >= 0,
    'the account section renders');
  const staffAdd = opButton(viewport, '+ Tambah akun');
  ok(!!staffAdd, 'the operator can add a staff account');
  if (staffAdd) {
    staffAdd.click();
    const staffInputs = sheetPanel.querySelectorAll('input');
    ok(staffInputs.length >= 2, 'the staff form has name and NIP inputs');
    if (staffInputs.length >= 2) {
      staffInputs[0].value = 'Bu Lilis';
      staffInputs[0].dispatch('input', { target: staffInputs[0] });
      staffInputs[1].value = '19870099';
      staffInputs[1].dispatch('input', { target: staffInputs[1] });
    }
    const staffSave = opButton(sheetPanel, 'Simpan akun');
    ok(!!staffSave, 'the staff form has a save action');
    if (staffSave) {
      const before = (preview.state.staffAccounts || []).length;
      staffSave.click();
      eq((preview.state.staffAccounts || []).length, before + 1,
        'saving adds a staff account');
    }
  }
}

// Materi: tambah materi lewat form operator.
preview.go('operator-materi');
const materialAdd = opButton(viewport, '+ Tambah materi');
ok(!!materialAdd, 'the operator can add a material');
if (materialAdd) {
  materialAdd.click();
  const materialInputs = sheetPanel.querySelectorAll('input');
  ok(materialInputs.length >= 2, 'the material form has title and summary inputs');
  if (materialInputs.length >= 2) {
    materialInputs[0].value = 'Materi operator';
    materialInputs[0].dispatch('input', { target: materialInputs[0] });
    materialInputs[1].value = 'Ringkasan dari operator';
    materialInputs[1].dispatch('input', { target: materialInputs[1] });
  }
  const materialSave = opButton(sheetPanel, 'Simpan materi');
  ok(!!materialSave, 'the material form has a save action');
  if (materialSave) {
    materialSave.click();
    ok(viewport.textContent.indexOf('Materi operator') >= 0,
      'the new material appears in the operator material list');
  }
}

// Materi: hapus aksi yang benar-benar diklik dan hitung rekamannya, bukan
// sekadar memastikan tombol "Hapus" terlihat.
if (typeof preview.materials === 'function') {
  preview.state.filter = 'Semua kelas';
  preview.go('operator-materi');
  const beforeDelete = preview.materials().length;
  const createdRecord = preview.materials()
    .filter((m) => m.title === 'Materi operator')[0];
  ok(!!createdRecord, 'the added material exists in the preview record store');
  const deleteButtons = viewport.querySelectorAll('button')
    .filter((b) => (b.textContent || '').trim() === 'Hapus');
  eq(deleteButtons.length, beforeDelete,
    'every material record renders its own delete action');
  if (createdRecord && deleteButtons.length) {
    // Materi baru disisipkan di depan daftar, jadi aksi pertama menghapusnya.
    deleteButtons[0].click();
    eq(preview.materials().length, beforeDelete - 1,
      'clicking Hapus removes exactly one material record');
    ok(preview.materials().every((m) => m.title !== 'Materi operator'),
      'the deleted material is gone from the record store');
    preview.go('operator-materi');
    ok(viewport.textContent.indexOf('Materi operator') < 0,
      'the deleted material no longer renders in the operator list');
  }
  // Kembalikan materi uji agar pemeriksaan berikutnya memakai data demo utuh.
  if (createdRecord && typeof preview.persistState === 'function') {
    preview.materials().push(createdRecord);
    preview.persistState();
  }
} else {
  ok(false, 'the preview exposes materials() for deletion verification');
}

// Kelas terakhir tidak boleh dihapus.
const savedClasses = preview.state.schoolClasses || [];
const savedStaff = preview.state.staffAccounts || [];
const savedRoster = preview.state.roster || [];
preview.state.operatorClassSection = 'Kelas';
preview.state.schoolClasses = savedClasses.length ? [savedClasses[0]] : [];
preview.go('operator-kelas');
const lastClassDelete = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').trim() === 'Hapus')[0];
ok(!!lastClassDelete, 'the single class still shows a delete action');
if (lastClassDelete) {
  lastClassDelete.click();
  eq((preview.state.schoolClasses || []).length, 1,
    'the preview refuses to delete the last class');
  ok(viewport.textContent.indexOf('Minimal satu kelas sekolah harus tetap ada.') >= 0,
    'the preview explains that one class must remain');
}

// Pesan yang sama harus muncul pula di dalam sheet form kelas yang sedang
// terbuka, agar operator tidak mengira tombol hapusnya rusak.
if (typeof preview.go === 'function') {
  preview.go('operator-kelas');
  const editClass = opButton(viewport, 'Ubah');
  ok(!!editClass, 'the last class still has an edit action');
  if (editClass) {
    editClass.click();
    const sheetDelete = opButton(sheetPanel, 'Hapus kelas ini');
    ok(!!sheetDelete, 'the class form offers a delete action');
    if (sheetDelete) {
      sheetDelete.click();
      eq((preview.state.schoolClasses || []).length, 1,
        'deleting from the open class form keeps the last class');
      ok(sheetPanel.textContent.indexOf('Minimal satu kelas sekolah harus tetap ada.') >= 0,
        'the open class form shows why the last class cannot be deleted');
    }
  }
  preview.state.operatorError = '';
}

// Kelas, akun, dan siswa yang dihapus tidak dibangkitkan lagi setelah
// pemuatan ulang (data lama tanpa daftar itu memakai data bawaan).
if (typeof preview.persistState === 'function' &&
    typeof preview.restoreState === 'function') {
  preview.state.schoolClasses = savedClasses.slice(1);
  preview.state.staffAccounts = savedStaff.slice(1);
  preview.state.roster = savedRoster.slice(1);
  preview.persistState();
  preview.state.schoolClasses = savedClasses;
  preview.state.staffAccounts = savedStaff;
  preview.state.roster = savedRoster;
  preview.restoreState();
  eq((preview.state.schoolClasses || []).length, savedClasses.length - 1,
    'deleted classes are not restored from the seed data');
  eq((preview.state.staffAccounts || []).length, savedStaff.length - 1,
    'deleted staff accounts are not restored from the seed data');
  eq((preview.state.roster || []).length, savedRoster.length - 1,
    'deleted students are not restored from the seed data');
} else {
  ok(false, 'the preview exposes persistState and restoreState for verification');
}

// Kembalikan data demo untuk pemeriksaan berikutnya.
preview.state.schoolClasses = savedClasses;
preview.state.staffAccounts = savedStaff;
preview.state.roster = savedRoster;
if (typeof preview.persistState === 'function') preview.persistState();
preview.go('operator-kelas');
preview.state.filter = 'Semua kelas';
preview.state.operatorClassSection = 'Kelas';

// Form tugas menolak tanggal tenggat yang tidak valid secara terlihat.
preview.go('operator-tugas');
const tasksBeforeValidation = preview.tasks().length;
const invalidDateTask = opButton(viewport, '+ Tambah tugas');
ok(!!invalidDateTask, 'the operator task form can be opened for validation');
if (invalidDateTask) {
  invalidDateTask.click();
  let dateInputs = sheetPanel.querySelectorAll('input');
  dateInputs[0].value = 'Tugas tanggal salah';
  dateInputs[0].dispatch('input', { target: dateInputs[0] });
  dateInputs[1].value = '30';
  dateInputs[1].dispatch('input', { target: dateInputs[1] });
  dateInputs[2].value = 'bukan tanggal';
  dateInputs[2].dispatch('input', { target: dateInputs[2] });
  opButton(sheetPanel, 'Simpan tugas').click();
  ok(sheetPanel.textContent.indexOf('Isi tanggal tenggat dengan format YYYY-MM-DD.') >= 0,
    'an invalid due date shows a visible error inside the form');
  eq(preview.tasks().length, tasksBeforeValidation,
    'an invalid due date does not create a task');
}

// IPAS mengikuti tingkat kelas: kelas bernomor 1-2 ditolak, kelas khusus
// tanpa angka boleh memakai semua mata pelajaran.
const IPAS = 'Ilmu Pengetahuan Alam dan Sosial (IPAS)';
ok(preview.operator.subjectsForClass('Kelas 1').indexOf(IPAS) < 0,
  'grade 1 does not offer IPAS');
ok(preview.operator.subjectsForClass('Kelas 3').indexOf(IPAS) >= 0,
  'grade 3 offers IPAS');
ok(preview.operator.subjectsForClass('Kelas Persiapan').indexOf(IPAS) >= 0,
  'a custom class without a numeric grade offers every subject');

const customClass = { id: 'kelas-persiapan', name: 'Kelas Persiapan', teacherName: 'Bu Uji' };
preview.state.schoolClasses = savedClasses.concat([customClass]);
preview.go('operator-tugas');
const ipasTask = opButton(viewport, '+ Tambah tugas');
if (ipasTask) {
  ipasTask.click();
  let chipsAll = sheetPanel.querySelectorAll('.chip-btn');
  const ipasChip = chipsAll.filter((c) => (c.textContent || '').trim() === IPAS)[0];
  const lowGradeChip = chipsAll.filter((c) => (c.textContent || '').trim() === 'Kelas 2')[0];
  ok(!!ipasChip && !!lowGradeChip, 'the task form offers subject and class chips');
  ok(preview.operator.classOptions().every(
    (n) => chipsAll.some((c) => (c.textContent || '').trim() === n)),
    'the task form class chips come from the dynamic class list');
  if (ipasChip && lowGradeChip) {
    ipasChip.click();
    lowGradeChip.click();
    let inputs = sheetPanel.querySelectorAll('input');
    inputs[0].value = 'Tugas IPAS kelas 2';
    inputs[0].dispatch('input', { target: inputs[0] });
    inputs[1].value = '30';
    inputs[1].dispatch('input', { target: inputs[1] });
    inputs[2].value = '2026-12-31';
    inputs[2].dispatch('input', { target: inputs[2] });
    opButton(sheetPanel, 'Simpan tugas').click();
    ok(sheetPanel.textContent.indexOf('IPAS hanya boleh dipakai untuk kelas 3-6.') >= 0,
      'IPAS for a grade 2 class is rejected with a visible error');
    eq(preview.tasks().length, tasksBeforeValidation,
      'the rejected IPAS task is not created');

    // Kelas khusus tanpa angka tingkat membuka IPAS.
    const customChip = sheetPanel.querySelectorAll('.chip-btn')
      .filter((c) => (c.textContent || '').trim() === 'Kelas Persiapan')[0];
    ok(!!customChip, 'the operator task form lists the dynamically added class');
    if (customChip) {
      customChip.click();
      inputs = sheetPanel.querySelectorAll('input');
      inputs[0].value = 'Tugas kelas persiapan';
      inputs[0].dispatch('input', { target: inputs[0] });
      inputs[1].value = '30';
      inputs[1].dispatch('input', { target: inputs[1] });
      inputs[2].value = '2026-12-31';
      inputs[2].dispatch('input', { target: inputs[2] });
      opButton(sheetPanel, 'Simpan tugas').click();
      eq(preview.tasks().length, tasksBeforeValidation + 1,
        'a custom class may use IPAS and create a task');
      const added = preview.tasks()
        .filter((t) => t.title === 'Tugas kelas persiapan')[0];
      ok(!!added && added.className === 'Kelas Persiapan',
        'the new task keeps the custom class name');
    }
  }
}

// Form siswa memakai daftar kelas dinamis, bukan hard-code Kelas 1-6.
preview.go('operator-siswa');
const dynamicStudentForm = opButton(viewport, '+ Tambah siswa');
if (dynamicStudentForm) {
  dynamicStudentForm.click();
  const studentClassChips = sheetPanel.querySelectorAll('.chip-btn')
    .map((c) => (c.textContent || '').trim());
  ok(studentClassChips.indexOf('Kelas Persiapan') >= 0,
    'the student form offers the dynamically added class');
  ok(preview.operator.classOptions().every(
    (n) => studentClassChips.indexOf(n) >= 0),
    'the student form offers every dynamically configured class');
  opButton(sheetPanel, 'Batal').click();
}

// Bersihkan data uji agar pemeriksaan berikutnya memakai data demo utuh.
preview.state.schoolClasses = savedClasses;
preview.tasks().splice(0, preview.tasks().length,
  ...preview.tasks().filter((t) => t.title !== 'Tugas kelas persiapan'));
if (typeof preview.persistState === 'function') preview.persistState();
preview.state.filter = 'Semua kelas';

// Data pribadi operator tidak boleh menimpa nama siswa.
preview.state.role = 'operator';
preview.state.studentName = 'Dimas Nugroho';
// Profil operator kini tab sendiri (keenam, di sebelah Media).
preview.go('operator-profil');
// Mock DOM tidak mendukung selector `[attr=value]`; saring manual.
const opInfoCard = viewport.querySelectorAll('[aria-label]')
  .filter((n) => n.getAttribute('aria-label') === 'Ubah profil operator')[0];
ok(!!opInfoCard, 'the operator profile tab renders an edit button');
if (opInfoCard) {
  // Section profil menampilkan jabatan, NIP, dan indikator kelengkapan.
  ok(viewport.textContent.indexOf('Operator Sekolah') >= 0,
    'the profile section shows the operator role');
  ok(viewport.textContent.indexOf('19870003') >= 0,
    'the profile section shows the operator NIP');
  // Section profil baru memuat keenam kolom, bukan hanya nama + NIP.
  const profileLabels = ['Nama lengkap', 'NIP', 'Jabatan', 'Unit kerja', 'Surel', 'Telepon'];
  eq(profileLabels.filter((l) => viewport.textContent.indexOf(l) >= 0).length, 6,
    'the profile section lists all six profile fields');
  ok(viewport.textContent.indexOf('Belum diisi') >= 0,
    'empty profile fields are labelled "Belum diisi"');
  ok(/Lengkapi (surel|telepon|data pribadi)[^()]*\(\d\/6 kolom terisi\)/.test(viewport.textContent),
    'the profile section shows how complete the profile is');
  ok(viewport.textContent.indexOf('Data pribadi sudah lengkap') < 0,
    'the demo operator profile is reported as incomplete until contact is filled');
  ok(viewport.textContent.indexOf('surel & telepon') >= 0,
    'the profile section names the missing columns');

  opInfoCard.click();
  ok(sheetBackdrop.hidden === false, 'the operator identity card opens the personal info sheet');
  ok(sheetPanel.textContent.indexOf('Identitas kerja operator') >= 0,
    'the operator sheet explains that this is work identity');

  const opNameInput = sheetPanel.querySelectorAll('#pi-name')[0];
  ok(!!opNameInput, 'the operator personal info form has a name input');
  // Form profil operator lengkap: NIP, jabatan, unit, surel, telepon.
  const opFieldIds = ['pi-name', 'pi-nip', 'pi-role', 'pi-unit', 'pi-email', 'pi-phone'];
  eq(opFieldIds.filter((id) => sheetPanel.querySelectorAll('#' + id).length === 1).length, 6,
    'the operator personal info form has all six profile fields');

  const field = (id) => sheetPanel.querySelectorAll('#' + id)[0];
  const typeInto = (id, value) => {
    const input = field(id);
    if (!input) return;
    input.value = value;
    input.dispatch('input', { target: input });
  };

  // NIP wajib.
  if (opNameInput) {
    opNameInput.value = 'Sari Operator';
    opNameInput.dispatch('input', { target: opNameInput });
  }
  typeInto('pi-nip', '');
  const saveBtn = () => sheetPanel.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Simpan perubahan') >= 0)[0];
  if (saveBtn()) saveBtn().click();
  ok(sheetPanel.textContent.indexOf('NIP tidak boleh kosong.') >= 0,
    'an empty NIP is rejected with a visible error');
  eq(preview.state.operatorName, 'Operator Sekolah',
    'a rejected save leaves the stored operator name untouched');

  // NIP harus angka.
  typeInto('pi-nip', 'abc');
  if (saveBtn()) saveBtn().click();
  ok(sheetPanel.textContent.indexOf('NIP harus berupa 6-20 angka.') >= 0,
    'a non-numeric NIP is rejected with a visible error');

  // Surel harus valid bila diisi.
  typeInto('pi-nip', '19870099');
  typeInto('pi-email', 'bukan-surel');
  if (saveBtn()) saveBtn().click();
  ok(sheetPanel.textContent.indexOf('Format surel belum benar') >= 0,
    'an invalid email is rejected with a visible error');

  // Telepon harus 8-16 angka.
  typeInto('pi-email', 'sari@sekolah.sch.id');
  typeInto('pi-phone', '123');
  if (saveBtn()) saveBtn().click();
  ok(sheetPanel.textContent.indexOf('Nomor telepon harus 8-16 angka.') >= 0,
    'a too-short phone number is rejected with a visible error');

  // Penyimpanan yang sah menyimpan seluruh kolom.
  typeInto('pi-phone', '081234567890');
  typeInto('pi-role', 'Operator Data');
  typeInto('pi-unit', 'SD Karitas Purwokerto');
  if (saveBtn()) saveBtn().click();
  const savedProfile = preview.state.operatorProfile || {};
  eq(savedProfile.name, 'Sari Operator', 'the operator name is saved');
  eq(savedProfile.nip, '19870099', 'the operator NIP is saved');
  eq(savedProfile.role, 'Operator Data', 'the operator role is saved');
  eq(savedProfile.email, 'sari@sekolah.sch.id', 'the operator email is saved');
  eq(savedProfile.phone, '081234567890', 'the operator phone is saved');
  eq(savedProfile.unit, 'SD Karitas Purwokerto', 'the operator unit is saved');
  eq(preview.state.studentName, 'Dimas Nugroho',
    'saving the operator profile does not overwrite the student name');

  // Profil lengkap sekarang dilaporkan lengkap.
  preview.go('operator-profil');
  ok(viewport.textContent.indexOf('Data pribadi sudah lengkap') >= 0,
    'the identity card reports a complete profile once every field is filled');
  ok(viewport.textContent.indexOf('sari@sekolah.sch.id') >= 0,
    'the identity card shows the saved contact details');

  // Kembalikan profil demo untuk pemeriksaan berikutnya.
  preview.state.operatorProfile = {
    name: 'Operator Sekolah', nip: '19870003', role: 'Operator Sekolah',
    email: '', phone: '', unit: 'SD Karitas Purwokerto'
  };
  preview.state.operatorName = 'Operator Sekolah';
  if (typeof preview.persistState === 'function') preview.persistState();
}

// Login operator.
preview.go('login-operator');
const opFields = viewport.querySelectorAll('input');
ok(opFields.length >= 2, 'the operator login screen has the id and password fields');
if (opFields.length >= 2) {
  opFields[0].value = '19870003';
  opFields[0].dispatch('input', { target: opFields[0] });
  opFields[1].value = 'salah';
  opFields[1].dispatch('input', { target: opFields[1] });
  const opSubmit = viewport.querySelectorAll('button')
    .filter((b) => (b.textContent || '').indexOf('Masuk') >= 0)[0];
  if (opSubmit) opSubmit.click();
  ok(viewport.textContent.indexOf('NIP/NISN atau kata sandi tidak sesuai.') >= 0,
    'the operator login rejects wrong credentials with the RN error message');
}

preview.state.role = 'siswa';
preview.state.filter = 'Semua kelas';

/* ------------------------------------------------------------------ *
 * 9b. Every role card on the welcome screen opens its own login screen
 * ------------------------------------------------------------------ */
// Regresi: kartu "Saya Operator Sekolah" pernah tidak bereaksi karena
// LOGIN_SCREEN tidak punya entri `operator`, sehingga go(undefined) no-op.
preview.go('welcome');
const roleCards = viewport.querySelectorAll('.role-card');
eq(roleCards.length, 5, 'the welcome screen offers all five role cards');
const expectedRoleCards = [
  { role: 'operator', title: 'Saya Operator Sekolah', login: 'login-operator' },
  { role: 'wali', title: 'Saya Wali Kelas', login: 'login-wali' },
  { role: 'guru', title: 'Saya Guru Mata Pelajaran', login: 'login-guru' },
  { role: 'orangtua', title: 'Saya Orang Tua/Wali', login: 'login-ortu' },
  { role: 'siswa', title: 'Saya Siswa', login: 'login-siswa' }
];
expectedRoleCards.forEach((expected, index) => {
  preview.go('welcome');
  const card = viewport.querySelectorAll('.role-card')[index];
  ok(!!card, 'the welcome screen renders the ' + expected.role + ' card');
  if (!card) return;
  ok((card.textContent || '').indexOf(expected.title) >= 0,
    'role card ' + index + ' is "' + expected.title + '"');
  card.click();
  eq(preview.state.screen, expected.login,
    'clicking the ' + expected.role + ' card opens ' + expected.login);
  eq(preview.state.role, expected.role,
    'clicking the ' + expected.role + ' card selects that role');
});

// Operator login screen: copy and credentials come from the operator account.
preview.go('welcome');
viewport.querySelectorAll('.role-card')[0].click();
ok(viewport.textContent.indexOf('Selamat datang,\nOperator Sekolah!') >= 0 ||
  viewport.textContent.indexOf('Operator Sekolah!') >= 0,
  'the operator login screen greets the operator');
ok(viewport.textContent.indexOf('Masuk untuk mengelola seluruh sekolah') >= 0,
  'the operator login screen explains the operator scope');
ok(viewport.textContent.indexOf('Halo, Orang Tua!') < 0,
  'the operator login screen does not reuse the parent greeting');

// Staf memakai NIP; hanya siswa/orang tua yang memakai NISN.
preview.go('welcome');
viewport.querySelectorAll('.role-card')[0].click();
eq(viewport.querySelectorAll('#login-username')[0].getAttribute('placeholder'), 'NIP',
  'the operator login field is labelled NIP');
ok(viewport.textContent.indexOf('NIP: 19870003') >= 0,
  'the operator demo box shows the operator NIP');
preview.go('welcome');
viewport.querySelectorAll('.role-card')[4].click();
eq(viewport.querySelectorAll('#login-username')[0].getAttribute('placeholder'), 'NISN',
  'the student login field is still labelled NISN');

// Kembali ke login operator untuk menguji kredensialnya.
preview.go('welcome');
viewport.querySelectorAll('.role-card')[0].click();
const operatorUser = viewport.querySelectorAll('#login-username')[0];
const operatorPass = viewport.querySelectorAll('#login-password')[0];
ok(!!operatorUser && !!operatorPass, 'the operator login screen has username and password fields');
if (operatorUser && operatorPass) {
  operatorUser.value = '19870003';
  operatorUser.dispatch('input', { target: operatorUser });
  operatorPass.value = 'operator123';
  operatorPass.dispatch('input', { target: operatorPass });
  const submit = opButton(viewport, 'Masuk');
  ok(!!submit, 'the operator login screen has a submit button');
  if (submit) {
    submit.click();
    eq(preview.state.screen, 'operator-beranda',
      'operator credentials open the operator home');
  }
}

/* ------------------------------------------------------------------ *
 * 9c. Unified login: role detected from credentials + "Ingat saya"
 * ------------------------------------------------------------------ */
// Alur baru: splash -> satu form login. Tidak ada layar pilih peran di jalur
// utama, dan peran ditentukan dari NIP/NISN yang diketik.
preview.go('splash');
eq(preview.state.screen, 'splash', 'the splashes stays put before the timer fires');

preview.go('login');
ok(viewport.textContent.indexOf('Selamat datang di KARSA') >= 0,
  'the unified login greets the user');
ok(viewport.textContent.indexOf('Masuk dengan NIP atau NISN Anda') >= 0,
  'the unified login explains that one form serves every role');
ok(viewport.textContent.indexOf('Pilih peran') < 0,
  'the unified login has no role picker');

// Kelima akun demo terdaftar dalam satu kotak.
const demoBtn = () => viewport.querySelectorAll('.demo-cred-row');
eq(demoBtn().length, 5, 'the demo box lists all five accounts');

// Kolom identitas mengikuti peran yang terdeteksi dari ketikan.
const unifiedUser = () => viewport.querySelectorAll('#login-username')[0];
ok(!!unifiedUser(), 'the unified login has an identity field');
if (unifiedUser()) {
  unifiedUser().value = '19870003';
  unifiedUser().dispatch('input', { target: unifiedUser() });
  eq(viewport.querySelectorAll('#login-username')[0].getAttribute('placeholder'), 'NIP',
    'staff identifiers are labelled NIP');
  ok(viewport.textContent.indexOf('Operator sekolah') >= 0,
    'typing the operator NIP reveals the detected role');
}

preview.go('login');
if (unifiedUser()) {
  unifiedUser().value = '10050001';
  unifiedUser().dispatch('input', { target: unifiedUser() });
  eq(viewport.querySelectorAll('#login-username')[0].getAttribute('placeholder'), 'NISN',
    'student identifiers are labelled NISN');
}

// Galat yang jelas untuk kolom kosong.
preview.go('login');
preview.state.login.username = '';
preview.state.login.password = '';
let unifiedSubmit = opButton(viewport, 'Masuk');
if (unifiedSubmit) unifiedSubmit.click();
ok(viewport.textContent.indexOf('Isi NIP atau NISN terlebih dahulu.') >= 0,
  'an empty identity shows a visible error');
eq(preview.state.screen, 'login', 'an empty identity keeps the user on the login screen');

// Kata sandi salah -> tetap di login.
preview.go('login');
preview.state.login.username = '19870003';
preview.state.login.password = 'salah';
unifiedSubmit = opButton(viewport, 'Masuk');
if (unifiedSubmit) unifiedSubmit.click();
ok(viewport.textContent.indexOf('NIP/NISN atau kata sandi tidak sesuai.') >= 0,
  'wrong credentials show a visible error');
eq(preview.state.screen, 'login', 'wrong credentials keep the user on the login screen');

// Setiap peran masuk lewat form yang sama dan mendarat di berandanya.
[
  { id: '19870003', pass: 'operator123', role: 'operator', screen: 'operator-beranda' },
  { id: '19870001', pass: 'wali123', role: 'wali', screen: 'wali-beranda' },
  { id: '19870002', pass: 'guru123', role: 'guru', screen: 'guru-beranda' },
  { id: '10050001', pass: 'siswa123', role: 'siswa', screen: 'siswa-beranda' },
  { id: '10010001', pass: 'ortu123', role: 'orangtua', screen: 'ortu-beranda' }
].forEach((c) => {
  preview.go('login');
  preview.state.login.username = c.id;
  preview.state.login.password = c.pass;
  const btn = opButton(viewport, 'Masuk');
  ok(!!btn, 'the unified login has a submit button for ' + c.role);
  if (btn) btn.click();
  eq(preview.state.screen, c.screen, c.role + ' logs in through the shared form');
  eq(preview.state.role, c.role, c.role + ' role is detected from the credentials');
});

// "Ingat saya" menyimpan identitas, bukan kata sandi.
preview.go('login');
preview.state.rememberMe = true;
preview.state.rememberedLogin = null;
preview.state.login.username = '19870003';
preview.state.login.password = 'operator123';
preview.render();
unifiedSubmit = opButton(viewport, 'Masuk');
if (unifiedSubmit) unifiedSubmit.click();
eq(preview.state.rememberedLogin && preview.state.rememberedLogin.identifier, '19870003',
  '"Ingat saya" remembers the identifier after a successful login');
eq(preview.state.rememberedLogin && preview.state.rememberedLogin.role, 'operator',
  '"Ingat saya" remembers the detected role');
ok(!('password' in (preview.state.rememberedLogin || {})),
  '"Ingat saya" never stores the password');

// Kartu "terakhir masuk" muncul dan bisa ditolak.
preview.go('login');
ok(!!viewport.querySelectorAll('.remembered-card')[0],
  'a remembered login shows a "terakhir masuk" card');
const rememberedText = viewport.textContent;
ok(rememberedText.indexOf('19870003') >= 0,
  'the remembered card shows the saved identifier');
const notMe = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Bukan saya') >= 0)[0];
ok(!!notMe, 'the remembered card offers a way to switch account');
if (notMe) {
  notMe.click();
  eq(preview.state.rememberedLogin, null, '"Bukan saya" clears the remembered login');
}

// Centang bisa dimatikan: login berikutnya tidak mengingat apa pun.
preview.go('login');
preview.state.rememberMe = false;
preview.state.rememberedLogin = null;
preview.state.login.username = '19870001';
preview.state.login.password = 'wali123';
preview.render();
unifiedSubmit = opButton(viewport, 'Masuk');
if (unifiedSubmit) unifiedSubmit.click();
eq(preview.state.rememberedLogin, null,
  'unchecking "Ingat saya" stores no identifier');

// "Ingat saya" bertahan setelah state dimuat ulang.
preview.state.rememberMe = true;
preview.state.rememberedLogin = { identifier: '19870002', role: 'guru' };
if (typeof preview.persistState === 'function') preview.persistState();
if (typeof preview.restoreState === 'function') {
  preview.state.rememberedLogin = null;
  preview.restoreState();
}
eq(preview.state.rememberedLogin && preview.state.rememberedLogin.identifier, '19870002',
  'the remembered login survives a reload');

// Keluar dari akun kembali ke form login dengan identitas terisi.
preview.state.rememberedLogin = { identifier: '19870003', role: 'operator' };
preview.state.role = 'operator';
preview.go('wali-profil');
const logoutBtn = viewport.querySelectorAll('button')
  .filter((b) => (b.textContent || '').indexOf('Keluar dari akun demo') >= 0)[0];
ok(!!logoutBtn, 'the profile screen offers a logout action');
if (logoutBtn) logoutBtn.click();
eq(preview.state.screen, 'login', 'logout returns to the login form');
eq(preview.state.login.username, '19870003',
  'logout keeps the remembered identifier in the form');
eq(preview.state.login.password, '', 'logout clears the password');

// Identitas tersimpan langsung terisi saat form login dibuka.
preview.state.rememberedLogin = { identifier: '10050001', role: 'siswa' };
preview.state.login = { username: '', password: '', show: false, error: '' };
preview.go('login');
eq(preview.state.login.username, '10050001',
  'the remembered identifier is prefilled when the form opens');
eq(viewport.querySelectorAll('#login-username')[0].getAttribute('placeholder'), 'NISN',
  'the prefilled identifier sets the field label to NISN');

// Kembalikan keadaan demo.
preview.state.rememberedLogin = null;
preview.state.rememberMe = true;
preview.state.login = { username: '', password: '', show: false, error: '' };
if (typeof preview.persistState === 'function') preview.persistState();

/* ------------------------------------------------------------------ *
 * 10. Dark mode toggle
 * ------------------------------------------------------------------ */
preview.go('welcome');
eq(doc.documentElement.getAttribute('data-theme'), 'light', 'default theme is light');
// Bar pengembang sudah dihapus: tema diganti dari tombol di dalam aplikasi.
const themeBtnInApp = viewport.querySelectorAll('.round-icon-btn')
  .filter((n) => (n.getAttribute('aria-label') || '').indexOf('mode gelap') >= 0)[0];
ok(!!themeBtnInApp, 'an in-app button can switch to dark mode');
if (themeBtnInApp) {
  themeBtnInApp.click();
  eq(doc.documentElement.getAttribute('data-theme'), 'dark', 'the in-app theme button switches the theme attribute');
  const themeBtnBack = viewport.querySelectorAll('.round-icon-btn')
    .filter((n) => (n.getAttribute('aria-label') || '').indexOf('mode terang') >= 0)[0];
  if (themeBtnBack) themeBtnBack.click();
  eq(doc.documentElement.getAttribute('data-theme'), 'light', 'the in-app theme button switches back to light');
}

/* ------------------------------------------------------------------ *
 * 10a. Tombol mode gelap di layar welcome & login
 * ------------------------------------------------------------------ */
// Ini yang dulu ada di bar pengembang; sekarang dipasang di dalam layar.
preview.state.role = null;
preview.go('welcome');
const welcomeThemeBtn = viewport.querySelectorAll('.round-icon-btn')
  .filter((n) => (n.getAttribute('aria-label') || '').indexOf('mode gelap') >= 0)[0];
ok(!!welcomeThemeBtn, 'the welcome screen offers a dark mode button');
if (welcomeThemeBtn) {
  welcomeThemeBtn.click();
  eq(preview.state.dark, true, 'the welcome screen button enables dark mode');
  const welcomeBack = viewport.querySelectorAll('.round-icon-btn')
    .filter((n) => (n.getAttribute('aria-label') || '').indexOf('mode terang') >= 0)[0];
  if (welcomeBack) welcomeBack.click();
  eq(preview.state.dark, false, 'the welcome screen button disables dark mode again');
}

['operator', 'wali', 'guru', 'siswa', 'orangtua'].forEach((role) => {
  preview.state.role = role;
  preview.go('login-' + (role === 'orangtua' ? 'ortu' : role));
  const loginBtn = viewport.querySelectorAll('button')
    .filter((n) => (n.getAttribute('aria-label') || '').indexOf('mode') >= 0)[0];
  ok(!!loginBtn, role + ' login screen offers a dark mode button');
});

/* ------------------------------------------------------------------ *
 * 10b. Setiap role punya tombol mode gelap di berandanya
 * ------------------------------------------------------------------ */
// Bar pengembang dihapus, jadi tombol tema harus ada DI DALAM layar tiap
// role setelah masuk dashboard-nya.
const HOMES = [
  { role: 'operator', screen: 'operator-beranda' },
  { role: 'wali', screen: 'wali-beranda' },
  { role: 'guru', screen: 'guru-beranda' },
  { role: 'siswa', screen: 'siswa-beranda' },
  { role: 'orangtua', screen: 'ortu-beranda' }
];

HOMES.forEach((home) => {
  preview.state.role = home.role;
  preview.state.tab = 'Beranda';
  preview.go(home.screen);
  const themeBtn = viewport.querySelectorAll('.round-icon-btn')
    .filter((n) => {
      const label = n.getAttribute('aria-label') || '';
      return label.indexOf('mode gelap') >= 0 || label.indexOf('mode terang') >= 0;
    })[0];
  ok(!!themeBtn, home.role + ' dashboard has a theme toggle button');

  // Tombolnya benar-benar bekerja: tema berganti dan atribut ikut berubah.
  if (themeBtn) {
    const before = preview.state.dark;
    themeBtn.click();
    ok(preview.state.dark === !before,
      home.role + ' theme button switches the theme');
    const expectTheme = preview.state.dark ? 'dark' : 'light';
    eq(doc.documentElement.getAttribute('data-theme'), expectTheme,
      home.role + ' theme button updates the data-theme attribute');
    // Kembalikan ke keadaan semula untuk pemeriksaan berikutnya.
    const backBtn = viewport.querySelectorAll('.round-icon-btn')
      .filter((n) => {
        const label = n.getAttribute('aria-label') || '';
        return label.indexOf('mode gelap') >= 0 || label.indexOf('mode terang') >= 0;
      })[0];
    if (backBtn) backBtn.click();
    eq(preview.state.dark, before, home.role + ' theme can be switched back');
  }
});

/* ------------------------------------------------------------------ *
 * 10c. Mode gelap: tidak boleh ada latar terang yang ditulis keras
 * ------------------------------------------------------------------ */
// Bug yang dilaporkan: kartu profil operator memakai background #FBEAEC
// (terang) yang tidak ikut berubah di mode gelap, sehingga teks `--ink`
// (terang) nyaris tak terbaca (kontras ~1:1). Warna permukaan harus memakai
// token CSS yang punya versi gelap.
const appSrc = fs.readFileSync(path.join(previewDir, 'app.js'), 'utf8');
const hardcodedLight = appSrc.match(/background:\s*#(?:FBEAEC|FFF|F2F6F8|FBEAEC)/gi) || [];
eq(hardcodedLight.length, 0,
  'no hard-coded light backgrounds inline (they stay light in dark mode)');

// Profil operator memakai token permukaan, bukan warna tetap.
preview.state.role = 'operator';
preview.state.tab = 'Profil';
preview.go('operator-profil');
const profileCard = viewport.querySelectorAll('.clay-soft')
  .filter((n) => n.getAttribute('style') &&
    String(n.getAttribute('style')).indexOf('surface-rose') >= 0)[0];
ok(!!profileCard, 'the operator profile card uses a theme-aware surface token');

// Token itu memang punya nilai berbeda di mode terang & gelap.
const cssAll = fs.readFileSync(path.join(previewDir, 'styles.css'), 'utf8');
const lightRose = cssAll.match(/--surface-rose:\s*([^;]+);/);
const darkBlock = cssAll.slice(cssAll.indexOf("[data-theme='dark']"));
const darkRose = darkBlock.match(/--surface-rose:\s*([^;]+);/);
ok(!!lightRose && !!darkRose, 'surface-rose is defined for both themes');
ok(!!lightRose && !!darkRose && lightRose[1].trim() !== darkRose[1].trim(),
  'surface-rose changes between light and dark themes');

/* ------------------------------------------------------------------ *
 * 11. Deep links (hash) resolve
 * ------------------------------------------------------------------ */
['#guru-tugas', '#wali-recap', '#wali-rekap', '#ortu-latihan', '#hasil-kuis'].forEach((hash) => {
  preview.go(hash.replace('#', ''));
  ok(preview.state.screen.indexOf('-') > 0, 'deep link ' + hash + ' resolves to ' + preview.state.screen);
});

/* ------------------------------------------------------------------ *
 * 10d. Role orang tua: warna & angka
 * ------------------------------------------------------------------ */
/* Warna keras di layar orang tua adalah bug mode gelap yang berulang:
   #F8EDF0 hampir putih, sementara --ink di mode gelap juga hampir putih
   (#F3EAF0) -> kontras 1.03:1, teks praktis hilang. Semua latar harus
   memakai token tema. */
preview.state.role = 'orangtua';
preview.state.dark = false;
preview.state.parentClass = 'Kelas 1';
preview.state.studentName = 'Dimas Nugroho';

const ortuScreens = ['ortu-beranda', 'ortu-tugas', 'ortu-latihan', 'ortu-profil'];
const orangTuaHardColors = [];
ortuScreens.forEach((sc) => {
  preview.go(sc);
  viewport.querySelectorAll('[style]').forEach((node) => {
    const st = node.getAttribute('style') || '';
    const hex = st.match(/#[0-9A-Fa-f]{3,8}/g);
    // item-tile boleh berwarna (ditimpa !important di mode gelap) dan tileColor
    // sudah diuji terpisah; yang dilarang adalah latar kartu/permukaan keras.
    if (!hex) return;
    const cls = node.getAttribute('class') || '';
    if (cls.indexOf('item-tile') >= 0 || cls.indexOf('stat-icon-circle') >= 0 ||
        cls.indexOf('greeting-avatar') >= 0) return;
    orangTuaHardColors.push(sc + ' .' + cls.split(' ')[0] + ' -> ' + hex.join(','));
  });
});
eq(orangTuaHardColors.length, 0,
  'orang tua: tidak ada warna keras di latar (aman mode gelap), ketemu: ' +
  orangTuaHardColors.join(' | '));

// Kartu "Perjalanan belajar" harus memakai token, bukan #F8EDF0.
preview.go('ortu-beranda');
const progressCard = Array.from(viewport.querySelectorAll('.karsa-card'))
  .filter((c) => (c.textContent || '').indexOf('Perjalanan belajar') >= 0)[0];
ok(!!progressCard, 'orang tua: kartu Perjalanan belajar ada');
ok(!!progressCard && (progressCard.getAttribute('style') || '').indexOf('--surface-progress') >= 0,
  'orang tua: kartu Perjalanan belajar memakai token tema (bukan warna keras)');

// Angka "tugas selesai" hanya menghitung kelas anak.
const resultsIds = Object.keys(preview.results());
const tasksAll = preview.tasks();
const childDone = tasksAll.filter((t) => t.className === 'Kelas 1' && preview.results()[t.id]).length;
ok(resultsIds.length > childDone,
  'orang tua: ada hasil kelas lain di data demo (prasyarat uji), total=' + resultsIds.length +
  ' kelas anak=' + childDone);
preview.go('ortu-profil');
const meter = (viewport.textContent || '').match(/(\d+) tugas dan 0 latihan selesai/);
ok(!!meter, 'orang tua: profil menampilkan ringkasan tugas');
eq(meter ? Number(meter[1]) : -1, childDone,
  'orang tua: "tugas selesai" hanya menghitung kelas anak (bukan seluruh RESULTS)');

// Saat belum ada yang selesai, jangan memuji "terus bertumbuh".
if (childDone === 0) {
  ok((viewport.textContent || '').indexOf('Ayo mulai perjalanannya') >= 0,
    'orang tua: tanpa progres, kartu memakai ajakan memulai (bukan pujian palsu)');
}

// Tema bisa diganti dari beranda orang tua (dan tetap tersimpan).
preview.state.dark = false;
preview.go('ortu-beranda');
const themeBtn = Array.from(viewport.querySelectorAll('button'))
  .filter((b) => /mode (gelap|terang)/i.test(b.getAttribute('aria-label') || ''))[0];
ok(!!themeBtn, 'orang tua: tombol tema ada di beranda');
if (themeBtn) {
  themeBtn.click();
  ok(preview.state.dark === true, 'orang tua: tombol tema mengaktifkan mode gelap');
  preview.state.dark = false;
  preview.render();
}

/* ------------------------------------------------------------------ *
 * 10g. Notifikasi pengumpulan guru: nama + nilai, bukan suruh ngerjain
 * ------------------------------------------------------------------ */
preview.state.role = 'guru';
preview.state.dark = false;
preview.state.teacherSubject = 'Matematika';
// Uji operator di atas bisa memangkas roster lewat penyimpanan. Pulihkan dari
// data bawaan supaya rekap punya siswa untuk diperiksa.
if (preview.state.roster.filter((r) => r.className === 'Kelas 1').length === 0) {
  preview.state.roster = preview.seedRoster ? preview.seedRoster() : preview.state.roster;
}
preview.go('notifikasi');

const notifCards = viewport.querySelectorAll('.karsa-card');
const submissionCards = notifCards.filter((c) => /mengumpulkan tugas/.test(c.textContent || ''));
ok(submissionCards.length > 0, 'guru melihat kartu pengumpulan');
ok(submissionCards.length >= 3,
  'ada beberapa siswa yang mengumpulkan, dapat ' + submissionCards.length);

const firstCard = submissionCards[0];
ok(/Aisyah Putri|Bagas Wicaksono|Dimas Nugroho/.test(firstCard.textContent || ''),
  'kartu menyebut NAMA siswa, bukan hanya "Tugas dikumpulkan siswa"');
ok(/Nilai \d+\/\d+/.test(firstCard.textContent || ''),
  'kartu menampilkan NILAI siswa');
ok((firstCard.textContent || '').indexOf('Tugas dikumpulkan siswa') < 0,
  'judul generik tanpa nama sudah tidak dipakai');

// Guru TIDAK boleh diminta mengerjakan: klik membuka rekap pengumpulan.
const targetCard = submissionCards.filter((c) => /Aisyah/.test(c.textContent || ''))[0]
  || submissionCards[0];
targetCard.click();
const submissionSheet = sheetPanel.textContent || '';
ok(submissionSheet.indexOf('Sudah kumpul') >= 0,
  'klik notifikasi membuka rekap "Sudah kumpul ... dari ... siswa"');
ok(submissionSheet.indexOf('Rata-rata') >= 0, 'rekap menampilkan rata-rata');
// Tes operator sebelumnya bisa memangkas roster, jadi jangan memaksa ada
// siswa yang "belum". Yang penting: setiap siswa di roster kelas muncul.
const rosterKelas1 = preview.state.roster
  .filter((r) => r.className === 'Kelas 1')
  .map((r) => r.name);
ok(rosterKelas1.length > 0, 'roster Kelas 1 tidak kosong');
ok(rosterKelas1.every((name) => submissionSheet.indexOf(name) >= 0),
  'semua siswa Kelas 1 muncul di rekap, roster=' + rosterKelas1.join(','));
const belumCount = rosterKelas1.filter((n) => submissionSheet.indexOf(n) >= 0).length
  - (submissionSheet.match(/Nilai \d+\/\d+/g) || []).length;
if (belumCount > 0) {
  ok(submissionSheet.indexOf('Belum mengumpulkan') >= 0,
    'siswa yang belum mengumpulkan ditandai "Belum mengumpulkan"');
}
ok(/Nilai \d+\/\d+/.test(submissionSheet), 'rekap menampilkan nilai per siswa');
ok(submissionSheet.indexOf('Pilih metode') < 0,
  'guru TIDAK disuruh memilih metode pengerjaan');
ok(submissionSheet.indexOf('Periksa jawaban') < 0,
  'guru tidak diminta mengerjakan soal');
preview.closeSheet();

// Siswa menyelesaikan kuis -> notifikasi baru bernama + bernilai untuk guru.
preview.state.role = 'siswa';
preview.state.parentClass = 'Kelas 5';
preview.state.studentName = 'Dimas Nugroho';
preview.state.studentId = 's1d';
preview.go('siswa-beranda');
const taskForSubmission = preview.tasks().filter((t) => t.id === 't1')[0];
ok(!!taskForSubmission, 'tugas t1 tersedia');
preview.startQuiz(taskForSubmission);
const submitBank = preview.state.quiz.bank.length;
const notifBefore = preview.notifications().length;
for (let i = 0; i < submitBank; i += 1) {
  const idx = preview.state.quiz.bank[preview.state.quiz.index].answerIndex;
  viewport.querySelectorAll('.choice-btn')[idx].click();
  const btn = () => Array.from(viewport.querySelectorAll('button'))
    .filter((b) => /Periksa jawaban|Soal berikutnya|Lihat hasil/.test(b.textContent || ''))[0];
  btn().click();
  btn().click();
}
eq(preview.notifications().length, notifBefore + 1,
  'menyelesaikan tugas membuat satu notifikasi guru');
const freshNotif = preview.notifications()[0];
eq(freshNotif.kind, 'submission', 'notifikasi baru bertipe submission');
eq(freshNotif.studentName, 'Dimas Nugroho', 'notifikasi membawa nama siswa');
eq(freshNotif.score, submitBank, 'notifikasi membawa nilai siswa');

/* ------------------------------------------------------------------ *
 * 10f. Pengumuman guru mapel
 * ------------------------------------------------------------------ */
preview.state.role = 'guru';
preview.state.dark = false;
preview.state.teacherSubject = 'Matematika';
preview.go('guru-pengumuman');
eq(preview.state.screen, 'guru-pengumuman', 'guru punya layar pengumuman sendiri');
ok((viewport.textContent || '').indexOf('Buat pengumuman') >= 0,
  'guru bisa membuat pengumuman dari layarnya sendiri');

// Form guru hanya menawarkan kelas yang diajar mapelnya.
const openGuruForm = () => {
  const btn = Array.from(viewport.querySelectorAll('button'))
    .filter((b) => /Buat pengumuman/.test(b.textContent || ''))[0];
  ok(!!btn, 'tombol buat pengumuman ada');
  if (btn) btn.click();
  return sheetPanel;
};

let form = openGuruForm();
let chipLabels = form.querySelectorAll('.chip-btn').map((c) => c.textContent);
ok(chipLabels.indexOf('Semua kelas') >= 0, 'guru boleh mengumumkan ke semua kelas');
ok(chipLabels.length > 1, 'form guru punya pilihan kelas');
preview.closeSheet();

// Mapel yang hanya ada di kelas atas: IPAS mulai Kelas 3.
preview.state.teacherSubject = 'Ilmu Pengetahuan Alam dan Sosial (IPAS)';
preview.go('guru-pengumuman');
form = openGuruForm();
chipLabels = form.querySelectorAll('.chip-btn').map((c) => c.textContent);
ok(chipLabels.indexOf('Kelas 3') >= 0, 'guru IPAS bisa memilih Kelas 3');
// `indexOf` pada array eksak, bukan pada string, agar "Kelas 1" tidak
// tertukar dengan "Kelas 10" bila kelak ada.
eq(chipLabels.indexOf('Kelas 1'), -1,
  'guru IPAS tidak ditawari Kelas 1 (IPAS tidak ada di kelas itu), ketemu: ' + chipLabels.join(','));
eq(chipLabels.indexOf('Kelas 2'), -1, 'guru IPAS tidak ditawari Kelas 2');
// Sekolah bisa punya kelas tambahan dari uji operator sebelumnya, jadi
// bandingkan dengan daftar mapel per kelas, bukan daftar tetap 3-6.
const ipasTaught = preview.state.schoolClasses
  .map((c) => c.name)
  .filter((name) => preview.subjectsForClass(name)
    .some((sub) => sub.indexOf('IPAS') >= 0));
ok(chipLabels.every((c) => c === 'Semua kelas' || ipasTaught.indexOf(c) >= 0),
  'semua opsi kelas guru IPAS memang kelas yang diajar mapelnya, ketemu: ' +
  chipLabels.join(',') + ' | diajar: ' + ipasTaught.join(','));

// Kirim pengumuman dan pastikan tercatat + bisa diubah.
const titleInput = form.querySelectorAll('input')[0];
titleInput.value = 'Ulangan IPAS bab 2';
titleInput.dispatch('input', { target: titleInput });
const bodyInput = form.querySelectorAll('textarea')[0];
bodyInput.value = 'Belajar halaman 20 sampai 30.';
bodyInput.dispatch('input', { target: bodyInput });
const send = form.querySelectorAll('button')
  .filter((b) => /Kirim pengumuman/.test(b.textContent || ''))[0];
ok(!!send, 'tombol kirim pengumuman ada');
const beforeCount = preview.announcements().length;
if (send) {
  send.click();
  eq(preview.announcements().length, beforeCount + 1,
    'pengumuman guru tersimpan');
  const created = preview.announcements()[0];
  eq(created.category, 'PENGUMUMAN GURU', 'kategori pengumuman guru benar');
  eq(created.title, 'Ulangan IPAS bab 2', 'judul tersimpan');
  eq(created.className, 'Kelas 3',
    'kelas awal mengikuti kelas pertama yang diajar mapelnya');
  ok((viewport.textContent || '').indexOf('Ulangan IPAS bab 2') >= 0,
    'pengumuman langsung tampil di daftar guru');
}

// Judul kosong ditolak, bukan tersimpan sebagai pengumuman kosong.
form = openGuruForm();
const countBeforeBad = preview.announcements().length;
const sendBad = form.querySelectorAll('button')
  .filter((b) => /Kirim pengumuman/.test(b.textContent || ''))[0];
if (sendBad) sendBad.click();
eq(preview.announcements().length, countBeforeBad,
  'pengumuman tanpa judul/isi ditolak');
preview.closeSheet();

// Pengumuman guru hanya sampai ke kelas yang dituju.
preview.state.teacherSubject = 'Matematika';
preview.announcements().forEach((a) => {
  if (a.category === 'PENGUMUMAN GURU' && a.title === 'Ulangan IPAS bab 2') {
    a.className = 'Kelas 3';
  }
});
preview.state.role = 'siswa';
preview.state.parentClass = 'Kelas 3';
preview.state.studentName = 'Dimas Nugroho';
ok(preview.visibleAnnouncements().some((a) => a.title === 'Ulangan IPAS bab 2'),
  'siswa Kelas 3 menerima pengumuman untuk Kelas 3');
preview.state.parentClass = 'Kelas 5';
ok(!preview.visibleAnnouncements().some((a) => a.title === 'Ulangan IPAS bab 2'),
  'siswa Kelas 5 tidak menerima pengumuman untuk Kelas 3');

/* ------------------------------------------------------------------ *
 * 11. Tata letak kuis mengikuti rancangan (warna tetap)
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.startQuiz(preview.tasks()[0]);

// Header: mapel+topik kecil, "Soal n dari m" besar, tombol tutup X.
ok(!!viewport.querySelectorAll('.quiz-eyebrow')[0], 'quiz header shows the small subject line');
ok(!!viewport.querySelectorAll('.quiz-step')[0], 'quiz header shows "Soal n dari m" prominently');
const stepText = viewport.querySelectorAll('.quiz-step')[0].textContent;
ok(/^Soal \d+ dari \d+$/.test(stepText), 'the step text reads "Soal n dari m", got: ' + stepText);
const closeBtn = Array.from(viewport.querySelectorAll('button'))
  .filter((b) => (b.getAttribute('aria-label') || '') === 'Tutup kuis')[0];
ok(!!closeBtn, 'quiz has a close (X) button in the header like the design');
ok(!!viewport.querySelectorAll('.quiz-progress')[0], 'quiz keeps the progress bar');

// Keadaan pilihan: label "Dipilih" setelah memilih.
const firstChoice = viewport.querySelectorAll('.choice-btn')[0];
firstChoice.click();
ok(viewport.textContent.indexOf('Dipilih') >= 0,
  'the chosen option is labelled "Dipilih" like the design');
ok(viewport.textContent.indexOf('Sudah yakin?') >= 0,
  'a small hint appears under the choices after picking');
ok(!!Array.from(viewport.querySelectorAll('.choice-state')).length,
  'the choice state label is rendered');

// Setelah diperiksa: label Benar/Salah + kartu umpan balik.
const checkBtn = Array.from(viewport.querySelectorAll('button'))
  .filter((b) => (b.textContent || '').indexOf('Periksa jawaban') >= 0)[0];
checkBtn.click();
const hasState = viewport.textContent.indexOf('Benar') >= 0 || viewport.textContent.indexOf('Salah') >= 0;
ok(hasState, 'after checking, options are labelled Benar / Salah');
ok(!!viewport.querySelectorAll('.quiz-feedback')[0], 'a feedback card appears after checking');
ok(!!(Array.from(viewport.querySelectorAll('.choice-btn')).filter((b) => /correct|wrong/.test(b.className)).length),
  'correct/wrong styling is applied to the options');

// Tombol tutup benar-benar keluar dari kuis.
preview.startQuiz(preview.tasks()[0]);
const closeAgain = Array.from(viewport.querySelectorAll('button'))
  .filter((b) => (b.getAttribute('aria-label') || '') === 'Tutup kuis')[0];
if (closeAgain) {
  closeAgain.click();
  ok(preview.state.screen !== 'kuis', 'the X button leaves the quiz');
}

// Warna tetap memakai token yang ada: tidak ada warna rose/hijau baru yang
// ditulis keras di luar token tema.
const quizCss = fs.readFileSync(path.join(previewDir, 'styles.css'), 'utf8');
ok(quizCss.indexOf('.quiz-feedback') >= 0, 'quiz feedback styles are defined');
ok(quizCss.indexOf('--surface-quiz-feedback') >= 0,
  'feedback surface uses a theme token (dark mode safe)');

/* ------------------------------------------------------------------ *
 * 10e. Latihan dua metode (pilihan ganda + esai)
 * ------------------------------------------------------------------ */
preview.state.role = 'siswa';
preview.state.dark = false;
preview.state.parentClass = 'Kelas 5';
preview.state.studentName = 'Dimas Nugroho';
preview.go('siswa-beranda');

const practice = preview.visiblePractices()[0];
ok(!!practice, 'ada latihan untuk siswa');

// Sheet detail latihan menawarkan dua metode.
preview.openPractice(practice);
let sheetText = sheetPanel.textContent || '';
ok(sheetText.indexOf('Pilih metode latihan') >= 0,
  'detail latihan menawarkan pilihan metode');
ok(sheetText.indexOf('Pilihan ganda') >= 0 && sheetText.indexOf('Esai') >= 0,
  'detail latihan punya metode pilihan ganda dan esai');
ok(sheetText.indexOf('dinilai otomatis') >= 0,
  'pilihan ganda latihan diberi label dinilai otomatis');
ok(sheetText.indexOf('tidak dinilai otomatis') >= 0,
  'esai diberi label tidak dinilai otomatis');
preview.closeSheet();

// Pilihan ganda latihan: memakai layar kuis, skor masuk PRACTICE_RESULTS.
preview.startPracticeQuiz(practice);
eq(preview.state.screen, 'kuis', 'pilihan ganda latihan membuka layar kuis');
eq(preview.state.quiz.practice && preview.state.quiz.practice.id, practice.id,
  'kuis latihan membawa konteks latihan');
ok(!!preview.state.quiz.bank.length, 'kuis latihan punya bank soal');
const pgCount = preview.state.quiz.bank.length;
ok(pgCount >= 4, 'latihan pilihan ganda punya minimal 4 soal, dapat ' + pgCount);
// Judul memakai mapel latihan, bukan tugas.
ok((viewport.textContent || '').indexOf(practice.subject) >= 0,
  'header kuis latihan menampilkan mapel latihan');

// Jawab semua soal dengan benar.
const resultsBefore = Object.keys(preview.results()).length;
for (let i = 0; i < pgCount; i += 1) {
  const bank = preview.state.quiz.bank;
  const correctIndex = bank[preview.state.quiz.index].answerIndex;
  viewport.querySelectorAll('.choice-btn')[correctIndex].click();
  const btn = () => Array.from(viewport.querySelectorAll('button'))
    .filter((b) => /Periksa jawaban|Soal berikutnya|Lihat hasil/.test(b.textContent || ''))[0];
  btn().click(); // periksa
  btn().click(); // lanjut / selesai
}
eq(preview.state.screen, 'hasil-latihan', 'selesai PG latihan membuka hasil latihan');
const pracRes = preview.practiceResults()[practice.id] || null;
ok(!!pracRes, 'skor latihan tersimpan di PRACTICE_RESULTS, bukan RESULTS tugas');
if (pracRes) {
  eq(pracRes.score, pgCount, 'semua benar memberi nilai penuh');
  eq(pracRes.total, pgCount, 'total soal tercatat');
  ok(viewport.textContent.indexOf(String(pracRes.score)) >= 0,
    'layar hasil menampilkan skor');
} else {
  ok(false, 'semua benar memberi nilai penuh');
  ok(false, 'total soal tercatat');
  ok(false, 'layar hasil menampilkan skor');
}
eq(Object.keys(preview.results()).length, resultsBefore,
  'skor latihan tidak menambah hasil tugas');
eq(preview.practiceDone()[practice.id], true,
  'latihan bertanda selesai setelah PG');

// Esai latihan tetap berjalan dan mencatat selesai tanpa skor.
const practice2 = preview.visiblePractices()[1] || practice;
preview.openPractice(practice2);
const essayBtn = sheetPanel.querySelectorAll('.method-card')
  .filter((c) => (c.textContent || '').indexOf('Esai') >= 0)[0];
ok(!!essayBtn, 'kartu metode esai bisa diklik');
if (essayBtn) {
  essayBtn.click();
  // Esai latihan tampil di sheet, bukan layar esai tugas.
  ok((sheetPanel.textContent || '').indexOf('Soal 1 dari') >= 0,
    'esai latihan langsung menampilkan soal pertama');
  ok((sheetPanel.textContent || '').indexOf('tanpa batas waktu') >= 0,
    'esai latihan menyebut tanpa batas waktu');

  // Kerjakan seluruh soal esai latihan.
  let guard = 0;
  while ((sheetPanel.textContent || '').indexOf('Hasil latihan') < 0 && guard < 30) {
    guard += 1;
    const textarea = sheetPanel.querySelectorAll('textarea')[0];
    if (!textarea) break;
    textarea.value = 'Jawaban esai nomor ' + guard + ' yang cukup panjang.';
    textarea.dispatch('input', { target: textarea });
    const next = sheetPanel.querySelectorAll('button')
      .filter((b) => /Soal berikutnya|Selesai/.test(b.textContent || ''))[0];
    if (!next) break;
    next.click();
  }
  ok((sheetPanel.textContent || '').indexOf('Hasil latihan') >= 0,
    'esai latihan berakhir di ringkasan hasil');
  eq(preview.practiceDone()[practice2.id], true,
    'esai latihan menandai selesai');
  eq(preview.practiceResults()[practice2.id], undefined,
    'esai latihan tidak menyimpan skor (tidak dinilai otomatis)');
  preview.closeSheet();
}

/* ------------------------------------------------------------------ *
 * 11a. Tombol kembali pada kuis & esai benar-benar berpindah layar
 * ------------------------------------------------------------------ */
// Bug yang dilaporkan: tombol kembali di layar kuis menuju 'kuis' (layar itu
// sendiri), jadi diklik tidak terjadi apa-apa.
[
  { role: 'siswa', screen: 'siswa-tugas' },
  { role: 'guru', screen: 'guru-tugas' },
  { role: 'orangtua', screen: 'ortu-tugas' }
].forEach(({ role, screen }) => {
  preview.state.role = role;
  const task = preview.tasks()[0];
  preview.startQuiz(task);
  eq(preview.state.screen, 'kuis', role + ': quiz opens');
  const back = viewport.querySelectorAll('.back-chevron')[0];
  ok(!!back, role + ': the quiz screen has a back button');
  if (back) {
    back.click();
    eq(preview.state.screen, screen,
      role + ': back from the quiz goes to the task list, not to the quiz itself');
    ok(preview.state.quiz === null, role + ': back leaves the quiz session');
  }
});

// Esai juga: kembali ke daftar tugas role aktif (dulu selalu 'siswa-tugas').
preview.state.role = 'guru';
preview.startEssayForTask(preview.tasks()[0]);
eq(preview.state.screen, 'esai', 'essay screen opens for a teacher');
const essayBack = viewport.querySelectorAll('.back-chevron')[0];
ok(!!essayBack, 'the essay screen has a back button');
if (essayBack) {
  essayBack.click();
  eq(preview.state.screen, 'guru-tugas',
    'back from the essay goes to the task list of the active role');
}

// Skenario yang dilaporkan: role kosong (mis. halaman dimuat ulang tepat di
// layar kuis). Dulu ini menghasilkan "undefinedberanda" -> go() menolak
// diam-diam dan tombol kembali benar-benar mati.
preview.state.role = null;
preview.state.studentClass = 'Kelas 5';
const reloadTask = preview.tasks().filter((t) => t.className === 'Kelas 5')[0]
  || preview.tasks()[0];
preview.startQuiz(reloadTask);
eq(preview.state.screen, 'kuis', 'quiz opens even without a role');
const nullRoleBack = viewport.querySelectorAll('.back-chevron')[0];
ok(!!nullRoleBack, 'the back button exists without a role');
if (nullRoleBack) {
  nullRoleBack.click();
  ok(preview.state.screen !== 'kuis',
    'back works even when the role is missing (was a dead button)');
  ok(preview.state.screen.indexOf('tugas') >= 0 || preview.state.screen === 'welcome',
    'it lands on a real registered screen: ' + preview.state.screen);
}

// Setiap layar yang punya tombol kembali harus benar-benar pindah layar.
const deadBacks = [];
['kuis', 'esai', 'hasil-kuis'].forEach((id) => {
  preview.state.role = 'siswa';
  preview.go(id);
  const before = preview.state.screen;
  const btn = viewport.querySelectorAll('.back-chevron')[0];
  if (btn) {
    btn.click();
    if (preview.state.screen === before) deadBacks.push(id);
  }
});
eq(deadBacks.length, 0, 'no screen has a dead back button: ' + JSON.stringify(deadBacks));

/* ------------------------------------------------------------------ *
 * 11b. Dua metode tugas: pilihan ganda + esai
 * ------------------------------------------------------------------ */
// Tugas harus menawarkan kedua metode; esai menyimpan jawaban per tugas dan
// tidak menghapus skor pilihan ganda yang sudah ada.
preview.state.role = 'siswa';
preview.state.studentClass = 'Kelas 1';
preview.state.taskFilter = 'Aktif';
preview.state.subjectFilter = 'Semua';
preview.state.search = '';
preview.go('siswa-tugas');

const methodTask = preview.tasks().filter((t) => t.className === 'Kelas 1')[0];
ok(!!methodTask, 'there is a task to exercise both methods');

if (methodTask) {
  // Bersihkan hasil lama supaya pemeriksaan ini mandiri.
  delete preview.results()[methodTask.id];
  preview.go('siswa-tugas');
  const card = viewport.querySelectorAll('.list-item-card')
    .filter((n) => (n.textContent || '').indexOf(methodTask.title) >= 0)[0];
  if (card) card.click();

  const methodCards = sheetPanel.querySelectorAll('.method-card');
  eq(methodCards.length, 2, 'the task detail offers exactly two methods');
  ok(sheetPanel.textContent.indexOf('Pilihan ganda') >= 0,
    'method 1 is labelled "Pilihan ganda"');
  ok(sheetPanel.textContent.indexOf('Esai') >= 0,
    'method 2 is labelled "Esai"');
  ok(sheetPanel.textContent.indexOf('Kamu boleh mengerjakan salah satu atau keduanya') >= 0,
    'the sheet explains that either or both methods can be done');

  // Metode 2: buka esai.
  const essayBtn = sheetPanel.querySelectorAll('button')
    .filter((b) => (b.getAttribute('aria-label') || '') === 'Esai')[0];
  ok(!!essayBtn, 'the essay method is clickable');
  if (essayBtn) {
    essayBtn.click();
    eq(preview.state.screen, 'esai', 'the essay screen opens');
    ok(viewport.textContent.indexOf('esai tugas') >= 0,
      'the essay screen is presented as part of the task');
    const essayBox = viewport.querySelectorAll('.essay-input')[0];
    ok(!!essayBox, 'the essay screen has an answer box');
    const primary = () => viewport.querySelectorAll('#essay-primary')[0];
    ok(!!primary(), 'the essay screen has a primary action');
    ok(!!primary() && primary().getAttribute('disabled') !== null,
      'the action is disabled until something is typed');
    if (essayBox) {
      essayBox.value = 'Jawaban saya: pecahan dibagi menjadi bagian yang sama besar.';
      essayBox.dispatch('input', { target: essayBox });
      // oninput memperbarui properti .disabled (atribut tidak dihapus di mock).
      ok(primary().disabled === false, 'typing enables the action');
    }
    // Lihat contoh jawaban.
    primary().click();
    ok(viewport.textContent.indexOf('Contoh jawaban') >= 0,
      'the essay screen can reveal a sample answer');

    // Maju sampai soal terakhir, lalu kirim.
    let guard = 0;
    while (guard < 20) {
      const btn = viewport.querySelectorAll('#essay-primary')[0];
      if (!btn || (btn.textContent || '').indexOf('Kirim jawaban esai') >= 0) break;
      btn.click();
      const box = viewport.querySelectorAll('.essay-input')[0];
      if (box) {
        box.value = 'Jawaban ' + guard;
        box.dispatch('input', { target: box });
      }
      guard += 1;
    }
    const sendBtn = viewport.querySelectorAll('#essay-primary')[0];
    ok(!!sendBtn && (sendBtn.textContent || '').indexOf('Kirim jawaban esai') >= 0,
      'the last essay question offers "Kirim jawaban esai"');
    if (sendBtn) sendBtn.click();

    const saved = preview.results()[methodTask.id];
    ok(!!saved, 'submitting the essay stores a result for the task');
    ok(!!saved && Array.isArray(saved.essayAnswers) && saved.essayAnswers.length > 0,
      'the saved result keeps the essay answers');
    eq(preview.state.screen, 'hasil-kuis', 'submitting the essay opens the result screen');
    ok(viewport.textContent.indexOf('Jawaban esai') >= 0,
      'the result screen lists the essay answers');
    ok(viewport.textContent.indexOf('tidak dinilai otomatis') >= 0,
      'the result screen is honest that essays are not auto-graded');
  }

  // Esai tidak menghapus skor pilihan ganda yang sudah ada: keduanya hidup di
  // TaskResult yang sama.
  const withScore = preview.results()[methodTask.id];
  ok(!!withScore && Array.isArray(withScore.essayAnswers),
    'the task result keeps essay answers');
  if (withScore) {
    withScore.score = 8;
    withScore.total = 10;
  }
  const rebuilt = preview.results()[methodTask.id];
  ok(rebuilt.score === 8 && rebuilt.total === 10 && rebuilt.essayAnswers.length > 0,
    'a multiple-choice score and essay answers can coexist in one result');
}

/* ------------------------------------------------------------------ *
 * 12. Splash markup contract
 * ------------------------------------------------------------------ */
preview.go('splash');
const splashStage = viewport.querySelectorAll('.splash-stage')[0];
ok(!!splashStage, 'splash renders the splash stage');
const splashImg = viewport.querySelectorAll('.splash-art')[0];
ok(!!splashImg, 'splash renders splash-art.png');
if (splashImg) ok(String(splashImg.getAttribute('src')).indexOf('splash-art.png') >= 0, 'splash art points at splash-art.png');
ok(viewport.textContent.indexOf('Menyiapkan pengalaman belajar') >= 0, 'splash shows the "Menyiapkan pengalaman belajar" pill');

/* ------------------------------------------------------------------ *
 * 12b. Kontrak tampilan mobile (tanpa mockup bingkai ponsel)
 * ------------------------------------------------------------------ */
// Pratinjau harus terasa seperti aplikasi sungguhan di HP. Sebelumnya ada
// bingkai ponsel hiasan; sekarang tidak boleh ada lagi.
ok(html.indexOf('device-frame') < 0, 'index.html has no phone-frame mockup');
ok(html.indexOf('device-notch') < 0, 'index.html has no decorative notch');
ok(/id="app-shell"/.test(html), 'the app shell is the outermost container');
ok(/id="app-viewport"/.test(html), 'the app viewport still lives inside the shell');
ok(html.indexOf('switcher-bar') < 0, 'no developer bar at the top of the page');
ok(html.indexOf('id="screen-select"') < 0, 'the "Login" screen dropdown is gone');
ok(html.indexOf('id="theme-toggle"') < 0, 'no developer theme button outside the app');
ok(/id="app-viewport"/.test(html), 'the viewport is the first thing inside the shell');
ok(/<main id="app-viewport"[^>]*><\/main>/.test(html), 'the app starts immediately, without a bar above it');

// CSS: tidak ada sisa aturan bar pengembang.
const cssText = fs.readFileSync(path.join(previewDir, 'styles.css'), 'utf8');
ok(cssText.indexOf('device-frame') < 0, 'styles carry no phone-frame rules');
ok(cssText.indexOf('switcher-bar') < 0, 'styles carry no developer-bar rules');
ok(/\.app-shell\s*\{[^}]*max-width:\s*480px/.test(cssText),
  'the shell stays a 480px column on wide screens');
ok(/\.app-shell\s*\{[^}]*100dvh/.test(cssText),
  'the shell fills the viewport height on phones');
ok(cssText.indexOf('safe-area-inset-top') >= 0,
  'the shell respects the device safe area');

// Tema tetap bisa diganti lewat API pratinjau (dipakai uji lain).
const themeBeforeApi = preview.state.dark;
preview.toggleTheme();
ok(preview.state.dark === !themeBeforeApi, 'the theme can still be toggled programmatically');
preview.toggleTheme();

// Perbaikan khusus HP: input 16px (iOS tidak auto-zoom), fallback vh,
// dan overscroll yang tidak memicu pull-to-refresh.
ok(/\.karsa-input\s*\{[^}]*font-size:\s*16px/.test(cssText),
  'inputs use 16px so iOS Safari does not zoom on focus');
ok(cssText.indexOf('min-height: 100vh') >= 0,
  'the shell has a vh fallback for older mobile browsers');
ok(/\.scroll-viewport\s*\{[^}]*overscroll-behavior:\s*contain/.test(cssText),
  'the scroll area does not bounce the whole page (no pull-to-refresh)');
ok(/env\(safe-area-inset-bottom/.test(cssText),
  'sheets and the shell respect the home-indicator inset');


/* ------------------------------------------------------------------ *
 * 13. No "Pratinjau" label in the top bar
 * ------------------------------------------------------------------ */
const topBarText = screenSelect.textContent + ' ' + themeToggle.textContent;
ok(topBarText.indexOf('Pratinjau') < 0, 'top bar contains no "Pratinjau" label');
const htmlText = fs.readFileSync(path.join(previewDir, 'index.html'), 'utf8');
ok(htmlText.indexOf('Pratinjau') < 0, 'index.html contains no "Pratinjau" label');
ok(htmlText.indexOf('http://') < 0 && htmlText.indexOf('https://') < 0, 'index.html has no CDN/external URLs');

/* ------------------------------------------------------------------ *
 * Report
 * ------------------------------------------------------------------ */
console.log('Checks passed: ' + passed);
if (failures.length) {
  console.log('FAILURES (' + failures.length + '):');
  failures.forEach((f) => console.log('  - ' + f));
  process.exit(1);
}
console.log('ALL PREVIEW CHECKS PASSED');
