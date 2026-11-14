# Rencana Pengujian — KarsaApp (Flutter)

> Proyek: **KarsaApp** — SD Karitas Purwokerto
> Versi dokumen: 1.0 · 14 November 2026
> Branch: `arena/efada06a-karsaapp`

Dokumen ini memuat: (A) apa yang **sudah** diverifikasi di lingkungan kerja
saat ini, (B) rencana uji manual yang harus dijalankan di mesin dengan Flutter
SDK, dan (C) matriks ACCEPTANCE yang memetakan setiap criteria ke bukti.

> **Penting.** Lingkungan pembuatan dokumen ini **tidak memiliki Flutter/Dart
> SDK**, tidak memiliki browser, dan tidak memiliki Playwright. Karena itu
> `flutter analyze` dan `flutter test` **belum pernah dijalankan** dan
> **tidak diklaim berhasil**. Semua klaim di bawah ini dibatasi pada
> pemeriksaan yang benar-benar dieksekusi.

---

## 1. Lingkungan verifikasi

| Tool | Tersedia | Digunakan untuk |
| --- | --- | --- |
| `python3` | ✅ | `tool/check_syntax.py`, server pratinjau (`serve.py`) |
| `node` | ✅ | `node --check`, harness mock DOM, generator data pratinjau |
| `git` | ✅ | status/diff/commit/PR |
| `gh` | ✅ | PR ke `main` |
| Flutter SDK / Dart SDK | ❌ | — |
| Browser / Playwright | ❌ | — |

---

## 2. Pemeriksaan yang sudah dieksekusi

### 2.1 Validasi statis Dart — `python3 tool/check_syntax.py`

Memeriksa 98 berkas Dart (11.294 baris):

1. keseimbangan `{}`, `[]`, `()` di luar string/komentar;
2. string literal (tunggal/ganda/triple) dan komentar tidak rusak;
3. setiap `import` relatif menunjuk berkas yang ada;
4. setiap `Asset(...)` / `assets/...` menunjuk aset yang ada;
5. seluruh kunci `pubspec.yaml` yang dirujuk ada;
6. setiap referensi member yang ditangani (`@karsa-demo-v1`, konstanta,
   nama enum/constructor) ada di berkas yang diimpor.

```bash
$ python3 karsa_app/tool/check_syntax.py
OK: Checked 98 Dart files (11294 lines), 107 top-level classes/enums/mixins, all imports & assets resolved.
```

### 2.2 Uji unit Flutter — **disiapkan, belum dieksekusi**

Empat berkas di `karsa_app/test/`:

| Berkas | Cakupan |
| --- | --- |
| `curriculum_test.dart` | Paritas bank soal: 9 mata pelajaran, 10 pilihan ganda + 5 esai per mata pelajaran, kunci jawaban, `subjectsForClass()` (IPAS hanya kelas 3–6), adaptasi 6 agama |
| `storage_migration_test.dart` | Kunci `@karsa-demo-v1`, JSON kompatibel AsyncStorage, normalisasi `"IPA"`, seeding tugas/hasil demo, ketahanan terhadap JSON rusak |
| `app_state_auth_test.dart` | Autentikasi 4 peran + pesan galat, filter tugas per peran, rekap kehadiran, ringkasan offline |
| `dark_color_mapper_test.dart` | `DarkColorMapper` (permukaan & teks pastel), token clay, dan pembentukan byte ekspor XLSX/PDF |

```bash
# Di mesin yang memiliki Flutter SDK:
cd karsa_app
flutter pub get
flutter analyze
flutter test
```

### 2.3 Pratinjau HTML — mock DOM

```bash
$ node karsa_app/preview/test_preview.js
Checks passed: 158
ALL PREVIEW CHECKS PASSED
```

Yang dipverifikasi:

* 28 layar terdaftar dan **seluruhnya** ter-render tanpa exception;
* alias `#wali-rekap` → `wali-recap`;
* splash menjadwalkan timer **2300 ms** dan otomatis pindah ke layar pilih peran;
* 4 layar login: input NIP/NISN + kata sandi berupa `<input>` asli, tombol mata,
  submit dengan **Enter**, pesan galat **"NIP/NISN atau kata sandi tidak sesuai."**
  saat kredensial salah, dan kotak akun demo berbeda per peran;
* bottom nav: 5/5/3/4 item untuk wali/guru/siswa/orang tua;
* chip kelas guru (7 chip), chip mata pelajaran siswa (≥9), segmen
  `Semua/Berjalan/Selesai` dan `Aktif/Riwayat`, serta pencarian menyaring daftar;
* tombol status kehadiran dapat dipilih dan tersimpan;
* kartu tips belajar berganti;
* alur kuis: pilih jawaban → periksa jawaban → tampilkan penjelasan benar →
  lanjut ke soal berikutnya → layar hasil;
