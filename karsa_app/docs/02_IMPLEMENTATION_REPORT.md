# Laporan Implementasi — Migrasi KarsaApp React Native → Flutter

> Proyek: **KarsaApp** — SD Karitas Purwokerto
> Sumber: React Native / Expo (`App.js` ±5.543 baris, `curriculum.js`, `gradeReports.js`, `assets/*.png`)
> Target: Flutter / Dart modular di `karsa_app/`
> Branch: `arena/efada06a-karsaapp`
> Tanggal: 14 November 2026

---

## 1. Ringkasan Eksekutif

Aplikasi React Native/Expo KarsaApp telah dipindahkan ke proyek Flutter/Dart yang
terpisah di `karsa_app/`, **tanpa menghapus, mengubah, atau memindahkan satu
pun berkas sumber React Native di root repository**. Kode RN tetap tersedia
sebagai rujukan audit dan perbandingan visual.

| Aspek | Sebelum (RN) | Sesudah (Flutter) |
| --- | --- | --- |
| Bahasa | JavaScript | Dart |
| Penyimpanan | `@react-native-async-storage/async-storage` (`@karsa-demo-v1`) | `shared_preferences` (`@karsa-demo-v1`, JSON identik) |
| State | `useState` + `useEffect` di satu `App.js` | `provider` + `ChangeNotifier` (`AppState`) |
| Navigasi | state `screen`/`tab` manual | `MainShell` + router berbasis state, satu sumber kebenaran |
| Aset | `assets/*.png` | `karsa_app/assets/images/*.png` (salinan identik) |
| Ikon | `@expo/vector-icons` Ionicons | Font `Ionicons.ttf` + `KarsaIcons` (27 codepoint) |
| Bank soal | `curriculum.js` | `lib/data/curriculum_data.dart` (generate 1:1) |
| Pratinjau | — | `karsa_app/preview/` — 28 layar HTML interaktif, offline |

**Skala implementasi**

| Komponen | Jumlah | Baris |
| --- | --- | --- |
| Berkas Dart (`lib/` + `test/`) | 98 | 11.294 |
| Top-level class / enum / mixin | 107 | — |
| Layar/tab Flutter (`lib/features/`) | 42 berkas | 5.480 |
| Widget reusable (`lib/core/widgets/`) | 15 | — |
| Model domain (`lib/models/`) | 15 | 925 |
| Pratinjau HTML (`preview/`) | 7 berkas | 6.228 (JS/CSS/HTML/Python) |

---

## 2. Tahap 1 — Audit

Hasil lengkap ada di [`01_AUDIT_MAPPING.md`](01_AUDIT_MAPPING.md). Ringkasan:

* **41 tampilan** pada state `screen` RN dipetakan ke 42 widget Flutter
  (layar RN `taskDetail`/`practiceDetail` menjadi bottom sheet modal di
  `lib/shared/widgets/main_shell.dart`).
* **5 tab** untuk masing-masing peran dipetakan ke `MainShell` role-aware.
* **27 ikon Ionicons** dipakai di `App.js` diekstrak menjadi tabel codepoint
  (`lib/core/widgets/karsa_icons.dart`) memakai font `Ionicons.ttf` dari
  `@expo/vector-icons@15.0.2` (389.724 byte, identik dengan berkas RN).
* **21 kunci penyimpanan** pada `@karsa-demo-v1` dipetakan ke
  `KarsaStoreData` (15 model domain + 1 aggregate).

---

## 3. Tahap 2 — Persiapan Flutter

### 3.1 Struktur

