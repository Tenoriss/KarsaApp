# 01 — Audit & Pemetaan Migrasi KarsaApp (React Native/Expo → Flutter)

Dokumen ini merangkum audit menyeluruh atas kode sumber asli repositori `Tenoriss/KarsaApp` (`App.js` 5.543 baris, `curriculum.js`, `gradeReports.js`, `app.json`, `package.json`, `README.md`, serta `assets/`) sebagai acuan 1:1 untuk migrasi ke Flutter di `karsa_app/`.

---

## 1. Daftar Halaman & Layar yang Tersedia

Aplikasi React Native mengelola tampilan melalui state `screen`, `role`, dan `tab` di dalam `App.js`:

### A. Layar Pra-Autentikasi & Autentikasi
1. **`splash` (`SplashScreen`)** — Latar biru langit `#A2D7FB`, ilustrasi `assets/splash-art.png` (654×1048) menempel bawah, pil pemuatan `"Menyiapkan pengalaman belajar"` dengan 3 titik `#C8526D`, transisi otomatis 2.300 ms ke `welcome` setelah data lokal termuat.
2. **`welcome`** — Pemilihan peran dengan brand `✿ KARSA`, tombol tema terang/gelap, kartu `SchoolIdentity` (`SD KARITAS PURWOKERTO · Karitas Sahabat Belajar`), 4 kartu peran (`wali`, `guru`, `orangtua`, `siswa`), kutipan motivasi, dan catatan `PROTOTIPE PEMBELAJARAN · KARSA`.
3. **`login`** — Halaman masuk spesifik peran (4 varian judul, subjudul, ikon kolom NIP/NISN, tombol mata kata sandi, validasi kredensial demo, tautan `Lupa kata sandi?`, tombol `Masuk →`, dan kotak informasi `Akun demo` sesuai peran).
4. **`forgot`** — Informasi pemulihan simulasi yang menampilkan NIP/NISN dan kata sandi akun demo peran aktif serta tombol `Kembali masuk`.

### B. Shell Utama (`main`) Berdasarkan Peran & Tab Bawah
- **Wali Kelas (`wali` — Kelas 1)**, 5 tab:
  5. `Beranda` (`waliHome`) — `SchoolIdentity` ringkas, sapaan Ibu Sari + toggle tema + lonceng notifikasi, `WaliHero` (`#F9EBEE`), 2 `StatCard` (Anggota kelas & Hadir hari ini), kartu grafik `Kehadiran hari ini` (4 baris `ChartRow`: Hadir `#78B995`, Izin `#79A6CD`, Sakit `#C58AAD`, Alpa `#CD6C7D`), kartu `Gambaran nilai` (`📊 Rata-rata kelas`), pintasan `📅 Agenda kelas`, catatan demo.
  6. `Anggota` (`waliMembers`) — Daftar 3 siswa contoh Kelas 1 (Dimas Nugroho, Sari Putri, Rafi Pratama), status kehadiran hari ini, nilai ringkas, dan tombol `Isi kehadiran`.
  7. `Rekap` (`waliRecap`) — Segmen `Kehadiran` (navigasi tanggal + 4 tombol status Hadir/Izin/Sakit/Alpa per siswa + `Hapus catatan`) dan `Nilai` (grafik rata-rata kelas + daftar nilai ringkas 0–100 per siswa).
  8. `Agenda` (`waliAgenda`) — Tombol `+ Tambah agenda`, kalender bulanan (`Sen`–`Min`), daftar agenda Kelas 1 pada tanggal terpilih.
  9. `Profil` (`waliProfile`) — Avatar `👩🏻‍🏫`, lencana `Wali kelas aktif`, informasi wali kelas, ringkasan aktivitas, 5 menu pengaturan, tombol `Keluar dari akun demo`.

