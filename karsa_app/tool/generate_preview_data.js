#!/usr/bin/env node
/**
 * Regenerates karsa_app/preview/curriculum-data.js from the original
 * curriculum.js (repo root) and the Ionicons glyph map.
 *
 * The generated file exposes the same data as the Flutter
 * `lib/data/curriculum_data.dart` (QuizQuestion / EssayPrompt field names) so
 * the HTML preview and the Flutter app read identical content.
 *
 * Usage:  node karsa_app/tool/generate_preview_data.js
 */
'use strict';

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..', '..');
const OUT_FILE = path.resolve(__dirname, '..', 'preview', 'curriculum-data.js');

/* Ionicons codepoints, extracted from @expo/vector-icons 15.0.2
 * (see tool/extract_ionicons.py and lib/core/widgets/karsa_icons.dart). */
const ICON_PROPS = {
  chevronBack: 0xf229,
  chevronForward: 0xf23b,
  sunnyOutline: 0xf5ae,
  moonOutline: 0xf461,
  notificationsOutline: 0xf47f,
  people: 0xf49f,
  checkmarkCircle: 0xf21e,
  pencil: 0xf49c,
  book: 0xf1a5,
  refreshOutline: 0xf518,
  grid: 0xf355,
  megaphone: 0xf44e,
  personOutline: 0xf4ac,
  bookOutline: 0xf1a6,
  shieldCheckmarkOutline: 0xf579,
  helpCircleOutline: 0xf37e,
  checkmark: 0xf21d,
  albums: 0xf10f,
  checkmarkDone: 0xf221,
  cardOutline: 0xf1e8,
  lockClosedOutline: 0xf3c8,
  eyeOffOutline: 0xf2e8,
  eyeOutline: 0xf2ea,
  home: 0xf382,
  barChart: 0xf16f,
  calendar: 0xf1cf,
  person: 0xf4a5
};

const ICON_NAMES = [
  'chevron-back', 'chevron-forward', 'sunny-outline', 'moon-outline',
  'notifications-outline', 'people', 'checkmark-circle', 'pencil', 'book',
  'refresh-outline', 'grid', 'megaphone', 'person-outline', 'book-outline',
  'shield-checkmark-outline', 'help-circle-outline', 'checkmark', 'albums',
  'checkmark-done', 'card-outline', 'lock-closed-outline', 'eye-off-outline',
  'eye-outline', 'home', 'bar-chart', 'calendar', 'person'
];

const ICON_PROPS_BY_NAME = {
  'chevron-back': 'chevronBack',
  'chevron-forward': 'chevronForward',
  'sunny-outline': 'sunnyOutline',
  'moon-outline': 'moonOutline',
  'notifications-outline': 'notificationsOutline',
  'people': 'people',
  'checkmark-circle': 'checkmarkCircle',
  'pencil': 'pencil',
  'book': 'book',
  'refresh-outline': 'refreshOutline',
  'grid': 'grid',
  'megaphone': 'megaphone',
  'person-outline': 'personOutline',
  'book-outline': 'bookOutline',
  'shield-checkmark-outline': 'shieldCheckmarkOutline',
  'help-circle-outline': 'helpCircleOutline',
  'checkmark': 'checkmark',
  'albums': 'albums',
  'checkmark-done': 'checkmarkDone',
  'card-outline': 'cardOutline',
  'lock-closed-outline': 'lockClosedOutline',
  'eye-off-outline': 'eyeOffOutline',
  'eye-outline': 'eyeOutline',
  'home': 'home',
  'bar-chart': 'barChart',
  'calendar': 'calendar',
  'person': 'person'
};

/* Faith examples, ported 1:1 from lib/data/curriculum_data.dart. */
const FAITH_EXAMPLES = {
  Islam: ['masjid', 'salat'],
  Kristen: ['gereja', 'berdoa'],
  Katolik: ['gereja', 'mengasihi sesama'],
  Hindu: ['pura', 'berdoa'],
  Buddha: ['vihara', 'berbuat baik'],
  Konghucu: ['kelenteng', 'menghormati sesama']
};

async function loadCurriculum() {
  const file = path.join(REPO_ROOT, 'curriculum.js');
  const url = require('url').pathToFileURL(file).href;
  return import(url);
}