```
karsa_app/
├── pubspec.yaml            # provider, shared_preferences, excel, pdf, dll.
├── analysis_options.yaml   # prefer_const_*: false (gaya RN dipertahankan)
├── README.md
├── .gitignore              # mengabaikan preview/assets/ + artefak build
├── assets/
│   ├── images/             # 6 PNG asli (salin byte-identik)
│   └── fonts/Ionicons.ttf
├── lib/
│   ├── main.dart           # entrypoint + error handler
│   ├── app.dart            # MaterialApp light/dark + KarsaThemeScope
│   ├── core/
│   │   ├── constants/      # app_constants.dart
│   │   ├── theme/          # app_colors, dark_color_mapper, clay_styles,
│   │   │                   # app_typography, karsa_theme
│   │   ├── utils/          # date_utils, offline_summarizer
│   │   └── widgets/        # 15 widget claymorphism reusable
│   ├── models/             # 15 model domain
│   ├── services/           # storage, attachment, file_bridge, export
│   ├── providers/          # app_state.dart (ChangeNotifier)
│   ├── data/               # curriculum_data.dart, seed_data.dart
│   ├── shared/widgets/     # main_shell, greeting_header, detail_bottom_sheet
│   └── features/           # splash, authentication, dashboard, homeroom,
│                           # teacher, tasks, quizzes, materials, grades,
│                           # calendar, announcements, student, settings
├── test/                   # 4 berkas uji
├── tool/                   # generator kurikulum & ikon, check_syntax.py
├── preview/                # pratinjau HTML 28 layar
└── docs/                   # 01–03
```

### 3.2 Ketergantungan

| Package | Versi | Peran |
| --- | --- | --- |
| `provider` | `^6.1.2` | State management (`ChangeNotifier`) |
| `shared_preferences` | `^2.3.2` | Penyimpanan lokal `@karsa-demo-v1` |
| `file_picker` | `^8.1.2` | Pemilihan lampiran tugas/materi |
| `path_provider` | `^2.1.4` | Direktori sementara untuk ekspor |
| `share_plus` | `^7.2.2` | Berbagi hasil ekspor (`Share.shareXFiles`) |
| `open_filex` | `^4.5.0` | Membuka file ekspor |
| `pdf` | `^3.11.1` | Ekspor PDF rekap nilai |
| `excel` | `^4.0.6` | Ekspor XLSX rekap nilai |

> Versi `share_plus` sengaja ditahan di `^7.2.2` (yang masih menyediakan
> `Share.shareXFiles`) agar konsisten dengan batas SDK `>=3.3.0 <4.0.0`.
> Tidak ada package lain yang ditambahkan; seluruh format tanggal dilakukan
> manual di `lib/core/utils/date_utils.dart` sehingga `intl` tidak diperlukan.

Tidak ada package yang tidak dipakai. Tidak ada backend, tidak ada API jaringan.

### 3.3 Token desain (1:1 dengan `App.js`)

**Palet terang** — ink `#203E5A`, muted `#8294A3`, rose `#B1445D`, pink `#C8526D`,
line `#EFDFD9`, bg `#FFFAF7`, card `#FFFDFB`, blue `#6E9CC3`.
**Palet gelap** — ink `#F3EAF0`, muted `#BBC0CA`, rose `#F09AB0`, pink `#D56B85`,
line `#4B4049`, bg `#211D27`, card `#302832`, blue `#85B2D1`.

**Claymorphism**

| Varian | Radius | Border | Bayangan |
| --- | --- | --- | --- |
| `soft` | 23 | putih 88% · 2px | `0 6 20 rgba(185,157,163,.17)` |
| `raised` | 20 | putih 55% · 2px | `0 7 18 rgba(167,126,136,.24)` |
| `inset` | 14 | `#F1E5E2` · 2px | tanpa bayangan |

**DarkColorMapper** (`lib/core/theme/dark_color_mapper.dart`) adalah port 1:1
dari `makeDarkStyle` RN:

* permukaan pastel → `#493640` (rose), `#34414E` (biru), `#332D36` (netral);
* teks pastel → `#F2A9BC` (rose) / `#EEE7ED` (netral);
* border gelap `#554A54`, bayangan `#08070A`.

**Tipografi** (`app_typography.dart`): brand 16/900 ls2 · name 20/800 ·
pageTitle 24/800 · section 18/800 · itemTitle 14/700 · muted 13 · small 11 ·
link 12/700 · overline 10/800 ls1 · badge 10/700 · statNumber 23/800 ·
button 14/800 putih · resultNumber 52/900.