* adaptasi agama pada soal pertama Pendidikan Agama (Islam → "masjid");
* deep link hash (`#guru-tugas`, `#wali-recap`, `#wali-rekap`, `#ortu-latihan`,
  `#hasil-kuis`);
* toggle mode gelap (`data-theme` pada `<html>`);
* tidak ada label "Pratinjau" dan tidak ada URL eksternal di `index.html`.

### 2.4 Server pratinjau — `curl`

```bash
$ python3 karsa_app/preview/serve.py --host 0.0.0.0 --port 8000 &
$ curl -i http://127.0.0.1:8000/healthz
HTTP/1.0 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache, no-store, must-revalidate
{"status":"ok","service":"karsa-preview"}
```

| Permintaan | Status | Content-Type |
| --- | --- | --- |
| `/` | 200 | `text/html; charset=utf-8` |
| `/styles.css` | 200 | `text/css; charset=utf-8` |
| `/app.js` | 200 | `text/javascript; charset=utf-8` |
| `/curriculum-data.js` | 200 | `text/javascript; charset=utf-8` |
| `/assets/fonts/Ionicons.ttf` | 200 | `font/ttf` (389.724 byte) |
| `/assets/images/*.png` (6 berkas) | 200 | `image/png` |
| `/nope.html` | 404 | — |

### 2.5 Validasi sintaks JS

```bash
$ node --check karsa_app/preview/app.js
$ node --check karsa_app/preview/curriculum-data.js
$ node --check karsa_app/preview/test_preview.js
$ node --check karsa_app/tool/generate_preview_data.js
# semua: tanpa keluaran (OK)
```

---

## 3. Rencana uji manual (butuh Flutter SDK / perangkat)

### 3.1 Build & analisis statis

| # | Langkah | Perkiraan |
| --- | --- | --- |
| T1 | `flutter create --platforms=android,ios .` (atau salin `android/`,`ios/`) lalu `flutter pub get` | sukses |
| T2 | `flutter analyze` → **0 error, 0 warning** | sukses |
| T3 | `flutter test` → 4 berkas uji hijau | sukses |
| T4 | `flutter build apk --debug` dan `flutter build ios --no-codesign` | sukses |

### 3.2 Alur per peran (manual, perangkat nyata)

Untuk setiap peran: splash → pilih peran → login dengan akun demo → dashboard
→ setiap tab → logout.

| # | Peran | Kredensial | Yang diperiksa |
| --- | --- | --- | --- |
| M1 | Wali Kelas | `19870001` / `wali123` | 5 tab (Beranda, Anggota, Rekap, Agenda, Profil); hero "Tumbuh bersama, Kelas 1 🌱"; StatCard anggota & hadir; grafik 4 status; rata-rata nilai; isi kehadiran; agenda + kalender; profil |
| M2 | Guru | `19870002` / `guru123` | 5 tab (Beranda, Kelas, Tugas, Kalender, Profil); banner guru; chip "Semua kelas" + Kelas 1–6; 4 tile metrik kelas; rekap nilai + ekspor |
| M3 | Orang Tua | `10010001` / `ortu123` | 4 tab (Beranda, Tugas, Latihan, Profil); "RUANG TUMBUH"; bintang & mood; latihan esai |
| M4 | Siswa | `10050001` / `siswa123` | 3 tab (Beranda, Tugas, Profil); StudentHero; MissionCard + progres; 9 baris tugas per mapel; tips berganti; IPAS tidak muncul di kelas <3 |

### 3.3 Negative & edge case

| # | Kasus | Hasil yang diharapkan |
| --- | --- | --- |
| N1 | NIP/NISN salah | Galat "NIP/NISN atau kata sandi tidak sesuai.", tetap di layar login |
| N2 | Kata sandi salah | Galat sama |
| N3 | Kolom kosong lalu tekan Enter | Galat sama (tidak crash) |
| N4 | `@karsa-demo-v1` berisi JSON rusak | Aplikasi tetap terbuka dengan data default |
| N5 | `@karsa-demo-v1` berisi `"IPA"` | Mapel ternormalisasi menjadi IPAS |
| N6 | Nilai absensi 0–100 | Ditolak di luar rentang |
| N7 | Tenggat tugas lewat | Label "Tenggat terlewat" |
| N8 | Nyala/matikan mode gelap lalu restart | Preferensi tersimpan (`darkMode`) |
| N9 | Layar sangat kecil (320×568) & tablet (≥800dp) | Tidak ada overflow; shell maksimum 480px |
| N10 | Geser cepat / putar layar | Tidak ada exception; state tidak hilang |

### 3.4 Ekspor berkas (wajib di perangkat)

