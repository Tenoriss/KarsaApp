# KarsaApp — Flutter

Migrasi penuh aplikasi **KarsaApp** (SD Karitas Purwokerto) dari
**React Native / Expo** ke **Flutter / Dart**.

Kode React Native asli **tetap utuh di root repository** (`App.js`,
`curriculum.js`, `gradeReports.js`, `assets/`) sebagai rujukan audit.
Semua kode Flutter berada di folder `karsa_app/` ini.

> **Status penting.** Proyek ini dibuat dan diverifikasi di lingkungan yang
> **tidak memiliki Flutter/Dart SDK**. Karena itu `flutter analyze` dan
> `flutter test` **belum pernah dijalankan** — lihat
> [`docs/03_TESTING_PLAN.md`](docs/03_TESTING_PLAN.md) untuk daftar persis
> apa yang sudah dan belum diverifikasi.

---

## Daftar isi

1. [Menjalankan](#menjalankan)
2. [Akun demo](#akun-demo)
3. [Struktur proyek](#struktur-proyek)
4. [Arsitektur singkat](#arsitektur-singkat)
5. [Penyimpanan data](#penyimpanan-data)
6. [Kurikulum](#kurikulum)
7. [Pratinjau HTML](#pratinjau-html)
8. [Dokumentasi](#dokumentasi)
9. [Fitur yang sudah dimigrasikan](#fitur-yang-sudah-dimigrasikan)
10. [Yang belum terverifikasi](#yang-belum-terverifikasi)

---

## Menjalankan

### Aplikasi Flutter

```bash
cd karsa_app

# 1. Siapkan platform (butuh Flutter SDK >= 3.3):
flutter create --platforms=android,ios .

# 2. Ambil dependensi
flutter pub get

# 3. Periksa & uji
flutter analyze
flutter test

# 4. Jalankan
flutter run
```

Target SDK: **Dart `>=3.3.0 <4.0.0`**, Flutter 3.19+ (stabil).

### Pratinjau HTML (tanpa Flutter)

```bash
cd karsa_app/preview
python3 serve.py --host 0.0.0.0 --port 8000
# buka http://127.0.0.1:8000
```

Pratinjau berisi **28 layar** interaktif, sepenuhnya offline (tanpa CDN), dan
memakai aset PNG asli serta font `Ionicons.ttf` yang sama dengan aplikasi.
Detail: [`preview/README.md`](preview/README.md).

### Generator & pemeriksa

```bash
# Regenerasi bank soal Dart dari curriculum.js
python3 karsa_app/tool/generate_curriculum.py

# Regenerasi data pratinjau dari curriculum.js
node karsa_app/tool/generate_preview_data.js

# Validasi statis seluruh kode Dart
python3 karsa_app/tool/check_syntax.py

# Uji perilaku pratinjau (mock DOM, tanpa browser)
node karsa_app/preview/test_preview.js
```

---

## Akun demo

> Akun **demo lokal** untuk mencoba aplikasi. **Tidak ada backend, tidak ada
> autentikasi server, dan bukan keamanan produksi.**

| Peran | NIP / NISN | Kata sandi | Lingkup |
| --- | --- | --- | --- |
| Wali Kelas | `19870001` | `wali123` | Hanya `Kelas 1`; tab Beranda, Anggota, Rekap (Kehadiran/Nilai), Agenda, Profil |
| Guru Mata Pelajaran | `19870002` | `guru123` | NIP, Ibu Sari, default `Matematika`, Kelas 1–6; tab Beranda, Kelas, Tugas, Kalender, Profil; rekap nilai + ekspor `.xlsx`/`.pdf` |
| Orang Tua/Wali | `10010001` | `ortu123` | NISN, Dimas Nugroho, Kelas 1–4; tab Beranda, Tugas, Latihan, Profil; Ruang Tumbuh, bintang progres, mood |
| Siswa | `10050001` | `siswa123` | NISN, Dimas Nugroho, Kelas 5–6; tab Beranda, Tugas, Profil; 9 mata pelajaran, IPAS hanya Kelas 3–6, soal pertama Pendidikan Agama menyesuaikan agama |

---

## Struktur proyek

```
karsa_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── .gitignore                  # mengabaikan preview/assets/ + artefak build
├── assets/
│   ├── images/                 # 6 PNG asli (logo, splash art, banner)
│   └── fonts/Ionicons.ttf      # 27 glif ikon (identik dengan @expo/vector-icons)
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── theme/              # app_colors, dark_color_mapper, clay_styles,
│   │   │                       # app_typography, karsa_theme
│   │   ├── utils/              # date_utils, offline_summarizer
│   │   └── widgets/            # 15 widget claymorphism reusable
│   ├── models/                 # 15 model domain
│   ├── services/               # storage, attachment, file_bridge, export
│   ├── providers/app_state.dart
│   ├── data/                   # curriculum_data.dart, seed_data.dart
│   ├── shared/widgets/         # main_shell, greeting_header, detail_bottom_sheet
│   └── features/
│       ├── splash/  authentication/  dashboard/  homeroom/  teacher/
│       ├── tasks/  quizzes/  materials/  grades/  calendar/
│       └── announcements/  student/  settings/
├── test/                       # 4 berkas uji Flutter
├── tool/                       # generator + check_syntax.py
├── preview/                    # pratinjau HTML 28 layar
└── docs/                       # 01–03
```

---

## Arsitektur singkat

* **State** — `AppState extends ChangeNotifier` (`lib/providers/app_state.dart`)
  Managing seluruh state aplikasi: peran aktif, tab, filter, data tugas/materi/hasil,
  kehadiran, nilai, agenda, notifikasi, mode gelap. Semua diakses via `provider`.
* **Shell** — `MainShell` (`lib/shared/widgets/main_shell.dart`) membangun
  `ConstrainedBox(maxWidth: 480)`, memilih tab bottom nav sesuai peran, dan
  menampilkan layar sebagai `taskDetail`/`practiceDetail` bottom sheet modal.
* **Tema** — `KarsaThemeScope` menyediakan palet terang/gelap; `ClayStyles`
  menyediakan tiga varian permukaan (`soft`, `raised`, `inset`);
  `DarkColorMapper` memetakan permukaan & teks pastel ke palet gelap
  (port 1:1 dari `makeDarkStyle` RN).
* **Icon** — `KarsaIcons` memetakan 27 nama ikon ke codepoint `Ionicons.ttf`.
* **Navigasi** — berbasis state (`AppState.setScreen` / `changeTab`), bukan
  package router, agar perilakunya identik dengan RN dan mudah diaudit.

---

## Penyimpanan data

* Backend: **tidak ada**. Seluruh data lokal (offline-first).
* Kunci: **`@karsa-demo-v1`** (satu string JSON di `SharedPreferences`).
* Skema kompatibel 1:1 dengan `AsyncStorage` versi React Native sehingga data
  lama tetap terbaca.

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

**Migrasi & ketahanan:** JSON rusak → kembali ke default (tidak crash);
subjek legacy `"IPA"` → `"Ilmu Pengetahuan Alam dan Sosial (IPAS)"`;
tugas/hasil demo yang hilang otomatis di-seed ulang; kegagalan penyimpanan
ditampilkan sebagai banner, bukan dialog memblokir.

---

## Kurikulum

`lib/data/curriculum_data.dart` (dihasilkan `tool/generate_curriculum.py`
dari `curriculum.js`):

* **9 mata pelajaran** lengkap dengan ikon & warna;
* **10 soal pilihan ganda + 5 latihan esai per mata pelajaran**;
* **6 adaptasi agama** (Islam, Kristen, Katolik, Hindu, Buddha, Konghucu) pada
  soal & latihan pertama Pendidikan Agama;
* `subjectsForClass()` — IPAS hanya untuk kelas 3–6.

Jumlah soal dan kunci jawaban **tidak dikurangi maupun diubah** dari
`curriculum.js`.

---

## Pratinjau HTML

`karsa_app/preview/` — 28 layar HTML interaktif, **tanpa dependensi CDN**,
mobile-first (`100dvh` di ponsel, kolom `480px` di layar lebar,
`env(safe-area-inset-*)`), **bukan** mock bingkai ponsel.

```bash
python3 karsa_app/preview/serve.py --host 0.0.0.0 --port 8000
curl http://127.0.0.1:8000/healthz
node karsa_app/preview/test_preview.js    # 158 pemeriksaan, mock DOM
```

---

## Dokumentasi

| Berkas | Isi |
| --- | --- |
| [`docs/01_AUDIT_MAPPING.md`](docs/01_AUDIT_MAPPING.md) | Audit RN → pemetaan Flutter: 41 tampilan, widget, data, alur, dependensi |
| [`docs/02_IMPLEMENTATION_REPORT.md`](docs/02_IMPLEMENTATION_REPORT.md) | Laporan implementasi per tahap + kendala + keputusan teknis |
| [`docs/03_TESTING_PLAN.md`](docs/03_TESTING_PLAN.md) | Apa yang sudah diverifikasi, rencana uji manual, matriks acceptance |
| [`preview/README.md`](preview/README.md) | Cara memakai pratinjau, daftar 28 layar, interaksi |

---

## Fitur yang sudah dimigrasikan

| Area | Detail |
| --- | --- |
| Identitas | Splash (#A2D7FB + ilustrasi asli, 2300 ms), logo & teks SD Karitas Purwokerto, banner siswa & guru |
| Autentikasi | Pemilihan peran, login 4 peran (NIP/NISN + kata sandi + tombol mata), lupa kata sandi, logout, validasi dengan pesan galat yang sama |
| Dashboard | 4 dashboard berbeda sesuai peran (tanpa menyatukan menjadi halaman generik) |
| Tugas | Daftar, filter kelas/mapel, pencarian, deadline & countdown, status, lampiran, form tambah tugas |
| Materi | Daftar, detail, form unggah, filter per kelas/mapel |
| Kuis & latihan | Bank soal 9 mapel, pilihan ganda, soal esai, navigasi soal, periksa jawaban, skor, riwayat |
| Kehadiran & nilai | Rekap kehadiran per tanggal (Hadir/Izin/Sakit/Alpa), input nilai 0–100, rata-rata kelas, rekap nilai per kelas |
| Ekspor | `.xlsx` dan `.pdf` rekap nilai (judul kolom 1:1 dengan `gradeReports.js`) |
| Kalender & agenda | `MonthCalendar`, agenda kelas, form agenda, daftar agenda |
| Pengumuman & notifikasi | Daftar pengumuman, detail, status dibaca/belum, notifikasi lokal |
| Pengaturan | Profil per peran, informasi pribadi, mata pelajaran, tampilan, notifikasi, privasi, pusat bantuan, keluar akun |
| Mode gelap | Palet gelap penuh dengan `DarkColorMapper`, tersimpan di `@karsa-demo-v1` |
| Lenyap | Offline-first, tanpa backend, catatan demo yang jujur di UI |

---

## Yang belum terverifikasi

* `flutter analyze` dan `flutter test` **belum dijalankan** (SDK tidak ada di
  lingkungan pembuatan). Empat berkas uji sudah siap di `karsa_app/test/`.
* Uji visual di perangkat iOS/Android nyata belum dilakukan.
* Pembukaan berkas ekspor `.xlsx`/`.pdf` di perangkat belum diuji.
* Perilaku `file_picker` di iOS belum diuji.

---

## Lisensi & atribusi

Aset logo, ilustrasi splash, dan banner berasal dari repository asli KarsaApp
dan dipakai apa adanya. Font `Ionicons.ttf` diambil dari paket
`@expo/vector-icons@15.0.2` (MIT).