**Shell**: `ConstrainedBox(maxWidth: 480)`, latar `#F4EDE9`, padding konten
20/30, bottom nav 76px latar `#FFFAF8` border atas 2px putih + soft shadow,
label 10px.

---

## 4. Tahap 3–6 — Komponen, autentikasi, dashboard, fitur

### 4.1 Komponen dasar (`lib/core/widgets/`, 15 widget)

`ClayCard`, `StatCard` + `WideStatCard`, `ListItemCard`, `NoticeCard`,
`KarsaButton`, `KarsaInput`, `KarsaChips`, `KarsaSegmentTabs`, `PageHeader`,
`SchoolIdentity`, `MonthCalendar`, `ChartRow`, `RoundIconButton`,
`MotionPressable` (scale 0.965 + semantics), `KarsaIcons`.

### 4.2 Autentikasi

Alur: `SplashPage` (2300 ms) → `WelcomePage` (pilih peran) → `LoginPage`
(per peran) → `MainShell` sesuai peran. `ForgotPasswordPage` menampilkan
informasi akun demo.

Validasi memakai `AppState.authenticate()`; pesan galat persis sama dengan RN:

```
NIP/NISN atau kata sandi tidak sesuai.
```

| Peran | NIP/NISN | Kata sandi | Label |
| --- | --- | --- | --- |
| Wali Kelas | `19870001` | `wali123` | Wali kelas |
| Guru Mata Pelajaran | `19870002` | `guru123` | Guru mata pelajaran |
| Orang Tua/Wali | `10010001` | `ortu123` | Orang tua / wali |
| Siswa | `10050001` | `siswa123` | Siswa kelas 5–6 |

> Akun demo **bukan** autentikasi produksi. Tidak ada backend, tidak ada
> verifikasi server, dan aplikasi menampilkan catatan tersebut secara terbuka di
> several layar (login, dashboard wali, notifikasi).

### 4.3 Dashboard per peran

| Peran | Beranda | Tab |
| --- | --- | --- |
| Wali Kelas | SchoolIdentity compact, greeting "Selamat datang, Wali Kelas" (Ibu Sari), hero `#F9EBEE` "Tumbuh bersama, Kelas 1 🌱", 2 StatCard (Anggota kelas / Hadir hari ini), AttendanceOverviewCard 4 ChartRow (`#78B995`/`#79A6CD`/`#C58AAD`/`#CD6C7D`), kartu rata-rata nilai 📊, pintasan agenda, catatan demo | Beranda · Anggota · Rekap · Agenda · Profil |
| Guru | Greeting "Selamat datang," + banner 125px radius 22, chip "Semua kelas"+Kelas 1–6, 2 StatCard, 3 WideStatCard (Latihan/Pengumuman/Materi), "Tugas Terbaru" | Beranda · Kelas · Tugas · Kalender · Profil |
| Siswa | Greeting "Halo, selamat belajar!", StudentHero `#F9E5E9` minH 160, MissionCard 🎯 + progress 8px `#F3E8E6`→`#C8526D`, 2 StatCard, WideStatCard materi, 9 baris tugas per mata pelajaran, TipCard `#EEF5F9` | Beranda · Tugas · Profil |
| Orang Tua | Greeting "Orang tua dari" + avatar "D", banner siswa, 2 StatCard, kartu "RUANG TUMBUH · Perjalanan belajar ✨" `#F8EDF0`, WideStatCard pengumuman & materi, "Tugas untukmu" | Beranda · Tugas · Latihan · Profil |

Profil memiliki 4 varian (wali / guru / siswa / orang tua): avatar 84 radius 42
`#F4E4E7`, badge `#F9E6EA`.

### 4.4 Fitur utama

* **Tugas** — `tasks_tab.dart`: pencarian, chip mata pelajaran (siswa),
  segmen `Aktif/Riwayat` (siswa, orang tua) atau `Semua/Berjalan/Selesai`
  (guru), tombol tambah tugas, NoticeCard, pengelompokan per mata pelajaran
  dengan overline.
