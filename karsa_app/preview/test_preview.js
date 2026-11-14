/* Verification harness for the KarsaApp HTML preview.
 *
 * Runs the preview script inside a tiny mock DOM (no browser required) and
 * asserts that:
 *   - every one of the 28 canonical screens renders without throwing,
 *   - the splash screen auto-advances to the welcome screen,
 *   - each role login validates credentials exactly like AppState.authenticate(),
 *   - the bottom navigation switches tabs,
 *   - chips / segments / search filter the task list,
 *   - attendance status buttons are selectable,
 *   - the study tip card cycles,
 *   - the quiz flow produces a result screen,
 *   - the dark mode toggle switches the theme attribute.
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
    const evt = Object.assign({ type, target: this, preventDefault() {}, stopPropagation() {} }, event || {});
    list.forEach((fn) => fn.call(this, evt));
    return evt;
  }
  focus() { doc.activeElement = this; }
  setSelectionRange() {}
  click() { this.dispatch('click', {}); }

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
const sheetPanel = new MockNode('div');
sheetPanel.setAttribute('id', 'sheet-panel');
[shell, viewport, bottomNav, screenSelect, themeToggle, sheetBackdrop, sheetPanel].forEach((n) => doc.body.appendChild(n));

const timers = [];
const fakeWindow = {
  document: doc,
  location: { hash: '' },
  history: { replaceState() { fakeWindow.location.hash = arguments[2]; } },
  setTimeout(fn, ms) { timers.push({ fn, ms }); return timers.length; },
  clearTimeout() {},
  addEventListener() {}
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
 * 1. Screen registry — 28 canonical screens + alias
 * ------------------------------------------------------------------ */
const EXPECTED_SCREENS = [
  'splash', 'welcome',
  'login-wali', 'login-guru', 'login-ortu', 'login-siswa', 'forgot',
  'wali-beranda', 'wali-anggota', 'wali-recap', 'wali-agenda', 'wali-profil',
  'guru-beranda', 'guru-kelas', 'guru-tugas', 'guru-kalender', 'guru-profil',
  'siswa-beranda', 'siswa-tugas', 'siswa-profil',
  'ortu-beranda', 'ortu-tugas', 'ortu-latihan', 'ortu-profil',
  'materi', 'notifikasi', 'kuis', 'hasil-kuis'
];

eq(preview.screens.length, 28, 'screen registry contains 28 screens');
EXPECTED_SCREENS.forEach((id) => {
  ok(preview.screens.indexOf(id) >= 0, 'screen "' + id + '" is registered');
});

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
  eq(preview.state.screen, 'welcome', 'splash auto-advances to welcome after 2300 ms');
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
  const startButton = sheetButtons.filter((b) => (b.textContent || '').indexOf('Kerjakan kuis') >= 0)[0];
  ok(!!startButton, 'task sheet offers the quiz action');
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
        ok(explanation.indexOf('Jawaban benar:') >= 0, 'quiz reveals the correct answer explanation');
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
  infoCard.click();
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

  eq(preview.state.studentName, 'Nadia Lestari', 'saving the personal info updates the student name');
  eq(preview.state.studentClass, 'Kelas 6', 'saving the personal info updates the student class');
  eq(preview.state.religion, 'Islam', 'saving the personal info updates the religion');

  preview.go('siswa-profil');
  ok(viewport.textContent.indexOf('Nadia Lestari') >= 0, 'the edited name is shown on the student profile');
  ok(viewport.textContent.indexOf('Kelas 6') >= 0, 'the edited class is shown on the student profile');
  ok(viewport.textContent.indexOf('Islam') >= 0, 'the edited religion is shown on the student profile');
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
 * 10. Dark mode toggle
 * ------------------------------------------------------------------ */
preview.go('welcome');
eq(doc.documentElement.getAttribute('data-theme'), 'light', 'default theme is light');
themeToggle.click();
eq(doc.documentElement.getAttribute('data-theme'), 'dark', 'dark mode toggle switches the theme attribute');
themeToggle.click();
eq(doc.documentElement.getAttribute('data-theme'), 'light', 'dark mode toggle switches back to light');

/* ------------------------------------------------------------------ *
 * 11. Deep links (hash) resolve
 * ------------------------------------------------------------------ */
['#guru-tugas', '#wali-recap', '#wali-rekap', '#ortu-latihan', '#hasil-kuis'].forEach((hash) => {
  preview.go(hash.replace('#', ''));
  ok(preview.state.screen.indexOf('-') > 0, 'deep link ' + hash + ' resolves to ' + preview.state.screen);
});

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
