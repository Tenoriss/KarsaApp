/* KarsaApp — Interactive HTML preview (offline, zero CDN dependencies).
 * Mirrors the Flutter/Dart implementation in karsa_app/lib 1:1 (clay tokens, screens, flows).
 * Content is generated from curriculum.js + the Flutter seed data.
 */
(function () {
  'use strict';

  /* ------------------------------------------------------------------ *
   * Constants (mirrors lib/core/constants/app_constants.dart)
   * ------------------------------------------------------------------ */
  var CURR = window.KARSA_CURRICULUM;
  var ICONS = CURR.icons || {};

  var ACCOUNTS = {
    siswa: { id: '10050001', password: 'siswa123', label: 'Siswa kelas 5–6' },
    wali: { id: '19870001', password: 'wali123', label: 'Wali kelas' },
    guru: { id: '19870002', password: 'guru123', label: 'Guru mata pelajaran' },
    orangtua: { id: '10010001', password: 'ortu123', label: 'Orang tua / wali' }
  };

  var SCHOOL_NAME = 'SD KARITAS PURWOKERTO';
  var SCHOOL_CAPTION = 'Karitas Sahabat Belajar';
  var BRAND_LABEL = '✿ KARSA';
  var WALI_CLASS = 'Kelas 1';
  var CLASSES = ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4', 'Kelas 5', 'Kelas 6'];
  var PARENT_CLASSES = CLASSES.slice(0, 4);
  var STUDENT_CLASSES = CLASSES.slice(4);
  var ATTENDANCE_STATUSES = ['Hadir', 'Izin', 'Sakit', 'Alpa'];
  var SUBJECTS = CURR.subjects;
  var SUBJECT_INFO = CURR.subjectInfo;
  var STUDY_TIPS = [
    'Baca soal pelan-pelan sebelum menjawab.',
    'Istirahat sebentar jika kamu merasa lelah.',
    'Tidak apa-apa bertanya jika belum mengerti.'
  ];
  var MOOD_OPTIONS = [
    ['😊', 'Senang'],
    ['😌', 'Tenang'],
    ['😴', 'Lelah'],
    ['😔', 'Sedih']
  ];
  var ASSETS = {
    icon: './assets/images/icon.png',
    loginLogo: './assets/images/karsa-login-logo.png',
    schoolLogo: './assets/images/logo-sd-karitas.png',
    splashArt: './assets/images/splash-art.png',
    studentBanner: './assets/images/student-banner.png',
    teacherBanner: './assets/images/teacher-banner.png'
  };

  var MONTH_NAMES = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  var SHORT_MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  var WEEKDAYS = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  var ATTENDANCE_COLORS = {
    Hadir: '#78B995',
    Izin: '#79A6CD',
    Sakit: '#C58AAD',
    Alpa: '#CD6C7D'
  };
  var PURPLE_STAT = '#8B7AA8';
  var GREEN_STAT = '#6FA98C';

  /* ------------------------------------------------------------------ *
   * DOM helpers
   * ------------------------------------------------------------------ */
  function append(node, children) {
    if (children === null || children === undefined) return node;
    if (Array.isArray(children)) {
      children.forEach(function (c) { append(node, c); });
      return node;
    }
    if (children instanceof Node) {
      node.appendChild(children);
      return node;
    }
    node.appendChild(document.createTextNode(String(children)));
    return node;
  }

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    if (attrs) {
      Object.keys(attrs).forEach(function (key) {
        var value = attrs[key];
        if (value === null || value === undefined || value === false) return;
        if (key === 'class') node.className = value;
        else if (key === 'text') node.textContent = value;
        else if (key === 'style') node.setAttribute('style', value);
        else if (key.slice(0, 2) === 'on') node.addEventListener(key.slice(2).toLowerCase(), value);
        else if (key === 'dataset') {
          Object.keys(value).forEach(function (d) { node.dataset[d] = value[d]; });
        } else if (value === true) node.setAttribute(key, '');
        else node.setAttribute(key, value);
      });
    }
    return append(node, children);
  }

  function icon(name, size) {
    var glyph = ICONS[name] || '';
    return el('span', {
      class: 'ion',
      style: 'font-size:' + (size || 20) + 'px',
      text: glyph,
      'aria-hidden': 'true'
    });
  }

  function clear(node) {
    while (node && node.firstChild) node.removeChild(node.firstChild);
  }

  /* ------------------------------------------------------------------ *
   * Date helpers (mirrors lib/core/utils/date_utils.dart)
   * ------------------------------------------------------------------ */
  function pad2(n) { return n < 10 ? '0' + n : String(n); }

  function dateKey(d) {
    return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate());
  }

  function fullDateId(d) {
    return d.getDate() + ' ' + MONTH_NAMES[d.getMonth()] + ' ' + d.getFullYear();
  }

  function dayMonthYearId(d) {
    return d.getDate() + ' ' + SHORT_MONTHS[d.getMonth()] + ' ' + d.getFullYear();
  }

  function monthYearId(year, month1) {
    return MONTH_NAMES[month1 - 1] + ' ' + year;
  }

  function deadlineCountdown(dueAtIso, now) {
    if (!dueAtIso) return 'Belum ada tenggat';
    var parsed = new Date(dueAtIso);
    if (isNaN(parsed.getTime())) return 'Tenggat tidak valid';
    var diff = parsed.getTime() - now.getTime();
    if (diff <= 0) return 'Tenggat terlewat';
    var days = Math.floor(diff / 86400000);
    var hours = Math.floor((diff % 86400000) / 3600000);
    if (days > 0) return days + ' hari ' + hours + ' jam lagi';
    return (hours < 1 ? 1 : hours) + ' jam lagi';
  }

  function createdAtId(iso) {
    var d = new Date(iso);
    if (isNaN(d.getTime())) return iso;
    return d.getDate() + '/' + (d.getMonth() + 1) + '/' + d.getFullYear() + ' ' +
      pad2(d.getHours()) + '.' + pad2(d.getMinutes());
  }

  /* ------------------------------------------------------------------ *
   * Curriculum helpers (mirrors lib/data/curriculum_data.dart)
   * ------------------------------------------------------------------ */
  function normalizeSubject(subject) {
    if (subject === 'IPA') return 'Ilmu Pengetahuan Alam dan Sosial (IPAS)';
    return subject;
  }

  function metaFor(subject) {
    return SUBJECT_INFO[normalizeSubject(subject)] || SUBJECT_INFO['Matematika'];
  }

  function subjectsForClass(className) {
    var digits = String(className).replace(/\D/g, '');
    var grade = parseInt(digits, 10);
    if (isNaN(grade)) grade = 1;
    return SUBJECTS.filter(function (s) {
      return s !== 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' || grade >= 3;
    });
  }

  function quizBankFor(subject) {
    if (typeof CURR.questionsFor === 'function') {
      return CURR.questionsFor(normalizeSubject(subject), state.religion || '');
    }
    return CURR.quizBank[normalizeSubject(subject)] || CURR.quizBank['Matematika'];
  }

  /* ------------------------------------------------------------------ *
   * Demo data (mirrors lib/data/seed_data.dart)
   * ------------------------------------------------------------------ */
  var NOW = new Date();

  function buildTasks() {
    var tasks = [];
    var initial = [
      { id: 'seed5', subject: 'Matematika', title: 'Pecahan dan perbandingan', className: 'Kelas 5', minutes: '30' },
      { id: 'seed6', subject: 'Ilmu Pengetahuan Alam dan Sosial (IPAS)', title: 'Ekosistem dan lingkungan', className: 'Kelas 6', minutes: '30' },
      { id: 't1', subject: 'Matematika', title: 'Penjumlahan sampai 20', className: 'Kelas 1', minutes: '30' },
      { id: 't2', subject: 'Bahasa Indonesia', title: 'Membaca kalimat', className: 'Kelas 1', minutes: '30' }
    ];
    initial.forEach(function (t) {
      tasks.push({
        id: t.id, subject: t.subject, title: t.title, className: t.className,
        minutes: t.minutes, dueAt: null, demo: false
      });
    });
    [5, 6].forEach(function (grade) {
      SUBJECTS.forEach(function (subject, i) {
        var due = new Date(NOW.getFullYear(), NOW.getMonth(), NOW.getDate() + i + 1, 23, 59, 59);
        var past = new Date(NOW.getFullYear(), NOW.getMonth(), NOW.getDate() - i - 2, 23, 59, 59);
        tasks.push({
          id: 'demo-' + grade + '-' + i + '-active', subject: subject, title: 'Tugas ' + subject,
          className: 'Kelas ' + grade, minutes: '30', dueAt: due.toISOString(), demo: true
        });
        tasks.push({
          id: 'demo-' + grade + '-' + i + '-history', subject: subject, title: 'Tugas sebelumnya · ' + subject,
          className: 'Kelas ' + grade, minutes: '30', dueAt: past.toISOString(), demo: true, demoHistory: true
        });
      });
    });
    return tasks;
  }

  var TASKS = buildTasks();

  var RESULTS = {};
  TASKS.forEach(function (t) {
    if (!t.demoHistory) return;
    RESULTS[t.id] = { score: 7, total: 10, answers: [], demo: true };
  });

  var PRACTICES = SUBJECTS.map(function (subject, i) {
    var id = subject === 'Matematika' ? 'p1'
      : subject === 'Bahasa Indonesia' ? 'p2'
        : subject === 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' ? 'p3'
          : 'practice-' + i;
    return { id: id, subject: subject, title: 'Latihan ' + subject, className: null };
  });

  var ANNOUNCEMENTS = [
    {
      id: 'a1', category: 'KEGIATAN SEKOLAH', title: 'Hari Literasi KARSA',
      detail: 'Jumat, 6 November 2026 · Aula sekolah',
      body: 'Mari tumbuhkan kebiasaan membaca melalui kegiatan berbagi cerita dan pojok baca kelas.',
      className: 'Semua kelas'
    },
    {
      id: 'a2', category: 'UNTUK ORANG TUA', title: 'Pertemuan Wali Murid',
      detail: 'Sabtu, 7 November 2026 · 09.00 WIB',
      body: 'Pertemuan rutin membahas perkembangan belajar dan kegiatan semester.',
      className: 'Semua kelas'
    },
    {
      id: 'a3', category: 'PENGINGAT', title: 'Pengumpulan tugas mingguan',
      detail: '',
      body: 'Pastikan semua tugas dikumpulkan tepat waktu.',
      className: 'Semua kelas'
    }
  ];

  var NOTIFICATIONS = [
    {
      id: 'n1', target: 'learners', subject: 'Matematika', className: 'Kelas 1',
      title: 'Tugas baru · Penjumlahan sampai 20', kind: 'task', contentId: 't1',
      createdAt: new Date(NOW.getTime() - 3600000).toISOString()
    },
    {
      id: 'n2', target: 'learners', subject: 'Bahasa Indonesia', className: 'Kelas 1',
      title: 'Materi baru · Membaca kalimat', kind: 'material', contentId: 'm1',
      createdAt: new Date(NOW.getTime() - 7200000).toISOString()
    },
    {
      id: 'n3', target: 'teachers', subject: 'Matematika', className: 'Kelas 1',
      title: 'Tugas dikumpulkan siswa', kind: 'task', contentId: 't1',
      createdAt: new Date(NOW.getTime() - 10800000).toISOString()
    }
  ];

  var MATERIALS = [
    {
      id: 'm1', subject: 'Matematika', className: 'Kelas 1', title: 'Ringkasan Pecahan',
      teacher: 'Ibu Sari', body: 'Pengenalan pecahan sederhana untuk siswa kelas 1.'
    },
    {
      id: 'm2', subject: 'Bahasa Indonesia', className: 'Kelas 1', title: 'Contoh Kalimat Sederhana',
      teacher: 'Ibu Sari', body: 'Kumpulan contoh kalimat sederhana beserta latihan membaca.'
    }
  ];

  var CLASS_EVENTS = [
    {
      id: 'e1', className: 'Kelas 1', date: dateKey(new Date(NOW.getFullYear(), NOW.getMonth(), NOW.getDate())),
      title: 'Pertemuan kelas pagi', time: '07.30', note: 'Diskusi mingle di kelas.'
    }
  ];

  var WALI_MEMBERS = [
    { id: 'dimas', name: 'Dimas Nugroho', icon: '👦🏻' },
    { id: 'sari', name: 'Sari Putri', icon: '👧🏻' },
    { id: 'rafi', name: 'Rafi Pratama', icon: '👦🏻' }
  ];

  var ROSTER = {
    'Kelas 1': ['Dimas Nugroho', 'Sari Putri', 'Rafi Pratama'],
    'Kelas 2': ['Alya Putri', 'Bima Saputra', 'Nadia Lestari'],
    'Kelas 3': ['Raka Pratama', 'Citra Maharani', 'Fajar Ramadhan'],
    'Kelas 4': ['Nabila Putri', 'Rizky Saputra', 'Intan Sari'],
    'Kelas 5': ['Dimas Nugroho', 'Nisa Aulia', 'Bintang Pratama'],
    'Kelas 6': ['Adit Prasetyo', 'Dewi Lestari', 'Farhan Maulana']
  };

  /* ------------------------------------------------------------------ *
   * App state
   * ------------------------------------------------------------------ */
  var state = {
    screen: 'splash',
    role: 'wali',
    dark: false,
    tab: 'Beranda',
    filter: 'Semua kelas',
    subjectFilter: 'Semua',
    taskFilter: 'Semua',
    search: '',
    recapTab: 'Kehadiran',
    recapDate: dateKey(new Date(NOW.getFullYear(), NOW.getMonth(), NOW.getDate())),
    attendance: {},
    classScores: { dimas: 82, sari: 91, rafi: 74 },
    tipIndex: 0,
    login: { username: '', password: '', show: false, error: '' },
    quiz: null,
    quizResult: null,
    mood: null,
    studentClass: 'Kelas 5',
    parentClass: 'Kelas 1',
    teacherSubject: 'Matematika',
    religion: '',
    studentName: 'Dimas Nugroho',
    teacherName: 'Ibu Sari',
    waliName: 'Ibu Sari',
    personalDraft: null
  };

  var ROLE_TABS = {
    wali: ['Beranda', 'Anggota', 'Rekap', 'Agenda', 'Profil'],
    guru: ['Beranda', 'Kelas', 'Tugas', 'Kalender', 'Profil'],
    siswa: ['Beranda', 'Tugas', 'Profil'],
    orangtua: ['Beranda', 'Tugas', 'Latihan', 'Profil']
  };

  var ROLE_SCREEN_PREFIX = {
    wali: 'wali-',
    guru: 'guru-',
    siswa: 'siswa-',
    orangtua: 'ortu-'
  };

  var ROLE_LABEL = {
    wali: 'Wali Kelas',
    guru: 'Guru Mata Pelajaran',
    siswa: 'Siswa',
    orangtua: 'Orang Tua/Wali'
  };

  var LOGIN_SCREEN = {
    wali: 'login-wali',
    guru: 'login-guru',
    siswa: 'login-siswa',
    orangtua: 'login-ortu'
  };

  /* ------------------------------------------------------------------ *
   * Reusable components (mirrors lib/core/widgets/*.dart)
   * ------------------------------------------------------------------ */
  function schoolIdentity(compact) {
    return el('div', { class: 'clay-soft school-identity' + (compact ? ' compact' : '') }, [
      el('div', { class: 'school-logo-frame' }, [
        el('img', { src: ASSETS.schoolLogo, alt: 'Logo SD Karitas Purwokerto' })
      ]),
      el('div', {}, [
        el('p', { class: 'school-name', text: SCHOOL_NAME }),
        el('p', { class: 'school-caption', text: SCHOOL_CAPTION })
      ])
    ]);
  }

  function greetingHeader(opts) {
    var children = [];
    if (opts.avatarIsLetter) {
      children.push(el('div', { class: 'greeting-avatar', text: opts.avatarText }));
    } else {
      children.push(el('div', { class: 'greeting-avatar', text: opts.avatarText }));
    }
    children.push(el('div', { style: 'flex:1;min-width:0' }, [
      el('p', { class: 't-small', style: 'color:var(--muted);margin:0 0 2px 0', text: opts.eyebrow }),
      el('p', { class: 't-name', text: opts.userName }),
      el('p', { class: 't-small', style: 'margin-top:2px', text: opts.subtitle })
    ]));
    children.push(el('button', {
      class: 'round-icon-btn pressable',
      type: 'button',
      'aria-label': opts.dark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
      onclick: function () { toggleTheme(); }
    }, [icon(opts.dark ? 'sunny-outline' : 'moon-outline', 20)]));
    children.push(el('button', {
      class: 'round-icon-btn pressable',
      type: 'button',
      style: 'margin-left:8px',
      'aria-label': 'Buka notifikasi',
      onclick: function () { go('notifikasi'); }
    }, [
      icon('notifications-outline', 20),
      opts.badgeCount ? el('span', { class: 'notif-dot', text: String(opts.badgeCount) }) : null
    ]));
    return el('div', { class: 'greeting-row' }, children);
  }

  function pageHeader(title, sub, onBack) {
    var children = [];
    if (onBack) {
      children.push(el('button', {
        class: 'back-chevron pressable', type: 'button', 'aria-label': 'Kembali',
        onclick: onBack
      }, [icon('chevron-back', 20)]));
    }
    children.push(el('div', { style: 'flex:1;min-width:0' }, [
      el('h1', { class: 't-page-title', text: title }),
      sub ? el('p', { class: 't-muted', style: 'margin-top:4px', text: sub }) : null
    ]));
    return el('div', { class: 'page-header' }, children);
  }

  function statCard(opts) {
    return el('div', {
      class: 'clay-soft stat-card karsa-card pressable',
      role: 'button',
      tabindex: '0',
      onclick: opts.onTap
    }, [
      el('div', { class: 'stat-icon-circle', style: 'background-color:' + opts.color }, [
        icon(opts.icon, 20)
      ]),
      el('div', { style: 'flex:1;min-width:0' }, [
        el('p', { class: 't-small', style: 'margin:0', text: opts.label }),
        el('p', { class: 't-stat-number', text: opts.value }),
        el('p', { class: 't-small', style: 'margin:0', text: opts.desc })
      ])
    ]);
  }

  function wideStatCard(opts) {
    return el('div', {
      class: 'clay-soft stat-card karsa-card pressable',
      role: 'button',
      tabindex: '0',
      onclick: opts.onTap
    }, [
      el('div', { class: 'stat-icon-circle', style: 'background-color:' + opts.color }, [
        icon(opts.icon, 20)
      ]),
      el('div', { style: 'flex:1;min-width:0' }, [
        el('p', { class: 't-small', style: 'margin:0', text: opts.label }),
        el('p', { class: 't-stat-number', text: opts.value }),
        el('p', { class: 't-small', style: 'margin:0', text: opts.desc })
      ]),
      el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 18)])
    ]);
  }

  function listItemCard(opts) {
    return el('div', {
      class: 'clay-soft list-item-card karsa-card pressable',
      role: 'button',
      tabindex: '0',
      onclick: opts.onTap
    }, [
      el('div', {
        class: 'item-tile',
        style: 'background-color:' + (opts.tileColor || '#F8EBEC')
      }, [el('span', { text: opts.iconEmoji })]),
      el('div', { style: 'flex:1;min-width:0' }, [
        el('p', { class: 't-item-title', text: opts.title }),
        el('p', { class: 't-small', text: opts.meta })
      ]),
      opts.status ? el('span', { class: 'status-badge', text: opts.status }) : null
    ]);
  }

  function chartRow(label, count, total, color, display) {
    var ratio = total > 0 ? Math.max(0, Math.min(1, count / total)) : 0;
    var text = display !== undefined ? display : String(count);
    return el('div', { class: 'chart-row' }, [
      el('span', { class: 'chart-label', text: label }),
      el('span', { class: 'chart-track' }, [
        el('span', { class: 'chart-fill', style: 'width:' + (ratio * 100) + '%;background-color:' + color })
      ]),
      el('span', { class: 'chart-number', text: text })
    ]);
  }

  function noticeCard(title, body) {
    return el('div', { class: 'notice-card' }, [
      title ? el('p', { class: 'notice-title', text: title }) : null,
      el('p', { class: 't-muted', text: body })
    ]);
  }

  function clayCard(children, opts) {
    opts = opts || {};
    return el('div', {
      class: 'clay-soft karsa-card' + (opts.onTap ? ' pressable' : ''),
      style: opts.backgroundColor ? 'background-color:' + opts.backgroundColor : null,
      role: opts.onTap ? 'button' : null,
      tabindex: opts.onTap ? '0' : null,
      onclick: opts.onTap
    }, children);
  }

  function chips(options, value, onChanged) {
    return el('div', { class: 'chips-row' }, options.map(function (option) {
      return el('button', {
        class: 'chip-btn pressable' + (option === value ? ' active' : ''),
        type: 'button',
        onclick: function () { onChanged(option); }
      }, [option]);
    }));
  }

  function segmentTabs(options, value, onChanged) {
    return el('div', { class: 'segment-track' }, options.map(function (option) {
      return el('button', {
        class: 'segment-item pressable' + (option === value ? ' active' : ''),
        type: 'button',
        onclick: function () { onChanged(option); }
      }, [option]);
    }));
  }

  function monthCalendar(year, month1, selectedDay) {
    var first = new Date(year, month1 - 1, 1);
    var leading = first.getDay() === 0 ? 6 : first.getDay() - 1;
    var daysInMonth = new Date(year, month1, 0).getDate();
    var grid = el('div', { class: 'cal-grid' }, []);
    WEEKDAYS.forEach(function (w) {
      grid.appendChild(el('div', { class: 'cal-weekday', text: w }));
    });
    for (var i = 0; i < leading; i++) {
      grid.appendChild(el('div', { style: 'height:42px' }));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      (function (day) {
        grid.appendChild(el('button', {
          class: 'cal-day pressable' + (day === selectedDay ? ' selected' : ''),
          type: 'button',
          onclick: function () { state.calDay = day; state.calMonth = month1; state.calYear = year; render(); }
        }, [String(day)]));
      })(d);
    }
    return el('div', {}, [
      el('div', { class: 'cal-header' }, [
        el('button', {
          class: 'back-chevron pressable', type: 'button', 'aria-label': 'Bulan sebelumnya',
          onclick: function () { shiftMonth(-1); }
        }, [icon('chevron-back', 20)]),
        el('p', { class: 't-section', style: 'margin:0', text: monthYearId(year, month1) }),
        el('button', {
          class: 'back-chevron pressable', type: 'button', 'aria-label': 'Bulan berikutnya',
          onclick: function () { shiftMonth(1); }
        }, [icon('chevron-forward', 20)])
      ]),
      grid
    ]);
  }

  function shiftMonth(delta) {
    var year = state.calYear || NOW.getFullYear();
    var month = (state.calMonth || NOW.getMonth() + 1) + delta;
    var day = state.calDay || NOW.getDate();
    if (month < 1) { month = 12; year -= 1; }
    if (month > 12) { month = 1; year += 1; }
    var maxDay = new Date(year, month, 0).getDate();
    state.calYear = year;
    state.calMonth = month;
    state.calDay = Math.min(day, maxDay);
    render();
  }

  function todayIso() { return dateKey(NOW); }

  function currentPersonalName() {
    if (state.role === 'wali') return state.waliName;
    if (state.role === 'guru') return state.teacherName;
    return state.studentName;
  }

  /* Ringkasan nilai kelas: rata-rata per mata pelajaran dari tugas yang
     sudah dikerjakan di perangkat ini (cermin AppState.classGradeSummaries). */
  function learnerClassName() {
    return state.role === 'siswa' ? state.studentClass : state.parentClass;
  }

  function classGradeSummaries() {
    var className = learnerClassName();
    var allowed = subjectsForClass(className);
    var buckets = {};
    var totals = {};
    TASKS.forEach(function (t) {
      if (t.className !== className) return;
      if (allowed.indexOf(t.subject) < 0) return;
      totals[t.subject] = (totals[t.subject] || 0) + 1;
      var r = RESULTS[t.id];
      if (!r || r.score === null || r.score === undefined || !r.total) return;
      buckets[t.subject] = buckets[t.subject] || [];
      buckets[t.subject].push(r.score * 100 / r.total);
    });
    return allowed.filter(function (subject) {
      return !!totals[subject];
    }).map(function (subject) {
      var list = buckets[subject] || [];
      var average = list.length
        ? list.reduce(function (a, b) { return a + b; }, 0) / list.length
        : 0;
      return {
        subject: subject,
        graded: list.length,
        total: totals[subject],
        average: average,
        averageLabel: list.length ? String(Math.round(average * 10) / 10) : '\u2014'
      };
    });
  }

  function classGradeAverage() {
    var graded = classGradeSummaries().filter(function (s) { return s.graded > 0; });
    if (!graded.length) return null;
    var sum = graded.reduce(function (acc, s) { return acc + s.average; }, 0);
    return Math.round(sum / graded.length);
  }

  /* Kartu "Nilai kelas" (dipakai pada profil siswa dan profil anak). */
  function classGradesCard() {
    var summaries = classGradeSummaries();
    var average = classGradeAverage();
    var gradedCount = summaries.reduce(function (acc, s) { return acc + s.graded; }, 0);
    var children = [
      el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
        el('div', { class: 'stat-icon-circle', style: 'background-color:var(--card);font-size:22px' }, ['\uD83D\uDCCA']),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Rata-rata kelas' }),
          el('p', {
            class: 't-small', style: 'margin:0',
            text: gradedCount + ' tugas bernilai \u00b7 ' + learnerClassName() + ' \u00b7 data lokal'
          })
        ]),
        el('p', { class: 't-stat-number', text: average === null ? '\u2014' : String(average) })
      ])
    ];

    if (!summaries.length) {
      children.push(el('p', {
        class: 't-small', style: 'margin:12px 0 0 0',
        text: 'Belum ada tugas di kelas ini. Nilai muncul setelah tugas dikerjakan.'
      }));
    } else {
      summaries.forEach(function (s) {
        children.push(gradeRow(s));
      });
      children.push(el('p', {
        class: 't-small', style: 'margin:12px 0 0 0',
        text: 'Nilai contoh dari kuis yang dikerjakan di perangkat ini, bukan nilai resmi sekolah.'
      }));
    }
    return clayCard(children);
  }

  /* Baris nilai per mata pelajaran: ikon mapel, nama lengkap, bar, dan nilai. */
  function gradeRow(summary) {
    var meta = metaFor(summary.subject);
    var ratio = Math.max(0, Math.min(1, summary.average / 100));
    return el('div', { style: 'display:flex;align-items:flex-start;gap:10px;margin-top:12px' }, [
      el('div', {
        class: 'item-tile',
        style: 'width:34px;height:34px;border-radius:12px;font-size:16px;background-color:' + meta.color
      }, [el('span', { text: meta.icon })]),
      el('div', { style: 'flex:1;min-width:0' }, [
        el('p', {
          class: 't-item-title',
          style: 'margin:0;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden',
          text: summary.subject
        }),
        el('div', { class: 'mission-track', style: 'margin:6px 0 4px 0' }, [
          el('div', {
            class: 'mission-fill',
            style: 'width:' + (ratio * 100) + '%;background-color:' +
              (summary.graded === 0 ? 'var(--muted)' : 'var(--rose)')
          })
        ]),
        el('p', {
          class: 't-small', style: 'margin:0',
          text: summary.graded + ' dari ' + summary.total + ' tugas dinilai'
        })
      ]),
      el('span', {
        style: 'color:var(--ink);font-size:15px;font-weight:800;padding-top:8px',
        text: summary.averageLabel
      })
    ]);
  }

  /* Kartu "Informasi pribadi" yang bisa diedit. */
  function personalInfoCard(isStudent) {
    var className = isStudent ? state.studentClass : state.parentClass;
    function infoRow(label, value) {
      return el('div', { style: 'display:flex;align-items:flex-start;gap:10px;margin-top:10px' }, [
        el('span', { class: 't-small', style: 'width:104px;flex-shrink:0', text: label }),
        el('span', { class: 't-item-title', style: 'flex:1;min-width:0', text: value })
      ]);
    }
    return clayCard([
      el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('person-outline', 20)]),
        el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: 'Data pribadi' }),
        el('span', { class: 't-link', text: 'Ubah' }),
        el('span', { style: 'color:var(--muted);display:inline-flex' }, [icon('chevron-forward', 17)])
      ]),
      infoRow('Nama', state.studentName),
      infoRow('Kelas', className),
      infoRow(isStudent ? 'NISN demo' : 'NISN anak demo', ACCOUNTS.siswa.id),
      infoRow('Agama', state.religion || 'Belum diisi'),
      el('p', {
        class: 't-small', style: 'margin:10px 0 0 0',
        text: 'Perubahan disimpan di perangkat ini pada kunci "@karsa-demo-v1".'
      })
    ], { onTap: function () { openSetting('Informasi pribadi'); } });
  }

  /* ------------------------------------------------------------------ *
   * Data selectors (mirrors AppState getters)
   * ------------------------------------------------------------------ */
  function classMembers() { return WALI_MEMBERS; }

  function childSubjects() { return subjectsForClass(state.parentClass); }

  function activeTasks() {
    var allowed = subjectsForClass(state.studentClass);
    return TASKS.filter(function (t) {
      return t.className === state.studentClass &&
        allowed.indexOf(t.subject) >= 0 &&
        !RESULTS[t.id];
    });
  }

  function completedTasks() {
    var allowed = subjectsForClass(state.studentClass);
    return TASKS.filter(function (t) {
      return t.className === state.studentClass &&
        allowed.indexOf(t.subject) >= 0 &&
        !!RESULTS[t.id];
    });
  }

  function educatorTasks() {
    return TASKS.filter(function (t) {
      if (state.role === 'wali' && t.className !== WALI_CLASS) return false;
      if (state.filter !== 'Semua kelas' && t.className !== state.filter) return false;
      if (state.role === 'guru' && t.subject !== state.teacherSubject) return false;
      return true;
    });
  }

  function visiblePractices() {
    var allowed = subjectsForClass(state.parentClass);
    return PRACTICES.filter(function (p) {
      return (p.className === null || p.className === state.parentClass) &&
        allowed.indexOf(p.subject) >= 0;
    });
  }

  function todayAttendance() { return state.attendance[todayIso()] || {}; }

  function recordsForTodayStatus(status) {
    var map = todayAttendance();
    return classMembers().filter(function (m) { return map[m.id] === status; }).length;
  }

  function scoreAverage() {
    var scored = classMembers().filter(function (m) { return state.classScores[m.id] !== undefined; });
    if (!scored.length) return null;
    var sum = scored.reduce(function (acc, m) { return acc + (state.classScores[m.id] || 0); }, 0);
    return Math.round(sum / scored.length);
  }

  function visibleAnnouncements() {
    return ANNOUNCEMENTS.filter(function (a) {
      if (state.role === 'wali') return a.className === 'Semua kelas' || a.className === WALI_CLASS;
      if (state.role === 'guru') return true;
      return a.className === 'Semua kelas' || a.className === state.parentClass;
    });
  }

  function unreadAnnouncementsCount() {
    return visibleAnnouncements().length; // demo: seeded announcements start unread
  }

  function relevantNotifications() {
    return NOTIFICATIONS.filter(function (n) {
      if (state.role === 'wali' || state.role === 'guru') {
        return n.target === 'teachers' &&
          (state.role !== 'guru' || n.subject === state.teacherSubject) &&
          (state.role !== 'wali' || n.className === WALI_CLASS);
      }
      return n.target === 'learners' && n.className === state.parentClass;
    });
  }

  function totalBadgeCount() {
    return unreadAnnouncementsCount() + relevantNotifications().length;
  }

  /* ------------------------------------------------------------------ *
   * Screens
   * ------------------------------------------------------------------ */
  function renderSplash() {
    return el('div', { class: 'splash-stage' }, [
      el('img', { class: 'splash-art', src: ASSETS.splashArt, alt: 'Ilustrasi KARSA' }),
      el('div', { class: 'splash-pill' }, [
        el('div', { class: 'splash-dots' }, [
          el('span', { class: 'splash-dot' }),
          el('span', { class: 'splash-dot' }),
          el('span', { class: 'splash-dot' })
        ]),
        el('div', { class: 'splash-pill-text', text: 'Menyiapkan pengalaman belajar' })
      ])
    ]);
  }

  var ROLE_CARDS = [
    { r: 'wali', emoji: '👩🏻‍🏫', title: 'Saya Wali Kelas', sub: 'Pantau kelas, siswa, dan perkembangan belajar.' },
    { r: 'guru', emoji: '📚', title: 'Saya Guru Mata Pelajaran', sub: 'Kelola tugas berdasarkan mata pelajaran dan kelas.' },
    { r: 'orangtua', emoji: '👩🏻', title: 'Saya Orang Tua/Wali', sub: 'Dampingi anak kelas 1–4 belajar dan mengerjakan tugas.' },
    { r: 'siswa', emoji: '🎒', title: 'Saya Siswa', sub: 'Kelas 5–6: lihat dan kerjakan tugas secara mandiri.' }
  ];

  function renderWelcome() {
    var cards = ROLE_CARDS.map(function (x, i) {
      return el('button', {
        class: 'role-card clay-soft pressable ' + (i === 1 ? 'blue-variant' : 'pink-variant'),
        type: 'button',
        style: 'width:100%;text-align:left;cursor:pointer',
        onclick: function () {
          state.role = x.r;
          state.login = { username: '', password: '', show: false, error: '' };
          go(LOGIN_SCREEN[x.r]);
        }
      }, [
        el('div', { class: 'role-avatar' }, [el('span', { text: x.emoji })]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', text: x.title }),
          el('p', { class: 't-small', text: x.sub })
        ]),
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 20)])
      ]);
    });

    return el('div', {}, [
      el('div', { class: 'welcome-top' }, [
        el('p', { class: 't-brand', style: 'margin:0', text: BRAND_LABEL }),
        el('button', {
          class: 'round-icon-btn pressable', type: 'button',
          'aria-label': state.dark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
          onclick: function () { toggleTheme(); }
        }, [icon(state.dark ? 'sunny-outline' : 'moon-outline', 20)])
      ]),
      schoolIdentity(false),
      el('h1', { class: 't-page-title', style: 'text-align:center', text: 'Selamat datang di KARSA' }),
      el('p', { class: 't-muted', style: 'text-align:center;margin:8px 0 0 0', text: 'Pilih peran Anda untuk melanjutkan' }),
      cards,
      el('p', { class: 'welcome-quote', text: 'Karena setiap anak\npunya potensi yang\nberharga ♥' }),
      el('p', { class: 'welcome-demo', text: 'PROTOTIPE PEMBELAJARAN · KARSA' })
    ]);
  }

  function loginTitle(role) {
    if (role === 'wali') return 'Selamat datang,\nWali Kelas!';
    if (role === 'guru') return 'Selamat datang,\nGuru!';
    if (role === 'siswa') return 'Halo, Siswa!';
    return 'Halo, Orang Tua!';
  }

  function loginSubtitle(role) {
    if (role === 'siswa') return 'Untuk siswa kelas 5–6';
    if (role === 'orangtua') return 'Untuk pendamping anak kelas 1–4';
    return 'Masuk untuk melanjutkan';
  }

  function renderLogin(role) {
    var account = ACCOUNTS[role];
    var isTeacher = role === 'guru';
    var usernameInput = el('input', {
      type: 'text',
      id: 'login-username',
      inputmode: 'numeric',
      autocomplete: 'off',
      autocapitalize: 'off',
      spellcheck: 'false',
      placeholder: isTeacher ? 'NIP' : 'NISN',
      'aria-label': isTeacher ? 'NIP' : 'NISN',
      value: state.login.username,
      oninput: function (e) { state.login.username = e.target.value; state.login.error = ''; }
    });

    var passwordInput = el('input', {
      type: state.login.show ? 'text' : 'password',
      id: 'login-password',
      autocomplete: 'current-password',
      placeholder: 'Kata sandi',
      'aria-label': 'Kata sandi',
      value: state.login.password,
      oninput: function (e) { state.login.password = e.target.value; state.login.error = ''; }
    });

    function submit() {
      var ok = state.login.username.trim() === account.id && state.login.password === account.password;
      if (!ok) {
        state.login.error = 'NIP/NISN atau kata sandi tidak sesuai.';
        render();
        return;
      }
      state.login.error = '';
      if (role === 'siswa') state.studentClass = 'Kelas 5';
      if (role === 'orangtua') state.parentClass = 'Kelas 1';
      state.filter = role === 'wali' ? WALI_CLASS : 'Semua kelas';
      state.tab = 'Beranda';
      state.role = role;
      go(ROLE_SCREEN_PREFIX[role] + 'beranda');
    }

    passwordInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); submit(); }
    });
    usernameInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); passwordInput.focus(); }
    });

    return el('div', { class: 'login-page' }, [
      el('div', { class: 'login-hero' }, [
        el('div', { class: 'login-circle-pink' }),
        el('div', { class: 'login-circle-blue' }),
        el('button', {
          class: 'login-back-btn pressable', type: 'button', 'aria-label': 'Kembali',
          onclick: function () { go('welcome'); }
        }, [icon('chevron-back', 23)]),
        el('img', { class: 'login-logo', src: ASSETS.loginLogo, alt: 'Logo KARSA' })
      ]),
      el('div', { class: 'login-body' }, [
        schoolIdentity(true),
        el('div', { style: 'display:flex;justify-content:flex-end' }, [
          el('button', {
            class: 'pressable', type: 'button', style: 'padding:8px;background:none;border:none',
            'aria-label': 'Ubah mode terang atau gelap',
            onclick: function () { toggleTheme(); }
          }, [icon(state.dark ? 'sunny-outline' : 'moon-outline', 20)])
        ]),
        el('h1', { class: 'login-title', text: loginTitle(role) }),
        el('p', { class: 'login-subtitle', text: loginSubtitle(role) }),
        el('div', { class: 'login-field' }, [
          icon(isTeacher ? 'card-outline' : 'person-outline', 22),
          usernameInput
        ]),
        el('div', { class: 'login-field' }, [
          icon('lock-closed-outline', 22),
          passwordInput,
          el('button', {
            class: 'pressable', type: 'button', style: 'padding:4px;background:none;border:none',
            'aria-label': state.login.show ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi',
            onclick: function () {
              state.login.show = !state.login.show;
              var next = renderLogin(role);
              var vp = document.getElementById('app-viewport');
              clear(vp);
              vp.appendChild(next);
              var pw = document.getElementById('login-password');
              if (pw) pw.focus();
            }
          }, [icon(state.login.show ? 'eye-off-outline' : 'eye-outline', 22)])
        ]),
        state.login.error ? el('p', { class: 'notice-title', style: 'margin:4px 0 0 0', text: state.login.error }) : null,
        el('div', { style: 'text-align:right;margin-top:6px' }, [
          el('button', {
            class: 't-link pressable', type: 'button',
            onclick: function () { go('forgot'); }
          }, ['Lupa kata sandi?'])
        ]),
        el('button', {
          class: 'login-submit-btn pressable', type: 'button', onclick: submit
        }, ['Masuk →']),
        el('div', { class: 'demo-account-box' }, [
          el('p', { class: 't-item-title', text: 'Akun demo · ' + account.label }),
          el('p', { class: 't-muted', text: (isTeacher ? 'NIP' : 'NISN') + ': ' + account.id }),
          el('p', { class: 't-muted', text: 'Kata sandi: ' + account.password }),
          el('p', { class: 't-small', text: 'Akun contoh untuk mencoba aplikasi, bukan autentikasi aman.' })
        ])
      ]),
      el('div', { class: 'login-wave-pink' }),
      el('div', { class: 'login-wave-blue' })
    ]);
  }

  function renderForgot() {
    var role = state.loginRole || state.role;
    var account = ACCOUNTS[role];
    var isTeacher = role === 'guru';
    return el('div', {}, [
      pageHeader('Lupa kata sandi?', 'Akun ini hanya untuk demonstrasi', function () {
        go(LOGIN_SCREEN[role]);
      }),
      clayCard([
        el('p', { class: 't-item-title', text: 'Informasi akun demo' }),
        el('p', { class: 't-muted', text: (isTeacher ? 'NIP' : 'NISN anak') + ': ' + account.id }),
        el('p', { class: 't-muted', text: 'Kata sandi: ' + account.password }),
        el('p', { class: 't-small', text: 'Belum tersedia pemulihan akun sungguhan.' })
      ]),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        style: 'border:none;cursor:pointer',
        onclick: function () { go(LOGIN_SCREEN[role]); }
      }, ['Kembali masuk'])
    ]);
  }

  /* ---------------- Wali ---------------- */
  function renderWaliBeranda() {
    var members = classMembers();
    var map = todayAttendance();
    var recorded = members.filter(function (m) { return map[m.id] !== undefined; }).length;
    var notRecorded = members.length - recorded;
    var scored = members.filter(function (m) { return state.classScores[m.id] !== undefined; });
    var avg = scoreAverage();

    return el('div', {}, [
      schoolIdentity(true),
      greetingHeader({
        avatarText: '👩🏻‍🏫',
        eyebrow: 'Selamat datang, Wali Kelas',
        userName: state.waliName,
        subtitle: WALI_CLASS + ' · SD Karitas Purwokerto',
        dark: state.dark,
        badgeCount: totalBadgeCount()
      }),
      el('div', { class: 'clay-soft wali-hero' }, [
        el('p', { class: 't-overline', style: 'margin:0 0 8px 0', text: 'RUANG WALI KELAS' }),
        el('p', { style: 'font-size:20px;font-weight:900;color:var(--ink);margin:0 0 8px 0', text: 'Tumbuh bersama, ' + WALI_CLASS + ' 🌱' }),
        el('p', { class: 't-muted', text: 'Pantau kehadiran dan perkembangan belajar siswa dalam satu tempat.' })
      ]),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'people', label: 'Anggota kelas', value: String(members.length), desc: 'Data contoh',
          color: 'var(--blue)', onTap: function () { go('wali-anggota'); }
        }),
        statCard({
          icon: 'checkmark-circle', label: 'Hadir hari ini',
          value: recordsForTodayStatus('Hadir') + '/' + members.length,
          desc: notRecorded + ' belum dicatat', color: 'var(--pink)',
          onTap: function () { state.recapTab = 'Kehadiran'; go('wali-recap'); }
        })
      ]),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Kehadiran hari ini' }),
        el('button', {
          class: 't-link pressable', type: 'button',
          onclick: function () { state.recapTab = 'Kehadiran'; go('wali-recap'); }
        }, ['Isi kehadiran ›'])
      ]),
      clayCard([
        el('p', { class: 't-small', style: 'margin:0', text: fullDateId(NOW) + ' · data dicatat manual' }),
        chartRow('Hadir', recordsForTodayStatus('Hadir'), members.length, ATTENDANCE_COLORS.Hadir),
        chartRow('Izin', recordsForTodayStatus('Izin'), members.length, ATTENDANCE_COLORS.Izin),
        chartRow('Sakit', recordsForTodayStatus('Sakit'), members.length, ATTENDANCE_COLORS.Sakit),
        chartRow('Alpa', recordsForTodayStatus('Alpa'), members.length, ATTENDANCE_COLORS.Alpa),
        el('p', { class: 't-small', style: 'margin:12px 0 0 0', text: notRecorded + ' dari ' + members.length + ' siswa belum dicatat.' })
      ]),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Gambaran nilai' }),
        el('button', {
          class: 't-link pressable', type: 'button',
          onclick: function () { state.recapTab = 'Nilai'; go('wali-recap'); }
        }, ['Lihat rekap ›'])
      ]),
      clayCard([
        el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
          el('div', { class: 'stat-icon-circle', style: 'background-color:var(--card);font-size:22px' }, ['📊']),
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', { class: 't-item-title', style: 'margin:0', text: 'Rata-rata kelas' }),
            el('p', { class: 't-small', style: 'margin:0', text: 'Dari ' + scored.length + ' siswa yang sudah diisi' })
          ]),
          el('p', { class: 't-stat-number', text: avg === null ? '—' : String(avg) })
        ]),
        scored.length ? scored.map(function (m) {
          return chartRow(m.name.split(' ')[0], state.classScores[m.id] || 0, 100, 'var(--blue)');
        }) : el('p', {
          class: 't-small', style: 'margin:10px 0 0 0',
          text: 'Belum ada nilai. Isi rekap nilai untuk melihat grafik.'
        })
      ]),
      el('div', {
        class: 'clay-soft pressable',
        style: 'margin-top:5px;padding:16px;border-radius:20px;display:flex;justify-content:space-between;align-items:center',
        role: 'button', tabindex: '0',
        onclick: function () { go('wali-agenda'); }
      }, [
        el('p', { class: 't-item-title', style: 'margin:0', text: '📅 Agenda kelas' }),
        el('span', { class: 't-link', text: 'Lihat agenda ›' })
      ]),
      el('p', {
        class: 't-muted',
        style: 'text-align:center;color:var(--muted);font-size:12px;margin-top:18px',
        text: 'Data contoh disimpan di perangkat ini, bukan data sekolah sebenarnya.'
      })
    ]);
  }

  function renderWaliAnggota() {
    var members = classMembers();
    return el('div', {}, [
      pageHeader('Anggota Kelas', WALI_CLASS + ' · ' + members.length + ' siswa contoh'),
      el('p', { class: 't-muted', text: 'Ketuk nama siswa untuk melihat dan mengisi nilai ringkas.' }),
      el('div', { style: 'height:12px' }),
      members.map(function (m) {
        var score = state.classScores[m.id];
        var meta = score === undefined
          ? 'Nilai belum diisi'
          : 'Nilai ringkas ' + score + ' · data lokal';
        return listItemCard({
          iconEmoji: m.icon, tileColor: '#F8EBEC', title: m.name, meta: meta,
          status: todayAttendance()[m.id] || 'Belum absen',
          onTap: function () { openMemberScore(m); }
        });
      }),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () { state.recapTab = 'Kehadiran'; go('wali-recap'); }
      }, ['Isi kehadiran'])
    ]);
  }

  function openMemberScore(member) {
    var value = state.classScores[member.id];
    var input = el('input', {
      type: 'number', min: '0', max: '100', value: value === undefined ? '' : String(value),
      class: 'karsa-input', style: 'margin-bottom:8px', 'aria-label': 'Nilai ringkas ' + member.name
    });
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: member.name }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: WALI_CLASS + ' · nilai ringkas 0–100 · data lokal' }),
      input,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () {
          var v = parseFloat(input.value);
          if (!isNaN(v)) state.classScores[member.id] = Math.max(0, Math.min(100, v));
          closeSheet();
          render();
        }
      }, ['Simpan nilai']),
      el('button', {
        class: 't-link pressable', type: 'button', style: 'margin-top:12px;display:block;width:100%',
        onclick: function () {
          delete state.classScores[member.id];
          closeSheet();
          render();
        }
      }, ['Hapus nilai'])
    ]));
  }

  function renderWaliRecap() {
    var members = classMembers();
    var dayMap = state.attendance[state.recapDate] || {};
    var avg = scoreAverage();
    var children = [
      pageHeader('Rekap Kelas', WALI_CLASS + ' · data lokal'),
      segmentTabs(['Kehadiran', 'Nilai'], state.recapTab, function (v) {
        state.recapTab = v;
        render();
      })
    ];

    if (state.recapTab === 'Kehadiran') {
      children.push(el('div', {
        style: 'display:flex;justify-content:space-between;align-items:center;margin-bottom:12px'
      }, [
        el('button', {
          class: 'back-chevron pressable', type: 'button', 'aria-label': 'Tanggal sebelumnya',
          onclick: function () { state.recapDate = shiftDateKey(state.recapDate, -1); render(); }
        }, [icon('chevron-back', 20)]),
        el('p', { class: 't-item-title', style: 'margin:0', text: formatKeyId(state.recapDate) }),
        el('button', {
          class: 'back-chevron pressable', type: 'button', 'aria-label': 'Tanggal berikutnya',
          onclick: function () { state.recapDate = shiftDateKey(state.recapDate, 1); render(); }
        }, [icon('chevron-forward', 20)])
      ]));
      children.push(el('p', {
        class: 't-muted', style: 'margin-bottom:14px',
        text: 'Pilih satu status untuk setiap siswa. Perubahan tersimpan otomatis.'
      }));
      members.forEach(function (m) {
        var buttons = ATTENDANCE_STATUSES.map(function (st) {
          var selected = dayMap[m.id] === st;
          return el('button', {
            class: 'attendance-btn pressable' + (selected ? ' active' : ''),
            type: 'button',
            'aria-label': m.name + ': ' + st,
            onclick: function () {
              var key = state.recapDate;
              if (!state.attendance[key]) state.attendance[key] = {};
              if (state.attendance[key][m.id] === st) {
                delete state.attendance[key][m.id];
              } else {
                state.attendance[key][m.id] = st;
              }
              render();
            }
          }, [st]);
        });
        var card = clayCard([
          el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
            el('span', { style: 'font-size:24px', text: m.icon }),
            el('div', { style: 'flex:1;min-width:0' }, [
              el('p', { class: 't-item-title', style: 'margin:0', text: m.name }),
              el('p', { class: 't-small', style: 'margin:0', text: dayMap[m.id] || 'Belum dicatat' })
            ])
          ]),
          el('div', { class: 'attendance-row' }, buttons),
          dayMap[m.id] ? el('div', { style: 'text-align:right' }, [
            el('button', {
              class: 't-link pressable', type: 'button',
              onclick: function () {
                delete state.attendance[state.recapDate][m.id];
                render();
              }
            }, ['Hapus catatan'])
          ]) : null
        ]);
        children.push(card);
      });
    } else {
      children.push(clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Rata-rata kelas: ' + (avg === null ? '—' : avg) }),
        el('p', {
          class: 't-small', style: 'margin:2px 0 0 0',
          text: 'Rata-rata dari ' + members.filter(function (m) { return state.classScores[m.id] !== undefined; }).length +
            ' nilai ringkas yang diisi manual, skala 0–100.'
        }),
        members.map(function (m) {
          var val = state.classScores[m.id];
          return chartRow(m.name.split(' ')[0], val || 0, 100, 'var(--pink)',
            val === undefined ? '—' : String(val));
        })
      ]));
      children.push(el('p', {
        class: 't-muted', style: 'margin-bottom:12px',
        text: 'Ketuk siswa untuk menambah atau mengubah nilai.'
      }));
      members.forEach(function (m) {
        var val = state.classScores[m.id];
        children.push(listItemCard({
          iconEmoji: m.icon, tileColor: '#E4EEF7', title: m.name,
          meta: 'Nilai ringkas · data lokal',
          status: val === undefined ? 'Belum diisi' : String(val),
          onTap: function () { openMemberScore(m); }
        }));
      });
    }
    return el('div', {}, children);
  }

  function shiftDateKey(key, delta) {
    var parts = key.split('-');
    var d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    d.setDate(d.getDate() + delta);
    return dateKey(d);
  }

  function formatKeyId(key) {
    var parts = key.split('-');
    return parseInt(parts[2], 10) + ' ' + SHORT_MONTHS[parseInt(parts[1], 10) - 1] + ' ' + parts[0];
  }

  function renderWaliAgenda() {
    var calYear = state.calYear || NOW.getFullYear();
    var calMonth = state.calMonth || NOW.getMonth() + 1;
    var calDay = state.calDay || NOW.getDate();
    var selectedKey = dateKey(new Date(calYear, calMonth - 1, calDay));
    var events = CLASS_EVENTS.filter(function (e) {
      return e.className === WALI_CLASS && e.date === selectedKey;
    });

    return el('div', {}, [
      pageHeader('Agenda Kelas', WALI_CLASS + ' · kegiatan dan pengingat'),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () {
          openSheet(el('div', {}, [
            el('div', { class: 'sheet-handle' }),
            el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: '+ Tambah agenda' }),
            el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Agenda tersimpan lokal di perangkat ini.' }),
            el('input', { class: 'karsa-input', id: 'agenda-title', placeholder: 'Judul agenda' }),
            el('input', { class: 'karsa-input', id: 'agenda-time', placeholder: 'Waktu (mis. 07.30)' }),
            el('button', {
              class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
              onclick: function () {
                var title = (document.getElementById('agenda-title').value || '').trim();
                var time = (document.getElementById('agenda-time').value || '').trim();
                if (title) {
                  CLASS_EVENTS.push({
                    id: 'e' + (CLASS_EVENTS.length + 1), className: WALI_CLASS, date: selectedKey,
                    title: title, time: time || '—', note: 'Agenda contoh tersimpan lokal.'
                  });
                }
                closeSheet();
                render();
              }
            }, ['Simpan agenda'])
          ]));
        }
      }, ['+ Tambah agenda']),
      el('div', { style: 'height:20px' }),
      monthCalendar(calYear, calMonth, calDay),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Agenda · ' + calDay + ' ' + monthYearId(calYear, calMonth) }),
      events.length ? events.map(function (e) {
        return listItemCard({
          iconEmoji: '📅', tileColor: '#F8EBEC', title: e.title,
          meta: WALI_CLASS + ' · ' + e.date, status: 'Lihat',
          onTap: function () {
            openSheet(el('div', {}, [
              el('div', { class: 'sheet-handle' }),
              el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: e.title }),
              el('p', { class: 't-muted', style: 'margin-bottom:10px', text: WALI_CLASS + ' · ' + e.date + ' · ' + e.time }),
              el('p', { class: 't-muted', text: e.note }),
              el('button', {
                class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
                onclick: function () { closeSheet(); render(); }
              }, ['Tutup'])
            ]));
          }
        });
      }) : el('p', { class: 't-muted', text: 'Belum ada agenda kelas pada tanggal ini.' }),
      el('p', {
        class: 't-muted',
        style: 'text-align:center;color:var(--muted);font-size:12px;margin-top:18px',
        text: 'Agenda disimpan lokal. Notifikasi hanya terlihat di perangkat yang sama.'
      })
    ]);
  }

  function renderWaliProfil() {
    var members = classMembers();
    return el('div', {}, [
      pageHeader('Profil Wali Kelas', 'Senang bertemu denganmu!'),
      profileHero('👩🏻‍🏫', state.waliName, 'Wali ' + WALI_CLASS + ' · SD Karitas Purwokerto', 'Wali kelas aktif'),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Informasi Wali Kelas' }),
      clayCard([
        el('p', { class: 't-small', style: 'margin:0', text: 'Kelas diampu' }),
        el('p', { class: 't-item-title', style: 'margin:0', text: WALI_CLASS }),
        el('p', { class: 't-small', style: 'margin:10px 0 0 0', text: 'NIP demo' }),
        el('p', { class: 't-item-title', style: 'margin:0', text: ACCOUNTS.wali.id })
      ]),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Ringkasan Aktivitas' }),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'people', label: 'Anggota', value: String(members.length), desc: 'Data contoh',
          color: 'var(--blue)', onTap: function () { go('wali-anggota'); }
        }),
        statCard({
          icon: 'book', label: 'Rekap Nilai', value: String(Object.keys(state.classScores).length),
          desc: 'Nilai terisi', color: 'var(--pink)', onTap: function () { state.recapTab = 'Nilai'; go('wali-recap'); }
        })
      ]),
      el('p', { class: 't-section', style: 'margin:20px 0 10px 0', text: 'Pengaturan' }),
      ['Informasi pribadi', 'Tampilan', 'Notifikasi', 'Privasi dan keamanan', 'Pusat bantuan'].map(function (item) {
        return clayCard([
          el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
            el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon(settingIcon(item), 20)]),
            el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: item }),
            el('span', { style: 'color:var(--muted);display:inline-flex' }, [icon('chevron-forward', 17)])
          ])
        ], { onTap: function () { openSetting(item); } });
      }),
      el('div', { style: 'text-align:center' }, [
        el('button', {
          class: 't-link pressable', type: 'button', style: 'padding:20px',
          onclick: function () { go('welcome'); }
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  function settingIcon(label) {
    switch (label) {
      case 'Informasi pribadi': return 'person-outline';
      case 'Mata pelajaran': return 'book-outline';
      case 'Tampilan': return 'moon-outline';
      case 'Notifikasi': return 'notifications-outline';
      case 'Privasi dan keamanan': return 'shield-checkmark-outline';
      default: return 'help-circle-outline';
    }
  }

  function openSetting(label) {
    var body = '';
    if (label === 'Informasi pribadi') {
      body = 'Data pribadi tersimpan di perangkat ini pada kunci "@karsa-demo-v1".';
    } else if (label === 'Mata pelajaran') {
      body = 'Mata pelajaran aktif: ' + state.teacherSubject + '.';
    } else if (label === 'Tampilan') {
      body = 'Mode ' + (state.dark ? 'gelap' : 'terang') + ' aktif. Preferensi disimpan lokal.';
    } else if (label === 'Notifikasi') {
      body = 'Notifikasi demo hanya tampil di perangkat/browser yang sama, bukan push notification.';
    } else if (label === 'Privasi dan keamanan') {
      body = 'Tidak ada autentikasi server. Akun demo hanya untuk mencoba aplikasi.';
    } else {
      body = 'Pusat bantuan demo. Gunakan kotak akun demo pada layar masuk untuk mencoba peran.';
    }
    if (label === 'Informasi pribadi') {
      state.personalDraft = null;
      openPersonalInfoForm();
      return;
    }

    var extra = [];
    var actions = [];
    if (label === 'Mata pelajaran') {
      extra.push(el('p', {
        class: 't-overline', style: 'margin:4px 0 6px 0', text: 'MATA PELAJARAN'
      }));
      extra.push(chips(SUBJECTS, state.teacherSubject, function (value) {
        state.teacherSubject = value;
        closeSheet();
        render();
        openSetting(label);
      }));
      actions = [{
        title: 'Selesai',
        onTap: function () { closeSheet(); render(); }
      }];
    } else {
      actions = [{
        title: 'Tutup',
        onTap: function () { closeSheet(); render(); }
      }];
    }
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: label }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: body }),
      extra,
      actions.map(function (action) {
        return el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer',
          onclick: action.onTap
        }, [action.title]);
      })
    ]));
  }

  /* Formulir "Informasi pribadi" yang bisa diedit (cermin SettingDetailPage). */
  function openPersonalInfoForm() {
    var isStudent = state.role === 'siswa';
    var isLearner = isStudent || state.role === 'orangtua';
    if (!state.personalDraft) {
      state.personalDraft = {
        name: currentPersonalName(),
        className: isStudent ? state.studentClass : state.parentClass,
        religion: state.religion,
        error: ''
      };
    }
    var draft = state.personalDraft;

    function refresh() {
      var panel = document.getElementById('sheet-panel');
      clear(panel);
      panel.appendChild(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: 'Informasi pribadi'
        }),
        el('p', {
          class: 't-muted', style: 'margin-bottom:14px',
          text: 'Data pribadi tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
        }),
        personalInfoForm(),
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer',
          onclick: savePersonalInfo
        }, ['Simpan perubahan']),
        el('button', {
          class: 't-link pressable', type: 'button',
          style: 'margin-top:12px;display:block;width:100%',
          onclick: function () { closeSheet(); render(); }
        }, ['Batal'])
      ]));
    }

    function personalInfoForm() {
      var nameInput = el('input', {
        class: 'karsa-input', type: 'text', value: draft.name, id: 'pi-name',
        placeholder: 'Nama', 'aria-label': 'Nama',
        oninput: function (e) {
          draft.name = e.target.value;
          draft.error = '';
        }
      });

      var classChips = chips(
        (isStudent ? ['Kelas 5', 'Kelas 6'] : ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4']),
        draft.className,
        function (value) {
          draft.className = value;
          refresh();
        }
      );

      var religionChips = chips(
        ['Tanpa agama'].concat(CURR.religions || []),
        draft.religion || 'Tanpa agama',
        function (value) {
          draft.religion = value === 'Tanpa agama' ? '' : value;
          refresh();
        }
      );

      return [
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Nama' }),
        nameInput,
        draft.error ? el('p', {
          class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error
        }) : null,
        isLearner ? el('p', {
          class: 't-label', style: 'margin-bottom:8px',
          text: isStudent ? 'Kelas saya' : 'Kelas anak'
        }) : null,
        isLearner ? classChips : null,
        isLearner ? el('p', {
          class: 't-small', style: 'margin:0 0 14px 0',
          text: isStudent
            ? 'Siswa hanya dapat memilih kelas 5 atau 6.'
            : 'Orang tua mendampingi anak kelas 1 sampai 4.'
        }) : null,
        isLearner ? el('p', {
          class: 't-label', style: 'margin-bottom:8px', text: 'Agama siswa (opsional)'
        }) : null,
        isLearner ? religionChips : null,
        isLearner ? el('p', {
          class: 't-small', style: 'margin:0 0 8px 0',
          text: 'Memilih agama menyesuaikan soal dan latihan Pendidikan Agama.'
        }) : null
      ];
    }

    refresh();
  }

  function savePersonalInfo() {
    var draft = state.personalDraft;
    if (!draft) {
      closeSheet();
      render();
      return;
    }
    var name = (draft.name || '').trim();
    if (!name) {
      draft.error = 'Nama tidak boleh kosong.';
      openPersonalInfoForm();
      return;
    }
    if (state.role === 'wali') {
      state.waliName = name;
    } else if (state.role === 'guru') {
      state.teacherName = name;
    } else {
      state.studentName = name;
      if (state.role === 'siswa') {
        state.studentClass = draft.className;
        state.parentClass = draft.className;
      } else {
        state.parentClass = draft.className;
      }
      state.religion = draft.religion;
    }
    state.personalDraft = null;
    closeSheet();
    render();
  }

  function profileHero(emoji, name, subtitle, badgeText, onEdit) {
    var children = [
      el('div', { class: 'big-avatar' }, [el('span', { text: emoji })]),
      el('h2', { class: 't-name', text: name }),
      el('p', { class: 't-small', text: subtitle })
    ];
    if (onEdit) {
      children.push(el('button', {
        class: 't-link pressable', type: 'button',
        style: 'display:inline-flex;align-items:center;gap:6px;margin-top:8px',
        onclick: onEdit
      }, [
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('pencil', 15)]),
        el('span', { text: 'Ubah informasi' })
      ]));
    }
    children.push(el('span', { class: 'profile-badge', text: badgeText }));
    return el('div', { class: 'profile-hero' }, children);
  }

  /* ---------------- Guru ---------------- */
  function renderGuruBeranda() {
    var educator = educatorTasks();
    var activeCount = educator.filter(function (t) { return !RESULTS[t.id]; }).length;
    var practiceCount = PRACTICES.filter(function (p) {
      return state.role !== 'guru' || p.subject === state.teacherSubject;
    }).length;
    var recent = educator.length > 2 ? educator.slice(educator.length - 2) : educator;

    return el('div', {}, [
      schoolIdentity(true),
      greetingHeader({
        avatarText: '👩🏻‍🏫',
        eyebrow: 'Selamat datang,',
        userName: state.teacherName,
        subtitle: 'Guru ' + state.teacherSubject + ' · SD Karitas Purwokerto',
        dark: state.dark,
        badgeCount: totalBadgeCount()
      }),
      el('img', { class: 'banner-img', src: ASSETS.teacherBanner, alt: 'Banner guru' }),
      chips(['Semua kelas'].concat(CLASSES), state.filter, function (v) {
        state.filter = v;
        render();
      }),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'people', label: 'Kelas', value: state.filter === 'Semua kelas' ? '6' : '1',
          desc: 'Lihat kelas', color: 'var(--blue)', onTap: function () { go('guru-kelas'); }
        }),
        statCard({
          icon: 'pencil', label: 'Tugas Aktif', value: String(activeCount), desc: 'Kelola tugas',
          color: 'var(--pink)', onTap: function () { go('guru-tugas'); }
        })
      ]),
      wideStatCard({
        icon: 'grid', label: 'Latihan', value: String(practiceCount), desc: 'Kelola latihan di kelas',
        color: PURPLE_STAT, onTap: function () { go('guru-kelas'); }
      }),
      wideStatCard({
        icon: 'megaphone', label: 'Pengumuman', value: String(unreadAnnouncementsCount()),
        desc: 'Belum dibaca', color: PURPLE_STAT, onTap: function () { go('notifikasi'); }
      }),
      wideStatCard({
        icon: 'book', label: 'Materi', value: String(MATERIALS.length),
        desc: 'Kelola materi pembelajaran', color: 'var(--blue)', onTap: function () { go('materi'); }
      }),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Tugas Terbaru' }),
        el('button', {
          class: 't-link pressable', type: 'button', onclick: function () { go('guru-tugas'); }
        }, ['Lihat semua ›'])
      ]),
      recent.map(function (t) {
        return listItemCard({
          iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
          meta: t.subject + ' · ' + t.className + ' · ' + t.minutes + ' menit' + (t.demo ? ' · contoh' : '') +
            ' · ' + deadlineCountdown(t.dueAt, NOW),
          status: RESULTS[t.id] ? 'Selesai' : 'Aktif',
          onTap: function () { openTaskDetail(t); }
        });
      })
    ]);
  }

  function renderGuruKelas() {
    var currentClass = state.filter === 'Semua kelas' ? 'Kelas 1' : state.filter;
    var classTasks = educatorTasks().filter(function (t) { return t.className === currentClass; });
    var classPractices = PRACTICES.filter(function (p) {
      return (p.className === null || p.className === currentClass) &&
        (state.role !== 'guru' || p.subject === state.teacherSubject);
    });
    var completed = classTasks.filter(function (t) { return RESULTS[t.id]; }).length;
    var percentage = classTasks.length ? Math.round((completed / classTasks.length) * 100) : 0;
    var studentNames = ['Dimas Nugroho', 'Sari Putri', 'Rafi Pratama'];
    var visibleSubjects = subjectsForClass(currentClass).filter(function (s) {
      return state.role !== 'guru' || s === state.teacherSubject;
    });

    function metricTile(label, number, sub, bg, onTap) {
      return el('div', {
        class: 'clay-soft class-tile pressable', role: 'button', tabindex: '0',
        style: 'background-color:' + bg, onclick: onTap
      }, [
        el('p', { style: 'color:var(--ink);font-size:12px;margin:0', text: label }),
        el('p', { style: 'color:var(--ink);font-size:25px;font-weight:800;margin:2px 0', text: number }),
        el('p', { class: 't-small', style: 'margin:0', text: sub })
      ]);
    }

    return el('div', {}, [
      pageHeader('Kelas Saya', 'Ruang belajar'),
      chips(CLASSES, currentClass, function (v) {
        state.filter = v;
        render();
      }),
      el('div', { class: 'clay-soft class-hero' }, [
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { style: 'font-size:24px;font-weight:800;color:var(--ink);margin:0', text: currentClass }),
          el('p', { class: 't-muted', style: 'margin:5px 0 0 0', text: 'Belajar seru, tumbuh bersama.' }),
          el('p', { class: 't-small', style: 'margin:0', text: 'Tahun ajaran 2026/2027' })
        ]),
        el('span', { style: 'font-size:68px;line-height:1', text: '🏫' })
      ]),
      el('div', { class: 'tiles-grid' }, [
        metricTile('Jumlah siswa', '3', 'Data contoh', '#FBD5D7', function () { openStudentList(currentClass); }),
        metricTile('Materi latihan', String(classPractices.length), 'Lihat latihan', '#D1F4D8', function () { go('ortu-latihan'); }),
        metricTile('Tugas berjalan', String(classTasks.length - completed), 'Lihat tugas', '#EDD7EF', function () { go('guru-tugas'); }),
        metricTile('Tugas selesai', percentage + '%', 'Data demo', '#F7EDDD', function () { go('guru-tugas'); })
      ]),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Daftar Siswa' }),
        el('button', {
          class: 't-link pressable', type: 'button', onclick: function () { openStudentList(currentClass); }
        }, ['Lihat semua ›'])
      ]),
      studentNames.map(function (name, i) {
        return listItemCard({
          iconEmoji: i === 2 ? '👦🏻' : '🙂', tileColor: '#F8EBEC', title: name,
          meta: i === 0 ? Object.keys(RESULTS).length + ' tugas selesai' : 'Siswa aktif · data contoh',
          status: 'Aktif',
          onTap: function () { openStudentDetail(name, i); }
        });
      }),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Mata Pelajaran' }),
      visibleSubjects.map(function (subject) {
        return listItemCard({
          iconEmoji: metaFor(subject).icon, tileColor: metaFor(subject).color, title: subject,
          meta: currentClass + ' · Lihat tugas dan latihan',
          onTap: function () { openSubjectDetail(subject, currentClass); }
        });
      })
    ]);
  }

  function openStudentList(className) {
    var names = ROSTER[className] || [];
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Siswa ' + className }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: names.length + ' siswa contoh · data lokal' }),
      names.map(function (name, i) {
        return listItemCard({
          iconEmoji: i === 2 ? '👦🏻' : '🙂', tileColor: '#F8EBEC', title: name,
          meta: 'Siswa aktif · data contoh', status: 'Aktif',
          onTap: function () { closeSheet(); openStudentDetail(name, i); }
        });
      })
    ]));
  }

  function openStudentDetail(name, index) {
    var tasks = TASKS.filter(function (t) {
      return t.className === (state.filter === 'Semua kelas' ? 'Kelas 1' : state.filter);
    });
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: name }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Siswa aktif · data contoh' }),
      clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Statistik kelas' }),
        el('p', { class: 't-small', style: 'margin:4px 0 10px 0', text: 'Ringkasan hasil belajar siswa' }),
        chartRow('Tugas', tasks.length, tasks.length, 'var(--blue)', String(tasks.length)),
        chartRow('Selesai', Math.min(index, tasks.length), tasks.length, ATTENDANCE_COLORS.Hadir,
          String(Math.min(index, tasks.length))),
        chartRow('Nilai rata-rata', 80 + index, 100, 'var(--pink)', String(80 + index))
      ]),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () { closeSheet(); render(); }
      }, ['Tutup'])
    ]));
  }

  function openSubjectDetail(subject, className) {
    var tasks = TASKS.filter(function (t) {
      return t.subject === subject && (t.className === className || state.filter === 'Semua kelas');
    });
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: subject }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: className + ' · tugas dan latihan' }),
      tasks.length ? tasks.map(function (t) {
        return listItemCard({
          iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
          meta: t.className + ' · ' + t.minutes + ' menit · ' + deadlineCountdown(t.dueAt, NOW),
          status: RESULTS[t.id] ? 'Selesai' : 'Aktif',
          onTap: function () { closeSheet(); openTaskDetail(t); }
        });
      }) : el('p', { class: 't-muted', text: 'Belum ada tugas untuk mata pelajaran ini.' })
    ]));
  }

  function renderGuruTugas() {
    var query = state.search.trim().toLowerCase();
    var filtered = TASKS.filter(function (t) {
      if (query) {
        var hay = (t.title + ' ' + t.subject + ' ' + t.className).toLowerCase();
        if (hay.indexOf(query) < 0) return false;
      }
      if (state.filter !== 'Semua kelas' && t.className !== state.filter) return false;
      if (state.role === 'guru' && t.subject !== state.teacherSubject) return false;
      var done = !!RESULTS[t.id];
      if (state.taskFilter === 'Selesai') return done;
      if (state.taskFilter === 'Berjalan') return !done;
      return true;
    });

    var children = [
      pageHeader('Daftar Tugas', 'Aktivitas kelas'),
      el('input', {
        class: 'karsa-input', type: 'search', value: state.search,
        placeholder: 'Cari tugas atau mata pelajaran...', 'aria-label': 'Cari tugas',
        oninput: function (e) {
          state.search = e.target.value;
          var vp = document.getElementById('app-viewport');
          var pos = e.target.selectionStart;
          clear(vp);
          vp.appendChild(renderScreen());
          var input = vp.querySelector('input[type="search"]');
          if (input) { input.focus(); try { input.setSelectionRange(pos, pos); } catch (err) { /* ignore */ } }
        }
      }),
      segmentTabs(['Semua', 'Berjalan', 'Selesai'], state.taskFilter, function (v) {
        state.taskFilter = v;
        render();
      }),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () { openTaskForm(); }
      }, ['+ Tambah tugas']),
      state.role === 'guru' ? el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        style: 'border:none;cursor:pointer;background-color:var(--blue)',
        onclick: function () { openGradeRecap(); }
      }, ['Rekap nilai per kelas']) : null,
      noticeCard('📚 Semangat belajar!', 'Kerjakan tugas sedikit demi sedikit setiap hari.')
    ];

    if (!filtered.length) {
      children.push(el('p', {
        class: 't-muted', style: 'text-align:center;margin-top:35px',
        text: 'Belum ada tugas di sini.'
      }));
    } else {
      filtered.forEach(function (t) {
        children.push(el('div', {}, [
          el('p', { class: 't-overline', text: metaFor(t.subject).icon + ' ' + t.subject.toUpperCase() }),
          listItemCard({
            iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
            meta: t.subject + ' · ' + t.className + ' · ' + t.minutes + ' menit' + (t.demo ? ' · contoh' : '') +
              ' · ' + deadlineCountdown(t.dueAt, NOW),
            status: RESULTS[t.id] ? 'Selesai' : 'Aktif',
            onTap: function () { openTaskDetail(t); }
          })
        ]));
      });
    }
    return el('div', {}, children);
  }

  function openTaskForm() {
    var titleInput = el('input', { class: 'karsa-input', id: 'task-title', placeholder: 'Judul tugas' });
    var subjectSelect = el('select', { class: 'karsa-input', id: 'task-subject' },
      SUBJECTS.map(function (s) { return el('option', { value: s, text: s }); }));
    var classSelect = el('select', { class: 'karsa-input', id: 'task-class' },
      CLASSES.map(function (c) { return el('option', { value: c, text: c }); }));
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: '+ Tambah tugas' }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Tugas baru tersimpan lokal di perangkat ini.' }),
      titleInput, subjectSelect, classSelect,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () {
          var title = (document.getElementById('task-title').value || '').trim();
          if (title) {
            TASKS.push({
              id: 'local-' + (TASKS.length + 1),
              subject: document.getElementById('task-subject').value,
              title: title,
              className: document.getElementById('task-class').value,
              minutes: '30',
              dueAt: new Date(NOW.getTime() + 3 * 86400000).toISOString(),
              demo: false
            });
          }
          closeSheet();
          render();
        }
      }, ['Simpan tugas'])
    ]));
  }

  function openGradeRecap() {
    var className = state.filter === 'Semua kelas' ? 'Kelas 1' : state.filter;
    var members = ROSTER[className] || [];
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Rekap Nilai ' + className }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Data lokal · ekspor XLSX dan PDF tersedia di aplikasi Flutter.' }),
      clayCard(members.map(function (name, i) {
        return chartRow(name.split(' ')[0], 70 + i * 5, 100, 'var(--blue)', String(70 + i * 5));
      })),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () { closeSheet(); render(); }
      }, ['Tutup'])
    ]));
  }

  function renderGuruKalender() {
    var calYear = state.calYear || NOW.getFullYear();
    var calMonth = state.calMonth || NOW.getMonth() + 1;
    var calDay = state.calDay || NOW.getDate();
    var isEventDay = calYear === 2026 && calMonth === 11 && (calDay === 6 || calDay === 7);
    return el('div', {}, [
      pageHeader('Kalender', 'Agenda dan kegiatan sekolah'),
      monthCalendar(calYear, calMonth, calDay),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Agenda · ' + calDay + ' ' + monthYearId(calYear, calMonth) }),
      isEventDay
        ? listItemCard({
          iconEmoji: '📣', tileColor: '#F8EBEC',
          title: calDay === 6 ? 'Hari Literasi KARSA' : 'Pertemuan Wali Murid',
          meta: 'Kegiatan sekolah',
          onTap: function () { go('notifikasi'); }
        })
        : el('p', { class: 't-muted', text: 'Tidak ada agenda pada tanggal ini.' })
    ]);
  }

  function renderGuruProfil() {
    var educator = educatorTasks();
    var needReview = educator.filter(function (t) {
      return RESULTS[t.id] && false;
    }).length;
    return el('div', {}, [
      pageHeader('Profil Guru', 'Senang bertemu denganmu!'),
      profileHero('👩🏻‍🏫', state.teacherName, 'Guru ' + state.teacherSubject + ' · SD Karitas Purwokerto', 'Guru aktif'),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Informasi Guru' }),
      clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Mata Pelajaran' }),
        el('p', { class: 't-muted', style: 'margin:4px 0 0 0', text: state.teacherSubject })
      ]),
      el('p', { class: 't-section', style: 'margin:14px 0 10px 0', text: 'Informasi Guru' }),
      clayCard([
        el('p', { class: 't-small', style: 'margin:0', text: 'Kelas diampu' }),
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Kelas 1 sampai Kelas 6' }),
        el('p', { class: 't-small', style: 'margin:10px 0 0 0', text: 'NIP demo' }),
        el('p', { class: 't-item-title', style: 'margin:0', text: ACCOUNTS.guru.id })
      ]),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Ringkasan Aktivitas' }),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'checkmark', label: 'Tugas Aktif',
          value: String(educator.filter(function (t) { return !RESULTS[t.id]; }).length),
          desc: 'Lihat tugas', color: 'var(--blue)', onTap: function () { go('guru-tugas'); }
        }),
        statCard({
          icon: 'albums', label: 'Kuis Dibuat', value: String(educator.length),
          desc: 'Data demo', color: 'var(--pink)', onTap: function () { go('guru-tugas'); }
        })
      ]),
      el('div', { class: 'stats-grid', style: 'margin-top:10px' }, [
        statCard({
          icon: 'people', label: 'Siswa', value: '3', desc: 'Data contoh', color: PURPLE_STAT,
          onTap: function () { openStudentList(state.filter === 'Semua kelas' ? 'Kelas 1' : state.filter); }
        }),
        statCard({
          icon: 'checkmark-done', label: 'Perlu Diperiksa', value: String(needReview),
          desc: 'Hasil baru', color: GREEN_STAT, onTap: function () { go('guru-tugas'); }
        })
      ]),
      el('p', { class: 't-section', style: 'margin:20px 0 10px 0', text: 'Pengaturan' }),
      ['Informasi pribadi', 'Mata pelajaran', 'Tampilan', 'Notifikasi', 'Privasi dan keamanan', 'Pusat bantuan']
        .map(function (item) {
          return clayCard([
            el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
              el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon(settingIcon(item), 20)]),
              el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: item }),
              el('span', { style: 'color:var(--muted);display:inline-flex' }, [icon('chevron-forward', 17)])
            ])
          ], { onTap: function () { openSetting(item); } });
        }),
      el('div', { style: 'text-align:center' }, [
        el('button', {
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: function () { go('welcome'); }
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  /* ---------------- Siswa ---------------- */
  function renderSiswaBeranda() {
    var childClass = state.studentClass;
    var classTasks = TASKS.filter(function (t) { return t.className === childClass; });
    var completed = classTasks.filter(function (t) { return RESULTS[t.id]; });
    var active = activeTasks();
    var ratio = classTasks.length ? Math.min(1, completed.length / classTasks.length) : 0;
    var classMaterials = MATERIALS.filter(function (m) { return m.className === childClass; }).length;
    var classSubjects = subjectsForClass(childClass);

    return el('div', {}, [
      schoolIdentity(true),
      greetingHeader({
        avatarText: '👦🏻',
        eyebrow: 'Halo, selamat belajar!',
        userName: state.studentName,
        subtitle: childClass + ' · SD Karitas Purwokerto',
        dark: state.dark,
        badgeCount: totalBadgeCount()
      }),
      el('div', { class: 'clay-soft student-hero' }, [
        el('div', { class: 'hero-cloud-1' }),
        el('div', { class: 'hero-cloud-2' }),
        el('div', { style: 'flex:1;min-width:0;position:relative;z-index:1' }, [
          el('p', {
            style: 'color:var(--rose);letter-spacing:1.2px;font-size:9px;font-weight:800;margin:0',
            text: '✦ RUANG BELAJAR'
          }),
          el('p', {
            style: 'font-size:25px;line-height:29px;color:var(--ink);font-weight:900;margin:8px 0 7px 0',
            text: 'Semangat\nbelajar!'
          }),
          el('p', {
            style: 'font-size:11px;line-height:16px;color:var(--student-hero-text);max-width:205px;margin:0',
            text: 'Satu langkah kecil hari ini, selangkah lebih dekat ke mimpimu.'
          })
        ]),
        el('div', { style: 'position:relative;z-index:1' }, [
          el('div', { class: 'student-hero-art' }, [el('span', { style: 'font-size:44px', text: '📚' })]),
          el('span', { style: 'position:absolute;right:-7px;top:-8px;font-size:23px', text: '✨' })
        ])
      ]),
      clayCard([
        el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
          el('div', {
            class: 'stat-icon-circle',
            style: 'background-color:var(--surface-badge);font-size:22px;width:42px;height:42px;border-radius:14px'
          }, ['🎯']),
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', { class: 't-item-title', style: 'margin:0', text: 'Misi belajarmu' }),
            el('p', { class: 't-small', style: 'margin:0', text: 'Selesaikan tugas di ' + childClass })
          ]),
          el('p', { style: 'font-size:14px;font-weight:900;color:var(--rose);margin:0', text: completed.length + '/' + classTasks.length })
        ]),
        el('div', { class: 'mission-track' }, [
          el('div', { class: 'mission-fill', style: 'width:' + (ratio * 100) + '%' })
        ]),
        el('p', {
          class: 't-small', style: 'margin:0',
          text: active.length ? 'Sedikit demi sedikit, kamu pasti bisa!' : 'Hebat! Semua tugas sudah selesai.'
        })
      ]),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'pencil', label: 'Tugas aktif', value: String(active.length),
          desc: 'Menunggu dikerjakan', color: 'var(--pink)', onTap: function () { go('siswa-tugas'); }
        }),
        statCard({
          icon: 'checkmark-circle', label: 'Selesai', value: String(completed.length),
          desc: 'Lihat riwayat', color: 'var(--blue)', onTap: function () { state.taskFilter = 'Riwayat'; go('siswa-tugas'); }
        })
      ]),
      wideStatCard({
        icon: 'book', label: 'Materi kelas', value: String(classMaterials),
        desc: 'Buka ringkasan dan materi', color: 'var(--blue)', onTap: function () { go('materi'); }
      }),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Tugas per mata pelajaran' }),
        el('button', {
          class: 't-link pressable', type: 'button', onclick: function () { go('siswa-tugas'); }
        }, ['Lihat semua ›'])
      ]),
      classSubjects.map(function (subject) {
        var list = active.filter(function (t) { return t.subject === subject; });
        list.sort(function (a, b) {
          return (new Date(a.dueAt || 0)) - (new Date(b.dueAt || 0));
        });
        var next = list.length ? list[0] : null;
        return listItemCard({
          iconEmoji: metaFor(subject).icon, tileColor: metaFor(subject).color, title: subject,
          meta: next
            ? next.title + ' · ' + deadlineCountdown(next.dueAt, NOW)
            : 'Tidak ada tugas aktif',
          status: next ? list.length + ' tugas' : 'Lihat',
          onTap: function () {
            state.subjectFilter = subject;
            state.taskFilter = 'Aktif';
            go('siswa-tugas');
          }
        });
      }),
      el('button', {
        class: 'tip-card pressable', type: 'button',
        'aria-label': 'Lihat tips belajar berikutnya',
        onclick: function () {
          state.tipIndex = (state.tipIndex + 1) % STUDY_TIPS.length;
          render();
        }
      }, [
        el('div', { class: 'tip-icon' }, [el('span', { text: '💡' })]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Tips belajar' }),
          el('p', { class: 't-small', style: 'margin:0', text: STUDY_TIPS[state.tipIndex] })
        ]),
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('refresh-outline', 20)])
      ])
    ]);
  }

  function renderSiswaTugas() {
    var childClass = state.studentClass;
    var allowed = subjectsForClass(childClass);
    var query = state.search.trim().toLowerCase();
    var filtered = TASKS.filter(function (t) {
      if (state.subjectFilter !== 'Semua' && t.subject !== state.subjectFilter) return false;
      if (query) {
        var hay = (t.title + ' ' + t.subject + ' ' + t.className).toLowerCase();
        if (hay.indexOf(query) < 0) return false;
      }
      if (t.className !== childClass || allowed.indexOf(t.subject) < 0) return false;
      var done = !!RESULTS[t.id];
      return state.taskFilter === 'Riwayat' ? done : !done;
    });

    var title = state.subjectFilter !== 'Semua' ? state.subjectFilter : 'Tugas';
    var children = [
      pageHeader(title, 'Dimas Nugroho · ' + childClass),
      chips(['Semua'].concat(allowed), state.subjectFilter, function (v) {
        state.subjectFilter = v;
        render();
      }),
      el('input', {
        class: 'karsa-input', type: 'search', value: state.search,
        placeholder: 'Cari tugas atau mata pelajaran...', 'aria-label': 'Cari tugas',
        oninput: function (e) {
          state.search = e.target.value;
          var vp = document.getElementById('app-viewport');
          var pos = e.target.selectionStart;
          clear(vp);
          vp.appendChild(renderScreen());
          var input = vp.querySelector('input[type="search"]');
          if (input) { input.focus(); try { input.setSelectionRange(pos, pos); } catch (err) { /* ignore */ } }
        }
      }),
      segmentTabs(['Aktif', 'Riwayat'], state.taskFilter, function (v) {
        state.taskFilter = v;
        render();
      }),
      noticeCard('📚 Semangat belajar!', 'Kerjakan tugas sedikit demi sedikit setiap hari.')
    ];

    if (!filtered.length) {
      children.push(el('p', {
        class: 't-muted', style: 'text-align:center;margin-top:35px', text: 'Belum ada tugas di sini.'
      }));
    } else {
      filtered.forEach(function (t) {
        children.push(el('div', {}, [
          el('p', { class: 't-overline', text: metaFor(t.subject).icon + ' ' + t.subject.toUpperCase() }),
          listItemCard({
            iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
            meta: t.subject + ' · ' + t.className + ' · ' + t.minutes + ' menit' + (t.demo ? ' · contoh' : '') +
              ' · ' + deadlineCountdown(t.dueAt, NOW),
            status: RESULTS[t.id] ? 'Selesai' : 'Kerjakan',
            onTap: function () { openTaskDetail(t); }
          })
        ]));
      });
    }
    return el('div', {}, children);
  }

  function renderSiswaProfil() {
    var childClass = state.studentClass;
    var allowed = subjectsForClass(childClass);
    var done = TASKS.filter(function (t) {
      return t.className === childClass && allowed.indexOf(t.subject) >= 0 && RESULTS[t.id];
    }).length;
    return el('div', {}, [
      pageHeader('Profil Anak', 'Senang bertemu denganmu!'),
      noticeCard('🌟 Semangat belajar, ' + state.studentName + '!',
        activeTasks().length ? 'Ada ' + activeTasks().length + ' tugas yang belum dikumpulkan.'
          : 'Semua tugas sudah selesai. Hebat!'),
      profileHero('👦🏻', state.studentName, childClass + ' · SD Karitas Purwokerto', 'Siswa aktif',
        function () { openSetting('Informasi pribadi'); }),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Informasi pribadi' }),
      personalInfoCard(true),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Aktivitas Tugas' }),
      clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Semangat mengerjakan tugas!' }),
        el('p', { class: 't-muted', style: 'margin:4px 0 0 0', text: done + ' tugas selesai.' })
      ]),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Nilai kelas' }),
      classGradesCard(),
      el('p', { class: 't-section', style: 'margin:20px 0 10px 0', text: 'Pengaturan' }),
      ['Informasi pribadi', 'Tampilan', 'Notifikasi', 'Privasi dan keamanan', 'Pusat bantuan'].map(function (item) {
        return clayCard([
          el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
            el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon(settingIcon(item), 20)]),
            el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: item }),
            el('span', { style: 'color:var(--muted);display:inline-flex' }, [icon('chevron-forward', 17)])
          ])
        ], { onTap: function () { openSetting(item); } });
      }),
      el('div', { style: 'text-align:center' }, [
        el('button', {
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: function () { go('welcome'); }
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  /* ---------------- Orang tua ---------------- */
  function renderOrtuBeranda() {
    var active = activeTasks();
    var remaining = visiblePractices().length;
    var classMaterials = MATERIALS.filter(function (m) { return m.className === state.parentClass; }).length;
    var preview = active.length > 2 ? active.slice(active.length - 2) : active;

    return el('div', {}, [
      schoolIdentity(true),
      greetingHeader({
        avatarText: 'D',
        avatarIsLetter: true,
        eyebrow: 'Orang tua dari',
        userName: state.studentName,
        subtitle: state.parentClass + ' · SD Karitas Purwokerto',
        dark: state.dark,
        badgeCount: totalBadgeCount()
      }),
      el('img', { class: 'banner-img', src: ASSETS.studentBanner, alt: 'Banner siswa' }),
      el('div', { class: 'stats-grid' }, [
        statCard({
          icon: 'pencil', label: 'Tugas Aktif', value: String(active.length),
          desc: 'Belum dikumpulkan', color: 'var(--blue)', onTap: function () { go('ortu-tugas'); }
        }),
        statCard({
          icon: 'grid', label: 'Latihan', value: String(remaining),
          desc: 'Belum dikerjakan', color: 'var(--pink)', onTap: function () { go('ortu-latihan'); }
        })
      ]),
      wideStatCard({
        icon: 'megaphone', label: 'Pengumuman', value: String(unreadAnnouncementsCount()),
        desc: 'Belum dibaca', color: PURPLE_STAT, onTap: function () { go('notifikasi'); }
      }),
      clayCard([
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-overline', style: 'margin:0 0 2px 0', text: 'RUANG TUMBUH' }),
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Perjalanan belajar ✨' }),
          el('p', { class: 't-small', style: 'margin:0', text: 'Lihat bintang dan semangat belajarmu' })
        ]),
        el('span', { style: 'font-size:30px', text: '🌟' }),
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 20)])
      ], { backgroundColor: '#F8EDF0', onTap: function () { openProgress(); } }),
      wideStatCard({
        icon: 'book', label: 'Materi', value: String(classMaterials),
        desc: 'Lihat materi untuk kelasmu', color: 'var(--blue)', onTap: function () { go('materi'); }
      }),
      el('div', { class: 'section-row' }, [
        el('p', { class: 't-section', text: 'Tugas untukmu' }),
        el('button', {
          class: 't-link pressable', type: 'button', onclick: function () { go('ortu-tugas'); }
        }, ['Lihat semua ›'])
      ]),
      preview.length ? preview.map(function (t) {
        return listItemCard({
          iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
          meta: t.subject + ' · ' + t.className + ' · ' + t.minutes + ' menit' + (t.demo ? ' · contoh' : '') +
            ' · ' + deadlineCountdown(t.dueAt, NOW),
          status: RESULTS[t.id] ? 'Selesai' : 'Aktif',
          onTap: function () { openTaskDetail(t); }
        });
      }) : el('p', { class: 't-muted', text: 'Semua tugas sudah selesai. Hebat!' })
    ]);
  }

  function openProgress() {
    var stars = Math.min(5, 1 + Object.keys(RESULTS).length);
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Ruang Tumbuh' }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Perjalanan belajar Dimas Nugroho · data lokal' }),
      clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Bintang semangat' }),
        el('p', { style: 'font-size:32px;letter-spacing:4px;margin:8px 0', text: '★★★★★'.slice(0, stars) + '☆☆☆☆☆'.slice(0, 5 - stars) }),
        el('p', { class: 't-small', style: 'margin:0', text: 'Moods hari ini' }),
        el('div', { style: 'display:flex;gap:8px;margin-top:8px' }, MOOD_OPTIONS.map(function (m) {
          var selected = state.mood === m[1];
          return el('button', {
            class: 'pressable', type: 'button',
            style: 'flex:1;border-radius:14px;padding:10px 4px;border:2px solid ' +
              (selected ? 'var(--rose)' : 'var(--clay-soft-border)') +
              ';background-color:var(--surface-input);font-size:20px',
            'aria-label': 'Mood ' + m[1],
            onclick: function () { state.mood = m[1]; closeSheet(); render(); openProgress(); }
          }, [m[0]]);
        }))
      ])
    ]));
  }

  function renderOrtuTugas() {
    var childClass = state.parentClass;
    var allowed = subjectsForClass(childClass);
    var query = state.search.trim().toLowerCase();
    var filtered = TASKS.filter(function (t) {
      if (t.className !== childClass || allowed.indexOf(t.subject) < 0) return false;
      if (query) {
        var hay = (t.title + ' ' + t.subject + ' ' + t.className).toLowerCase();
        if (hay.indexOf(query) < 0) return false;
      }
      var done = !!RESULTS[t.id];
      return state.taskFilter === 'Riwayat' ? done : !done;
    });

    var children = [
      pageHeader('Tugas', 'Dimas Nugroho · ' + childClass),
      el('input', {
        class: 'karsa-input', type: 'search', value: state.search,
        placeholder: 'Cari tugas atau mata pelajaran...', 'aria-label': 'Cari tugas',
        oninput: function (e) {
          state.search = e.target.value;
          var vp = document.getElementById('app-viewport');
          var pos = e.target.selectionStart;
          clear(vp);
          vp.appendChild(renderScreen());
          var input = vp.querySelector('input[type="search"]');
          if (input) { input.focus(); try { input.setSelectionRange(pos, pos); } catch (err) { /* ignore */ } }
        }
      }),
      segmentTabs(['Aktif', 'Riwayat'], state.taskFilter, function (v) {
        state.taskFilter = v;
        render();
      }),
      noticeCard('📚 Semangat belajar!', 'Kerjakan tugas sedikit demi sedikit setiap hari.')
    ];

    if (!filtered.length) {
      children.push(el('p', {
        class: 't-muted', style: 'text-align:center;margin-top:35px', text: 'Belum ada tugas di sini.'
      }));
    } else {
      filtered.forEach(function (t) {
        children.push(el('div', {}, [
          el('p', { class: 't-overline', text: metaFor(t.subject).icon + ' ' + t.subject.toUpperCase() }),
          listItemCard({
            iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
            meta: t.subject + ' · ' + t.className + ' · ' + t.minutes + ' menit' + (t.demo ? ' · contoh' : '') +
              ' · ' + deadlineCountdown(t.dueAt, NOW),
            status: RESULTS[t.id] ? 'Selesai' : 'Kerjakan',
            onTap: function () { openTaskDetail(t); }
          })
        ]));
      });
    }
    return el('div', {}, children);
  }

  function renderOrtuLatihan() {
    var practices = visiblePractices();
    return el('div', {}, [
      pageHeader('Latihan', '0 dari ' + practices.length + ' selesai · soal esai'),
      practices.map(function (p) {
        return el('div', {}, [
          el('p', { class: 't-overline', text: metaFor(p.subject).icon + ' ' + p.subject.toUpperCase() }),
          listItemCard({
            iconEmoji: metaFor(p.subject).icon, tileColor: metaFor(p.subject).color, title: p.title,
            meta: '5 soal esai · tanpa batas waktu',
            status: 'Kerjakan',
            onTap: function () { openPractice(p); }
          })
        ]);
      })
    ]);
  }

  function openPractice(practice) {
    var bank = typeof CURR.exercisesFor === 'function'
      ? CURR.exercisesFor(normalizeSubject(practice.subject), state.religion || '')
      : (CURR.practiceBank[normalizeSubject(practice.subject)] || []);
    var answers = [];
    var index = 0;

    function body() {
      if (index >= bank.length) {
        return el('div', {}, [
          el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Hasil latihan' }),
          el('p', { class: 't-muted', style: 'margin-bottom:14px', text: practice.title + ' · ' + bank.length + ' soal esai selesai' }),
          el('p', { class: 't-result-number', text: answers.filter(function (a) { return a.trim().length > 0; }).length + ' / ' + bank.length }),
          el('button', {
            class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
            onclick: function () { closeSheet(); render(); }
          }, ['Tutup'])
        ]);
      }
      var q = bank[index];
      var textarea = el('textarea', {
        class: 'karsa-input', rows: '3', value: answers[index] || '',
        placeholder: 'Tulis jawabanmu...', 'aria-label': 'Jawaban esai soal ' + (index + 1),
        style: 'height:auto;resize:vertical',
        oninput: function (e) { answers[index] = e.target.value; }
      });
      return el('div', {}, [
        el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: practice.title }),
        el('p', { class: 't-muted', style: 'margin-bottom:12px', text: 'Soal ' + (index + 1) + ' dari ' + bank.length + ' · tanpa batas waktu' }),
        el('p', { class: 't-item-title', style: 'margin-bottom:10px', text: q.prompt }),
        textarea,
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
          onclick: function () {
            answers[index] = (textarea.value || '').trim();
            index += 1;
            var panel = document.getElementById('sheet-panel');
            clear(panel);
            panel.appendChild(body());
          }
        }, [index + 1 >= bank.length ? 'Selesai' : 'Soal berikutnya'])
      ]);
    }

    openSheet(body());
  }

  function renderOrtuProfil() {
    return el('div', {}, [
      pageHeader('Profil Anak', 'Senang bertemu denganmu!'),
      noticeCard('🌟 Semangat belajar, ' + state.studentName + '!',
        activeTasks().length ? 'Ada ' + activeTasks().length + ' tugas yang belum dikumpulkan.'
          : 'Semua tugas sudah selesai. Hebat!'),
      profileHero('👦🏻', state.studentName, state.parentClass + ' · SD Karitas Purwokerto', 'Siswa aktif',
        function () { openSetting('Informasi pribadi'); }),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Informasi pribadi' }),
      personalInfoCard(false),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Perjalanan Belajarku' }),
      clayCard([
        el('p', { class: 't-item-title', style: 'margin:0', text: 'Terus bertumbuh! 🌱' }),
        el('p', {
          class: 't-muted', style: 'margin:4px 0 0 0',
          text: Object.keys(RESULTS).length + ' tugas dan 0 latihan selesai.'
        })
      ]),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Nilai kelas' }),
      classGradesCard(),
      el('p', { class: 't-section', style: 'margin:20px 0 10px 0', text: 'Pengaturan' }),
      ['Informasi pribadi', 'Tampilan', 'Notifikasi', 'Privasi dan keamanan', 'Pusat bantuan'].map(function (item) {
        return clayCard([
          el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
            el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon(settingIcon(item), 20)]),
            el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: item }),
            el('span', { style: 'color:var(--muted);display:inline-flex' }, [icon('chevron-forward', 17)])
          ])
        ], { onTap: function () { openSetting(item); } });
      }),
      el('div', { style: 'text-align:center' }, [
        el('button', {
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: function () { go('welcome'); }
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  /* ---------------- Shared pages ---------------- */
  function renderMateri() {
    var list = MATERIALS.filter(function (m) {
      if (state.role === 'guru') {
        var classOk = state.filter === 'Semua kelas' || m.className === state.filter;
        var subjOk = m.subject === state.teacherSubject;
        return classOk && subjOk;
      }
      if (state.role === 'wali') return m.className === WALI_CLASS;
      return m.className === state.parentClass || m.className === state.studentClass;
    });

    var children = [
      pageHeader('Materi belajar', state.role === 'guru' ? 'Kelola materi dan ringkasan' : 'Materi untuk ' + state.parentClass,
        function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); }),
      state.role === 'guru' ? el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () { openMaterialForm(); }
      }, ['+ Unggah materi']) : null,
      el('p', { class: 't-muted', style: 'margin:12px 0', text: 'Materi dan ringkasan tersimpan di perangkat ini.' })
    ];

    if (!list.length) {
      children.push(el('p', {
        class: 't-muted', style: 'text-align:center;margin-top:35px', text: 'Belum ada materi untuk ditampilkan.'
      }));
    } else {
      list.forEach(function (m) {
        children.push(listItemCard({
          iconEmoji: metaFor(m.subject).icon, tileColor: metaFor(m.subject).color, title: m.title,
          meta: m.subject + ' · ' + m.className + ' · ' + m.teacher, status: 'Lihat',
          onTap: function () {
            openSheet(el('div', {}, [
              el('div', { class: 'sheet-handle' }),
              el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: m.title }),
              el('p', { class: 't-muted', style: 'margin-bottom:12px', text: m.subject + ' · ' + m.className + ' · ' + m.teacher }),
              el('p', { class: 't-muted', text: m.body }),
              el('button', {
                class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
                onclick: function () { closeSheet(); render(); }
              }, ['Tutup'])
            ]));
          }
        }));
      });
    }
    return el('div', {}, children);
  }

  function openMaterialForm() {
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: '+ Unggah materi' }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Materi tersimpan lokal di perangkat ini.' }),
      el('input', { class: 'karsa-input', id: 'material-title', placeholder: 'Judul materi' }),
      el('select', { class: 'karsa-input', id: 'material-class' },
        CLASSES.map(function (c) { return el('option', { value: c, text: c }); })),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () {
          var title = (document.getElementById('material-title').value || '').trim();
          if (title) {
            MATERIALS.push({
              id: 'm' + (MATERIALS.length + 1), subject: state.teacherSubject,
              className: document.getElementById('material-class').value,
              title: title, teacher: 'Ibu Sari', body: 'Ringkasan materi contoh tersimpan lokal.'
            });
          }
          closeSheet();
          render();
        }
      }, ['Simpan materi'])
    ]));
  }

  function renderNotifikasi() {
    var list = relevantNotifications();
    var children = [
      pageHeader('Notifikasi', 'Pembaruan pembelajaran di perangkat ini',
        function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); }),
      noticeCard('Pengumuman sekolah (' + unreadAnnouncementsCount() + ')',
        visibleAnnouncements().map(function (a) { return a.title; }).join(' · '))
    ];
    if (!list.length) {
      children.push(el('p', {
        class: 't-muted', style: 'text-align:center;margin:35px 0 20px 0', text: 'Belum ada pemberitahuan baru.'
      }));
    } else {
      list.forEach(function (n) {
        children.push(listItemCard({
          iconEmoji: n.target === 'teachers' ? '✅' : (n.kind === 'material' ? '📚' : '📝'),
          tileColor: '#F8EBEC', title: n.title,
          meta: n.subject + ' · ' + n.className + ' · ' + createdAtId(n.createdAt),
          status: 'Baru',
          onTap: function () { n.read = true; render(); }
        }));
      });
    }
    children.push(el('button', {
      class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
      onclick: function () { openAnnouncements(); }
    }, ['Pengumuman sekolah (' + unreadAnnouncementsCount() + ')']));
    children.push(el('p', {
      class: 't-muted',
      style: 'text-align:center;color:var(--muted);font-size:12px;margin-top:18px',
      text: 'Notifikasi demo hanya muncul pada perangkat/browser yang sama, bukan push notification.'
    }));
    return el('div', {}, children);
  }

  function openAnnouncements() {
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Pengumuman sekolah' }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: visibleAnnouncements().length + ' pengumuman · data lokal' }),
      visibleAnnouncements().map(function (a) {
        return clayCard([
          el('p', { class: 't-overline', style: 'margin:0 0 4px 0', text: a.category }),
          el('p', { class: 't-item-title', style: 'margin:0', text: a.title }),
          el('p', { class: 't-small', style: 'margin:4px 0 0 0', text: a.detail }),
          el('p', { class: 't-muted', style: 'margin:8px 0 0 0', text: a.body })
        ]);
      })
    ]));
  }

  function openTaskDetail(task) {
    var bank = quizBankFor(task.subject);
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: task.title }),
      el('p', {
        class: 't-muted', style: 'margin-bottom:12px',
        text: task.subject + ' · ' + task.className + ' · ' + task.minutes + ' menit · ' +
          deadlineCountdown(task.dueAt, NOW)
      }),
      el('p', { class: 't-item-title', style: 'margin-bottom:8px', text: 'Soal tersedia: ' + bank.length + ' pertanyaan' }),
      RESULTS[task.id]
        ? el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
          onclick: function () { closeSheet(); showResult(task); }
        }, ['Lihat hasil'])
        : el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
          onclick: function () { closeSheet(); startQuiz(task); }
        }, ['Kerjakan kuis']),
      el('button', {
        class: 't-link pressable', type: 'button', style: 'margin-top:12px;display:block;width:100%',
        onclick: function () { closeSheet(); render(); }
      }, ['Tutup'])
    ]));
  }

  function startQuiz(task) {
    state.quiz = {
      task: task,
      bank: quizBankFor(task.subject),
      index: 0,
      choice: -1,
      checked: false,
      answers: [],
      score: 0
    };
    go('kuis');
  }

  function renderQuiz() {
    var quiz = state.quiz;
    if (!quiz) {
      return el('div', {}, [
        pageHeader('Kuis', null, function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); })
      ]);
    }
    var q = quiz.bank[quiz.index];
    var letters = ['A', 'B', 'C', 'D'];
    var ratio = (quiz.index + 1) / quiz.bank.length;

    var choices = q.choices.map(function (choice, i) {
      var selected = quiz.choice === i;
      var isCorrect = quiz.checked && i === q.answerIndex;
      var cls = 'choice-btn pressable';
      if (isCorrect) cls += ' correct';
      else if (selected) cls += ' selected';
      return el('button', {
        class: cls, type: 'button',
        onclick: function () {
          if (quiz.checked) return;
          quiz.choice = i;
          render();
        }
      }, [
        el('span', { class: 'choice-letter', text: letters[i % letters.length] }),
        el('span', { style: 'flex:1;font-size:14px;color:var(--ink)', text: choice })
      ]);
    });

    return el('div', {}, [
      pageHeader(quiz.task.subject + ' · ' + quiz.task.title, 'Soal ' + (quiz.index + 1) + ' dari ' + quiz.bank.length,
        function () { go('kuis'); }),
      el('div', { class: 'quiz-progress' }, [
        el('div', { class: 'quiz-progress-fill', style: 'width:' + (ratio * 100) + '%' })
      ]),
      el('p', { class: 'quiz-question', text: q.question }),
      choices,
      quiz.checked ? noticeCard('Jawaban benar: ' + q.choices[q.answerIndex] + ' · ' + q.explanation) : null,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
        onclick: function () {
          if (!quiz.checked) {
            if (quiz.choice < 0) return;
            quiz.checked = true;
            if (quiz.choice === q.answerIndex) quiz.score += 1;
          } else if (quiz.index + 1 >= quiz.bank.length) {
            quiz.answers = quiz.answers;
            RESULTS[quiz.task.id] = {
              score: quiz.score, total: quiz.bank.length, answers: quiz.answers, demo: quiz.task.demo
            };
            state.quiz = null;
            go('hasil-kuis');
            return;
          } else {
            quiz.index += 1;
            quiz.choice = -1;
            quiz.checked = false;
          }
          render();
        }
      }, [
        quiz.checked
          ? (quiz.index + 1 >= quiz.bank.length ? 'Selesai' : 'Soal berikutnya')
          : 'Periksa jawaban'
      ])
    ]);
  }

  function showResult(task) {
    state.quizResult = { task: task, result: RESULTS[task.id] };
    go('hasil-kuis');
  }

  function renderHasilKuis() {
    var target = state.quizResult;
    if (!target) {
      return el('div', {}, [
        pageHeader('Hasil kuis', null, function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); })
      ]);
    }
    var task = target.task;
    var result = target.result;
    var bank = quizBankFor(task.subject);
    var total = result.total || bank.length;

    var children = [
      pageHeader('Hasil kuis', task.subject + ' · ' + task.title + (result.demo ? ' · Contoh' : ''),
        function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); }),
      el('div', { class: 'clay-soft', style: 'margin-bottom:16px;padding:45px;text-align:center' }, [
        el('span', { style: 'font-size:45px', text: '🌟' }),
        el('p', { class: 't-result-number', style: 'margin:15px 0', text: (result.score || 0) + ' / ' + total }),
        el('p', { class: 't-section', style: 'margin:0', text: 'Bagus! Terus berlatih ya.' })
      ])
    ];

    if (total !== bank.length) {
      children.push(el('p', {
        class: 't-small',
        text: 'Rincian soal lama tidak tersedia setelah pembaruan bank soal; nilai tetap tersimpan.'
      }));
    } else {
      for (var i = 0; i < total; i++) {
        var answered = (result.answers || [])[i];
        children.push(clayCard([
          el('p', {
            class: 't-item-title', style: 'margin:0',
            text: (answered === bank[i].answerIndex ? '✓' : '✕') + ' ' + (i + 1) + '. ' + bank[i].question
          }),
          el('p', {
            class: 't-small', style: 'margin:4px 0 0 0',
            text: 'Jawaban benar: ' + bank[i].choices[bank[i].answerIndex]
          })
        ]));
      }
    }
    children.push(el('p', {
      class: 't-muted',
      style: 'text-align:center;color:var(--muted);font-size:12px;margin-top:18px',
      text: 'Hasil tersimpan di perangkat ini, belum dikirim ke guru.'
    }));
    children.push(el('button', {
      class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
      onclick: function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); }
    }, ['Kembali ke tugas']));
    return el('div', {}, children);
  }

  /* ------------------------------------------------------------------ *
   * Screen registry (28 canonical screens)
   * ------------------------------------------------------------------ */
  var SCREENS = [
    { id: 'splash', label: 'Splash', group: 'Umum', render: renderSplash, nav: null },
    { id: 'welcome', label: 'Pilih Peran', group: 'Umum', render: renderWelcome, nav: null },
    { id: 'login-wali', label: 'Login · Wali Kelas', group: 'Umum', render: function () { return renderLogin('wali'); }, nav: null },
    { id: 'login-guru', label: 'Login · Guru', group: 'Umum', render: function () { return renderLogin('guru'); }, nav: null },
    { id: 'login-ortu', label: 'Login · Orang Tua', group: 'Umum', render: function () { return renderLogin('orangtua'); }, nav: null },
    { id: 'login-siswa', label: 'Login · Siswa', group: 'Umum', render: function () { return renderLogin('siswa'); }, nav: null },
    { id: 'forgot', label: 'Lupa Kata Sandi', group: 'Umum', render: renderForgot, nav: null },
    { id: 'wali-beranda', label: 'Wali · Beranda', group: 'Wali Kelas', render: renderWaliBeranda, nav: 'wali' },
    { id: 'wali-anggota', label: 'Wali · Anggota', group: 'Wali Kelas', render: renderWaliAnggota, nav: 'wali' },
    { id: 'wali-recap', label: 'Wali · Rekap', group: 'Wali Kelas', render: renderWaliRecap, nav: 'wali' },
    { id: 'wali-agenda', label: 'Wali · Agenda', group: 'Wali Kelas', render: renderWaliAgenda, nav: 'wali' },
    { id: 'wali-profil', label: 'Wali · Profil', group: 'Wali Kelas', render: renderWaliProfil, nav: 'wali' },
    { id: 'guru-beranda', label: 'Guru · Beranda', group: 'Guru', render: renderGuruBeranda, nav: 'guru' },
    { id: 'guru-kelas', label: 'Guru · Kelas', group: 'Guru', render: renderGuruKelas, nav: 'guru' },
    { id: 'guru-tugas', label: 'Guru · Tugas', group: 'Guru', render: renderGuruTugas, nav: 'guru' },
    { id: 'guru-kalender', label: 'Guru · Kalender', group: 'Guru', render: renderGuruKalender, nav: 'guru' },
    { id: 'guru-profil', label: 'Guru · Profil', group: 'Guru', render: renderGuruProfil, nav: 'guru' },
    { id: 'siswa-beranda', label: 'Siswa · Beranda', group: 'Siswa', render: renderSiswaBeranda, nav: 'siswa' },
    { id: 'siswa-tugas', label: 'Siswa · Tugas', group: 'Siswa', render: renderSiswaTugas, nav: 'siswa' },
    { id: 'siswa-profil', label: 'Siswa · Profil', group: 'Siswa', render: renderSiswaProfil, nav: 'siswa' },
    { id: 'ortu-beranda', label: 'Orang Tua · Beranda', group: 'Orang Tua', render: renderOrtuBeranda, nav: 'orangtua' },
    { id: 'ortu-tugas', label: 'Orang Tua · Tugas', group: 'Orang Tua', render: renderOrtuTugas, nav: 'orangtua' },
    { id: 'ortu-latihan', label: 'Orang Tua · Latihan', group: 'Orang Tua', render: renderOrtuLatihan, nav: 'orangtua' },
    { id: 'ortu-profil', label: 'Orang Tua · Profil', group: 'Orang Tua', render: renderOrtuProfil, nav: 'orangtua' },
    { id: 'materi', label: 'Materi', group: 'Umum', render: renderMateri, nav: null },
    { id: 'notifikasi', label: 'Notifikasi', group: 'Umum', render: renderNotifikasi, nav: null },
    { id: 'kuis', label: 'Kuis', group: 'Umum', render: renderQuiz, nav: null },
    { id: 'hasil-kuis', label: 'Hasil Kuis', group: 'Umum', render: renderHasilKuis, nav: null }
  ];

  var SCREEN_ALIASES = { 'wali-rekap': 'wali-recap' };

  function resolveScreen(id) {
    if (SCREEN_ALIASES[id]) return SCREEN_ALIASES[id];
    for (var i = 0; i < SCREENS.length; i++) {
      if (SCREENS[i].id === id) return SCREENS[i].id;
    }
    return null;
  }

  function screenDef(id) {
    for (var i = 0; i < SCREENS.length; i++) {
      if (SCREENS[i].id === id) return SCREENS[i];
    }
    return null;
  }

  /* ------------------------------------------------------------------ *
   * Navigation
   * ------------------------------------------------------------------ */
  var NAV_ICONS = {
    Beranda: 'home', Anggota: 'people', Rekap: 'bar-chart', Agenda: 'calendar', Profil: 'person',
    Kelas: 'grid', Tugas: 'book', Kalender: 'calendar', Latihan: 'albums'
  };

  function navScreenFor(role, tab) {
    var prefix = ROLE_SCREEN_PREFIX[role];
    var map = {
      Beranda: prefix + 'beranda', Anggota: prefix + 'anggota', Rekap: prefix + 'recap',
      Agenda: prefix + 'agenda', Profil: prefix + 'profil', Kelas: prefix + 'kelas',
      Tugas: prefix + 'tugas', Kalender: prefix + 'kalender', Latihan: prefix + 'latihan'
    };
    return map[tab] || prefix + 'beranda';
  }

  function bottomNav(role) {
    var tabs = ROLE_TABS[role] || [];
    var nav = document.getElementById('bottom-nav');
    clear(nav);
    if (!tabs.length) {
      nav.hidden = true;
      return;
    }
    nav.hidden = false;
    tabs.forEach(function (tab) {
      nav.appendChild(el('button', {
        class: 'nav-item pressable' + (state.tab === tab ? ' active' : ''),
        type: 'button',
        onclick: function () {
          state.tab = tab;
          go(navScreenFor(role, tab));
        }
      }, [
        el('span', { class: 'ion', text: ICONS[NAV_ICONS[tab]] || '' }),
        el('span', { text: tab })
      ]));
    });
  }

  function go(id) {
    var resolved = resolveScreen(id);
    if (!resolved) return;
    var def = screenDef(resolved);
    state.screen = resolved;
    if (def.nav) {
      state.role = def.nav;
      var tabs = ROLE_TABS[def.nav] || [];
      var label = def.label.split('·')[1];
      label = label ? label.trim() : 'Beranda';
      if (tabs.indexOf(label) >= 0) state.tab = label;
      if (def.nav === 'wali') state.filter = WALI_CLASS;
    }
    if (resolved.indexOf('login-') === 0) {
      var role = resolved.replace('login-', '');
      if (role === 'ortu') role = 'orangtua';
      state.loginRole = role;
      state.role = role;
    }
    if (resolved === 'forgot' && !state.loginRole) state.loginRole = state.role;
    if (window.location.hash !== '#' + resolved) {
      try { history.replaceState(null, '', '#' + resolved); } catch (err) { window.location.hash = resolved; }
    }
    render();
  }

  function toggleTheme() {
    state.dark = !state.dark;
    applyTheme();
    render();
  }

  function applyTheme() {
    document.documentElement.setAttribute('data-theme', state.dark ? 'dark' : 'light');
    document.body.classList.toggle('is-splash', state.screen === 'splash');
    var toggle = document.getElementById('theme-toggle');
    clear(toggle);
    toggle.appendChild(icon(state.dark ? 'sunny-outline' : 'moon-outline', 18));
  }

  /* ------------------------------------------------------------------ *
   * Bottom sheet
   * ------------------------------------------------------------------ */
  function openSheet(content) {
    var backdrop = document.getElementById('sheet-backdrop');
    var panel = document.getElementById('sheet-panel');
    clear(panel);
    panel.appendChild(content);
    backdrop.hidden = false;
    backdrop.onclick = function (e) { if (e.target === backdrop) closeSheet(); };
  }

  function closeSheet() {
    var backdrop = document.getElementById('sheet-backdrop');
    backdrop.hidden = true;
    clear(document.getElementById('sheet-panel'));
  }

  /* ------------------------------------------------------------------ *
   * Renderer
   * ------------------------------------------------------------------ */
  function renderScreen() {
    var def = screenDef(state.screen);
    if (!def) return renderWelcome();
    return def.render();
  }

  function render() {
    var viewport = document.getElementById('app-viewport');
    var isSplash = state.screen === 'splash';
    viewport.classList.toggle('no-pad', isSplash);
    clear(viewport);
    viewport.appendChild(renderScreen());
    document.getElementById('app-shell').classList.toggle('splash-mode', isSplash);
    document.body.classList.toggle('is-splash', isSplash);
    var def = screenDef(state.screen);
    var navRole = def && def.nav ? def.nav : null;
    if (navRole) {
      bottomNav(navRole);
    } else {
      var nav = document.getElementById('bottom-nav');
      clear(nav);
      nav.hidden = true;
    }
    var select = document.getElementById('screen-select');
    if (select.value !== state.screen) select.value = state.screen;
  }

  /* ------------------------------------------------------------------ *
   * Boot
   * ------------------------------------------------------------------ */
  function buildScreenSelect() {
    var select = document.getElementById('screen-select');
    clear(select);
    var groups = [];
    SCREENS.forEach(function (s) {
      if (groups.indexOf(s.group) < 0) groups.push(s.group);
    });
    groups.forEach(function (group) {
      var optgroup = el('optgroup', { label: group });
      SCREENS.forEach(function (s) {
        if (s.group !== group) return;
        optgroup.appendChild(el('option', { value: s.id, text: s.label }));
      });
      select.appendChild(optgroup);
    });
    select.addEventListener('change', function (e) {
      var value = e.target.value;
      var resolved = resolveScreen(value);
      if (resolved) {
        go(resolved);
      }
    });
  }

  function boot() {
    buildScreenSelect();
    document.getElementById('theme-toggle').addEventListener('click', function () { toggleTheme(); });
    applyTheme();

    var hash = (window.location.hash || '').replace('#', '');
    var resolved = hash ? resolveScreen(hash) : null;
    if (resolved) {
      state.screen = resolved;
      if (resolved.indexOf('login-') === 0) {
        var role = resolved.replace('login-', '');
        if (role === 'ortu') role = 'orangtua';
        state.loginRole = role;
        state.role = role;
      }
      if (resolved.indexOf('wali-') === 0) { state.role = 'wali'; state.filter = WALI_CLASS; }
      if (resolved.indexOf('guru-') === 0) { state.role = 'guru'; }
      if (resolved.indexOf('siswa-') === 0) { state.role = 'siswa'; }
      if (resolved.indexOf('ortu-') === 0) { state.role = 'orangtua'; }
      render();
    } else {
      state.screen = 'splash';
      render();
      window.setTimeout(function () {
        if (state.screen === 'splash') go('welcome');
      }, 2300);
    }

    window.addEventListener('hashchange', function () {
      var value = (window.location.hash || '').replace('#', '');
      var target = value ? resolveScreen(value) : null;
      if (target && target !== state.screen) {
        var def = screenDef(target);
        state.screen = target;
        if (def && def.nav) {
          state.role = def.nav;
          if (def.nav === 'wali') state.filter = WALI_CLASS;
        }
        render();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }

  /* Expose a tiny surface for automated verification (mock DOM tests). */
  window.KARSA_PREVIEW = {
    state: state,
    screens: SCREENS.map(function (s) { return s.id; }),
    go: go,
    toggleTheme: toggleTheme,
    render: render
  };
})();