* **Materi** — `materials_page.dart` (+ detail & form), filter per kelas/mapel.
* **Kuis** — `quiz_page.dart`: progres soal, pilihan A–D, periksa jawaban,
  penjelasan, skor; `quiz_result_page.dart`: kartu skor 52/900 +
  rincian per soal.
* **Latihan** — `practice_list_tab.dart` (5 soal esai per mata pelajaran),
  `essay_practice_page.dart`, `practice_result_page.dart`.
* **Kehadiran & nilai** — `wali_recap_tab.dart` dengan segmen
  Kehadiran/Nilai, tombol status Hadir/Izin/Sakit/Alpa radius 12 `#F7EEED`,
  input nilai 0–100, `ChartRow` rata-rata.
* **Agenda & kalender** — `wali_agenda_tab.dart`, `calendar_tab.dart`,
  `MonthCalendar` (Sen–Min), form agenda.
* **Pengumuman & notifikasi** — `announcements_page.dart`,
  `notifications_page.dart` dengan status Dibaca/Baru.
* **Pengaturan** — `profile_tab.dart` + `setting_detail_page.dart`
  (Informasi pribadi, Mata pelajaran, Tampilan, Notifikasi, Privasi dan
  keamanan, Pusat bantuan), keluar akun demo.
* **Perbaikan tombol role siswa (perubahan terbaru)** — notifikasi siswa kini
  bisa diklik: item ditandai "Dibaca" dan lembar detail tugas/materinya
  langsung dibuka (sebelumnya hanya menandai `read` tanpa efek terlihat).
  Notifikasi dan materi kini dibatasi pada kelas belajar masing-masing
  (siswa: kelasnya, orang tua: kelas anaknya), dan data seed materi untuk
  kelas 5-6 ditambahkan supaya kartu "Materi kelas" tidak lagi nol. Mock DOM
  pada harness kini meniru *event bubbling* seperti browser sehingga tombol
  mati tidak lagi tertutupi.
* **Profil siswa (perubahan terbaru)** — kartu **Informasi pribadi** yang bisa
  diedit langsung (ikon pensil "Ubah informasi" pada hero profil, kartu
  "Data pribadi" berisi Nama, Kelas, NISN, Agama, dan tombol "Ubah"), plus
  section **Nilai kelas**: rata-rata kelas dan nilai per mata pelajaran
  (ikon mapel, nama lengkap, bar nilai, jumlah tugas yang dinilai) beserta
  empty state yang jujur bila belum ada nilai. Data disimpan ke
  `@karsa-demo-v1` lewat `savePersonalInfo()`.
* **Rekap nilai + ekspor** — `grade_recap_page.dart` +
  `grade_export_service.dart` (lihat §5.3).

### 4.5 Kurikulum

`lib/data/curriculum_data.dart` dihasilkan oleh `tool/generate_curriculum.py`
dari `curriculum.js`:

* 9 mata pelajaran dengan ikon & warna;
* 10 soal pilihan ganda + 5 latihan esai **per mata pelajaran**;
* `subjectsForClass()` menyembunyikan IPAS untuk kelas 1–2 (hanya kelas 3–6);
* 6 adaptasi agama pada soal & latihan pertama Pendidikan Agama
  (Islam, Kristen, Katolik, Hindu, Buddha, Konghucu) — `faithExamples`;
* normalisasi subjek legacy `"IPA"` → `"Ilmu Pengetahuan Alam dan Sosial (IPAS)"`.

**Jumlah soal dan jawaban benar tidak dikurangi maupun diubah.**

---

## 5. Tahap 7 — Penyimpanan dan ekspor

### 5.1 Skema penyimpanan (1:1 dengan AsyncStorage)

Kunci: **`@karsa-demo-v1`**. Isi: satu string JSON.

```json
{
  "tasks": [], "customPractices": [], "results": {}, "practiceDone": {},
  "announcements": [], "readAnnouncements": [], "teacherName": "Ibu Sari",
  "waliName": "Ibu Sari", "studentName": "Dimas Nugroho", "notifications": true,
  "reviewed": [], "childClass": "Kelas 1", "parentClass": "Kelas 1",
  "studentClass": "Kelas 5", "teacherSubject": "Matematika", "religion": "",
  "mood": null, "darkMode": false, "attendance": {}, "classScores": {},
  "classEvents": [], "materials": [], "localNotifications": [],
  "readNotifications": {}
}
```