- **Guru Mata Pelajaran (`guru`)**, 5 tab:
  10. `Beranda` (`dashboard` cabang `teacher`) — `SchoolIdentity` ringkas, sapaan Ibu Sari, `teacher-banner.png`, chip `Semua kelas` + `Kelas 1`–`Kelas 6`, 2 `StatCard` (`Kelas` & `Tugas Aktif`), 3 kartu statistik lebar (`Latihan`, `Pengumuman`, `Materi`), seksi `Tugas Terbaru` (2 tugas terakhir).
  11. `Kelas` (`classes`) — Chip `Kelas 1`–`Kelas 6`, hero kelas (`#E5F0F8` + `🏫`), 4 tile statistik berwarna (`#FBD5D7`, `#D1F4D8`, `#EDD7EF`, `#F7EDDD`), daftar siswa contoh, dan daftar mata pelajaran sesuai kelas.
  12. `Tugas` (`tasks` cabang `teacher`) — Pencarian tugas/mapel, segmen `Semua` / `Berjalan` / `Selesai`, tombol `+ Tambah tugas`, tombol `Rekap nilai per kelas`, `NoticeCard`, daftar tugas dengan overline mapel.
  13. `Kalender` (`calendar`) — Kalender bulanan sekolah + agenda kegiatan sekolah pada 6 & 7 November 2026 (`Hari Literasi KARSA`, `Pertemuan Wali Murid`).
  14. `Profil` (`profile` cabang `teacher`) — Avatar `👩🏻‍🏫`, lencana `Guru aktif`, kartu Mata Pelajaran, kartu Informasi Guru, 4 `StatCard` ringkasan aktivitas (`Tugas Aktif`, `Kuis Dibuat`, `Siswa`, `Perlu Diperiksa`), 6 menu pengaturan (termasuk `Mata pelajaran`), tombol keluar.

- **Siswa (`siswa` — Kelas 5–6)**, 3 tab:
  15. `Beranda` (`dashboard` cabang `student`) — `SchoolIdentity` ringkas, sapaan Dimas Nugroho, `StudentHero` (`#F9E5E9` dengan awan dekoratif & `📚✨`), `MissionCard` (`🎯 Misi belajarmu` + progress bar 8px), 2 `StatCard` (`Tugas aktif` & `Selesai`), kartu lebar `Materi kelas`, 9 baris `Tugas per mata pelajaran`, `TipCard` (`#EEF5F9` berganti 3 tips saat diketuk).
  16. `Tugas` (`tasks` cabang `student`) — Chip `Semua` + mapel kelas aktif (ketika mapel dipilih muncul segmen `Tugas` / `Latihan`), segmen `Aktif` / `Riwayat`, `NoticeCard`, daftar tugas berstatus `Kerjakan` / `Selesai`.
  17. `Profil` (`profile` cabang `student`) — `NoticeCard` semangat belajar, avatar `👦🏻`, lencana `Siswa aktif`, kartu `Aktivitas Tugas`, 5 menu pengaturan, tombol keluar.

- **Orang Tua/Wali (`orangtua` — Kelas 1–4)**, 4 tab:
  18. `Beranda` (`dashboard` cabang orang tua) — `SchoolIdentity` ringkas, sapaan `Orang tua dari` + avatar `D`, `student-banner.png`, 2 `StatCard` (`Tugas Aktif` & `Latihan`), kartu `Pengumuman`, kartu `RUANG TUMBUH · Perjalanan belajar ✨` (`#F8EDF0`), kartu `Materi`, seksi `Tugas untukmu`.
  19. `Tugas` (`tasks` cabang orang tua) — Tanpa chip mapel, segmen `Aktif` / `Riwayat`, `NoticeCard`, daftar tugas kelas anak.
  20. `Latihan` (`practiceList`) — Daftar latihan esai per mata pelajaran sesuai kelas anak (`8` mapel untuk Kelas 1–2 karena IPAS hanya Kelas 3–6; `9` mapel untuk Kelas 3–4).
  21. `Profil` (`profile` cabang orang tua) — `NoticeCard`, avatar `👦🏻`, lencana `Siswa aktif`, kartu `Perjalanan Belajarku`, 5 menu pengaturan, tombol keluar.