| # | Langkah | Hasil yang diharapkan |
| --- | --- | --- |
| E1 | Guru → Kelas → pilih kelas → Rekap nilai per kelas → Ekspor XLSX | Berkas `.xlsx` valid, sheet "Rekap Nilai", 6 kolom sesuai `gradeReports.js` |
| E2 | Buka `.xlsx` di Excel/Sheets | Terbaca, nilai & kolom sesuai |
| E3 | Ekspor PDF | PDF 842×595 pt landscape, judul kolom sama |
| E4 | Buka PDF | Terbaca & rapi |
| E5 | Tambah tugas + lampirkan berkas | Berkas tersimpan lokal, bisa dibuka kembali |

### 3.5 Pratinjau HTML (manual, browser)

| # | Langkah | Hasil yang diharapkan |
| --- | --- | --- |
| P1 | Buka `http://localhost:8000` | Splash tampil, pindah otomatis ke pilih peran dalam 2300 ms |
| P2 | Ganti layar lewat dropdown | Semua 28 layar terbuka tanpa error konsol |
| P3 | Login dengan 4 akun demo | Masuk ke beranda peran yang sesuai |
| P4 | Login dengan data salah | Galat tampil, tetap di layar login |
| P5 | Klik chip kelas/mapel, segmen, ketik di pencarian | Daftar tersaring |
| P6 | Klik tombol status kehadiran | Status tersorot & tersimpan |
| P7 | Kerjakan kuis sampai habis | Layar hasil menampilkan skor & rincian |
| P8 | Klik tombol mode gelap | Seluruh palet beralih ke mode gelap |
| P9 | Buka `#guru-tugas` langsung | Layar yang benar terbuka |
| P10 | Layar ponsel (375×667) & desktop (1440×900) | Shell 100dvh di ponsel, kolom 480px di desktop |

---

## 4. Matriks ACCEPTANCE

| # | Kriteria | Bukti | Status |
| --- | --- | --- | --- |
| A1 | Identitas visual, layout, tipografi, claymorphism, mode terang/gelap dipertahankan 1:1 | `lib/core/theme/*` (token identik `App.js`), `DarkColorMapper` port `makeDarkStyle`, pratinjau `styles.css` | ✅ |
| A2 | Aset PNG asli dipakai | `karsa_app/assets/images/*.png` (6 berkas, salinan), font `Ionicons.ttf` asli | ✅ |
| A3 | Penyimpanan lokal `SharedPreferences`, kunci `@karsa-demo-v1`, JSON kompatibel | `lib/services/storage_service.dart`, `lib/models/karsa_store_data.dart`, `test/storage_migration_test.dart` | ✅ (uji belum dieksekusi) |
| A4 | Normalisasi `"IPA"` dan seeding demo | `KarsaStoreData.fromSavedJson()` | ✅ |
| A5 | 4 peran + kredensial + dashboard/tab/profil berbeda | `AppState.authenticate()`, `lib/features/dashboard/*`, `lib/features/settings/profile_tab.dart` | ✅ |
| A6 | Kurikulum utuh (9 mapel, 10 PG + 5 esai, 6 agama) | `lib/data/curriculum_data.dart` + `tool/generate_curriculum.py` | ✅ |
| A7 | Struktur Flutter modular, tanpa layar placeholder / tombol mati | 98 berkas Dart, `tool/check_syntax.py` lolos | ✅ |
| A8 | Pratinjau 28 layar, mobile-first, tanpa CDN, tanpa label "Pratinjau" | `karsa_app/preview/*`, `node karsa_app/preview/test_preview.js` (158 cek) | ✅ |
| A9 | Ekspor XLSX & PDF benar-benar dapat dibuat & dibuka | `lib/services/grade_export_service.dart` | ⚠️ belum diuji di perangkat |
| A10 | `flutter analyze` / `flutter test` hijau | — | ❌ **belum dijalankan** (SDK tidak ada) |
| A11 | Commit bertahap, push, PR ke `main`, merge | Riwayat git branch `arena/efada06a-karsaapp` | ✅ (lihat §6) |

---

## 5. Pelaporan ke pengguna

Setiap tahap harus melaporkan: pekerjaan yang selesai, berkas yang dibuat/diubah,
fitur yang berfungsi, kendala, cara menjalankan/menguji, dan hal yang **belum**
diuji. Tidak ada klaim "selesai" tanpa bukti eksekusi.

---

## 6. Riwayat Eksekusi (14 November 2026)

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Sintaks Dart | `python3 karsa_app/tool/check_syntax.py` | OK — 98 berkas / 11.294 baris / 107 class |
| Sintaks JS | `node --check` ×4 | OK |
| Harness pratinjau | `node karsa_app/preview/test_preview.js` | OK — 158 cek lulus |
| Server pratinjau | `curl` ×13 | OK — semua aset 200, `/healthz` 200 |
| `flutter analyze` | — | **tidak dijalankan** |
| `flutter test` | — | **tidak dijalankan** |