### 5.2 Migrasi & ketahanan data

`StorageService.load()`:

1. membaca string pada `@karsa-demo-v1`;
2. Jika JSON rusak / bukan map → kembali ke default (tidak crash, tidak kehilangan app);
3. `KarsaStoreData.fromSavedJson()` menormalisasi subjek legacy `"IPA"`,
   men_seed ulang tugas demo & hasil demo yang hilang, dan memetakan tanggal
   ISO-8601;
4. `save()` menulis ulang seluruh state sebagai satu string JSON.

Tidak ada data yang dihapus saat aplikasi ditutup. Kegagalan penyimpanan
ditampilkan sebagai banner (`MainShell`), bukan dialog yang memblokir.

### 5.3 Ekspor berkas

* `grade_export_service.dart` — `buildExcelBytes()` menghasilkan `.xlsx` asli
  (package `excel`, sheet "Rekap Nilai", lebar kolom, baris ringkasan), dan
  `buildPdfBytes()` menghasilkan PDF valid 842×595 pt landscape (package `pdf`).
  Judul kolom persis sama dengan `gradeReports.js`.
* `attachment_service.dart` + `file_bridge.dart` — pemilihan lampiran melalui
  `file_picker`, penyimpanan di direktori aplikasi (`path_provider`), dibuka
  kembali dengan `open_filex`, dibagikan dengan `share_plus`.

---

## 6. Tahap 8 — Pengujian

Karena lingkungan ini **tidak memiliki Flutter/Dart SDK**, `flutter analyze`
dan `flutter test` **tidak pernah dijalankan** dan tidak diklaim berhasil.
Pemeriksaan yang dilakukan:

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Sintaks & struktur Dart | `python3 karsa_app/tool/check_syntax.py` | OK — 98 berkas, 11.294 baris, 107 class/enum/mixin; semua import, aset, dan referensi member resolve |
| Uji unit Flutter (disiapkan, belum dieksekusi) | `flutter test` | **Tidak dijalankan** — SDK tidak tersedia (termasuk uji baru: ringkasan nilai kelas + pengeditan data pribadi) |
| Sintaks JS pratinjau | `node --check` | OK untuk `app.js`, `curriculum-data.js`, `test_preview.js`, `tool/generate_preview_data.js` |
| Perilaku pratinjau (mock DOM) | `node karsa_app/preview/test_preview.js` | OK — 206 pemeriksaan lulus |
| Server pratinjau | `curl http://127.0.0.1:8000/...` | OK — `/healthz` 200, HTML/CSS/JS 200 + charset utf-8, 6 PNG 200, `Ionicons.ttf` 200, 404 untuk berkas tak dikenal |

Rencana uji lengkap: [`03_TESTING_PLAN.md`](03_TESTING_PLAN.md).

---

## 7. Tahap 9 — Pratinjau HTML (`karsa_app/preview/`)

Pratinjau HTML interaktif 28 layar dibuat agar tampilan dan alur dapat
diperiksa **tanpa Flutter** dan **tanpa browser automation**.

* **Mobile-first**: `100dvh` pada ponsel, kolom `480px` pada layar lebar,
  `env(safe-area-inset-*)`; **bukan** mock bingkai ponsel.
* **Tanpa CDN**: seluruh aset diambil dari `karsa_app/assets/` lewat rute
  `/assets/...` milik `serve.py`.
* **Bar atas** hanya berisi dropdown pemilih layar + tombol mode gelap
  (tanpa label "Pratinjau").
* **28 layar**: splash, pilih peran, 4 login, lupa kata sandi, 5 tab wali,
  5 tab guru, 3 tab siswa, 4 tab orang tua, materi, notifikasi, kuis, hasil kuis.