function normalizeQuizItem(item) {
  return {
    question: item.q,
    choices: item.choices,
    answerIndex: item.answer,
    explanation: item.explain
  };
}

function normalizePracticeItem(item) {
  return { prompt: item[0], sampleAnswer: item[1] };
}

(async function main() {
  const curriculum = await loadCurriculum();

  const icons = {};
  ICON_NAMES.forEach((name) => {
    const prop = ICON_PROPS_BY_NAME[name];
    icons[name] = String.fromCodePoint(ICON_PROPS[prop]);
  });

  const quizBank = {};
  Object.keys(curriculum.quizBank).forEach((subject) => {
    quizBank[subject] = curriculum.quizBank[subject].map(normalizeQuizItem);
  });

  const practiceBank = {};
  Object.keys(curriculum.practiceBank).forEach((subject) => {
    practiceBank[subject] = curriculum.practiceBank[subject].map(normalizePracticeItem);
  });

  const payload = {
    subjectInfo: curriculum.subjectInfo,
    subjects: curriculum.subjects,
    quizBank,
    practiceBank,
    religions: curriculum.religions,
    faithExamples: FAITH_EXAMPLES,
    icons
  };

  const helperSource = `
/* Mirrors lib/data/curriculum_data.dart */
window.KARSA_CURRICULUM.normalizeSubject = function (subject) {
  return subject === 'IPA' ? 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' : subject;
};
window.KARSA_CURRICULUM.subjectsForClass = function (className) {
  var digits = String(className).replace(/\\D/g, '');
  var grade = parseInt(digits, 10);
  if (isNaN(grade)) grade = 1;
  return window.KARSA_CURRICULUM.subjects.filter(function (s) {
    return s !== 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' || grade >= 3;
  });
};
window.KARSA_CURRICULUM.questionsFor = function (subject, religion) {
  var base = window.KARSA_CURRICULUM.quizBank[subject] ||
    window.KARSA_CURRICULUM.quizBank['Matematika'];
  var faith = religion ? window.KARSA_CURRICULUM.faithExamples[religion] : null;
  if (subject !== 'Pendidikan Agama dan Budi Pekerti' || !faith) return base;
  var first = religion === 'Katolik'
    ? {
      question: 'Dalam pembinaan iman Katolik, teladan Yesus mengajak kita untuk ...',
      choices: ['mengasihi sesama', 'mengejek teman', 'berbuat curang', 'mengabaikan teman'],
      answerIndex: 0,
      explanation: 'Mengasihi sesama merupakan bagian dari teladan Yesus.'
    }
    : {
      question: 'Tempat ibadah yang dikenal dalam agama ' + religion + ' adalah ...',
      choices: [faith[0], 'perpustakaan', 'pasar', 'lapangan'],
      answerIndex: 0,
      explanation: faith[0] + ' merupakan salah satu tempat ibadah umat ' + religion + '.'
    };
  return [first].concat(base.slice(1));
};
window.KARSA_CURRICULUM.exercisesFor = function (subject, religion) {
  var base = window.KARSA_CURRICULUM.practiceBank[subject] ||
    window.KARSA_CURRICULUM.practiceBank['Matematika'];
  var faith = religion ? window.KARSA_CURRICULUM.faithExamples[religion] : null;
  if (subject !== 'Pendidikan Agama dan Budi Pekerti' || !faith) return base;
  var first = {
    prompt: 'Ceritakan contoh ' + faith[1] + ' dalam kehidupan sehari-hari sesuai ajaran ' + religion + '.',
    sampleAnswer: 'Jawaban dapat beragam. Diskusikan dengan guru dan keluarga sesuai ajaran ' + religion + '.'
  };
  return [first].concat(base.slice(1));
};
`;

  const header = '/* GENERATED FILE — do not edit by hand.\n' +
    ' * Source: curriculum.js (repo root) + lib/core/widgets/karsa_icons.dart\n' +
    ' * Regenerate with: node karsa_app/tool/generate_preview_data.js\n' +
    ' */\n';

  fs.writeFileSync(
    OUT_FILE,
    header + 'window.KARSA_CURRICULUM = ' + JSON.stringify(payload, null, 2) + ';\n' + helperSource,
    'utf8'
  );
  console.log('Wrote ' + path.relative(REPO_ROOT, OUT_FILE));
})();