### C. Halaman Detail, Formulir, Kuis & Panel Bawah (Bottom Sheet)
22. **`taskDetail` (Modal Bottom Sheet)** — Detail tugas siswa/orang tua, info tenggat & hitung mundur, buka lampiran / tandai selesai (untuk tugas file) atau mulai kuis (untuk tugas kuis).
23. **`practiceDetail` (Modal Bottom Sheet)** — Detail latihan esai 5 soal tanpa batas waktu bagi siswa/orang tua.
24. **`quiz`** — Pengerjaan 10 soal pilihan ganda (A/B/C/D), progress bar, tombol `Periksa jawaban` dengan umpan balik langsung (`✓ Tepat!` / `Belum tepat. Tetap semangat!`) + pembahasan, lanjut `Soal berikutnya` / `Lihat hasil`.
25. **`result`** — Hasil kuis (`🌟`, skor besar `52sp/w900`, rincian benar/salah tiap soal, kembali ke riwayat tugas).
26. **`essay`** — Pengerjaan 5 soal latihan esai, input jawaban bebas, lihat `💡 Contoh jawaban`, lanjut hingga selesai.
27. **`practiceResult`** — Layar selesai latihan (`🌱 Hebat, kamu sudah berlatih!`).
28. **`teacherTask`** — Detail tugas bagi guru/wali berisi durasi, lampiran/info soal, daftar nilai 3 siswa pada kelas tugas (skala 0–100 atau `—`), dan pintasan ke `Rekap nilai per kelas`.
29. **`gradeRecap`** — Rekap nilai guru per kelas (chip Kelas 1–6, tabel ringkas per tugas & siswa, ekspor `.xlsx` dan `.pdf`).
30. **`taskForm`** — Formulir tambah tugas (judul, chip mapel, unggah file atau tombol `Gunakan kuis contoh`, tenggat `YYYY-MM-DD`, durasi menit, chip kelas).
31. **`subject`** — Halaman mata pelajaran guru (`Tugas` / `Latihan` + tombol `＋ Tambah`).
32. **`practicePreview`** — Pratinjau latihan esai untuk guru.
33. **`practiceForm`** — Formulir tambah latihan esai kustom untuk kelas.
34. **`students` & `studentDetail`** — Daftar siswa contoh dan detail perkembangan siswa.
35. **`materials`, `materialDetail`, `materialForm`** — Daftar materi belajar, baca materi + buka file lampiran, dan formulir unggah materi dengan peringkas offline 3 kalimat pertama (`.txt` otomatis dibaca maks. 12.000 karakter).
36. **`notifications`** — Daftar notifikasi lokal lintas peran pada perangkat yang sama + tombol ke `Pengumuman sekolah`.
37. **`announcements`, `announcementDetail`, `announcementForm`** — Daftar pengumuman sekolah/guru, detail pengumuman (otomatis menandai sudah dibaca), dan formulir buat pengumuman.
38. **`waliMember`** — Detail anggota Kelas 1 bagi wali kelas + input/hapus nilai ringkas 0–100.
39. **`agendaForm` & `agendaDetail`** — Formulir tambah agenda kelas (`YYYY-MM-DD`) dan detail agenda.
40. **`progress`** — Halaman `Perjalanan belajar` orang tua/anak: total bintang belajar (tugas selesai + latihan selesai) dan pemilih perasaan hari ini (`Senang`, `Tenang`, `Lelah`, `Sedih`).
41. **`setting`** — Halaman detail pengaturan: `Informasi pribadi` (nama, kelas anak, agama opsional), `Mata pelajaran` (guru), `Tampilan` (mode gelap), `Notifikasi`, `Privasi dan keamanan`, dan `Pusat bantuan`.

---

## 2. Pemetaan Komponen UI & Token Desain