* **Interaksi hidup**: input NIP/NISN + kata sandi asli dengan tombol mata dan
  submit Enter, validasi per peran dengan pesan galat RN, kotak akun demo
  berbeda per peran, bottom nav per peran, chip kelas/mapel + segmen +
  pencarian, tombol status kehadiran, kartu tips berganti, kuis interaktif,
  toggle mode gelap, deep link hash (`#guru-tugas`, `#wali-recap`, alias
  `#wali-rekap`).
* `serve.py`: server statis tanpa cache, MIME UTF-8, `/healthz`, opsi
  `--host 0.0.0.0 --port`.

---

## 8. Kendala & keputusan teknis

1. **Tidak ada Flutter/Dart SDK di lingkungan kerja.** Semua perkiraan
   kompilasi divalidasi secara statis (`tool/check_syntax.py`) dan melalui
   4 berkas uji Flutter yang siap dijalankan di mesin yang memiliki SDK.
2. **Font ikon.** `@expo/vector-icons` tidak bisa dipakai di Flutter; font
   `Ionicons.ttf` diambil dari paket npm yang sama (15.0.2) sehingga glyph
   identik, lalu codepoint-nya dibekukan di `KarsaIcons`.
3. **State management.** RN memusatkan state di satu `App.js`; dipindahkan ke
   `AppState` (`ChangeNotifier`) + `provider` supaya setiap layar cukup
   `context.watch<AppState>()` dan tidak ada logika di dalam `main.dart`.
4. **Bottom sheet vs halaman.** `taskDetail` dan `practiceDetail` pada RN
   adalah modal; agar konsisten dengan Android/iOS, keduanya menjadi
   `DetailBottomSheet` di dalam `MainShell` (bukan route terpisah).
5. **Ekspor XLSX/PDF.**RN memakai `xlsx` + `jspdf`; Flutter memakai paket
   `excel` + `pdf`. Format keluaran (judul kolom, isi, ukuran PDF) dipertahankan
   1:1, namun **pembuatan file hanya dapat diverifikasi di perangkat** —
   lingkungan ini tidak dapat menjalankan kode Dart.
6. **Notifikasi.** RN memakai `expo-notifications` untuk push; tidak ada backend
   push di aplikasi ini. Flutter hanya memakai notifikasi lokal (in-app)
   sehingga catatan "bukan push notification" tetap jujur.
7. **Pratinjau bukan aplikasi.** HTML preview hanya memvisualkan alur, token,
   dan isi soal; tidak menggantikan aplikasi Flutter.

---

## 9. Yang **belum** terverifikasi (jujur)

* `flutter analyze` dan `flutter test` **tidak pernah dijalankan** — tidak ada
  SDK di lingkungan ini. Empat berkas uji di `test/` sudah ditulis dan siap
  dijalankan di mesin ber-SDK.
* Uji visual per perangkat (iOS/Android nyata) belum dilakukan.
* Pembukaan file ekspor `.xlsx`/`.pdf` di aplikasi native belum diuji di
  perangkat.
* Perilaku `file_picker` pada iOS belum diuji.

---

## 10. Berkas yang Dibuat / Diubah

**Dibuat (baru, tidak menyentuh berkas RN):**

```
karsa_app/pubspec.yaml
karsa_app/analysis_options.yaml
karsa_app/.gitignore
karsa_app/README.md
karsa_app/assets/images/*.png                 (6 berkas, salinan)
karsa_app/assets/fonts/Ionicons.ttf
karsa_app/lib/**                               (94 berkas Dart)
karsa_app/test/*.dart                          (4 berkas)
karsa_app/tool/{extract_ionicons.py,generate_curriculum.py,generate_preview_data.js,check_syntax.py}
karsa_app/preview/{index.html,styles.css,app.js,curriculum-data.js,serve.py,README.md,test_preview.js}
karsa_app/docs/{01_AUDIT_MAPPING.md,02_IMPLEMENTATION_REPORT.md,03_TESTING_PLAN.md}
```

**Diubah:** tidak ada berkas sumber React Native di root repository yang
diubah, dipindah, atau dihapus.
