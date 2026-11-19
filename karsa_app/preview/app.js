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
    operator: { id: '19870003', password: 'operator123', label: 'Operator sekolah', emoji: '🗂️' },
    wali: { id: '19870001', password: 'wali123', label: 'Wali kelas', emoji: '👩🏻‍🏫' },
    guru: { id: '19870002', password: 'guru123', label: 'Guru mata pelajaran', emoji: '📚' },
    siswa: { id: '10050001', password: 'siswa123', label: 'Siswa kelas 5–6', emoji: '🎒' },
    orangtua: { id: '10010001', password: 'ortu123', label: 'Orang tua / wali', emoji: '👩🏻' }
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
  /* Daftar siswa resmi (sama seperti SeedData.initialRoster di Flutter). */
  function buildRoster() {
    var seeds = [
      ['s1a', '10050002', 'Aisyah Putri', 'Kelas 1', 'P', 'Ibu Rina'],
      ['s1b', '10050003', 'Bagas Wicaksono', 'Kelas 1', 'L', 'Bapak Doni'],
      ['s1c', '10050004', 'Citra Kirana', 'Kelas 1', 'P', 'Ibu Melati'],
      ['s1d', '10050005', 'Dimas Nugroho', 'Kelas 1', 'L', 'Bapak Hendra'],
      ['s2a', '10050006', 'Eka Prasetyo', 'Kelas 2', 'L', 'Bapak Joko'],
      ['s2b', '10050007', 'Fitri Handayani', 'Kelas 2', 'P', 'Ibu Sari'],
      ['s2c', '10050008', 'Gilang Ramadhan', 'Kelas 2', 'L', 'Bapak Arif'],
      ['s2d', '10050009', 'Hana Salsabila', 'Kelas 2', 'P', 'Ibu Yuni'],
      ['s3a', '10050010', 'Indira Maharani', 'Kelas 3', 'P', 'Ibu Ratna'],
      ['s3b', '10050011', 'Jovan Kurniawan', 'Kelas 3', 'L', 'Bapak Teguh'],
      ['s3c', '10050012', 'Kirana Ayu', 'Kelas 3', 'P', 'Ibu Wulan'],
      ['s3d', '10050013', 'Lukman Hakim', 'Kelas 3', 'L', 'Bapak Slamet'],
      ['s4a', '10050014', 'Maya Anggraini', 'Kelas 4', 'P', 'Ibu Dyah'],
      ['s4b', '10050015', 'Naufal Akbar', 'Kelas 4', 'L', 'Bapak Rudi'],
      ['s4c', '10050016', 'Nabila Zahra', 'Kelas 4', 'P', 'Ibu Eka'],
      ['s4d', '10050017', 'Omar Dzaki', 'Kelas 4', 'L', 'Bapak Irwan'],
      ['s5a', '10050018', 'Puspita Rani', 'Kelas 5', 'P', 'Ibu Lilis'],
      ['s5b', '10050019', 'Rendi Saputra', 'Kelas 5', 'L', 'Bapak Cahyo'],
      ['s5c', '10050020', 'Sekar Arum', 'Kelas 5', 'P', 'Ibu Nining'],
      ['s5d', '10050021', 'Taufik Hidayat', 'Kelas 5', 'L', 'Bapak Wahyu'],
      ['s6a', '10050022', 'Ulfa Rahmawati', 'Kelas 6', 'P', 'Ibu Tati'],
      ['s6b', '10050023', 'Vino Ardiansyah', 'Kelas 6', 'L', 'Bapak Gunawan'],
      ['s6c', '10050024', 'Wulan Puspita', 'Kelas 6', 'P', 'Ibu Rina'],
      ['s6d', '10050025', 'Yoga Pratama', 'Kelas 6', 'L', 'Bapak Farid']
    ];
    return seeds.map(function (row) {
      return {
        id: row[0], nisn: row[1], name: row[2], className: row[3],
        gender: row[4], parentName: row[5], active: true
      };
    });
  }

  /* Kelas sekolah yang dikelola operator sekolah. */
  function buildSchoolClasses() {
    var seeds = [
      ['c1', 'Kelas 1', 'Ibu Sari'],
      ['c2', 'Kelas 2', 'Ibu Tuti'],
      ['c3', 'Kelas 3', 'Bapak Agus'],
      ['c4', 'Kelas 4', 'Ibu Rina'],
      ['c5', 'Kelas 5', 'Bapak Doni'],
      ['c6', 'Kelas 6', 'Ibu Maya']
    ];
    return seeds.map(function (row) {
      return { id: row[0], name: row[1], teacherName: row[2] };
    });
  }

  /* Akun guru dan wali kelas yang dikelola operator sekolah. */
  function buildStaffAccounts() {
    var seeds = [
      ['u1', 'Ibu Sari', '19870001', 'wali', 'Kelas 1'],
      ['u2', 'Ibu Tuti', '19870011', 'wali', 'Kelas 2'],
      ['u3', 'Bapak Agus', '19870012', 'wali', 'Kelas 3'],
      ['u4', 'Ibu Rina', '19870013', 'wali', 'Kelas 4'],
      ['u5', 'Bapak Doni', '19870014', 'wali', 'Kelas 5'],
      ['u6', 'Ibu Maya', '19870015', 'wali', 'Kelas 6'],
      ['u7', 'Pak Rudi', '19870021', 'guru', '']
    ];
    return seeds.map(function (row) {
      return { id: row[0], name: row[1], nip: row[2], role: row[3], className: row[4] };
    });
  }

  var ASSETS = {
    icon: './assets/images/icon.png',
    loginLogo: './assets/images/karsa-login-logo.png',
    schoolLogo: './assets/images/logo-sd-karitas.png',
    splashArt: './assets/images/splash-art.png',
    studentBanner: './assets/images/student-banner.png',
    teacherBanner: './assets/images/teacher-banner.png'
  };

  /* Slot grafis yang dikelola operator sekolah. */
  var MEDIA_SLOTS = [
    { key: 'school-logo', label: 'Logo sekolah', desc: 'Tampil di kartu identitas sekolah pada semua layar.', fallback: ASSETS.schoolLogo },
    { key: 'banner-siswa', label: 'Banner siswa', desc: 'Gambar besar di beranda siswa dan orang tua.', fallback: ASSETS.studentBanner },
    { key: 'banner-guru', label: 'Banner guru', desc: 'Gambar besar di beranda guru dan wali kelas.', fallback: ASSETS.teacherBanner }
  ];

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

  /* "2026-11-07" -> "7 November 2026". Dipakai rincian agenda di beranda operator. */
  function fullDateFromKey(key) {
    var parts = String(key || '').split('-');
    if (parts.length !== 3) return String(key || '');
    var y = parseInt(parts[0], 10);
    var m = parseInt(parts[1], 10);
    var d = parseInt(parts[2], 10);
    if (!y || !m || !d || m < 1 || m > 12) return String(key || '');
    return d + ' ' + MONTH_NAMES[m - 1] + ' ' + y;
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
    // Kelas dengan nama bebas (tanpa angka) tidak punya tingkat yang jelas,
    // jadi semua mata pelajaran boleh dipakai - cermin
    // CurriculumData.subjectsForClass di aplikasi Flutter.
    if (isNaN(grade)) return SUBJECTS.slice();
    return SUBJECTS.filter(function (s) {
      return s !== 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' || grade >= 3;
    });
  }

  function essayBankFor(subject) {
    if (typeof CURR.exercisesFor === 'function') {
      return CURR.exercisesFor(normalizeSubject(subject), state.religion || '');
    }
    return [];
  }

  /// Layar daftar tugas yang sesuai dengan role yang sedang aktif.
  ///
  /// Harus selalu mengembalikan layar yang benar-benar terdaftar: bila role
  /// kosong (mis. halaman dimuat ulang tepat di layar kuis), versi lama
  /// menghasilkan "undefinedberanda" sehingga `go()` menolak diam-diam dan
  /// tombol kembali tampak mati.
  function tasksScreenForRole() {
    // Bila role hilang (reload di layar kuis), tebak dari tugas yang terbuka:
    // ini tugas yang tampil di kelas siswa/orang tua, atau tugas guru sendiri.
    var role = state.role;
    if (!role) {
      var task = state.quiz && state.quiz.task;
      if (task) {
        if (task.className === state.studentClass) role = 'siswa';
        else if (task.className === state.parentClass) role = 'orangtua';
        else role = 'guru';
      }
    }
    if (role === 'guru') return 'guru-tugas';
    if (role === 'siswa') return 'siswa-tugas';
    if (role === 'orangtua') return 'ortu-tugas';
    if (role === 'wali') return 'wali-beranda';
    if (role === 'operator') return 'operator-beranda';
    // Role tidak diketahui: kembali ke pemilihan peran, bukan menebak.
    return 'welcome';
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

  // Skor pilihan ganda latihan, dipisah dari nilai tugas supaya tidak
  // tercampur (cermin KarsaStoreData.practiceResults).
  var PRACTICE_RESULTS = {};

  // Latihan yang sudah dikerjakan (esai maupun pilihan ganda).
  var PRACTICE_DONE = {};


  // SUBMISSIONS[taskId][studentId] di atas dipakai guru untuk melihat siapa
  // saja yang sudah mengerjakan dan nilainya.

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
      // Notifikasi guru harus menyebut SIAPA yang mengumpulkan dan nilainya.
      // Sebelumnya hanya "Tugas dikumpulkan siswa" tanpa nama, dan tombolnya
      // membuka tugas untuk dikerjakan guru sendiri.
      id: 'n3', target: 'teachers', subject: 'Matematika', className: 'Kelas 1',
      title: 'Aisyah Putri mengumpulkan Matematika', kind: 'submission',
      contentId: 't1', studentName: 'Aisyah Putri', studentId: 's1a',
      score: 9, total: 10,
      createdAt: new Date(NOW.getTime() - 10800000).toISOString()
    },
    {
      id: 'n3b', target: 'teachers', subject: 'Matematika', className: 'Kelas 1',
      title: 'Bagas Wicaksono mengumpulkan Matematika', kind: 'submission',
      contentId: 't1', studentName: 'Bagas Wicaksono', studentId: 's1b',
      score: 7, total: 10,
      createdAt: new Date(NOW.getTime() - 9000000).toISOString()
    },
    {
      id: 'n3c', target: 'teachers', subject: 'Matematika', className: 'Kelas 1',
      title: 'Dimas Nugroho mengumpulkan Matematika', kind: 'submission',
      contentId: 't1', studentName: 'Dimas Nugroho', studentId: 's1d',
      score: 10, total: 10,
      createdAt: new Date(NOW.getTime() - 8400000).toISOString()
    },
    // Notifikasi untuk kelas siswa (Kelas 5). Nuris ini memakai kelas belajar
    // masing-masing, jadi siswa harus melihat notifikasi kelasnya sendiri.
    {
      id: 'n4', target: 'learners', subject: 'Matematika', className: 'Kelas 5',
      title: 'Tugas baru · Pecahan dan perbandingan', kind: 'task', contentId: 'seed5',
      createdAt: new Date(NOW.getTime() - 5400000).toISOString()
    },
    {
      id: 'n5', target: 'learners', subject: 'Bahasa Indonesia', className: 'Kelas 5',
      title: 'Materi baru · Ringkasan Pecahan Kelas 5', kind: 'material', contentId: 'm3',
      createdAt: new Date(NOW.getTime() - 9000000).toISOString()
    }
  ];

  // Pengumpulan yang sudah ada di data demo (cermin TaskResult siswa pada
  // seed): tiga siswa Kelas 1 sudah mengumpulkan Matematika t1.
  var SUBMISSIONS = {
    t1: {
      s1a: { score: 9, total: 10, at: new Date(NOW.getTime() - 10800000).toISOString(), name: 'Aisyah Putri', className: 'Kelas 1' },
      s1b: { score: 7, total: 10, at: new Date(NOW.getTime() - 9000000).toISOString(), name: 'Bagas Wicaksono', className: 'Kelas 1' },
      s1d: { score: 10, total: 10, at: new Date(NOW.getTime() - 8400000).toISOString(), name: 'Dimas Nugroho', className: 'Kelas 1' }
    }
  };

  var MATERIALS = [
    {
      id: 'm1', subject: 'Matematika', className: 'Kelas 1', title: 'Ringkasan Pecahan',
      teacher: 'Ibu Sari', body: 'Pengenalan pecahan sederhana untuk siswa kelas 1.'
    },
    {
      id: 'm2', subject: 'Bahasa Indonesia', className: 'Kelas 1', title: 'Contoh Kalimat Sederhana',
      teacher: 'Ibu Sari', body: 'Kumpulan contoh kalimat sederhana beserta latihan membaca.'
    },
    {
      id: 'm3', subject: 'Matematika', className: 'Kelas 5', title: 'Ringkasan Pecahan Kelas 5',
      teacher: 'Ibu Sari', body: 'Penjelasan pecahan, perbandingan, dan cara menyederhanakan bilangan pecahan.'
    },
    {
      id: 'm4', subject: 'Bahasa Indonesia', className: 'Kelas 5', title: 'Contoh Menyinggung Kalimat',
      teacher: 'Ibu Sari', body: 'Contoh kalimat berhias beserta latihan menentukan jenis majas.'
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
    tipIndex: 0,
    login: { username: '', password: '', show: false, error: '' },
    quiz: null,
    quizResult: null,
    mood: null,
    studentClass: 'Kelas 5',
    parentClass: 'Kelas 1',
    // NISN/roster id siswa yang sedang login, dipakai mencatat pengumpulan.
    studentId: null,
    teacherSubject: 'Matematika',
    religion: '',
    studentName: 'Dimas Nugroho',
    teacherName: 'Ibu Sari',
    waliName: 'Ibu Sari',
    operatorOpen: {},
    rememberMe: true,
    rememberedLogin: null,
    operatorName: 'Operator Sekolah',
    // Cermin OperatorProfile di Flutter: identitas kerja operator.
    operatorProfile: {
      name: 'Operator Sekolah',
      nip: '19870003',
      role: 'Operator Sekolah',
      email: '',
      phone: '',
      unit: 'SD Karitas Purwokerto'
    },
    personalDraft: null,
    readNotifications: {},
    mediaAssets: {},
    operatorQuery: '',
    operatorClassSection: 'Kelas',
    operatorError: '',
    roster: buildRoster(),
    schoolClasses: buildSchoolClasses(),
    staffAccounts: buildStaffAccounts(),
    rosterScores: {},
    classScores: { dimas: 82, sari: 91, rafi: 74 }
  };

  var ROLE_TABS = {
    operator: ['Beranda', 'Siswa', 'Kelas', 'Materi', 'Media', 'Profil'],
    wali: ['Beranda', 'Anggota', 'Rekap', 'Agenda', 'Profil'],
    guru: ['Beranda', 'Kelas', 'Tugas', 'Kalender', 'Profil'],
    siswa: ['Beranda', 'Tugas', 'Profil'],
    orangtua: ['Beranda', 'Tugas', 'Latihan', 'Profil']
  };

  var ROLE_SCREEN_PREFIX = {
    operator: 'operator-',
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
    operator: 'login-operator',
    wali: 'login-wali',
    guru: 'login-guru',
    siswa: 'login-siswa',
    orangtua: 'login-ortu'
  };

  /* ------------------------------------------------------------------ *
   * Reusable components (mirrors lib/core/widgets/*.dart)
   * ------------------------------------------------------------------ */
  /* Logo sekolah: pakai gambar yang dipilih operator, fallback ke aset bawaan. */
  function mediaImage(slotKey, fallback) {
    var custom = state.mediaAssets[slotKey];
    return el('img', { src: custom || fallback, alt: 'Logo SD Karitas Purwokerto' });
  }

  function schoolIdentity(compact) {
    return el('div', { class: 'clay-soft school-identity' + (compact ? ' compact' : '') }, [
      el('div', { class: 'school-logo-frame' }, [
        mediaImage('school-logo', ASSETS.schoolLogo)
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

  function pageHeader(title, sub, onBack, trailing) {
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
    if (trailing) children.push(trailing);
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
    if (state.role === 'operator') return state.operatorName;
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

  /* Menyimpan satu pengumpulan siswa + membuat notifikasi untuk guru. */
  function recordSubmission(task, payload) {
    if (!task) return;
    var sid = state.studentId || 'self';
    if (!SUBMISSIONS[task.id]) SUBMISSIONS[task.id] = {};
    SUBMISSIONS[task.id][sid] = {
      score: payload.score,
      total: payload.total,
      at: new Date().toISOString(),
      name: payload.name || state.studentName,
      className: payload.className || task.className
    };
    var notif = {
      id: 'n' + Date.now() + '-' + Math.floor(Math.random() * 9000 + 1000),
      target: 'teachers',
      subject: task.subject,
      className: task.className,
      title: (payload.name || state.studentName) + ' mengumpulkan ' + task.subject,
      kind: 'submission',
      contentId: task.id,
      studentName: payload.name || state.studentName,
      studentId: sid,
      score: payload.score,
      total: payload.total,
      createdAt: new Date().toISOString()
    };
    NOTIFICATIONS = [notif].concat(NOTIFICATIONS);
    persistState();
  }

  /* "9/10" atau "Belum dinilai" untuk satu notifikasi pengumpulan. */
  function scoreLabel(n) {
    if (n.score === null || n.score === undefined) return 'Belum dinilai';
    return 'Nilai ' + n.score + '/' + (n.total || 10);
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
      // Pelajar (siswa dan orang tua) hanya melihat notifikasi kelasnya
      // sendiri: siswa memakai kelasnya, orang tua memakai kelas anaknya.
      return n.target === 'learners' && n.className === learnerClassName();
    });
  }

  function isNotificationRead(id) {
    var bucket = state.readNotifications[state.role] || [];
    return bucket.indexOf(id) >= 0;
  }

  function markNotificationRead(id) {
    var bucket = (state.readNotifications[state.role] || []).slice();
    if (bucket.indexOf(id) < 0) bucket.push(id);
    state.readNotifications[state.role] = bucket;
    persistState();
  }

  /* ------------------------------------------------------------------ *
   * Penyimpanan lokal (cermin StorageService Flutter, kunci "@karsa-demo-v1")
   * ------------------------------------------------------------------ */
  var STORE_KEY = '@karsa-demo-v1';

  function storage() {
    try {
      return window.localStorage || null;
    } catch (e) {
      return null;
    }
  }

  function persistState() {
    var store = storage();
    if (!store) return;
    try {
      store.setItem(STORE_KEY, JSON.stringify({
        studentName: state.studentName,
        teacherName: state.teacherName,
        waliName: state.waliName,
        operatorName: state.operatorName,
        rememberedLogin: state.rememberedLogin,
        operatorProfile: state.operatorProfile,
        studentClass: state.studentClass,
        parentClass: state.parentClass,
        religion: state.religion,
        readNotifications: state.readNotifications,
        mediaAssets: state.mediaAssets,
        roster: state.roster,
        materials: MATERIALS,
        tasks: TASKS,
        announcements: ANNOUNCEMENTS,
        classEvents: CLASS_EVENTS,
        classScores: state.classScores,
        rosterScores: state.rosterScores,
        schoolClasses: state.schoolClasses,
        staffAccounts: state.staffAccounts
      }));
    } catch (e) {
      /* Penyimpanan penuh atau diblokir - pratinjau tetap berjalan. */
    }
  }

  function restoreState() {
    var store = storage();
    if (!store) return;
    try {
      var raw = store.getItem(STORE_KEY);
      if (!raw) return;
      var saved = JSON.parse(raw);
      if (!saved || typeof saved !== 'object') return;
      ['studentName', 'teacherName', 'waliName', 'operatorName', 'studentClass', 'parentClass', 'religion']
        .forEach(function (key) {
          if (typeof saved[key] === 'string' && saved[key]) state[key] = saved[key];
        });
      if (saved.rememberedLogin && typeof saved.rememberedLogin === 'object' &&
          typeof saved.rememberedLogin.identifier === 'string' &&
          typeof saved.rememberedLogin.role === 'string') {
        state.rememberedLogin = {
          identifier: saved.rememberedLogin.identifier,
          role: saved.rememberedLogin.role
        };
      }
      if (saved.operatorProfile && typeof saved.operatorProfile === 'object') {
        var savedProfile = saved.operatorProfile;
        ['name', 'nip', 'role', 'email', 'phone', 'unit'].forEach(function (key) {
          if (typeof savedProfile[key] === 'string') {
            state.operatorProfile[key] = savedProfile[key];
          }
        });
        if (typeof savedProfile.name === 'string' && savedProfile.name) {
          state.operatorName = savedProfile.name;
        }
      }
      if (saved.readNotifications && typeof saved.readNotifications === 'object') {
        state.readNotifications = saved.readNotifications;
      }
      if (saved.mediaAssets && typeof saved.mediaAssets === 'object') {
        state.mediaAssets = saved.mediaAssets;
      }
      if (Array.isArray(saved.roster)) {
        // Daftar roster yang tersimpan dipakai apa adanya, termasuk kosong,
        // supaya siswa yang dihapus operator tidak muncul lagi.
        state.roster = saved.roster;
      }
      if (Array.isArray(saved.materials) && saved.materials.length) {
        MATERIALS = saved.materials;
      }
      if (Array.isArray(saved.tasks) && saved.tasks.length) {
        TASKS = saved.tasks;
      }
      if (Array.isArray(saved.announcements) && saved.announcements.length) {
        ANNOUNCEMENTS = saved.announcements;
      }
      if (Array.isArray(saved.classEvents) && saved.classEvents.length) {
        CLASS_EVENTS = saved.classEvents;
      }
      if (saved.classScores && typeof saved.classScores === 'object') {
        state.classScores = saved.classScores;
      }
      if (saved.rosterScores && typeof saved.rosterScores === 'object') {
        state.rosterScores = saved.rosterScores;
      }
      if (Array.isArray(saved.schoolClasses)) {
        // Kelas yang dihapus operator tidak boleh dibangkitkan lagi, jadi
        // daftar yang tersimpan dipakai apa adanya (bisa kosong).
        state.schoolClasses = saved.schoolClasses;
      }
      if (Array.isArray(saved.staffAccounts)) {
        state.staffAccounts = saved.staffAccounts;
      }
    } catch (e) {
      /* Data rusak - pakai bawaan. */
    }
  }

  function unreadNotificationCount() {
    return relevantNotifications().filter(function (n) {
      return !isNotificationRead(n.id);
    }).length;
  }

  function totalBadgeCount() {
    return unreadAnnouncementsCount() + unreadNotificationCount();
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
    { r: 'operator', emoji: '🗂️', title: 'Saya Operator Sekolah', sub: 'Kelola siswa, kelas, materi, dan grafis sekolah.' },
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

  // Cermin DemoAccount.idFieldLabel: staf memakai NIP, siswa/orang tua NISN.
  function idFieldLabel(role) {
    return (role === 'wali' || role === 'guru' || role === 'operator') ? 'NIP' : 'NISN';
  }

  function loginTitle(role) {
    if (role === 'wali') return 'Selamat datang,\nWali Kelas!';
    if (role === 'guru') return 'Selamat datang,\nGuru!';
    if (role === 'operator') return 'Selamat datang,\nOperator Sekolah!';
    if (role === 'siswa') return 'Halo, Siswa!';
    return 'Halo, Orang Tua!';
  }

  function loginSubtitle(role) {
    if (role === 'siswa') return 'Untuk siswa kelas 5–6';
    if (role === 'orangtua') return 'Untuk pendamping anak kelas 1–4';
    if (role === 'operator') return 'Masuk untuk mengelola seluruh sekolah';
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
      placeholder: idFieldLabel(role),
      'aria-label': idFieldLabel(role),
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
          icon(role === 'siswa' || role === 'orangtua' ? 'person-outline' : 'card-outline', 22),
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
          el('p', { class: 't-muted', text: idFieldLabel(role) + ': ' + account.id }),
          el('p', { class: 't-muted', text: 'Kata sandi: ' + account.password }),
          el('p', { class: 't-small', text: 'Akun contoh untuk mencoba aplikasi, bukan autentikasi aman.' })
        ])
      ]),
      el('div', { class: 'login-wave-pink' }),
      el('div', { class: 'login-wave-blue' })
    ]);
  }

  // Cermin AppState.logout(): kembali ke form login, bukan ke pemilih peran.
  // Identitas tersimpan dibiarkan supaya pengguna tidak mengetik ulang.
  function logoutDemo() {
    state.role = null;
    state.login = {
      username: state.rememberedLogin ? state.rememberedLogin.identifier : '',
      password: '',
      show: false,
      error: ''
    };
    state.tab = 'Beranda';
    go('login');
  }

  /* Form login tunggal untuk kelima peran.
     Peran dideteksi dari NIP/NISN, jadi tidak ada lagi layar pilih peran.
     Cermin LoginPage (Flutter) setelah penyatuan form. */
  function renderUnifiedLogin() {
    var remembered = state.rememberedLogin;
    // "Ingat saya": isi kolom identitas otomatis, kata sandi tetap kosong.
    if (remembered && !state.login.username) {
      state.login.username = remembered.identifier;
    }

    function detectRole(identifier) {
      var id = (identifier || '').trim();
      if (!id) return null;
      var keys = Object.keys(ACCOUNTS);
      for (var i = 0; i < keys.length; i += 1) {
        if (ACCOUNTS[keys[i]].id === id) return keys[i];
      }
      return null;
    }

    var detected = detectRole(state.login.username);
    var hintRole = detected || (remembered && remembered.role) || 'operator';
    var isStaff = hintRole === 'wali' || hintRole === 'guru' || hintRole === 'operator';

    var usernameInput = el('input', {
      type: 'text',
      id: 'login-username',
      inputmode: 'numeric',
      autocomplete: 'username',
      autocapitalize: 'off',
      spellcheck: 'false',
      placeholder: idFieldLabel(hintRole),
      'aria-label': idFieldLabel(hintRole),
      value: state.login.username,
      oninput: function (e) {
        state.login.username = e.target.value;
        state.login.error = '';
        refreshFields();
      }
    });

    var passwordInput = el('input', {
      type: state.login.show ? 'text' : 'password',
      id: 'login-password',
      autocomplete: 'current-password',
      placeholder: 'Kata sandi',
      'aria-label': 'Kata sandi',
      value: state.login.password,
      oninput: function (e) {
        state.login.password = e.target.value;
        state.login.error = '';
      }
    });

    var hintBadge = el('div', { class: 'login-role-hint', hidden: !detected });
    var errorSlot = el('div', {});

    function refreshFields() {
      var nowDetected = detectRole(state.login.username);
      usernameInput.setAttribute('placeholder', idFieldLabel(nowDetected || hintRole));
      usernameInput.setAttribute('aria-label', idFieldLabel(nowDetected || hintRole));
      hintBadge.hidden = !nowDetected;
      clear(hintBadge);
      if (nowDetected) {
        hintBadge.appendChild(el('span', { text: ACCOUNTS[nowDetected].emoji || '' }));
        hintBadge.appendChild(el('span', { text: ACCOUNTS[nowDetected].label }));
      }
    }

    function showError(message) {
      clear(errorSlot);
      errorSlot.appendChild(el('p', {
        class: 'notice-title', style: 'margin:4px 0 0 0', text: message
      }));
    }

    function submit() {
      var id = (state.login.username || '').trim();
      var pass = state.login.password || '';
      if (!id) { showError('Isi NIP atau NISN terlebih dahulu.'); return; }
      if (!pass) { showError('Isi kata sandi terlebih dahulu.'); return; }

      var role = null;
      var keys = Object.keys(ACCOUNTS);
      for (var i = 0; i < keys.length; i += 1) {
        var acc = ACCOUNTS[keys[i]];
        if (acc.id === id && acc.password === pass) { role = keys[i]; break; }
      }
      if (!role) {
        showError('NIP/NISN atau kata sandi tidak sesuai.');
        return;
      }

      state.login.error = '';
      // "Ingat saya": simpan identitas + peran saja, kata sandi tidak pernah.
      if (state.rememberMe) {
        state.rememberedLogin = { identifier: id, role: role };
      } else {
        state.rememberedLogin = null;
      }
      persistState();

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

    // Kotak centang "Ingat saya".
    var checkBox = el('span', {
      class: 'remember-box' + (state.rememberMe ? ' checked' : ''),
      'aria-hidden': 'true'
    }, state.rememberMe ? [icon('checkmark', 13)] : []);
    var rememberRow = el('button', {
      class: 'remember-row pressable', type: 'button', id: 'remember-toggle',
      'aria-pressed': state.rememberMe ? 'true' : 'false',
      'aria-label': 'Ingat saya. Saat dicentang, NIP atau NISN disimpan di perangkat ini ' +
        'supaya tidak perlu diketik ulang.',
      onclick: function () {
        state.rememberMe = !state.rememberMe;
        checkBox.className = 'remember-box' + (state.rememberMe ? ' checked' : '');
        clear(checkBox);
        if (state.rememberMe) checkBox.appendChild(icon('checkmark', 13));
        rememberRow.setAttribute('aria-pressed', state.rememberMe ? 'true' : 'false');
      }
    }, [
      checkBox,
      el('span', { class: 'remember-label', text: 'Ingat saya' })
    ]);

    // Daftar akun demo: ketuk untuk mengisi form.
    var demoRows = Object.keys(ACCOUNTS).map(function (key) {
      var acc = ACCOUNTS[key];
      return el('button', {
        class: 'demo-cred-row pressable', type: 'button',
        onclick: function () {
          state.login.username = acc.id;
          state.login.password = acc.password;
          state.login.error = '';
          var next = renderUnifiedLogin();
          var vp = document.getElementById('app-viewport');
          if (vp) { clear(vp); vp.appendChild(next); }
        }
      }, [
        el('span', { class: 'demo-cred-role', text: acc.label }),
        el('span', { class: 'demo-cred-id', text: acc.id + ' / ' + acc.password })
      ]);
    });

    // Kartu "lanjutkan sebagai" bila ada identitas tersimpan.
    var rememberedCard = remembered ? el('div', { class: 'remembered-card' }, [
      el('div', { style: 'flex:1;min-width:0' }, [
        el('p', { class: 't-small', style: 'margin:0', text: 'Terakhir masuk sebagai' }),
        el('p', { class: 't-item-title', style: 'margin:2px 0 0 0',
          text: (ACCOUNTS[remembered.role] ? ACCOUNTS[remembered.role].label : 'Pengguna') +
                ' · ' + remembered.identifier })
      ]),
      el('button', {
        class: 't-link pressable', type: 'button',
        onclick: function () {
          state.rememberedLogin = null;
          state.login.username = '';
          state.login.password = '';
          persistState();
          render();
        }
      }, ['Bukan saya'])
    ]) : null;

    refreshFields();

    return el('div', { class: 'login-page' }, [
      el('div', { class: 'login-hero' }, [
        el('div', { class: 'login-circle-pink' }),
        el('div', { class: 'login-circle-blue' }),
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
        el('h1', { class: 'login-title', text: 'Selamat datang di KARSA' }),
        el('p', { class: 'login-subtitle', text: 'Masuk dengan NIP atau NISN Anda' }),
        rememberedCard,
        el('div', { class: 'login-field' }, [
          icon(isStaff ? 'card-outline' : 'person-outline', 22),
          usernameInput
        ]),
        hintBadge,
        el('div', { class: 'login-field' }, [
          icon('lock-closed-outline', 22),
          passwordInput,
          el('button', {
            class: 'pressable', type: 'button', style: 'padding:4px;background:none;border:none',
            'aria-label': state.login.show ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi',
            onclick: function () {
              state.login.show = !state.login.show;
              var next = renderUnifiedLogin();
              var vp = document.getElementById('app-viewport');
              if (vp) { clear(vp); vp.appendChild(next); }
              var pw = document.getElementById('login-password');
              if (pw) pw.focus();
            }
          }, [icon(state.login.show ? 'eye-off-outline' : 'eye-outline', 22)])
        ]),
        errorSlot,
        el('div', { class: 'login-helper-row' }, [
          rememberRow,
          el('button', {
            class: 't-link pressable', type: 'button',
            onclick: function () { go('forgot'); }
          }, ['Lupa kata sandi?'])
        ]),
        el('button', {
          class: 'login-submit-btn pressable', type: 'button', onclick: submit
        }, ['Masuk →']),
        el('div', { class: 'demo-account-box' }, [
          el('p', { class: 't-item-title', text: 'Akun demo' })
        ].concat(demoRows).concat([
          el('p', { class: 't-small', text: 'Ketuk salah satu akun untuk mengisi form. Peran dideteksi otomatis dari NIP/NISN. Akun contoh, bukan autentikasi aman.' })
        ]))
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
        el('p', { class: 't-muted', text: (role === 'siswa' || role === 'orangtua' ? 'NISN anak' : 'NIP') + ': ' + account.id }),
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
    var waliTasks = TASKS.filter(function (t) { return t.className === WALI_CLASS; });

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
      el('p', { class: 't-section', style: 'margin:8px 0 10px 0', text: 'Tugas kelas' }),
      el('div', {
        class: 'clay-soft pressable',
        style: 'padding:16px;display:flex;align-items:center;gap:12px',
        role: 'button', tabindex: '0',
        'aria-label': 'Buat tugas dari bahan ajar',
        onclick: function () { openTaskForm(); }
      }, [
        el('div', {
          style: 'width:44px;height:44px;border-radius:22px;background:var(--blue);color:#fff;' +
                 'display:flex;align-items:center;justify-content:center'
        }, [icon('albums', 20)]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Buat tugas dari bahan' }),
          el('p', { class: 't-small', style: 'margin:0',
            text: 'Unggah PDF/gambar/teks, lalu susun soal dengan asisten' })
        ]),
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 18)])
      ]),
      el('div', {
        class: 'clay-soft pressable',
        style: 'margin-top:10px;padding:16px;display:flex;align-items:center;gap:12px',
        role: 'button', tabindex: '0',
        'aria-label': 'Kelola materi kelas',
        onclick: function () { go('materi'); }
      }, [
        el('div', {
          style: 'width:44px;height:44px;border-radius:22px;background:var(--rose);color:#fff;' +
                 'display:flex;align-items:center;justify-content:center'
        }, [icon('book-outline', 20)]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Materi kelas' }),
          el('p', { class: 't-small', style: 'margin:0',
            text: 'Unggah bahan bacaan dan ringkasan untuk kelas ' + WALI_CLASS })
        ]),
        el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 18)])
      ]),
      // Daftar tugas kelas: wali tidak punya tab 'Tugas' di pratinjau.
      el('div', {
        style: 'display:flex;justify-content:space-between;align-items:center;' +
               'margin:16px 0 8px 0'
      }, [
        el('p', { class: 't-section', style: 'margin:0', text: 'Tugas kelas' }),
        el('p', {
          class: 't-small', style: 'margin:0',
          text: waliTasks.length + ' tugas'
        })
      ]),
      waliTasks.length
        ? el('div', {}, waliTasks.map(function (t) {
            return listItemCard({
              iconEmoji: metaFor(t.subject).icon,
              tileColor: metaFor(t.subject).color,
              title: t.title,
              meta: t.subject + ' · ' + t.minutes + ' menit' +
                (t.questionsSource === 'assistant'
                  ? ' · ' + t.questions.length + ' soal asisten'
                  : '') +
                ' · ' + deadlineCountdown(t.dueAt, NOW),
              status: RESULTS[t.id] ? 'Selesai'
                : (t.questionsSource === 'assistant' ? 'Soal asisten' : 'Aktif'),
              onTap: function () { openTaskDetail(t); }
            });
          }))
        : el('p', {
            class: 't-small', style: 'margin:0 0 4px 0',
            text: 'Belum ada tugas untuk ' + WALI_CLASS +
              '. Buat satu dari bahan ajar di atas.'
          }),
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
          onclick: logoutDemo
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
      var op = state.operatorProfile || {};
      state.personalDraft = {
        name: currentPersonalName(),
        className: isStudent ? state.studentClass : state.parentClass,
        religion: state.religion,
        nip: op.nip || '',
        role: op.role || '',
        email: op.email || '',
        phone: op.phone || '',
        unit: op.unit || '',
        error: ''
      };
    }
    var draft = state.personalDraft;

    function refresh() {
      // Pakai openSheet() (bukan menulis langsung ke #sheet-panel) supaya
      // backdrop ikut ditampilkan. Tanpa ini formnya tersusun di dalam
      // container yang tetap `hidden` sehingga tidak pernah terlihat.
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: 'Informasi pribadi'
        }),
        el('p', {
          class: 't-muted', style: 'margin-bottom:14px',
          text: state.role === 'operator'
            ? 'Identitas kerja operator tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
            : 'Data pribadi tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
        }),
        state.role === 'operator' ? operatorProfileHero() : null,
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

    // Indikator kelengkapan profil operator (6 kolom).
    function operatorProfileHero() {
      var op = state.operatorProfile || {};
      var parts = (op.name || '').trim().split(/\s+/).filter(function (w) { return w; });
      var initials = parts.length
        ? (parts.length === 1
            ? parts[0].charAt(0)
            : parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
        : '?';
      var filled = ['name', 'nip', 'role', 'email', 'phone', 'unit']
        .filter(function (k) { return (op[k] || '').trim(); }).length;
      var contact = [op.email, op.phone].filter(function (v) { return v; }).join(' · ');

      return el('div', { class: 'clay-soft', style: 'padding:16px;margin-bottom:16px' }, [
        el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
          el('div', {
            style: 'width:56px;height:56px;border-radius:28px;background:var(--surface-input);display:flex;' +
                   'align-items:center;justify-content:center;font-weight:800;font-size:19px;color:var(--rose)'
          }, [initials]),
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', { class: 't-item-title', style: 'margin:0', text: op.name || 'Operator Sekolah' }),
            el('p', { class: 't-small', style: 'margin:2px 0 0 0',
              text: [op.role, op.nip ? 'NIP ' + op.nip : ''].filter(function (v) { return v; }).join(' · ') }),
            op.unit ? el('p', { class: 't-small', style: 'margin:2px 0 0 0', text: op.unit }) : null
          ])
        ]),
        contact ? el('p', { class: 't-small', style: 'margin:10px 0 0 0', text: contact }) : null,
        el('div', {
          style: 'height:7px;border-radius:8px;background:var(--line);margin-top:12px;overflow:hidden'
        }, [
          el('div', {
            style: 'height:100%;width:' + Math.round(filled / 6 * 100) + '%;background:var(--rose)'
          })
        ]),
        el('p', { class: 't-small', style: 'margin:6px 0 0 0',
          text: filled >= 6
            ? 'Profil lengkap - semua kolom terisi.'
            : 'Profil ' + filled + '/6 kolom terisi. Lengkapi surel dan telepon agar sekolah mudah menghubungi Anda.' })
      ]);
    }

    function operatorInput(field, placeholder, ariaLabel) {
      return el('input', {
        class: 'karsa-input', type: field === 'email' ? 'email' : (field === 'phone' ? 'tel' : 'text'),
        value: draft[field] || '', id: 'pi-' + field,
        placeholder: placeholder, 'aria-label': ariaLabel,
        oninput: function (e) {
          draft[field] = e.target.value;
          draft.error = '';
        }
      });
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
        state.role === 'operator' ? el('p', {
          class: 't-label', style: 'margin:6px 0 8px 0', text: 'NIP'
        }) : null,
        state.role === 'operator' ? operatorInput('nip', 'Nomor induk pegawai', 'NIP operator') : null,
        state.role === 'operator' ? el('p', {
          class: 't-label', style: 'margin:12px 0 8px 0', text: 'Jabatan'
        }) : null,
        state.role === 'operator' ? operatorInput('role', 'Mis. Operator Sekolah', 'Jabatan operator') : null,
        state.role === 'operator' ? el('p', {
          class: 't-label', style: 'margin:12px 0 8px 0', text: 'Unit kerja'
        }) : null,
        state.role === 'operator' ? operatorInput('unit', 'Mis. SD Karitas Purwokerto', 'Unit kerja operator') : null,
        state.role === 'operator' ? el('p', {
          class: 't-label', style: 'margin:16px 0 8px 0', text: 'Surel'
        }) : null,
        state.role === 'operator' ? operatorInput('email', 'nama@sekolah.sch.id', 'Surel operator') : null,
        state.role === 'operator' ? el('p', {
          class: 't-label', style: 'margin:12px 0 8px 0', text: 'Telepon'
        }) : null,
        state.role === 'operator' ? operatorInput('phone', '08xxxxxxxxxx', 'Telepon operator') : null,
        state.role === 'operator' ? el('p', {
          class: 't-small', style: 'margin:2px 0 14px 0',
          text: 'Nama dan NIP wajib diisi. Surel dan telepon boleh dikosongkan, tetapi kalau '
              + 'diisi formatnya harus benar.'
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
    } else if (state.role === 'operator') {
      // Operator punya profil kerja lengkap; validasi cermin
      // AppState.saveOperatorProfileForm().
      var nip = (draft.nip || '').trim();
      var email = (draft.email || '').trim();
      var phone = (draft.phone || '').trim();
      if (!nip) {
        draft.error = 'NIP tidak boleh kosong.';
        openPersonalInfoForm();
        return;
      }
      if (!/^[0-9]{6,20}$/.test(nip)) {
        draft.error = 'NIP harus berupa 6-20 angka.';
        openPersonalInfoForm();
        return;
      }
      if (email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
        draft.error = 'Format surel belum benar, mis. nama@sekolah.sch.id';
        openPersonalInfoForm();
        return;
      }
      if (phone) {
        if (!/^[0-9+()\-\s]+$/.test(phone) ||
            phone.replace(/\D/g, '').length < 8 ||
            phone.replace(/\D/g, '').length > 16) {
          draft.error = 'Nomor telepon harus 8-16 angka.';
          openPersonalInfoForm();
          return;
        }
      }
      var base = state.operatorProfile || {};
      state.operatorProfile = {
        name: name,
        nip: nip,
        role: (draft.role || '').trim() || base.role || 'Operator Sekolah',
        email: email,
        phone: phone,
        unit: (draft.unit || '').trim() || base.unit || 'SD Karitas Purwokerto'
      };
      state.operatorName = name;
    } else {
      state.studentName = name;
      // Kelas siswa dan kelas anak orang tua berdiri sendiri: mengubah kelas
      // siswa tidak boleh ikut mengubah kelas anak orang tua.
      if (state.role === 'siswa') {
        state.studentClass = draft.className;
      } else {
        state.parentClass = draft.className;
      }
      state.religion = draft.religion;
    }
    state.personalDraft = null;
    persistState();
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
      el('img', { class: 'banner-img', src: state.mediaAssets['banner-guru'] || ASSETS.teacherBanner, alt: 'Banner guru' }),
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
        // Guru punya layar pengumuman sendiri (buat + ubah), bukan hanya
        // membaca daftar notifikasi.
        desc: 'Buat dan kelola', color: PURPLE_STAT, onTap: function () { go('guru-pengumuman'); }
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

  /* ---------------- Simulasi asisten penyusun soal ----------------
     Cermin QuizDraftService (Flutter): bukan AI sungguhan, offline, dan
     tidak membaca PDF. Kalimat bahan dipecah, kata kunci diambil sebagai
     jawaban, kata kunci kalimat lain jadi pengecoh. Hasil deterministik. */
  var ASSISTANT_STOP_WORDS = [
    'yang', 'dengan', 'untuk', 'dari', 'dalam', 'pada', 'adalah', 'akan',
    'dapat', 'juga', 'kita', 'mereka', 'siswa', 'kelas', 'materi', 'belajar',
    'tugas', 'soal', 'ini', 'itu', 'dan', 'atau', 'agar', 'karena', 'saat',
    'setelah', 'sebelum', 'lebih', 'sangat', 'contoh', 'mengenai', 'tentang'
  ];

  function assistantSentences(text) {
    var cleaned = String(text || '').replace(/\s+/g, ' ').trim();
    if (!cleaned) return [];
    return cleaned.split(/(?<=[.!?])\s+/)
      .map(function (x) { return x.trim(); })
      .filter(function (x) { return x.length >= 24; });
  }

  function assistantKeywords(sentence, limit) {
    var words = String(sentence || '').toLowerCase()
      .replace(/[^a-z0-9\s]/g, ' ')
      .split(/\s+/)
      .filter(function (w) {
        return w.length >= 4 && ASSISTANT_STOP_WORDS.indexOf(w) < 0;
      });
    var unique = [];
    words.forEach(function (w) {
      if (unique.indexOf(w) < 0) unique.push(w);
    });
    return unique.slice(0, limit || 6);
  }

  function assistantQuestions(text, count) {
    var limit = count || 10;
    var lines = assistantSentences(text);
    if (lines.length < 2) return [];
    var questions = [];
    for (var i = 0; i < lines.length && questions.length < limit; i++) {
      var keys = assistantKeywords(lines[i]);
      if (!keys.length) continue;
      var answer = keys[0];
      var distractors = [];
      for (var off = 1; off < lines.length + 1 && distractors.length < 3; off++) {
        var other = lines[(i + off) % lines.length];
        assistantKeywords(other).forEach(function (k) {
          if (k !== answer && distractors.indexOf(k) < 0 && distractors.length < 3) {
            distractors.push(k);
          }
        });
      }
      if (distractors.length < 3) continue;
      var answerIndex = questions.length % 4;
      var choices = distractors.slice(0, 3);
      choices.splice(answerIndex, 0, answer);
      var shown = lines[i].length > 110
        ? lines[i].slice(0, 110).trim() + '…'
        : lines[i];
      questions.push({
        question: 'Berdasarkan bahan bacaan, kata kunci pada kalimat "' + shown + '" adalah ...',
        choices: choices,
        answerIndex: answerIndex,
        explanation: 'Kata kunci kalimat itu adalah "' + answer + '".'
      });
    }
    return questions;
  }

  function openTaskForm() {
    // Mapel default harus tersedia di kelas yang dipilih: IPAS baru ada mulai
    // kelas 3, jadi Kelas 1 tidak boleh memakai SUBJECTS[0] (IPAS) — kalau
    // tidak, tugas tersimpan tapi tidak pernah muncul di daftar siswa.
    // Mapel default mencerminkan AppState.openForm: mapel guru untuk guru,
    // Matematika untuk peran lain — lalu dijaga agar tersedia di kelasnya
    // (IPAS baru ada mulai kelas 3), supaya tugas tidak "hilang" dari daftar.
    var startClass = state.role === 'wali' ? WALI_CLASS : CLASSES[0];
    var startSubjects = subjectsForClass(startClass);
    var wanted = state.role === 'guru' ? state.teacherSubject : 'Matematika';
    var startSubject = startSubjects.indexOf(wanted) >= 0
      ? wanted
      : startSubjects[0];
    var draft = {
      title: '',
      subject: startSubject,
      className: startClass,
      attachmentName: '',
      attachmentText: '',
      source: '',
      questions: [],
      used: false,
      error: '',
      notice: ''
    };

    function refresh() {
      var questionList = draft.questions.length
        ? el('div', {}, draft.questions.map(function (q, i) {
            return el('p', {
              class: 't-small',
              style: 'margin:7px 0 0 0;color:var(--ink)',
              text: (i + 1) + '. ' + q.question
            });
          }))
        : null;

      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: '+ Tambah tugas'
        }),
        el('p', {
          class: 't-muted', style: 'margin-bottom:14px',
          text: 'Tugas baru tersimpan lokal di perangkat ini.'
        }),
        el('input', {
          class: 'karsa-input', id: 'task-title', type: 'text',
          value: draft.title, placeholder: 'Judul tugas',
          'aria-label': 'Judul tugas',
          oninput: function (e) { draft.title = e.target.value; draft.error = ''; }
        }),
        el('select', {
          class: 'karsa-input', id: 'task-subject', 'aria-label': 'Mata pelajaran',
          onchange: function (e) { draft.subject = e.target.value; }
        }, subjectsForClass(draft.className).map(function (sub) {
          return el('option', {
            value: sub, text: sub,
            selected: sub === draft.subject ? 'selected' : null
          });
        })),
        el('select', {
          class: 'karsa-input', id: 'task-class', 'aria-label': 'Kelas',
          onchange: function (e) {
            draft.className = e.target.value;
            // Mapel yang tidak ada di kelas baru (mis. IPAS di Kelas 1) diganti.
            if (subjectsForClass(draft.className).indexOf(draft.subject) < 0) {
              draft.subject = subjectsForClass(draft.className)[0];
            }
            refresh();
          }
        }, CLASSES.map(function (cl) {
          return el('option', {
            value: cl, text: cl,
            selected: cl === draft.className ? 'selected' : null
          });
        })),

        // Unggah bahan. Berkas tidak benar-benar dibaca; teks .txt bisa
        // ditempel, PDF diarahkan ke tempel manual (batasan jujur).
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer;margin-top:4px',
          onclick: function () {
            draft.attachmentName = draft.attachmentName ? '' : 'bahan-ajar.pdf';
            draft.questions = [];
            draft.used = false;
            refresh();
          }
        }, [draft.attachmentName ? 'Ganti bahan' : 'Unggah bahan (PDF/gambar/teks)']),
        draft.attachmentName ? el('p', {
          class: 't-small', style: 'margin:6px 0 0 0',
          text: '📎 ' + draft.attachmentName +
            ' — bukan .txt, teksnya tidak terbaca otomatis. Tempel teksnya di bawah.'
        }) : null,

        el('div', { class: 'assistant-panel' }, [
          el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
            el('span', { class: 'assistant-badge' }, [icon('albums', 17)]),
            el('div', { style: 'flex:1;min-width:0' }, [
              el('p', { class: 't-item-title', style: 'margin:0', text: 'Asisten penyusun soal' }),
              el('p', { class: 't-small', style: 'margin:0', text: 'Simulasi offline' })
            ])
          ]),
          el('p', {
            class: 't-small', style: 'margin:10px 0 0 0',
            text: 'Unggah bahan lalu tempel isinya di bawah, atau unggah file .txt '
              + 'yang teksnya terbaca otomatis. Asisten menyusun soal pilihan ganda '
              + 'dari bahan itu: satu soal per kalimat lengkap, maksimal 10 soal.'
          }),
          el('textarea', {
            class: 'karsa-input', id: 'assistant-source', rows: '4',
            placeholder: 'Tempel teks bahan ajar di sini (minimal dua kalimat)...',
            'aria-label': 'Teks bahan ajar',
            oninput: function (e) { draft.source = e.target.value; draft.error = ''; }
          }, draft.source ? [draft.source] : []),
          el('button', {
            class: 'karsa-btn clay-raised pressable', type: 'button',
            style: 'border:none;cursor:pointer;margin-top:10px',
            onclick: function () {
              var text = (draft.source || '').trim() || (draft.attachmentText || '').trim();
              if (!text) {
                draft.error = 'Tempel teks bahan ajar dulu (atau unggah file .txt). ' +
                  'PDF belum bisa dibaca otomatis di demo ini.';
                draft.questions = [];
                draft.used = false;
                refresh();
                return;
              }
              var made = assistantQuestions(text, 10);
              if (!made.length) {
                draft.questions = [];
                draft.used = false;
                draft.error = 'Bahan terlalu pendek untuk dijadikan soal (minimal dua ' +
                  'kalimat lengkap). Tambah teks atau pakai kuis contoh.';
                refresh();
                return;
              }
              draft.questions = made;
              draft.used = true;
              draft.error = '';
              draft.notice = made.length + ' soal dibuat dari bahan yang ditempel ' +
                '(simulasi offline, bukan AI sungguhan).';
              if (!draft.title.trim()) draft.title = 'Tugas ' + draft.subject;
              refresh();
            }
          }, [draft.used ? 'Buat ulang soal dari bahan' : 'Buat soal dengan asisten'])
        ]),
        draft.questions.length ? el('div', { class: 'assistant-result' }, [
          el('div', { style: 'display:flex;align-items:center;gap:6px' }, [
            el('span', { style: 'display:inline-flex;color:var(--blue)' }, [icon('checkmark-circle', 16)]),
            el('span', {
              class: 't-small',
              style: 'flex:1;font-weight:700;color:var(--ink)',
              text: draft.questions.length + ' soal siap dipakai tugas ini'
            }),
            el('button', {
              class: 't-link pressable', type: 'button',
              onclick: function () {
                draft.questions = [];
                draft.used = false;
                draft.notice = '';
                refresh();
              }
            }, ['Buang'])
          ]),
          questionList
        ]) : null,
        draft.error ? el('p', {
          class: 'notice-title', style: 'margin:10px 0 0 0', text: draft.error
        }) : null,
        draft.notice ? el('p', {
          class: 't-small', style: 'margin:10px 0 0 0', text: draft.notice
        }) : null,
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer;margin-top:12px',
          onclick: function () {
            var title = (draft.title || '').trim();
            if (!title) {
              draft.error = 'Isi judul tugas terlebih dahulu.';
              refresh();
              return;
            }
            // Tugas sah bila punya lampiran atau soal dari asisten; kalau
            // tidak keduanya, jatuh ke bank soal contoh seperti sebelumnya.
            TASKS.push({
              id: 'local-' + (TASKS.length + 1),
              subject: draft.subject,
              title: title,
              className: draft.className,
              minutes: '30',
              dueAt: new Date(NOW.getTime() + 3 * 86400000).toISOString(),
              kind: draft.used ? 'quiz' : (draft.attachmentName ? 'file' : 'quiz'),
              file: draft.attachmentName || null,
              teacher: state.role === 'wali' ? state.waliName : state.teacherName,
              questions: draft.used ? draft.questions : [],
              questionsSource: draft.used ? 'assistant' : 'example',
              demo: false
            });
            closeSheet();
            render();
          }
        }, ['Simpan tugas'])
      ]));
    }

    refresh();
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
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: logoutDemo
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
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: logoutDemo
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  /* ---------------- Orang tua ---------------- */
  /* Hasil tugas yang benar-benar milik kelas anak. RESULTS menyimpan hasil
     semua kelas (termasuk demo kelas lain), jadi tidak boleh dipakai apa adanya
     di layar orang tua. */
  function completedTasksForChild() {
    return TASKS.filter(function (t) {
      return t.className === state.parentClass && !!RESULTS[t.id];
    }).length;
  }

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
      el('img', { class: 'banner-img', src: state.mediaAssets['banner-siswa'] || ASSETS.studentBanner, alt: 'Banner siswa' }),
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
      ], { backgroundColor: 'var(--surface-progress)', onTap: function () { openProgress(); } }),
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

  /* Sheet detail latihan: dua metode seperti tugas. */
  function openPractice(practice) {
    state.practiceResult = practice;
    var res = PRACTICE_RESULTS[practice.id];
    var esaiBank = typeof CURR.exercisesFor === 'function'
      ? CURR.exercisesFor(normalizeSubject(practice.subject), state.religion || '')
      : (CURR.practiceBank[normalizeSubject(practice.subject)] || []);
    var pgBank = questionsForPractice(practice.subject);

    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 2px 0', text: practice.title }),
      el('p', { class: 't-muted', style: 'margin-bottom:14px', text: practice.subject + ' · ' + (practice.className || 'Latihan') }),
      el('p', { class: 't-section', style: 'margin:4px 0 10px 0', text: 'Pilih metode latihan' }),
      el('div', { class: 'method-card pressable', role: 'button', tabindex: '0',
        onclick: function () { closeSheet(); startPracticeQuiz(practice); }
      }, [
        el('div', { class: 'method-icon', text: '🔠' }),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Pilihan ganda' }),
          el('p', { class: 't-small', style: 'margin:0', text: pgBank.length + ' soal · dinilai otomatis' })
        ]),
        el('span', { class: 't-link', text: res && res.score != null ? 'Nilai ' + res.score + '/' + res.total : 'Mulai' })
      ]),
      el('div', { class: 'method-card pressable', role: 'button', tabindex: '0',
        onclick: function () { closeSheet(); startEssayForPractice(practice); }
      }, [
        el('div', { class: 'method-icon', text: '✍️' }),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', style: 'margin:0', text: 'Esai' }),
          el('p', { class: 't-small', style: 'margin:0', text: esaiBank.length + ' soal · tidak dinilai otomatis' })
        ]),
        el('span', { class: 't-link', text: PRACTICE_DONE[practice.id] ? 'Selesai' : 'Mulai' })
      ]),
      el('p', {
        class: 't-small', style: 'margin-top:12px',
        text: 'Kamu boleh mengerjakan salah satu atau keduanya. Esai tidak dinilai otomatis.'
      })
    ]));
  }

  function startEssayForPractice(practice) {
    var bank = typeof CURR.exercisesFor === 'function'
      ? CURR.exercisesFor(normalizeSubject(practice.subject), state.religion || '')
      : (CURR.practiceBank[normalizeSubject(practice.subject)] || []);
    var answers = [];
    var index = 0;

    function body() {
      if (index >= bank.length) {
        PRACTICE_DONE[practice.id] = true;
        return el('div', {}, [
          el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Hasil latihan' }),
          el('p', { class: 't-muted', style: 'margin-bottom:14px', text: practice.title + ' · ' + bank.length + ' soal esai selesai' }),
          el('p', { class: 't-result-number', text: answers.filter(function (a) { return a.trim().length > 0; }).length + ' / ' + bank.length }),
          el('button', {
            class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
            onclick: function () { closeSheet(); go('hasil-latihan'); }
          }, ['Lihat hasil'])
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
        el('p', {
          class: 't-item-title', style: 'margin:0',
          // Jangan memuji "terus bertumbuh" saat belum ada yang selesai.
          text: completedTasksForChild() ? 'Terus bertumbuh! 🌱' : 'Ayo mulai perjalanannya! 🚀'
        }),
        el('p', {
          class: 't-muted', style: 'margin:4px 0 0 0',
          // Hitung hanya tugas kelas anak. Sebelumnya memakai seluruh RESULTS,
          // sehingga hasil milik kelas lain ikut terhitung (mis. 18 tugas
          // padahal anak di Kelas 1 belum menyelesaikan satu pun).
          text: completedTasksForChild() + ' tugas dan 0 latihan selesai.'
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
          class: 't-link pressable', type: 'button', style: 'padding:20px', onclick: logoutDemo
        }, ['Keluar dari akun demo'])
      ])
    ]);
  }

  /* ---------------- Operator sekolah ---------------- */
  function rosterForClass(className) {
    return state.roster.filter(function (s) { return s.className === className; });
  }

  function operatorStatCard(opts) {
    return statCard(opts);
  }

  /* Beranda operator: cermin OperatorHomeTab yang baru.
     Tidak ada banner "Semangat mengajar" (banner itu milik guru/siswa);
     sapaan singkat langsung di bawah judul, lima pintasan yang bisa dilipat
     sendiri-sendiri, lalu section profil operator lengkap. */
  function operatorWelcomeLine(name) {
    return el('div', { style: 'margin-bottom:16px' }, [
      el('p', {
        style: 'margin:0;font-size:20px;line-height:1.3;font-weight:800;color:var(--ink)',
        text: 'Selamat datang, ' + (name || 'Operator Sekolah')
      }),
      el('p', {
        class: 't-muted', style: 'margin:4px 0 0 0',
        text: 'Semua data siswa, kelas, materi, dan aset sekolah bisa diubah dari sini.'
      })
    ]);
  }

  /* Kartu pintasan yang bisa dilipat sendiri-sendiri (cermin
     OperatorCollapsibleCard). Kunci buka/tutupnya hidup di state supaya
     pilihan operator tidak hilang saat layar dirender ulang. */
  function operatorCollapsibleCard(opts) {
    var open = !!(state.operatorOpen && state.operatorOpen[opts.key]);
    return el('div', {
      class: 'clay-soft collapsible-card',
      'data-card': opts.key
    }, [
      el('div', {
        class: 'collapsible-head pressable',
        role: 'button', tabindex: '0',
        'aria-expanded': open ? 'true' : 'false',
        'aria-label': (open ? 'Tutup rincian ' : 'Buka rincian ') + opts.title,
        onclick: function () { toggleOperatorCard(opts.key); },
        onkeydown: function (e) {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            toggleOperatorCard(opts.key);
          }
        }
      }, [
        el('div', {
          class: 'item-tile', style: 'background-color:' + (opts.tileColor || '#F8EBEC')
        }, [el('span', { text: opts.iconEmoji })]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', { class: 't-item-title', text: opts.title }),
          el('p', { class: 't-small', text: opts.meta })
        ]),
        el('button', {
          class: 'status-badge pressable', type: 'button',
          'aria-label': opts.status + ' ' + opts.title,
          onclick: function (e) {
            if (e && e.stopPropagation) e.stopPropagation();
            opts.onManage();
          }
        }, [opts.status]),
        el('span', { class: 'collapsible-caret' + (open ? ' open' : ''), 'aria-hidden': 'true' },
          [icon('chevron-forward', 17)])
      ]),
      open && opts.details && opts.details.length
        ? el('div', { class: 'collapsible-body' }, opts.details.map(function (line) {
            return el('div', { class: 'collapsible-line' }, [
              el('span', { class: 'collapsible-dot', 'aria-hidden': 'true' }),
              el('span', { text: line })
            ]);
          }))
        : null
    ]);
  }

  /* Pindah ke tab Profil operator (tab keenam) dari beranda. */
  function openOperatorProfilTab() {
    state.tab = 'Profil';
    go('operator-profil');
  }

  function toggleOperatorCard(key) {
    if (!state.operatorOpen) state.operatorOpen = {};
    state.operatorOpen[key] = !state.operatorOpen[key];
    render();
  }

  function renderOperatorBeranda() {
    var custom = Object.keys(state.mediaAssets).length;
    var active = state.roster.filter(function (s) { return s.active; }).length;
    var op = state.operatorProfile || {};

    var subjects = [];
    TASKS.forEach(function (t) {
      if (subjects.indexOf(t.subject) < 0) subjects.push(t.subject);
    });
    var taskClasses = [];
    TASKS.forEach(function (t) {
      if (taskClasses.indexOf(t.className) < 0) taskClasses.push(t.className);
    });

    var announcementDetails = ANNOUNCEMENTS.length
      ? ANNOUNCEMENTS.slice(0, 3).map(function (a) { return a.title || a.body; })
      : ['Belum ada pengumuman tersimpan.'];

    var eventDetails = CLASS_EVENTS.length
      ? CLASS_EVENTS.slice().sort(function (a, b) {
          return String(a.date).localeCompare(String(b.date));
        }).slice(0, 3).map(function (e) {
          return e.title + ' · ' + fullDateFromKey(e.date);
        })
      : ['Belum ada agenda tersimpan.'];

    return el('div', {}, [
      pageHeader('Operator Sekolah', 'Kelola seluruh isi KARSA', null, el('button', {
        class: 'round-icon-btn pressable', type: 'button',
        'aria-label': state.dark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
        onclick: function () { toggleTheme(); }
      }, [icon(state.dark ? 'sunny-outline' : 'moon-outline', 20)])),
      operatorWelcomeLine(op.name),
      el('div', { class: 'stats-grid' }, [
        operatorStatCard({
          icon: 'person', label: 'Siswa', value: String(state.roster.length),
          desc: active + ' aktif', color: 'var(--rose)',
          onTap: function () { go('operator-siswa'); }
        }),
        operatorStatCard({
          icon: 'people', label: 'Kelas', value: String(state.schoolClasses.length),
          desc: 'kelas aktif', color: 'var(--blue)',
          onTap: function () { go('operator-kelas'); }
        })
      ]),
      el('div', { class: 'stats-grid' }, [
        operatorStatCard({
          icon: 'book-outline', label: 'Materi', value: String(MATERIALS.length),
          desc: 'semua guru', color: 'var(--blue)',
          onTap: function () { go('operator-materi'); }
        }),
        operatorStatCard({
          icon: 'albums', label: 'Aset', value: custom + '/3',
          desc: 'grafis aktif', color: 'var(--rose)',
          onTap: function () { go('operator-media'); }
        })
      ]),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Kelola sekolah' }),
      operatorCollapsibleCard({
        key: 'tasks', iconEmoji: '📝', title: 'Tugas sekolah',
        meta: TASKS.length + ' tugas aktif lintas kelas', status: 'Kelola',
        details: [
          subjects.length + ' mata pelajaran · ' + taskClasses.length + ' kelas',
          subjects.slice(0, 4).join(', ')
        ].filter(function (v) { return v; }),
        onManage: function () { go('operator-tugas'); }
      }),
      operatorCollapsibleCard({
        key: 'announcements', iconEmoji: '📣', title: 'Pengumuman sekolah',
        meta: ANNOUNCEMENTS.length + ' pengumuman aktif', status: 'Kelola',
        details: announcementDetails,
        onManage: function () { go('operator-pengumuman'); }
      }),
      operatorCollapsibleCard({
        key: 'agenda', iconEmoji: '📅', title: 'Agenda sekolah',
        meta: CLASS_EVENTS.length + ' agenda tersimpan', status: 'Kelola',
        details: eventDetails,
        onManage: function () { go('operator-agenda'); }
      }),
      operatorCollapsibleCard({
        key: 'grades', iconEmoji: '📊', title: 'Nilai kelas',
        meta: 'Isi, ubah, dan hapus nilai ringkas siswa', status: 'Kelola',
        details: [
          'Nilai ringkas per kelas dipakai untuk rekap di beranda wali kelas.',
          'Nilai di luar 0–100 ditolak.'
        ],
        onManage: function () { go('operator-nilai'); }
      }),
      operatorCollapsibleCard({
        key: 'media', iconEmoji: '🗂️', title: 'Logo & banner sekolah',
        meta: custom === 0 ? 'Masih memakai aset bawaan aplikasi'
          : custom + ' grafis memakai gambar pilihan operator',
        status: 'Ubah',
        details: [
          ['school-logo', 'Logo sekolah', 'logo-sd-karitas.png'],
          ['banner-siswa', 'Banner siswa', 'student-banner.png'],
          ['banner-guru', 'Banner guru', 'teacher-banner.png']
        ].map(function (slot) {
          return slot[1] + ' — ' + (state.mediaAssets[slot[0]] ? 'gambar pilihan operator' : 'aset bawaan');
        }),
        onManage: function () { go('operator-media'); }
      }),
      // Profil operator kini tab sendiri (keenam, di sebelah Media); beranda
      // hanya menyisakan pintasan ringkas supaya tidak menumpuk.
      el('div', { style: 'height:8px' }),
      el('div', {
        class: 'clay-soft pressable',
        style: 'padding:15px;background:var(--surface-rose);cursor:pointer',
        role: 'button', tabindex: '0',
        'aria-label': 'Buka tab Profil operator',
        onclick: function () { openOperatorProfilTab(); },
        onkeydown: function (e) {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            openOperatorProfilTab();
          }
        }
      }, [
        el('div', { style: 'display:flex;align-items:center;gap:12px' }, [
          el('div', {
            style: 'width:42px;height:42px;border-radius:21px;background:var(--surface-input);display:flex;' +
                   'align-items:center;justify-content:center;font-weight:800;font-size:15px;color:var(--rose)'
          }, [profileInitials(op)]),
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', { class: 't-item-title', style: 'margin:0',
              text: (op.name || '').trim() || 'Operator Sekolah' }),
            el('p', { class: 't-small', style: 'margin:2px 0 0 0',
              text: 'Identitas kerja dan pengaturan ada di tab Profil' })
          ]),
          el('span', { style: 'color:var(--rose);display:inline-flex' }, [icon('chevron-forward', 18)])
        ])
      ])
    ]);
  }

  /* Inisial dua huruf untuk avatar operator, mis. "Operator Sekolah" -> "OS". */
  function profileInitials(op) {
    var parts = ((op && op.name) || '').trim().split(/\s+/).filter(function (w) { return w; });
    if (!parts.length) return '?';
    if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
  }

  /* Enam kolom profil read-only + indikator kelengkapan.
     Dipakai tab Profil operator (cermin _ProfileFields di Flutter). */
  function operatorProfileFields(op) {
    var fields = [
      ['Nama lengkap', op.name],
      ['NIP', op.nip],
      ['Jabatan', op.role],
      ['Unit kerja', op.unit],
      ['Surel', op.email],
      ['Telepon', op.phone]
    ];
    var filled = fields.filter(function (f) { return (f[1] || '').trim(); }).length;
    var missing = [];
    if (!(op.email || '').trim()) missing.push('surel');
    if (!(op.phone || '').trim()) missing.push('telepon');

    return el('div', { class: 'clay-soft', style: 'padding:4px 16px 12px 16px' }, [
      el('div', {}, fields.map(function (f, i) {
        var value = (f[1] || '').trim();
        return el('div', {
          class: 'profile-field' + (i === fields.length - 1 ? ' last' : '')
        }, [
          el('span', { class: 'profile-field-label', text: f[0] }),
          el('span', {
            class: 'profile-field-value' + (value ? '' : ' empty'),
            text: value || 'Belum diisi'
          })
        ]);
      })),
      el('div', { class: 'profile-complete' }, [
        icon(filled < 6 ? 'help-circle-outline' : 'checkmark-circle', 17),
        el('span', {
          text: filled < 6
            ? 'Lengkapi ' + (missing.length ? missing.join(' & ') : 'data pribadi') +
              ' (' + filled + '/6 kolom terisi)'
            : 'Data pribadi sudah lengkap'
        })
      ])
    ]);
  }

  /* Tab Profil operator: cermin OperatorProfileTab (tab keenam, di sebelah
     Media). Identitas kerja read-only + pengaturan akun. */
  function renderOperatorProfil() {
    var op = state.operatorProfile || {};
    var settings = [
      ['Tampilan', 'sunny-outline'],
      ['Notifikasi', 'notifications-outline'],
      ['Privasi dan keamanan', 'shield-checkmark-outline'],
      ['Pusat bantuan', 'help-circle-outline']
    ];

    return el('div', {}, [
      pageHeader('Profil Operator', 'Identitas kerja dan pengaturan akun'),
      schoolIdentity(false),
      el('div', { class: 'clay-soft', style: 'padding:18px;margin-bottom:20px;background:var(--surface-rose)' }, [
        el('div', { style: 'display:flex;align-items:center;gap:14px' }, [
          el('div', {
            style: 'width:62px;height:62px;border-radius:31px;background:var(--surface-input);display:flex;' +
                   'align-items:center;justify-content:center;font-weight:800;font-size:22px;color:var(--rose)'
          }, [profileInitials(op)]),
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', {
              class: 't-item-title',
              style: 'margin:0;font-size:16px',
              text: (op.name || '').trim() || 'Operator Sekolah'
            }),
            el('p', {
              class: 't-small',
              style: 'margin:3px 0 0 0',
              text: (op.role || '').trim() || 'Operator sekolah'
            }),
            el('p', {
              class: 't-small',
              style: 'margin:2px 0 0 0',
              text: (op.unit || '').trim() || 'Unit kerja belum diisi'
            })
          ])
        ]),
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'margin-top:14px;border:none;cursor:pointer;height:44px',
          'aria-label': 'Ubah profil operator',
          onclick: function () { openSetting('Informasi pribadi'); }
        }, ['Ubah profil'])
      ]),
      el('p', { class: 't-section', style: 'margin-bottom:10px', text: 'Informasi pribadi' }),
      operatorProfileFields(op),
      el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Pengaturan' }),
      el('div', { class: 'clay-soft', style: 'padding:0;overflow:hidden' },
        settings.map(function (item, index) {
          return el('button', {
            class: 'setting-row pressable' + (index === settings.length - 1 ? ' last' : ''),
            type: 'button',
            style: 'width:100%;border:none;cursor:pointer',
            onclick: function () { openSetting(item[0]); }
          }, [
            el('span', { class: 'setting-row-icon' }, [icon(item[1], 18)]),
            el('span', { class: 'setting-row-label', text: item[0] }),
            el('span', { style: 'display:inline-flex;color:var(--muted)' }, [icon('chevron-forward', 17)])
          ]);
        })
      ),
      el('div', { style: 'text-align:center' }, [
        el('button', {
          class: 't-link pressable', type: 'button', style: 'padding:20px',
          onclick: logoutDemo
        }, ['Keluar dari akun demo'])
      ]),
      el('p', {
        class: 't-small',
        style: 'text-align:center;color:var(--muted);font-size:12px',
        text: 'Data profil tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
      })
    ]);
  }

  function renderOperatorSiswa() {
    var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
    var list = filter === 'Semua kelas' ? state.roster : rosterForClass(filter);
    var query = (state.operatorQuery || '').trim().toLowerCase();
    var visible = query === '' ? list : list.filter(function (s) {
      return s.name.toLowerCase().indexOf(query) >= 0 || s.nisn.indexOf(query) >= 0;
    });

    var children = [
      pageHeader('Data Siswa', state.roster.length + ' siswa · ' +
        state.roster.filter(function (s) { return s.active; }).length + ' aktif'),
      chips(['Semua kelas'].concat(CLASSES), filter, function (v) {
        state.filter = v;
        render();
      }),
      el('input', {
        class: 'karsa-input', type: 'text', value: state.operatorQuery || '',
        placeholder: 'Cari nama atau NISN', 'aria-label': 'Cari siswa',
        oninput: function (e) { state.operatorQuery = e.target.value; render(); }
      })
    ];

    if (!visible.length) {
      children.push(noticeCard('Tidak ada siswa', 'Tidak ada siswa yang cocok dengan pencarian ini.'));
    } else {
      visible.forEach(function (s) {
        children.push(listItemCard({
          iconEmoji: s.gender === 'P' ? '👧🏻' : '👦🏻',
          tileColor: '#F8EBEC', title: s.name,
          meta: s.className + ' · NISN ' + (s.nisn || '-') +
            (s.parentName ? ' · ' + s.parentName : ''),
          status: s.active ? 'Aktif' : 'Nonaktif',
          onTap: function () { openStudentForm(s); }
        }));
      });
    }

    children.push(el('button', {
      class: 'karsa-btn clay-raised pressable', type: 'button', style: 'border:none;cursor:pointer',
      onclick: function () { openStudentForm(null); }
    }, ['+ Tambah siswa']));
    children.push(el('p', {
      class: 't-small',
      style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Data tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
    }));
    return el('div', {}, children);
  }

  function renderOperatorKelas() {
    var children = [
      pageHeader('Kelas Sekolah', state.schoolClasses.length + ' kelas · ' +
        state.staffAccounts.length + ' akun guru dan wali'),
      segmentTabs(['Kelas', 'Akun', 'Siswa'], state.operatorClassSection || 'Kelas', function (v) {
        state.operatorClassSection = v;
        state.operatorError = '';
        render();
      })
    ];

    if (state.operatorError) {
      children.push(el('p', {
        class: 't-small',
        style: 'margin:0 0 10px 0;color:var(--rose);font-weight:800;font-size:12px',
        text: state.operatorError
      }));
    }

    if ((state.operatorClassSection || 'Kelas') === 'Kelas') {
      state.schoolClasses.forEach(function (schoolClass) {
        var className = schoolClass.name;
        var students = rosterForClass(className);
        var tasks = TASKS.filter(function (t) { return t.className === className; }).length;
        var materials = MATERIALS.filter(function (m) { return m.className === className; }).length;
        children.push(clayCard([
          el('div', { style: 'display:flex;align-items:center;gap:10px' }, [
            el('p', { class: 't-item-title', style: 'flex:1;margin:0', text: className }),
            el('p', { class: 't-small', style: 'margin:0', text: students.length + ' siswa' })
          ]),
          el('p', {
            class: 't-small', style: 'margin:6px 0 0 0',
            text: 'Wali kelas: ' + (schoolClass.teacherName || 'Belum ditentukan') +
              ' · ' + tasks + ' tugas · ' + materials + ' materi'
          }),
          operatorRowActions([
            operatorLink('Ubah', function () { openOperatorClassForm(schoolClass); }),
            operatorLink('Hapus', function () { removeOperatorClass(schoolClass); })
          ])
        ]));
      });
      children.push(operatorBtn('+ Tambah kelas', function () { openOperatorClassForm(null); }));
      children.push(el('p', {
        class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
        text: 'Menghapus kelas memindahkan siswanya ke kelas pertama yang tersisa.'
      }));
    }

    if (state.operatorClassSection === 'Akun') {
      state.staffAccounts.forEach(function (account) {
        children.push(listItemCard({
          iconEmoji: account.role === 'wali' ? '👩🏻‍🏫' : '📚',
          tileColor: '#F8EBEC', title: account.name,
          meta: 'NIP ' + account.nip + ' · ' +
            (account.role === 'wali' ? 'Wali kelas' : 'Guru mata pelajaran') +
            (account.className ? ' · ' + account.className : ''),
          status: 'Ubah', onTap: function () { openOperatorStaffForm(account); }
        }));
        children.push(operatorRowActions([
          operatorLink('Ubah', function () { openOperatorStaffForm(account); }),
          operatorLink('Hapus', function () {
            state.staffAccounts = state.staffAccounts.filter(function (a) {
              return a.id !== account.id;
            });
            persistState();
            render();
          })
        ]));
      });
      children.push(operatorBtn('+ Tambah akun', function () { openOperatorStaffForm(null); }));
      children.push(el('p', {
        class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
        text: 'Akun guru dan wali yang dibuat operator tersimpan di perangkat ini.'
      }));
    }

    if (state.operatorClassSection === 'Siswa') {
      var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
      var students = filter === 'Semua kelas'
        ? state.roster
        : rosterForClass(filter);
      children.push(chips(operatorFilterOptions(), filter, function (v) {
        state.filter = v;
        render();
      }));
      students.forEach(function (s) {
        children.push(listItemCard({
          iconEmoji: s.gender === 'P' ? '👧🏻' : '👦🏻', tileColor: '#F8EBEC', title: s.name,
          meta: s.className + ' · NISN ' + (s.nisn || '-'),
          status: s.active ? 'Aktif' : 'Nonaktif',
          onTap: function () { openStudentForm(s); }
        }));
        children.push(operatorRowActions([
          operatorLink('Ubah data', function () { openStudentForm(s); })
        ]));
      });
      children.push(el('p', {
        class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
        text: 'Pindah kelas siswa lewat tombol "Ubah data" pada form siswa.'
      }));
    }

    return el('div', {}, children);
  }

  function removeOperatorClass(schoolClass) {
    var remaining = state.schoolClasses.filter(function (c) { return c.id !== schoolClass.id; });
    if (!remaining.length) {
      // Kelas terakhir tidak boleh dihapus karena seluruh data sekolah memakai
      // nama kelas.
      state.operatorError = 'Minimal satu kelas sekolah harus tetap ada.';
      render();
      return false;
    }
    state.operatorError = '';
    var fallback = remaining[0].name;
    state.roster = state.roster.map(function (s) {
      if (s.className === schoolClass.name) {
        return { id: s.id, nisn: s.nisn, name: s.name, className: fallback,
          gender: s.gender, parentName: s.parentName, active: s.active };
      }
      return s;
    });
    state.schoolClasses = remaining;
    persistState();
    render();
    return true;
  }

  function openOperatorClassForm(schoolClass) {
    var draft = schoolClass
      ? { id: schoolClass.id, name: schoolClass.name, teacherName: schoolClass.teacherName || '', error: '' }
      : { id: '', name: '', teacherName: '', error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Kelas' : 'Tambah Kelas'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Kelas sekolah beserta wali kelasnya' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Nama kelas' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.name, placeholder: 'Mis. Kelas 7',
          'aria-label': 'Nama kelas',
          oninput: function (e) { draft.name = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Wali kelas' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.teacherName, placeholder: 'Nama wali kelas',
          'aria-label': 'Wali kelas',
          oninput: function (e) { draft.teacherName = e.target.value; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan kelas', function () {
          var name = (draft.name || '').trim();
          if (!name) {
            draft.error = 'Isi nama kelas.';
            refresh();
            return;
          }
          var duplicate = state.schoolClasses.some(function (c) {
            return c.name.toLowerCase() === name.toLowerCase() && c.id !== draft.id;
          });
          if (duplicate) {
            draft.error = 'Kelas dengan nama itu sudah ada.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-class-' + Date.now()),
            name: name,
            teacherName: (draft.teacherName || '').trim()
          };
          var exists = false;
          state.schoolClasses = state.schoolClasses.map(function (c) {
            if (c.id === record.id) { exists = true; return record; }
            return c;
          });
          if (!exists) state.schoolClasses = state.schoolClasses.concat([record]);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus kelas ini', function () {
          // Pakai nama yang tersimpan, bukan draft yang mungkin sudah diedit
          // namun belum disimpan, agar siswa tetap dipindahkan dengan benar.
          var matches = state.schoolClasses.filter(function (c) {
            return c.id === draft.id;
          });
          if (!matches.length) { closeSheet(); render(); return; }
          if (removeOperatorClass(matches[0])) {
            closeSheet();
            render();
            return;
          }
          draft.error = state.operatorError ||
            'Minimal satu kelas sekolah harus tetap ada.';
          refresh();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  function openOperatorStaffForm(account) {
    var draft = account
      ? { id: account.id, name: account.name, nip: account.nip, role: account.role,
          className: account.className || '', error: '' }
      : { id: '', name: '', nip: '', role: 'guru', className: '', error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Akun' : 'Tambah Akun'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Akun guru atau wali kelas' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Nama lengkap' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.name, placeholder: 'Nama pengguna',
          'aria-label': 'Nama pengguna',
          oninput: function (e) { draft.name = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'NIP' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.nip, placeholder: 'Nomor induk pegawai',
          'aria-label': 'NIP',
          oninput: function (e) { draft.nip = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Peran' }),
        chips(['guru', 'wali'], draft.role, function (v) { draft.role = v; refresh(); }),
        draft.role === 'wali' ? el('div', {}, [
          el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Kelas yang diampu' }),
          chips(operatorClassOptions(), draft.className, function (v) { draft.className = v; refresh(); })
        ]) : null,
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan akun', function () {
          var name = (draft.name || '').trim();
          var nip = (draft.nip || '').trim();
          if (!name || !nip) {
            draft.error = 'Isi nama lengkap dan NIP.';
            refresh();
            return;
          }
          var duplicate = state.staffAccounts.some(function (a) {
            return a.nip === nip && a.id !== draft.id;
          });
          if (duplicate) {
            draft.error = 'NIP itu sudah dipakai akun lain.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-user-' + Date.now()),
            name: name,
            nip: nip,
            role: draft.role,
            className: draft.role === 'wali' ? draft.className : ''
          };
          var exists = false;
          state.staffAccounts = state.staffAccounts.map(function (a) {
            if (a.id === record.id) { exists = true; return record; }
            return a;
          });
          if (!exists) state.staffAccounts = state.staffAccounts.concat([record]);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus akun ini', function () {
          state.staffAccounts = state.staffAccounts.filter(function (a) { return a.id !== draft.id; });
          persistState();
          closeSheet();
          render();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  function renderOperatorMateri() {
    var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
    var list = filter === 'Semua kelas'
      ? MATERIALS
      : MATERIALS.filter(function (m) { return m.className === filter; });

    var children = [
      pageHeader('Materi Sekolah', MATERIALS.length + ' materi dari semua guru'),
      chips(operatorFilterOptions(), filter, function (v) {
        state.filter = v;
        render();
      })
    ];
    if (!list.length) {
      children.push(noticeCard('Belum ada materi', 'Belum ada materi untuk kelas ini.'));
    }
    list.forEach(function (m) {
      children.push(el('div', {}, [
        listItemCard({
          iconEmoji: '📚', tileColor: '#F8EBEC', title: m.title,
          meta: m.subject + ' · ' + m.className + ' · ' + m.teacher,
          status: 'Ubah', onTap: function () { openOperatorMaterialForm(m); }
        }),
        operatorRowActions([
          operatorLink('Ubah', function () { openOperatorMaterialForm(m); }),
          operatorLink('Hapus', function () {
            MATERIALS = MATERIALS.filter(function (x) { return x.id !== m.id; });
            persistState();
            render();
          })
        ])
      ]));
    });
    children.push(operatorBtn('+ Tambah materi', function () { openOperatorMaterialForm(null); }));
    children.push(el('p', {
      class: 't-small',
      style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Operator sekolah boleh menambah, mengubah, dan menghapus materi milik guru dan wali kelas.'
    }));
    return el('div', {}, children);
  }

  function openOperatorMaterialForm(material) {
    var draft = material
      ? { id: material.id, title: material.title, subject: material.subject,
          className: material.className, summary: material.body || '', error: '' }
      : { id: '', title: '', subject: 'Matematika',
          className: operatorClassOptions()[0] || 'Kelas 1', summary: '', error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Materi' : 'Tambah Materi'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Materi untuk seluruh kelas' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Judul materi' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.title, placeholder: 'Mis. Ekosistem',
          'aria-label': 'Judul materi',
          oninput: function (e) { draft.title = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Mata pelajaran' }),
        chips(SUBJECTS, draft.subject, function (v) { draft.subject = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Untuk kelas' }),
        chips(operatorClassOptions(), draft.className, function (v) { draft.className = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Ringkasan materi' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.summary, placeholder: 'Ringkasan materi',
          'aria-label': 'Ringkasan materi',
          oninput: function (e) { draft.summary = e.target.value; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan materi', function () {
          var title = (draft.title || '').trim();
          if (!title) {
            draft.error = 'Isi judul materi.';
            refresh();
            return;
          }
          if (!(draft.summary || '').trim()) {
            draft.error = 'Isi ringkasan materi.';
            refresh();
            return;
          }
          if (subjectsForClass(draft.className).indexOf(draft.subject) < 0) {
            draft.error = 'IPAS hanya boleh dipakai untuk kelas 3-6.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-material-' + Date.now()),
            subject: draft.subject,
            className: draft.className,
            title: title,
            teacher: state.teacherName,
            body: (draft.summary || '').trim()
          };
          var exists = false;
          MATERIALS = MATERIALS.map(function (m) {
            if (m.id === record.id) { exists = true; return record; }
            return m;
          });
          if (!exists) MATERIALS = [record].concat(MATERIALS);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus materi ini', function () {
          MATERIALS = MATERIALS.filter(function (m) { return m.id !== draft.id; });
          persistState();
          closeSheet();
          render();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  function renderOperatorMedia() {
    var children = [
      pageHeader('Foto & Grafis', 'Logo dan banner sekolah'),
      noticeCard('Aset sekolah dikelola operator',
        'Pilih gambar JPG atau PNG. Grafik yang dipilih langsung tampil di seluruh aplikasi - beranda siswa, beranda guru, dan kartu identitas sekolah. Slot yang dikosongkan kembali memakai aset bawaan.')
    ];

    MEDIA_SLOTS.forEach(function (slot) {
      var custom = state.mediaAssets[slot.key];
      var tile = el('div', {
        style: 'width:76px;height:76px;border-radius:18px;overflow:hidden;' +
          'border:1px solid var(--line);flex-shrink:0;background:var(--card)'
      }, [
        el('img', {
          src: custom || slot.fallback, alt: slot.label,
          style: 'width:100%;height:100%;object-fit:cover;display:block'
        })
      ]);

      var actions = [
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer;margin-top:12px',
          onclick: function () { pickMediaImage(slot.key); }
        }, [custom ? 'Ganti gambar' : 'Pilih gambar'])
      ];
      if (custom) {
        actions.push(el('button', {
          class: 't-link pressable', type: 'button', style: 'margin-top:8px;display:block;width:100%',
          onclick: function () {
            delete state.mediaAssets[slot.key];
            persistState();
            render();
          }
        }, ['Hapus gambar']));
      }

      children.push(clayCard([
        el('div', { style: 'display:flex;gap:12px;align-items:center' }, [
          tile,
          el('div', { style: 'flex:1;min-width:0' }, [
            el('p', { class: 't-item-title', style: 'margin:0', text: slot.label }),
            el('p', { class: 't-small', style: 'margin:3px 0 0 0', text: slot.desc }),
            el('p', {
              class: 't-small', style: 'margin:6px 0 0 0',
              text: custom ? 'Gambar pilihan operator aktif' : 'Memakai aset bawaan aplikasi'
            })
          ])
        ])
      ].concat(actions)));
    });

    children.push(el('p', {
      class: 't-small',
      style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Gambar disimpan di perangkat ini pada kunci "@karsa-demo-v1".'
    }));
    return el('div', {}, children);
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: helper
   * ------------------------------------------------------------------ */
  function operatorClassNames() {
    return state.schoolClasses.map(function (c) { return c.name; });
  }

  function operatorClassOptions() {
    var names = operatorClassNames();
    return names.length ? names : CLASSES.slice();
  }

  function operatorFilterOptions() {
    return ['Semua kelas'].concat(operatorClassOptions());
  }

  function operatorActiveCount() {
    return state.roster.filter(function (s) { return s.active; }).length;
  }

  function operatorRosterScores(className) {
    var values = state.roster.filter(function (s) {
      return s.className === className && state.rosterScores[s.id] !== undefined;
    }).map(function (s) { return state.rosterScores[s.id]; });
    if (!values.length) return null;
    var sum = values.reduce(function (a, b) { return a + b; }, 0);
    return sum / values.length;
  }

  function operatorBtn(label, onClick, style) {
    return el('button', {
      class: 'karsa-btn clay-raised pressable', type: 'button',
      style: 'border:none;cursor:pointer' + (style ? ';' + style : ''),
      onclick: onClick
    }, [label]);
  }

  function operatorLink(label, onClick) {
    return el('button', {
      class: 't-link pressable', type: 'button',
      style: 'background:none;border:none;padding:4px 8px;cursor:pointer',
      onclick: onClick
    }, [label]);
  }

  function operatorRowActions(items) {
    return el('div', { style: 'display:flex;justify-content:flex-end;gap:4px' }, items);
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: tugas
   * ------------------------------------------------------------------ */
  function renderOperatorTugas() {
    var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
    var list = filter === 'Semua kelas'
      ? TASKS
      : TASKS.filter(function (t) { return t.className === filter; });

    var children = [
      pageHeader('Tugas Sekolah', TASKS.length + ' tugas dari semua guru', function () {
        go('operator-beranda');
      }),
      chips(operatorFilterOptions(), filter, function (v) {
        state.filter = v;
        render();
      })
    ];

    if (!list.length) {
      children.push(noticeCard('Belum ada tugas', 'Belum ada tugas untuk kelas ini.'));
    }
    list.forEach(function (t) {
      children.push(listItemCard({
        iconEmoji: metaFor(t.subject).icon, tileColor: metaFor(t.subject).color, title: t.title,
        meta: t.subject + ' · ' + t.className + (t.teacher ? ' · ' + t.teacher : '') +
          ' · ' + t.minutes + ' menit',
        status: 'Ubah', onTap: function () { openOperatorTaskForm(t); }
      }));
      children.push(operatorRowActions([
        operatorLink('Ubah', function () { openOperatorTaskForm(t); }),
        operatorLink('Hapus', function () {
          TASKS = TASKS.filter(function (x) { return x.id !== t.id; });
          persistState();
          render();
        })
      ]));
    });

    children.push(operatorBtn('+ Tambah tugas', function () { openOperatorTaskForm(null); }));
    children.push(el('p', {
      class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Operator sekolah boleh menambah, mengubah, dan menghapus tugas milik role lain.'
    }));
    return el('div', {}, children);
  }

  function openOperatorTaskForm(task) {
    var draft = task
      ? { id: task.id, title: task.title, subject: task.subject, className: task.className,
          minutes: task.minutes, dueAt: task.dueAt || '', error: '' }
      : { id: '', title: '', subject: 'Matematika', className: operatorClassOptions()[0] || 'Kelas 1',
          minutes: '30', dueAt: dateKey(new Date(NOW.getTime() + 7 * 86400000)), error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Tugas' : 'Tambah Tugas'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Tersimpan di perangkat ini.' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Judul' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.title, placeholder: 'Judul tugas',
          'aria-label': 'Judul tugas',
          oninput: function (e) { draft.title = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Mata pelajaran' }),
        chips(SUBJECTS, draft.subject, function (v) { draft.subject = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Untuk kelas' }),
        chips(operatorClassOptions(), draft.className, function (v) { draft.className = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Durasi pengerjaan (menit)' }),
        el('input', {
          class: 'karsa-input', type: 'number', value: draft.minutes, placeholder: '30',
          'aria-label': 'Durasi pengerjaan',
          oninput: function (e) { draft.minutes = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Tenggat pengumpulan (YYYY-MM-DD)' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.dueAt, placeholder: '2026-12-31',
          'aria-label': 'Tenggat pengumpulan',
          oninput: function (e) { draft.dueAt = e.target.value; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan tugas', function () {
          var title = (draft.title || '').trim();
          var mins = parseFloat(draft.minutes);
          if (!title || !isFinite(mins) || mins <= 0) {
            draft.error = 'Isi judul dan batas waktu yang valid.';
            refresh();
            return;
          }
          if (!/^\d{4}-\d{2}-\d{2}$/.test(draft.dueAt || '') ||
              isNaN(new Date(draft.dueAt + 'T23:59:59').getTime())) {
            draft.error = 'Isi tanggal tenggat dengan format YYYY-MM-DD.';
            refresh();
            return;
          }
          if (subjectsForClass(draft.className).indexOf(draft.subject) < 0) {
            draft.error = 'IPAS hanya boleh dipakai untuk kelas 3-6.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-task-' + Date.now()),
            subject: draft.subject,
            title: title,
            className: draft.className,
            minutes: String(mins),
            kind: 'quiz',
            teacher: state.teacherName,
            dueAt: draft.dueAt ? new Date(draft.dueAt + 'T23:59:59').toISOString() : null,
            demo: false
          };
          var exists = false;
          TASKS = TASKS.map(function (x) {
            if (x.id === record.id) { exists = true; return record; }
            return x;
          });
          if (!exists) TASKS = TASKS.concat([record]);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus tugas ini', function () {
          TASKS = TASKS.filter(function (x) { return x.id !== draft.id; });
          persistState();
          closeSheet();
          render();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: pengumuman
   * ------------------------------------------------------------------ */
  /* ------------------------------------------------------------------ *
   * Pengumuman guru mapel
   * Cermin AnnouncementFormPage + AppState.saveAnnouncement: guru hanya
   * mengumumkan untuk mapelnya, ke "Semua kelas" atau kelas yang diajar.
   * ------------------------------------------------------------------ */
  function teacherClasses() {
    return operatorClassNames().filter(function (c) {
      return subjectsForClass(c).indexOf(state.teacherSubject) >= 0;
    });
  }

  function renderGuruPengumuman() {
    var mine = ANNOUNCEMENTS.filter(function (a) { return a.category === 'PENGUMUMAN GURU'; });
    var taught = teacherClasses();

    var children = [
      pageHeader('Pengumuman', state.teacherSubject + ' · ' + taught.length + ' kelas', function () {
        go('guru-beranda');
      }),
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        style: 'border:none;cursor:pointer',
        onclick: function () { openGuruAnnouncementForm(null); }
      }, ['+ Buat pengumuman']),
      el('p', {
        class: 't-small', style: 'margin:10px 0 14px 0',
        text: 'Hanya sampai ke ' + taught.join(', ') + ' atau semua kelas.'
      })
    ];

    if (!mine.length) {
      children.push(noticeCard('Belum ada pengumumanmu',
        'Buat pengumuman pertama untuk kelas yang kamu ajar.'));
    }
    mine.forEach(function (a) {
      children.push(listItemCard({
        iconEmoji: '📣', tileColor: '#F8EBEC', title: a.title,
        meta: a.className + ' · ' + a.body,
        status: 'Ubah', onTap: function () { openGuruAnnouncementForm(a); }
      }));
    });

    // Pengumuman sekolah tetap terlihat, tapi tidak bisa diubah guru.
    var school = ANNOUNCEMENTS.filter(function (a) { return a.category !== 'PENGUMUMAN GURU'; });
    if (school.length) {
      children.push(el('p', { class: 't-section', style: 'margin:18px 0 10px 0', text: 'Dari sekolah' }));
      school.forEach(function (a) {
        children.push(listItemCard({
          iconEmoji: '🏫', tileColor: '#E4EEF7', title: a.title,
          meta: a.className + ' · ' + a.body, status: null,
          onTap: function () { openAnnouncements(); }
        }));
      });
    }
    return el('div', {}, children);
  }

  function openGuruAnnouncementForm(announcement) {
    var taught = teacherClasses();
    var options = ['Semua kelas'].concat(taught);
    var defaultClass = taught.indexOf(state.filter) >= 0 ? state.filter
      : (taught[0] || 'Semua kelas');
    var draft = announcement
      ? { id: announcement.id, title: announcement.title, body: announcement.body,
          className: announcement.className, error: '' }
      : { id: '', title: '', body: '', className: defaultClass, error: '' };
    if (options.indexOf(draft.className) < 0) draft.className = defaultClass;

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Pengumuman' : 'Buat Pengumuman'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Tersimpan di perangkat ini.' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Judul' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.title, placeholder: 'Judul pengumuman',
          'aria-label': 'Judul pengumuman',
          oninput: function (e) { draft.title = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Isi pengumuman' }),
        el('textarea', {
          class: 'karsa-input', rows: '3', value: draft.body,
          placeholder: 'Tulis pengumuman...', 'aria-label': 'Isi pengumuman',
          style: 'height:auto;resize:vertical',
          oninput: function (e) { draft.body = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Untuk kelas' }),
        // chips memakai daftar kelas yang diajar mapel guru, bukan semua kelas
        chips(options, draft.className, function (v) { draft.className = v; refresh(); }),
        draft.error ? el('p', {
          class: 'notice-title', style: 'margin:10px 0 0 0', text: draft.error
        }) : null,
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer;margin-top:14px;width:100%',
          onclick: function () {
            if (!draft.title.trim() || !draft.body.trim()) {
              draft.error = 'Isi judul dan isi pengumuman.';
              refresh();
              return;
            }
            if (draft.className !== 'Semua kelas' && taught.indexOf(draft.className) < 0) {
              draft.error = draft.className + ' bukan kelas yang kamu ajar.';
              refresh();
              return;
            }
            if (draft.id) {
              ANNOUNCEMENTS = ANNOUNCEMENTS.map(function (a) {
                return a.id === draft.id
                  ? Object.assign({}, a, {
                    title: draft.title.trim(), body: draft.body.trim(),
                    className: draft.className, detail: 'Diperbarui · ' + draft.className
                  })
                  : a;
              });
            } else {
              ANNOUNCEMENTS = [{
                id: 'a' + Date.now(), category: 'PENGUMUMAN GURU',
                title: draft.title.trim(), body: draft.body.trim(),
                detail: 'Baru saja · ' + draft.className, className: draft.className
              }].concat(ANNOUNCEMENTS);
            }
            persistState();
            closeSheet();
            go('guru-pengumuman');
          }
        }, ['Kirim pengumuman'])
      ]));
    }
    refresh();
  }

  function renderOperatorPengumuman() {
    var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
    var list = filter === 'Semua kelas'
      ? ANNOUNCEMENTS
      : ANNOUNCEMENTS.filter(function (a) {
        return a.className === filter || a.className === 'Semua kelas';
      });

    var children = [
      pageHeader('Pengumuman Sekolah', ANNOUNCEMENTS.length + ' pengumuman aktif', function () {
        go('operator-beranda');
      }),
      chips(operatorFilterOptions(), filter, function (v) {
        state.filter = v;
        render();
      })
    ];

    if (!list.length) {
      children.push(noticeCard('Belum ada pengumuman', 'Belum ada pengumuman untuk kelas ini.'));
    }
    list.forEach(function (a) {
      children.push(listItemCard({
        iconEmoji: '📣', tileColor: '#F8EBEC', title: a.title,
        meta: a.className + ' · ' + a.body,
        status: 'Ubah', onTap: function () { openOperatorAnnouncementForm(a); }
      }));
      children.push(operatorRowActions([
        operatorLink('Ubah', function () { openOperatorAnnouncementForm(a); }),
        operatorLink('Hapus', function () {
          ANNOUNCEMENTS = ANNOUNCEMENTS.filter(function (x) { return x.id !== a.id; });
          persistState();
          render();
        })
      ]));
    });

    children.push(operatorBtn('+ Tambah pengumuman', function () { openOperatorAnnouncementForm(null); }));
    children.push(el('p', {
      class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Pengumuman sekolah muncul di beranda siswa, orang tua, dan guru.'
    }));
    return el('div', {}, children);
  }

  function openOperatorAnnouncementForm(announcement) {
    var draft = announcement
      ? { id: announcement.id, title: announcement.title, body: announcement.body,
          className: announcement.className, error: '' }
      : { id: '', title: '', body: '', className: 'Semua kelas', error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Pengumuman' : 'Buat Pengumuman'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Tersimpan di perangkat ini.' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Judul' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.title, placeholder: 'Judul pengumuman',
          'aria-label': 'Judul pengumuman',
          oninput: function (e) { draft.title = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Isi pengumuman' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.body, placeholder: 'Isi pengumuman',
          'aria-label': 'Isi pengumuman',
          oninput: function (e) { draft.body = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Untuk kelas' }),
        chips(operatorFilterOptions(), draft.className, function (v) { draft.className = v; refresh(); }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan pengumuman', function () {
          var title = (draft.title || '').trim();
          var body = (draft.body || '').trim();
          if (!title || !body) {
            draft.error = 'Isi judul dan isi pengumuman.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-ann-' + Date.now()),
            category: 'PENGUMUMAN SEKOLAH',
            title: title,
            detail: draft.id ? 'Diperbarui operator sekolah' : 'Baru saja · ' + draft.className,
            body: body,
            className: draft.className
          };
          var exists = false;
          ANNOUNCEMENTS = ANNOUNCEMENTS.map(function (a) {
            if (a.id === record.id) { exists = true; return record; }
            return a;
          });
          if (!exists) ANNOUNCEMENTS = [record].concat(ANNOUNCEMENTS);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus pengumuman ini', function () {
          ANNOUNCEMENTS = ANNOUNCEMENTS.filter(function (a) { return a.id !== draft.id; });
          persistState();
          closeSheet();
          render();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: agenda
   * ------------------------------------------------------------------ */
  function renderOperatorAgenda() {
    var filter = state.filter === 'Semua kelas' ? 'Semua kelas' : state.filter;
    var list = filter === 'Semua kelas'
      ? CLASS_EVENTS
      : CLASS_EVENTS.filter(function (e) { return e.className === filter; });

    var children = [
      pageHeader('Agenda Sekolah', CLASS_EVENTS.length + ' agenda tersimpan', function () {
        go('operator-beranda');
      }),
      chips(operatorFilterOptions(), filter, function (v) {
        state.filter = v;
        render();
      })
    ];

    if (!list.length) {
      children.push(noticeCard('Belum ada agenda', 'Belum ada agenda untuk kelas ini.'));
    }
    list.forEach(function (e) {
      children.push(listItemCard({
        iconEmoji: '📅', tileColor: '#F8EBEC', title: e.title,
        meta: e.className + ' · ' + e.date + (e.note ? ' · ' + e.note : ''),
        status: 'Ubah', onTap: function () { openOperatorAgendaForm(e); }
      }));
      children.push(operatorRowActions([
        operatorLink('Ubah', function () { openOperatorAgendaForm(e); }),
        operatorLink('Hapus', function () {
          CLASS_EVENTS = CLASS_EVENTS.filter(function (x) { return x.id !== e.id; });
          persistState();
          render();
        })
      ]));
    });

    children.push(operatorBtn('+ Tambah agenda', function () { openOperatorAgendaForm(null); }));
    children.push(el('p', {
      class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Agenda sekolah tersimpan di perangkat ini pada kunci "@karsa-demo-v1".'
    }));
    return el('div', {}, children);
  }

  function openOperatorAgendaForm(event) {
    var draft = event
      ? { id: event.id, title: event.title, note: event.note || '', date: event.date,
          className: event.className, error: '' }
      : { id: '', title: '', note: '', date: dateKey(new Date(NOW.getFullYear(), NOW.getMonth(), NOW.getDate())),
          className: operatorClassOptions()[0] || 'Kelas 1', error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Agenda' : 'Tambah Agenda'
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Tersimpan di perangkat ini.' }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Judul agenda' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.title, placeholder: 'Judul agenda',
          'aria-label': 'Judul agenda',
          oninput: function (e) { draft.title = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Tanggal (YYYY-MM-DD)' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.date, placeholder: '2026-11-07',
          'aria-label': 'Tanggal agenda',
          oninput: function (e) { draft.date = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Untuk kelas' }),
        chips(operatorClassOptions(), draft.className, function (v) { draft.className = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Catatan (opsional)' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.note, placeholder: 'Catatan kegiatan',
          'aria-label': 'Catatan agenda',
          oninput: function (e) { draft.note = e.target.value; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan agenda', function () {
          var title = (draft.title || '').trim();
          if (!title || !/^\d{4}-\d{2}-\d{2}$/.test(draft.date)) {
            draft.error = 'Isi judul dan tanggal valid dengan format YYYY-MM-DD.';
            refresh();
            return;
          }
          var record = {
            id: draft.id || ('local-event-' + Date.now()),
            title: title,
            note: (draft.note || '').trim(),
            date: draft.date,
            className: draft.className,
            time: event && event.time ? event.time : '—'
          };
          var exists = false;
          CLASS_EVENTS = CLASS_EVENTS.map(function (x) {
            if (x.id === record.id) { exists = true; return record; }
            return x;
          });
          if (!exists) CLASS_EVENTS = CLASS_EVENTS.concat([record]);
          persistState();
          closeSheet();
          render();
        }),
        draft.id ? operatorLink('Hapus agenda ini', function () {
          CLASS_EVENTS = CLASS_EVENTS.filter(function (x) { return x.id !== draft.id; });
          persistState();
          closeSheet();
          render();
        }) : null,
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  /* ------------------------------------------------------------------ *
   * Operator sekolah: nilai
   * ------------------------------------------------------------------ */
  function renderOperatorNilai() {
    var options = operatorClassOptions();
    var className = state.filter === 'Semua kelas'
      ? (options[0] || 'Kelas 1')
      : state.filter;
    var students = rosterForClass(className);
    var average = operatorRosterScores(className);

    var children = [
      pageHeader('Nilai Kelas', className, function () { go('operator-beranda'); }),
      chips(options, className, function (v) {
        state.filter = v;
        render();
      }),
      el('p', {
        class: 't-muted', style: 'margin:4px 0 12px 0',
        text: average === null
          ? 'Belum ada nilai yang diisi untuk kelas ini.'
          : 'Rata-rata kelas: ' + average.toFixed(1)
      })
    ];

    if (!students.length) {
      children.push(noticeCard('Belum ada siswa', 'Belum ada siswa di kelas ini.'));
    }
    students.forEach(function (s) {
      var score = state.rosterScores[s.id];
      children.push(listItemCard({
        iconEmoji: s.gender === 'P' ? '👧🏻' : '👦🏻', tileColor: '#F8EBEC', title: s.name,
        meta: 'NISN ' + (s.nisn || '-'),
        status: score === undefined ? 'Belum ada nilai' : 'Nilai ' + score,
        onTap: function () { openOperatorScoreForm(s); }
      }));
      children.push(operatorRowActions([
        operatorLink('Ubah nilai', function () { openOperatorScoreForm(s); }),
        operatorLink('Hapus nilai', function () {
          delete state.rosterScores[s.id];
          persistState();
          render();
        })
      ]));
    });

    children.push(el('p', {
      class: 't-small', style: 'margin-top:12px;color:var(--muted);font-size:12px',
      text: 'Nilai kosong berarti belum dinilai - tidak ada angka contoh yang dibuat operator.'
    }));
    return el('div', {}, children);
  }

  function openOperatorScoreForm(student) {
    var draft = {
      id: student.id,
      value: state.rosterScores[student.id] === undefined
        ? ''
        : String(state.rosterScores[student.id]),
      error: ''
    };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: 'Nilai ' + student.name
        }),
        el('p', { class: 't-muted', style: 'margin-bottom:14px', text: 'Nilai ringkas 0-100 · data lokal' }),
        el('input', {
          class: 'karsa-input', type: 'number', value: draft.value, placeholder: 'Nilai 0-100',
          'aria-label': 'Nilai siswa',
          oninput: function (e) { draft.value = e.target.value; draft.error = ''; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        operatorBtn('Simpan nilai', function () {
          var raw = (draft.value || '').trim();
          if (raw === '') {
            delete state.rosterScores[draft.id];
          } else {
            var parsed = parseFloat(raw);
            if (!isFinite(parsed) || parsed < 0 || parsed > 100) {
              draft.error = 'Nilai harus antara 0 dan 100.';
              refresh();
              return;
            }
            state.rosterScores[draft.id] = parsed;
          }
          persistState();
          closeSheet();
          render();
        }),
        operatorLink('Batal', function () { closeSheet(); render(); })
      ]));
    }
    refresh();
  }

  /* Memilih gambar untuk satu slot media (input file tersembunyi). */
  function pickMediaImage(slotKey) {
    var input = el('input', { type: 'file', accept: 'image/png,image/jpeg', style: 'display:none' });
    input.addEventListener('change', function () {
      var file = input.files && input.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function () {
        state.mediaAssets[slotKey] = String(reader.result);
        persistState();
        render();
      };
      reader.readAsDataURL(file);
    });
    document.body.appendChild(input);
    input.click();
    if (input.remove) input.remove();
  }

  /* Form tambah / ubah data siswa. */
  function openStudentForm(student) {
    var draft = student
      ? { id: student.id, name: student.name, nisn: student.nisn, className: student.className,
          gender: student.gender, parentName: student.parentName, active: student.active, error: '' }
      : { id: '', name: '', nisn: '', className: operatorClassOptions()[0] || 'Kelas 1',
          gender: 'L', parentName: '', active: true, error: '' };

    function refresh() {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', {
          class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0',
          text: draft.id ? 'Ubah Data Siswa' : 'Tambah Siswa'
        }),
        el('p', {
          class: 't-muted', style: 'margin-bottom:14px',
          text: 'Perubahan langsung tersimpan di perangkat ini'
        }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Nama lengkap' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.name, placeholder: 'Nama siswa',
          'aria-label': 'Nama siswa',
          oninput: function (e) { draft.name = e.target.value; draft.error = ''; }
        }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'NISN' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.nisn, placeholder: 'Nomor induk siswa',
          'aria-label': 'NISN',
          oninput: function (e) { draft.nisn = e.target.value; }
        }),
        el('p', { class: 't-label', style: 'margin-bottom:8px', text: 'Kelas' }),
        chips(operatorClassOptions(), draft.className, function (v) { draft.className = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Jenis kelamin' }),
        chips(['L', 'P'], draft.gender, function (v) { draft.gender = v; refresh(); }),
        el('p', { class: 't-label', style: 'margin:12px 0 8px 0', text: 'Orang tua / wali' }),
        el('input', {
          class: 'karsa-input', type: 'text', value: draft.parentName,
          placeholder: 'Nama orang tua atau wali', 'aria-label': 'Nama orang tua',
          oninput: function (e) { draft.parentName = e.target.value; }
        }),
        draft.error ? el('p', { class: 'notice-title', style: 'margin:0 0 10px 0', text: draft.error }) : null,
        el('button', {
          class: 'karsa-btn clay-raised pressable', type: 'button',
          style: 'border:none;cursor:pointer',
          onclick: function () {
            var name = (draft.name || '').trim();
            if (!name) {
              draft.error = 'Nama siswa tidak boleh kosong.';
              refresh();
              return;
            }
            var record = {
              id: draft.id || ('siswa-' + Date.now()),
              nisn: (draft.nisn || '').trim(),
              name: name,
              className: draft.className,
              gender: draft.gender,
              parentName: (draft.parentName || '').trim(),
              active: draft.active
            };
            var exists = false;
            state.roster = state.roster.map(function (s) {
              if (s.id === record.id) { exists = true; return record; }
              return s;
            });
            if (!exists) state.roster = [record].concat(state.roster);
            persistState();
            closeSheet();
            render();
          }
        }, ['Simpan data siswa']),
        draft.id ? el('button', {
          class: 't-link pressable', type: 'button', style: 'margin-top:12px;display:block;width:100%',
          onclick: function () {
            state.roster = state.roster.filter(function (s) { return s.id !== draft.id; });
            persistState();
            closeSheet();
            render();
          }
        }, ['Hapus siswa ini']) : null,
        el('button', {
          class: 't-link pressable', type: 'button', style: 'margin-top:12px;display:block;width:100%',
          onclick: function () { closeSheet(); render(); }
        }, ['Batal'])
      ]));
    }
    refresh();
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
      // Pelajar hanya melihat materi kelasnya sendiri.
      return m.className === learnerClassName();
    });

    var children = [
      pageHeader('Materi belajar', state.role === 'guru' ? 'Kelola materi dan ringkasan' : 'Materi untuk ' + learnerClassName(),
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
          onTap: function () { openMaterialDetail(m); }
        }));
      });
    }
    return el('div', {}, children);
  }

  function openMaterialDetail(m) {
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
        var read = isNotificationRead(n.id);
        // Notifikasi pengumpulan menampilkan nama siswa + nilainya, bukan
        // sekadar "Tugas dikumpulkan siswa".
        var isSubmission = n.kind === 'submission' || n.target === 'teachers';
        var meta = isSubmission && n.studentName
          ? n.subject + ' · ' + n.className + ' · ' +
            scoreLabel(n) + ' · ' + createdAtId(n.createdAt)
          : n.subject + ' · ' + n.className + ' · ' + createdAtId(n.createdAt);
        children.push(listItemCard({
          iconEmoji: isSubmission ? '✅' : (n.kind === 'material' ? '📚' : '📝'),
          tileColor: '#F8EBEC',
          // Nama cukup muncul sekali, di judul; meta mengisi kelas + nilai.
          title: isSubmission && n.studentName ? n.studentName + ' mengumpulkan tugas' : n.title,
          meta: meta,
          status: read ? 'Dibaca' : 'Baru',
          onTap: function () { openNotification(n); }
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

  /* Notifikasi harus bisa diklik: tandai sudah dibaca lalu buka isi yang
     terkait (tugas atau materi), sama seperti AppState.markNotification(). */
  function openNotification(n) {
    markNotificationRead(n.id);
    render();
    // Guru tidak mengerjakan tugas: klik notifikasi pengumpulan membuka daftar
    // siapa saja yang sudah mengumpulkan beserta nilainya.
    if (state.role === 'guru' && (n.kind === 'submission' || n.target === 'teachers')) {
      var submissionTask = TASKS.filter(function (t) { return t.id === n.contentId; })[0];
      openSubmissions(submissionTask, n);
      return;
    }
    if (n.kind === 'task') {
      var task = TASKS.filter(function (t) { return t.id === n.contentId; })[0];
      if (task) {
        openTaskDetail(task);
        return;
      }
    }
    if (n.kind === 'material') {
      var material = MATERIALS.filter(function (m) { return m.id === n.contentId; })[0];
      if (material) {
        openMaterialDetail(material);
        return;
      }
    }
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
    // Tugas hasil asisten membawa soalnya sendiri; hitungan harus mencerminkan
    // soal yang benar-benar akan dikerjakan siswa.
    var own = task && task.questions && task.questions.length ? task.questions : null;
    var bank = own || quizBankFor(task.subject);
    var isAssistant = !!(own && task.questionsSource === 'assistant');
    var essayBank = essayBankFor(task.subject);
    var savedResult = RESULTS[task.id];
    var essayAnswers = (savedResult && savedResult.essayAnswers) || [];
    var essayDone = essayAnswers.some(function (a) { return String(a).trim(); });
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: task.title }),
      el('p', {
        class: 't-muted', style: 'margin-bottom:12px',
        text: task.subject + ' · ' + task.className + ' · ' + task.minutes + ' menit · ' +
          deadlineCountdown(task.dueAt, NOW)
      }),
      el('p', { class: 't-item-title', style: 'margin-bottom:8px',
        text: state.role === 'siswa' || state.role === 'orangtua'
          ? 'Pilih metode pengerjaan'
          : 'Metode pengerjaan siswa' }),
      isAssistant ? el('p', {
        class: 't-small', style: 'margin:0 0 10px 0',
        text: 'Soal disusun asisten dari bahan yang diunggah ' + task.teacher +
          ' (simulasi offline, bukan AI sungguhan).'
      }) : null,
      // Metode 1: pilihan ganda (dinilai otomatis).
      el('button', {
        class: 'method-card pressable', type: 'button',
        'aria-label': 'Pilihan ganda',
        onclick: function () {
          closeSheet();
          if (savedResult) showResult(task); else startQuiz(task);
        }
      }, [
        el('span', { class: 'method-icon', text: '🔠' }),
        el('span', { style: 'flex:1;min-width:0;text-align:left' }, [
          el('span', { class: 't-item-title', style: 'display:block', text: 'Pilihan ganda' }),
          el('span', { class: 't-small', style: 'display:block',
            text: bank.length + ' soal · dinilai otomatis' }),
          savedResult && savedResult.score !== undefined
            ? el('span', { class: 'method-badge',
                text: 'Nilai ' + savedResult.score + '/' + savedResult.total })
            : null
        ]),
        el('span', { class: 'method-action',
          text: savedResult && savedResult.score !== undefined ? 'Kerjakan lagi' : 'Mulai' })
      ]),
      // Metode 2: esai (jawaban disimpan, tidak dinilai otomatis).
      el('button', {
        class: 'method-card pressable', type: 'button',
        'aria-label': 'Esai',
        onclick: function () { closeSheet(); startEssayForTask(task); }
      }, [
        el('span', { class: 'method-icon', text: '✍️' }),
        el('span', { style: 'flex:1;min-width:0;text-align:left' }, [
          el('span', { class: 't-item-title', style: 'display:block', text: 'Esai' }),
          el('span', { class: 't-small', style: 'display:block',
            text: essayBank.length + ' soal · jawabanmu disimpan' }),
          essayDone ? el('span', { class: 'method-badge', text: 'Sudah dikirim' }) : null
        ]),
        el('span', { class: 'method-action', text: essayDone ? 'Lihat jawaban' : 'Mulai' })
      ]),
      el('p', {
        class: 't-small', style: 'margin:10px 0 0 0',
        text: essayDone
          ? 'Kedua metode sudah dikerjakan. Kamu bisa mengulanginya kapan saja.'
          : 'Kamu boleh mengerjakan salah satu atau keduanya. Esai tidak dinilai otomatis.'
      }),
      el('button', {
        class: 't-link pressable', type: 'button', style: 'margin-top:12px;display:block;width:100%',
        onclick: function () { closeSheet(); render(); }
      }, ['Tutup'])
    ]));
  }

  function startQuiz(task) {
    // Tugas hasil asisten membawa soalnya sendiri (cermin
    // AppState.currentQuizBank): tanpa ini soal asisten tidak pernah tampil.
    var own = task && task.questions && task.questions.length ? task.questions : null;
    state.quiz = {
      task: task,
      practice: null,
      bank: own || quizBankFor(task.subject),
      index: 0,
      choice: -1,
      checked: false,
      answers: [],
      score: 0
    };
    go('kuis');
  }

  /* Pilihan ganda sebuah latihan (metode 1). Memakai layar kuis yang sama,
     tetapi skornya disimpan di PRACTICE_RESULTS - bukan di RESULTS tugas. */
  function startPracticeQuiz(practice) {
    state.quiz = {
      task: null,
      practice: practice,
      bank: questionsForPractice(practice.subject),
      index: 0,
      choice: -1,
      checked: false,
      answers: [],
      score: 0
    };
    go('kuis');
  }

  function questionsForPractice(subject) {
    var norm = normalizeSubject(subject);
    if (typeof CURR.questionsFor === 'function') {
      return CURR.questionsFor(norm, state.religion || '');
    }
    return CURR.quizBank[norm] || CURR.quizBank['Matematika'] || [];
  }

  /* ------------------------------------------------------------------ *
   * Bagian esai sebuah tugas (metode 2)
   * Cermin AppState.startTaskEssay/submitTaskEssay: bank esai mengikuti
   * mapel tugas, jawaban disimpan ke RESULTS[task.id].essayAnswers, dan
   * skor pilihan ganda yang sudah ada tidak dihapus.
   * ------------------------------------------------------------------ */
  function startEssayForTask(task) {
    var bank = essayBankFor(task.subject);
    var saved = (RESULTS[task.id] && RESULTS[task.id].essayAnswers) || [];
    var drafts = bank.map(function (_, i) { return saved[i] || ''; });
    state.essay = {
      task: task,
      bank: bank,
      index: 0,
      drafts: drafts,
      showExample: false,
      error: ''
    };
    go('esai');
  }

  function submitTaskEssay() {
    var esai = state.essay;
    if (!esai) return;
    var answers = esai.drafts.map(function (a) { return String(a || '').trim(); });
    if (!answers.some(function (a) { return a; })) {
      esai.error = 'Tulis minimal satu jawaban esai sebelum mengirim.';
      render();
      return;
    }
    var previous = RESULTS[esai.task.id] || {};
    RESULTS[esai.task.id] = {
      score: previous.score,
      total: previous.total,
      answers: previous.answers || [],
      demo: previous.demo || false,
      studentName: state.studentName,
      className: esai.task.className,
      essayAnswers: answers,
      essayAt: new Date().toISOString()
    };
    state.essay = null;
    state.quizResult = { task: esai.task, result: RESULTS[esai.task.id] };
    go('hasil-kuis');
  }

  function renderEssay() {
    var esai = state.essay;
    if (!esai || !esai.bank.length) {
      // Tanpa data (mis. dibuka lewat deep link): tetap ada isi yang jelas,
      // jangan layar kosong.
      return el('div', {}, [
        pageHeader('Esai', null, function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); }),
        el('p', { class: 't-muted', style: 'margin-top:20px',
          text: 'Belum ada soal esai yang dibuka. Pilih tugas dari daftar Tugas, ' +
            'lalu pilih metode Esai.' })
      ]);
    }
    var pair = esai.bank[esai.index];
    var ratio = (esai.index + 1) / esai.bank.length;
    var isLast = esai.index + 1 >= esai.bank.length;

    var input = el('textarea', {
      class: 'karsa-input essay-input', rows: '5',
      placeholder: 'Tulis jawabanmu di sini...',
      'aria-label': 'Jawaban esai',
      oninput: function (e) {
        esai.drafts[esai.index] = e.target.value;
        esai.error = '';
        // Perbarui status tombol tanpa menimpa kotak yang sedang diketik.
        var btn = document.getElementById('essay-primary');
        if (btn) btn.disabled = !String(e.target.value).trim();
      }
    }, [esai.drafts[esai.index] || '']);

    return el('div', {}, [
      pageHeader(esai.task.subject + ' · Esai',
        'Soal ' + (esai.index + 1) + ' dari ' + esai.bank.length + ' · esai tugas',
        // Kembali ke daftar tugas role aktif, bukan selalu siswa.
        function () { state.essay = null; go(tasksScreenForRole()); }),
      el('div', { class: 'quiz-progress' }, [
        el('div', { class: 'quiz-progress-fill', style: 'width:' + (ratio * 100) + '%' })
      ]),
      el('p', { class: 'quiz-question', text: pair.prompt }),
      el('p', { class: 't-label', style: 'margin:0 0 8px 0', text: 'Jawabanmu' }),
      input,
      esai.showExample ? noticeCard('💡 Contoh jawaban', pair.sampleAnswer) : null,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        id: 'essay-primary',
        style: 'border:none;cursor:pointer',
        disabled: !String(esai.drafts[esai.index] || '').trim() ? true : null,
        onclick: function () {
          if (!String(esai.drafts[esai.index] || '').trim()) return;
          if (!esai.showExample) {
            esai.showExample = true;
            render();
            return;
          }
          if (isLast) { submitTaskEssay(); return; }
          esai.index += 1;
          esai.showExample = false;
          render();
        }
      }, [esai.showExample
        ? (isLast ? 'Kirim jawaban esai' : 'Soal berikutnya')
        : 'Lihat contoh jawaban']),
      esai.error ? el('p', { class: 'notice-title', style: 'margin:10px 0 0 0', text: esai.error }) : null,
      el('p', {
        class: 't-small',
        style: 'text-align:center;color:var(--muted);font-size:12px;margin-top:18px',
        text: 'Esai tidak dinilai otomatis. Jawabanmu tersimpan untuk tugas ini, ' +
          'dan kamu tetap bisa mengerjakan pilihan gandanya.'
      })
    ]);
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
    var checked = quiz.checked;
    var isLast = quiz.index + 1 >= quiz.bank.length;

    function closeQuiz() {
      var backTo = tasksScreenForRole();
      state.quiz = null;
      go(backTo);
    }

    // Tiap pilihan punya tiga keadaan: biasa, dipilih (belum diperiksa), dan
    // setelah diperiksa -> benar / salah. Label di kanan mengikuti keadaan itu,
    // seperti rancangan (Dipilih / Benar / Salah + ikon).
    var choices = q.choices.map(function (choice, i) {
      var isChosen = quiz.choice === i;
      var isAnswer = i === q.answerIndex;
      var cls = 'choice-btn pressable';
      var label = null;
      var labelIcon = null;

      if (checked) {
        if (isAnswer) {
          cls += ' correct';
          label = 'Benar';
          labelIcon = 'checkmark-circle';
        } else if (isChosen) {
          cls += ' wrong';
          label = 'Salah';
          labelIcon = 'close-circle';
        } else {
          cls += ' muted-choice';
        }
      } else if (isChosen) {
        cls += ' selected';
        label = 'Dipilih';
        labelIcon = 'checkmark-circle';
      }

      return el('button', {
        class: cls, type: 'button',
        disabled: checked ? true : null,
        onclick: function () {
          if (checked) return;
          quiz.choice = i;
          render();
        }
      }, [
        el('span', { class: 'choice-letter', text: letters[i % letters.length] }),
        el('span', { style: 'flex:1;font-size:14px;color:var(--ink);text-align:left', text: choice }),
        label ? el('span', { class: 'choice-state' }, [
          // Teks label dipisah dari ikon agar teks tetap bersih saat dibaca
          // pembaca layar maupun diuji.
          el('span', { class: 'choice-state-text', text: label }),
          el('span', { class: 'choice-state-icon', style: 'display:inline-flex' }, [icon(labelIcon, 15)])
        ]) : null
      ]);
    });

    // Petunjuk kecil di bawah pilihan saat siswa sudah memilih tapi belum
    // memeriksa: "Pilihanmu: B. Sudah yakin?" seperti rancangan.
    var hint = null;
    if (!checked && quiz.choice >= 0) {
      hint = el('div', { class: 'quiz-hint' }, [
        el('span', { style: 'display:inline-flex;color:var(--rose)' }, [icon('bulb-outline', 14)]),
        el('span', {
          text: 'Pilihanmu: ' + letters[quiz.choice % 4] + '. Sudah yakin?'
        })
      ]);
    }

    // Setelah diperiksa: kartu umpan balik benar/salah menggantikan petunjuk.
    var feedback = null;
    if (checked) {
      var ok = quiz.choice === q.answerIndex;
      feedback = el('div', { class: 'quiz-feedback ' + (ok ? 'is-correct' : 'is-wrong') }, [
        el('p', {
          class: 'quiz-feedback-title',
          text: ok
            ? '✓ Tepat! Jawabannya ' + letters[q.answerIndex % 4] + '.'
            : 'Belum tepat. Jawaban yang benar: ' +
              letters[q.answerIndex % 4] + '. ' + q.choices[q.answerIndex]
        }),
        el('p', { class: 'quiz-feedback-body', text: q.explanation })
      ]);
    }

    return el('div', {}, [
      // Header ringkas seperti rancangan: mapel + topik kecil di atas, soal ke-n
      // besar di bawah, dan tombol tutup (X) di kanan.
      el('div', { class: 'quiz-top' }, [
        // Panah kembali + tombol tutup, keduanya tetap ada: panah untuk
        // navigasi seperti layar lain, X untuk keluar cepat seperti rancangan.
        el('button', {
          class: 'back-chevron pressable', type: 'button',
          'aria-label': 'Kembali',
          onclick: closeQuiz
        }, [icon('chevron-back', 20)]),
        el('div', { style: 'flex:1;min-width:0' }, [
          el('p', {
            class: 'quiz-eyebrow',
            text: quiz.practice
              ? quiz.practice.subject + ' · ' + quiz.practice.title
              : quiz.task.subject + ' · ' + quiz.task.title
          }),
          el('p', { class: 'quiz-step', text: 'Soal ' + (quiz.index + 1) + ' dari ' + quiz.bank.length })
        ]),
        el('button', {
          class: 'quiz-close pressable', type: 'button',
          'aria-label': 'Tutup kuis',
          onclick: closeQuiz
        }, [icon('close', 18)])
      ]),
      el('div', { class: 'quiz-progress' }, [
        el('div', { class: 'quiz-progress-fill', style: 'width:' + (ratio * 100) + '%' })
      ]),
      el('p', { class: 'quiz-question', text: q.question }),
      choices,
      hint,
      feedback,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        style: 'border:none;cursor:pointer;margin-top:14px',
        disabled: !checked && quiz.choice < 0 ? true : null,
        onclick: function () {
          if (!checked) {
            if (quiz.choice < 0) return;
            quiz.checked = true;
            if (quiz.choice === q.answerIndex) quiz.score += 1;
          } else if (isLast) {
            if (quiz.practice) {
              // Latihan: skor masuk PRACTICE_RESULTS, status selesai dicatat,
              // dan nilai tugas tidak tersentuh.
              PRACTICE_RESULTS[quiz.practice.id] = {
                score: quiz.score, total: quiz.bank.length, answers: quiz.answers
              };
              PRACTICE_DONE[quiz.practice.id] = true;
              state.quiz = null;
              go('hasil-latihan');
              return;
            }
            RESULTS[quiz.task.id] = {
              score: quiz.score, total: quiz.bank.length, answers: quiz.answers, demo: quiz.task.demo
            };
            // Catat siapa yang mengumpulkan supaya muncul di daftar guru.
            recordSubmission(quiz.task, {
              score: quiz.score, total: quiz.bank.length,
              name: state.studentName, className: quiz.task.className
            });
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
      }, [checked
        ? (isLast ? 'Lihat hasil' : 'Soal berikutnya')
        : 'Periksa jawaban'])
    ]);
  }

  /* Hasil latihan: menampilkan skor pilihan ganda bila latihan dikerjakan
     lewat metode itu; esai tidak dinilai otomatis sehingga tanpa skor. */
  /* ------------------------------------------------------------------ *
   * Daftar pengumpulan tugas untuk guru
   * Menjawab "siapa saja yang sudah mengerjakan dan nilainya berapa".
   * ------------------------------------------------------------------ */
  function submissionsFor(task) {
    // Siswa nyata (roster) + hasil yang tersimpan, ditambah siswa yang
    // memang mengirim dari perangkat ini.
    var rows = (state.roster || [])
      .filter(function (r) { return task && r.className === task.className; })
      .map(function (r) {
        var res = RESULTS[task.id];
        var own = SUBMISSIONS[task.id] && SUBMISSIONS[task.id][r.id];
        return {
          id: r.id, name: r.name, className: r.className,
          score: own ? own.score : null,
          total: own ? own.total : (res && res.total) || null,
          at: own ? own.at : null
        };
      });

    // Siswa di luar roster (mis. siswa demo yang mengirim) tidak boleh hilang.
    var known = rows.map(function (r) { return r.id; });
    var extra = SUBMISSIONS[task.id] || {};
    Object.keys(extra).forEach(function (sid) {
      if (known.indexOf(sid) >= 0) return;
      var row = extra[sid];
      rows.push({
        id: sid, name: row.name || state.studentName, className: row.className || task.className,
        score: row.score, total: row.total, at: row.at
      });
    });
    return rows;
  }

  function openSubmissions(task, notification) {
    if (!task) {
      openSheet(el('div', {}, [
        el('div', { class: 'sheet-handle' }),
        el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 4px 0', text: 'Pengumpulan tugas' }),
        el('p', { class: 't-muted', text: 'Tugas tidak ditemukan di perangkat ini.' })
      ]));
      return;
    }
    var rows = submissionsFor(task);
    var done = rows.filter(function (r) { return r.score !== null && r.score !== undefined; });
    var avg = done.length
      ? Math.round(done.reduce(function (a, r) { return a + r.score; }, 0) / done.length * 10) / 10
      : null;

    var children = [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 2px 0', text: task.title }),
      el('p', { class: 't-muted', style: 'margin-bottom:12px',
        text: task.subject + ' · ' + task.className }),
      el('div', { class: 'stats-grid', style: 'margin-bottom:6px' }, [
        statCard({
          icon: 'checkmark-circle', label: 'Sudah kumpul', value: String(done.length),
          desc: 'dari ' + rows.length + ' siswa', color: 'var(--rose)', onTap: function () {}
        }),
        statCard({
          icon: 'bar-chart', label: 'Rata-rata', value: avg === null ? '—' : String(avg),
          desc: avg === null ? 'belum ada nilai' : 'dari 10', color: 'var(--blue)', onTap: function () {}
        })
      ])
    ];

    if (!rows.length) {
      children.push(noticeCard('Belum ada siswa', 'Kelas ini belum punya daftar siswa.'));
    } else {
      // Yang sudah mengumpulkan tampil lebih dulu, nilai tertinggi di atas.
      rows.sort(function (a, b) {
        var aDone = a.score !== null && a.score !== undefined;
        var bDone = b.score !== null && b.score !== undefined;
        if (aDone !== bDone) return aDone ? -1 : 1;
        if (aDone && bDone) return b.score - a.score;
        return a.name.localeCompare(b.name);
      });
      rows.forEach(function (r) {
        var submitted = r.score !== null && r.score !== undefined;
        children.push(listItemCard({
          iconEmoji: submitted ? '✅' : '⏳',
          tileColor: submitted ? '#D1F4D8' : '#F8EBEC',
          title: r.name,
          meta: submitted
            ? r.className + ' · Nilai ' + r.score + '/' + (r.total || 10) +
              (r.at ? ' · ' + createdAtId(r.at) : '')
            : r.className + ' · Belum mengumpulkan',
          status: submitted ? (r.score >= 8 ? 'Baik' : 'Perlu latihan') : 'Belum',
          onTap: function () {
            if (!submitted) return;
            // Sorot siswa yang diklik dari notifikasi.
            openStudentSubmission(task, r);
          }
        }));
      });
    }

    children.push(el('p', {
      class: 't-small', style: 'margin-top:14px',
      text: 'Nilai pilihan ganda dihitung otomatis. Esai tidak dinilai otomatis ' +
        'sehingga tidak mengubah angka di atas.'
    }));
    openSheet(el('div', {}, children));
  }

  function openStudentSubmission(task, row) {
    var esai = (SUBMISSIONS[task.id] && SUBMISSIONS[task.id][row.id] &&
      SUBMISSIONS[task.id][row.id].essayAnswers) || [];
    openSheet(el('div', {}, [
      el('div', { class: 'sheet-handle' }),
      el('h2', { class: 't-page-title', style: 'font-size:20px;margin:6px 0 2px 0', text: row.name }),
      el('p', { class: 't-muted', style: 'margin-bottom:12px',
        text: task.subject + ' · ' + task.className }),
      clayCard([
        el('p', { class: 't-overline', style: 'margin:0 0 4px 0', text: 'NILAI PILIHAN GANDA' }),
        el('p', { style: 'margin:0;font-size:30px;font-weight:800;color:var(--ink)',
          text: row.score + ' / ' + (row.total || 10) }),
        el('p', { class: 't-small', style: 'margin:4px 0 0 0',
          text: row.at ? 'Dikumpulkan ' + createdAtId(row.at) : 'Waktu pengumpulan tidak tercatat' })
      ]),
      el('p', { class: 't-section', style: 'margin:16px 0 8px 0', text: 'Jawaban esai' }),
      esai.length
        ? el('div', {}, esai.map(function (a, i) {
          return clayCard([
            el('p', { class: 't-overline', style: 'margin:0 0 4px 0', text: 'SOAL ' + (i + 1) }),
            el('p', { class: 't-item-title', style: 'margin:0', text: a || '(tidak dijawab)' })
          ]);
        }))
        : el('p', { class: 't-muted', text: 'Siswa belum mengirim jawaban esai untuk tugas ini.' })
    ]));
  }

  function renderHasilLatihan() {
    var practice = state.practiceResult || null;
    var res = practice ? PRACTICE_RESULTS[practice.id] : null;
    var back = function () {
      state.practiceResult = null;
      go(tasksScreenForRole());
    };
    if (!practice) {
      return el('div', {}, [pageHeader('Hasil latihan', null, back)]);
    }
    var total = res ? res.total : 0;
    var pct = total ? Math.round((res.score / total) * 100) : 0;
    return el('div', {}, [
      pageHeader('Hasil latihan', practice.subject + ' · ' + practice.title, back),
      el('div', { class: 'clay-soft karsa-card', style: 'text-align:center;padding:26px 18px' }, [
        el('p', { style: 'font-size:44px;margin:0', text: res ? '🎯' : '🌱' }),
        el('p', {
          class: 't-page-title', style: 'margin:8px 0 0 0',
          text: res ? 'Latihan selesai!' : 'Jawaban esai tersimpan'
        }),
        el('p', {
          class: 't-muted', style: 'margin:6px 0 0 0',
          text: res
            ? 'Pilihan ganda langsung dinilai.'
            : 'Esai tidak dinilai otomatis; jawabanmu tersimpan untuk tugas ini.'
        })
      ]),
      res ? el('div', { class: 'stats-grid', style: 'margin-top:14px' }, [
        statCard({
          icon: 'checkmark-circle', label: 'Nilai', value: res.score + '/' + total,
          desc: pct + '% benar', color: 'var(--rose)', onTap: function () {}
        }),
        statCard({
          icon: 'grid', label: 'Soal', value: String(total),
          desc: 'pilihan ganda', color: 'var(--blue)', onTap: function () {}
        })
      ]) : null,
      el('button', {
        class: 'karsa-btn clay-raised pressable', type: 'button',
        style: 'border:none;cursor:pointer;margin-top:16px', onclick: back
      }, ['Kembali ke latihan'])
    ]);
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
    var own = task && task.questions && task.questions.length ? task.questions : null;
    var bank = own || quizBankFor(task.subject);
    var total = result.total || bank.length;
    // Hasil bisa datang dari pilihan ganda, esai, atau keduanya.
    var essayAnswers = (result.essayAnswers || []).filter(function (a) {
      return String(a || '').trim();
    });
    var hasQuizScore = result.score !== undefined && result.score !== null;
    var essayOnly = !hasQuizScore && essayAnswers.length > 0;
    var essayBank = essayBankFor(task.subject);

    var children = [
      pageHeader(essayOnly ? 'Hasil esai' : 'Hasil kuis',
        task.subject + ' · ' + task.title + (result.demo ? ' · Contoh' : ''),
        function () { go(ROLE_SCREEN_PREFIX[state.role] + 'beranda'); })
    ];

    if (!essayOnly) {
      children.push(el('div', { class: 'clay-soft', style: 'margin-bottom:16px;padding:45px;text-align:center' }, [
        el('span', { style: 'font-size:45px', text: '🌟' }),
        el('p', { class: 't-result-number', style: 'margin:15px 0', text: (result.score || 0) + ' / ' + total }),
        el('p', { class: 't-section', style: 'margin:0', text: 'Bagus! Terus berlatih ya.' })
      ]));
    } else {
      children.push(el('div', { class: 'clay-soft', style: 'margin-bottom:16px;padding:32px;text-align:center' }, [
        el('span', { style: 'font-size:45px', text: '✍️' }),
        el('p', { class: 't-section', style: 'margin:12px 0 6px 0', text: 'Jawaban esai terkirim' }),
        el('p', { class: 't-small', style: 'margin:0',
          text: essayAnswers.length + ' jawaban tersimpan di perangkat ini.' })
      ]));
    }

    // Bagian esai selalu ditampilkan bila ada jawabannya.
    if (essayAnswers.length) {
      children.push(el('p', { class: 't-section', style: 'margin:0 0 10px 0', text: 'Jawaban esai' }));
      children.push(clayCard([
        el('p', { class: 't-small', style: 'margin:0',
          text: 'Esai tidak dinilai otomatis. Berikut jawaban yang kamu kirim; guru dapat memeriksanya.' }),
        el('div', {}, essayAnswers.map(function (answer, i) {
          return el('div', { style: 'margin-top:12px' }, [
            el('p', { class: 't-item-title', style: 'margin:0',
              text: (i + 1) + '. ' + (i < essayBank.length ? essayBank[i].prompt : 'Soal esai') }),
            el('p', { class: 't-muted', style: 'margin:4px 0 0 0', text: answer })
          ]);
        }))
      ]));
    }

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
    { id: 'login', label: 'Login', group: 'Umum', render: renderUnifiedLogin, nav: null },
    { id: 'login-operator', label: 'Login · Operator Sekolah', group: 'Umum', render: function () { return renderLogin('operator'); }, nav: null },
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
    { id: 'operator-beranda', label: 'Operator · Beranda', group: 'Operator Sekolah', render: renderOperatorBeranda, nav: 'operator' },
    { id: 'operator-siswa', label: 'Operator · Siswa', group: 'Operator Sekolah', render: renderOperatorSiswa, nav: 'operator' },
    { id: 'operator-kelas', label: 'Operator · Kelas', group: 'Operator Sekolah', render: renderOperatorKelas, nav: 'operator' },
    { id: 'operator-materi', label: 'Operator · Materi', group: 'Operator Sekolah', render: renderOperatorMateri, nav: 'operator' },
    { id: 'operator-media', label: 'Operator · Media', group: 'Operator Sekolah', render: renderOperatorMedia, nav: 'operator' },
    { id: 'operator-profil', label: 'Operator · Profil', group: 'Operator Sekolah', render: renderOperatorProfil, nav: 'operator' },
    { id: 'operator-tugas', label: 'Operator · Tugas', group: 'Operator Sekolah', render: renderOperatorTugas, nav: null, role: 'operator' },
    { id: 'operator-pengumuman', label: 'Operator · Pengumuman', group: 'Operator Sekolah', render: renderOperatorPengumuman, nav: null, role: 'operator' },
    { id: 'guru-pengumuman', label: 'Guru · Pengumuman', group: 'Guru', render: renderGuruPengumuman, nav: null, role: 'guru' },
    { id: 'operator-agenda', label: 'Operator · Agenda', group: 'Operator Sekolah', render: renderOperatorAgenda, nav: null, role: 'operator' },
    { id: 'operator-nilai', label: 'Operator · Nilai', group: 'Operator Sekolah', render: renderOperatorNilai, nav: null, role: 'operator' },
    { id: 'materi', label: 'Materi', group: 'Umum', render: renderMateri, nav: null },
    { id: 'notifikasi', label: 'Notifikasi', group: 'Umum', render: renderNotifikasi, nav: null },
    { id: 'kuis', label: 'Kuis', group: 'Umum', render: renderQuiz, nav: null },
    { id: 'esai', label: 'Esai', group: 'Umum', render: renderEssay, nav: null },
    { id: 'hasil-kuis', label: 'Hasil Kuis', group: 'Umum', render: renderHasilKuis, nav: null },
    { id: 'hasil-latihan', label: 'Hasil Latihan', group: 'Umum', render: renderHasilLatihan, nav: null }
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
    Kelas: 'grid', Tugas: 'book', Kalender: 'calendar', Latihan: 'albums',
    Siswa: 'person', Materi: 'book', Media: 'albums'
  };

  function navScreenFor(role, tab) {
    var prefix = ROLE_SCREEN_PREFIX[role];
    var map = {
      Beranda: prefix + 'beranda', Anggota: prefix + 'anggota', Rekap: prefix + 'recap',
      Agenda: prefix + 'agenda',
      // Operator memakai 'operator-profil'; peran lain tetap '<prefix>profil'.
      Profil: role === 'operator' ? 'operator-profil' : prefix + 'profil',
      Kelas: prefix + 'kelas',
      Tugas: prefix + 'tugas', Kalender: prefix + 'kalender', Latihan: prefix + 'latihan',
      Siswa: prefix + 'siswa', Materi: prefix + 'materi', Media: prefix + 'media'
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
    if (def.role) state.role = def.role;
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
    // Tema diganti lewat tombol di dalam layar (header sapaan), bukan dari
    // bar pengembang yang sudah dihapus.
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
  }

  /* ------------------------------------------------------------------ *
   * Boot
   * ------------------------------------------------------------------ */
  function boot() {
    applyTheme();
    restoreState();

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
        // Splash langsung ke form login: tidak ada lagi layar pilih peran.
        if (state.screen === 'splash') go('login');
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
    render: render,
    persistState: persistState,
    restoreState: restoreState,
    materials: function () { return MATERIALS; },
    tasks: function () { return TASKS; },
    visiblePractices: visiblePractices,
    results: function () { return RESULTS; },
    announcements: function () { return ANNOUNCEMENTS; },
    notifications: function () { return NOTIFICATIONS; },
    visibleAnnouncements: visibleAnnouncements,
    submissionsFor: submissionsFor,
    seedRoster: buildRoster,
    openSubmissions: openSubmissions,
    subjectsForClass: subjectsForClass,
    startQuiz: startQuiz,
    startEssayForTask: startEssayForTask,
    startPracticeQuiz: startPracticeQuiz,
    openPractice: openPractice,
    closeSheet: closeSheet,
    practiceResults: function () { return PRACTICE_RESULTS; },
    practiceDone: function () { return PRACTICE_DONE; },
    operator: {
      classNames: operatorClassNames,
      classOptions: operatorClassOptions,
      subjectsForClass: subjectsForClass,
      rosterScores: state.rosterScores
    }
  };
})();