| Komponen React Native (`App.js`) | Widget Flutter (`karsa_app/lib/`) | Spesifikasi Visual 1:1 |
|---|---|---|
| `Pressable` (`MotionPressable` scale `0.965`) | `MotionPressable` | Animasi tekan `scale: 0.965` (nonaktif bila `MediaQuery.disableAnimations` aktif). |
| `Card` (`styles.card` + `clay.soft`) | `ClayCard` | `borderRadius: 23`, `padding: 15`, `marginBottom: 12`, border putih 88% `2px`, shadow `0 6 20 rgba(185,157,163,0.17)`. |
| `Button` (`styles.button` + `clay.raised`) | `KarsaButton` | `borderRadius: 20`, `padding: 16`, warna `rose`, teks putih `14/w800`, border putih 55% `2px`, shadow `0 7 18 rgba(167,126,136,0.24)`. |
| `TextInput` (`styles.input` + `clay.inset`) | `KarsaInput` | `borderRadius: 14`, `padding: 15`, border `#EFDFD9` / `#F1E5E2`, tanpa shadow luar. |
| `Chips` (`styles.chip` / `chipActive`) | `KarsaChips` | Scroll horizontal, `borderRadius: 24`, padding `9×16`, teks `12/w700`, aktif `rose` teks putih. |
| `Tabs` (`styles.segment` + `segmentActive`) | `KarsaSegmentTabs` | Track inset `#F5ECEA` `borderRadius: 20` `padding: 4`, pil aktif `#FFFDFB` `borderRadius: 16`. |
| `Stat` (`styles.stat` + `statIcon`) | `StatCard` / `WideStatCard` | Lingkaran ikon `40×40` `borderRadius: 20` (`clay.raised`, ikon putih `19px`), angka `23/w800`. |
| `Item` (`styles.item` + `badge`) | `ListItemCard` | Tile ikon `46×46` `borderRadius: 14`, judul `14/w700`, meta `11`, lencana kanan `borderRadius: 12` `#F9E8ED` teks `rose` `10/w700`. |
| `ClaySection` (`styles.note`) | `NoticeCard` | Latar `#FFF1E8`, `borderRadius: 18`, `padding: 16`, judul `rose` `w800`. |
| `Header` (`styles.pageHeader`) | `PageHeader` | Margin atas `15`, bawah `24`, chevron kembali polos, judul `24/w800`, subjudul `13`. |
| `SchoolIdentity` | `SchoolIdentity` | Kartu `borderRadius: 18`, bingkai logo putih `38×38` `borderRadius: 12`, `logo-sd-karitas.png` `33×33`. |
| `ChartRow` | `ChartRow` | Label `58px` `12/w700`, track tinggi `10` `borderRadius: 8` `#F3E7E6`, angka kanan `30px` `12/w800`. |
| Kalender grid (`waliAgenda` / `calendar`) | `MonthCalendar` | Header bulan + chevron, grid 7 kolom (`Sen`–`Min`), tanggal terpilih pil `rose` `borderRadius: 20`. |
| `styles.bell` | `RoundIconButton` | Lingkaran `42×42` `borderRadius: 21`, border `1px line`, badge angka `18×18` `pink`. |
| `makeDarkStyle` | `DarkColorMapper` | Pemetaan otomatis permukaan terang ke `#493640` (rose), `#34414E` (biru), `#332D36` (netral), teks ke `#F2A9BC`/`#EEE7ED`, border `#554A54`, shadow `#08070A`. |

---

## 3. Penyimpanan Lokal & Kompatibilitas Data (`@karsa-demo-v1`)

Aplikasi menyimpan satu objek JSON utuh pada kunci **`@karsa-demo-v1`** (di Flutter melalui `SharedPreferences` string key `@karsa-demo-v1`). Seluruh properti dipertahankan 1:1 agar data lama tetap terbaca:

- `tasks`: daftar tugas (`initialTasks` + `seedTasks` 36 tugas contoh Kelas 5–6 untuk 9 mapel + tugas buatan guru). Subjek lama `"IPA"` otomatis dinormalisasi menjadi `"Ilmu Pengetahuan Alam dan Sosial (IPAS)"`.
- `customPractices`: latihan tambahan yang dibuat guru.
- `results`: map `taskId -> { score, total, answers, demo, submittedOnly, religion, studentName, className }`.
- `practiceDone`: map `practiceId -> bool`.
- `announcements` & `readAnnouncements`: daftar pengumuman dan ID pengumuman yang sudah dibaca.
- `teacherName` (`"Ibu Sari"`), `waliName` (`"Ibu Sari"`), `studentName` (`"Dimas Nugroho"`).
- `notifications` (`bool`), `reviewed` (`List<String>`).
- `childClass`, `parentClass` (`"Kelas 1"`), `studentClass` (`"Kelas 5"`), `teacherSubject` (`"Matematika"`), `religion` (`""`), `mood` (`String?`), `darkMode` (`bool`).
- `attendance`: map `YYYY-MM-DD -> { memberId: "Hadir"|"Izin"|"Sakit"|"Alpa" }`.
- `classScores`: map `memberId -> num (0..100)`.
- `classEvents`: daftar agenda wali kelas (`{ id, title, body, date, className, teacher }`).
- `materials`: daftar materi (`{ id, title, subject, className, file, summary, teacher }`).
- `localNotifications` & `readNotifications`: notifikasi lokal lintas peran dan status baca per `notificationKey` (`wali`, `guru`, `siswa:Kelas 5`, `orangtua:Kelas 1`).

---

## 4. Kurikulum & Bank Soal (`curriculum.js` → `curriculum_data.dart`)

- **9 Mata Pelajaran**:
  1. Pendidikan Agama dan Budi Pekerti (`🙏`, `#F9E5E9`)
  2. Pendidikan Pancasila (`🇮🇩`, `#F8E7E4`)
  3. Bahasa Indonesia (`📕`, `#F9E8E9`)
  4. Matematika (`📘`, `#E4EEF7`)
  5. Ilmu Pengetahuan Alam dan Sosial (IPAS) (`🌿`, `#E7F1E9`) — khusus Kelas 3–6 (`subjectsForClass`)
  6. Seni dan Budaya (`🎨`, `#F4E8F5`)
  7. Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK) (`⚽`, `#E6F2E9`)
  8. Bahasa Inggris (`🔤`, `#E8EFF9`)
  9. Muatan Lokal (`🌾`, `#FFF1DF`)
- **Bank Soal Kuis (`quizBank`)**: 9 × 10 = **90 soal pilihan ganda** lengkap dengan 4 opsi, indeks jawaban benar, dan penjelasan.
- **Bank Latihan (`practiceBank`)**: 9 × 5 = **45 soal esai** beserta contoh jawaban.
- **Adaptasi Agama Opsional (`religions`: Islam, Kristen, Katolik, Hindu, Buddha, Konghucu)**: mengganti soal pertama & latihan pertama pada mapel Pendidikan Agama dan Budi Pekerti sesuai agama yang dipilih (termasuk pembinaan iman Katolik).

---

## 5. Pemetaan Dependensi React Native/Expo → Flutter

| Paket React Native / Expo | Paket / Solusi Flutter | Kegunaan |
|---|---|---|
| `react`, `react-native` | `flutter` (Material dikustomisasi penuh), `provider` | UI deklaratif, state management reaktif (`AppState` `ChangeNotifier`). |
| `@react-native-async-storage/async-storage` | `shared_preferences` | Penyimpanan JSON lokal dengan kunci `@karsa-demo-v1`. |
| `@expo/vector-icons` (`Ionicons`) | Font aset `assets/fonts/Ionicons.ttf` + `KarsaIcons` | Ikon vektor identik 1:1 dengan Ionicons Expo tanpa ketergantungan internet. |
| `expo-document-picker` | `file_picker` | Memilih lampiran PDF, DOCX, TXT, JPG, PNG (batas 10 MB perangkat / 1 MB web). |
| `expo-file-system` | `path_provider` + `dart:io` / data URI web | Menyalin & membaca file lampiran lokal (termasuk baca `.txt` otomatis). |
| `expo-sharing` | `share_plus` + `open_filex` | Membuka / membagikan lampiran serta hasil ekspor rekap nilai. |
| `pdf-lib` (`gradeReports.js`) | `pdf` | Membuat dokumen PDF landscape A4 (842×595 pt) berisi tabel rekap nilai per kelas. |
| `xlsx` (`gradeReports.js`) | `excel` | Membuat workbook `.xlsx` sheet `Rekap Nilai` dengan header dan baris identik. |

---

## 6. Strategi Migrasi & Verifikasi

1. Kode React Native asli (`App.js`, `curriculum.js`, `gradeReports.js`, `assets/`) tetap dipertahankan utuh di root repositori sebagai rujukan.
2. Seluruh aplikasi Flutter ditempatkan secara modular di `karsa_app/`.
3. Aset gambar asli disalin ke `karsa_app/assets/images/` dan font `Ionicons.ttf` diekstrak ke `karsa_app/assets/fonts/Ionicons.ttf`.
4. Disediakan pratinjau HTML interaktif 28 layar di `karsa_app/preview/` yang mereplikasi token desain, data kurikulum, validasi akun demo, dan interaksi widget Flutter tanpa ketergantungan CDN.
