# Rencana Pengujian — KarsaApp (Flutter)

> Proyek: **KarsaApp** — SD Karitas Purwokerto
> Versi dokumen: 1.0 · 14 November 2026
> Branch: `arena/c189c199-karsaapp`

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

Memeriksa 120 berkas Dart (16.623 baris):

1. keseimbangan `{}`, `[]`, `()` di luar string/komentar;
2. string literal (tunggal/ganda/triple) dan komentar tidak rusak;
3. setiap `import` relatif menunjuk berkas yang ada;
4. setiap `Asset(...)` / `assets/...` menunjuk aset yang ada;
5. seluruh kunci `pubspec.yaml` yang dirujuk ada;
6. setiap referensi member yang ditangani (`@karsa-demo-v1`, konstanta,
   nama enum/constructor) ada di berkas yang diimpor;
7. setiap field `final` non-`late` diinisialisasi oleh parameter konstruktor
   atau initializer list (menangkap model yang bertambah field tanpa
   memperbarui konstruktor);
8. `Image(...)`/`ImageIcon(...)` hanya menerima argumen bernama;
9. variabel lokal nullable hasil `x == null ? null : ...` tidak langsung
   dipanggil `.isEmpty` tanpa penjagaan `null`;
10. setiap kelas lokal yang dipakai sebagai `Nama.konstanta` diimpor langsung
    oleh berkas pemakainya (Dart tidak me-reekspor import transitif).
Pemeriksaan 7–10 ditambahkan setelah audit kompilasi manual menemukan tiga
kelas masalah nyata: `Image(provider, ...)`, `existing.isEmpty` pada daftar
nullable, dan `KarsaStoreData` yang kehilangan tiga parameter konstruktor.
Ketiganya sudah diperbaiki dan kini dijaga oleh pemeriksa statis.

```bash
$ python3 karsa_app/tool/check_syntax.py
OK: Checked 120 Dart files (16623 lines), 148 top-level classes/enums/mixins, all imports & assets resolved.
```

### 2.2 Uji unit Flutter — **disiapkan, belum dieksekusi**

Lima berkas di `karsa_app/test/`:

| Berkas | Cakupan |
| --- | --- |
| `curriculum_test.dart` | Paritas bank soal: 9 mata pelajaran, 10 pilihan ganda + 5 esai per mata pelajaran, kunci jawaban, `subjectsForClass()` (IPAS hanya kelas 3–6 untuk kelas bernomor; kelas khusus tanpa angka tingkat mendapat semua mapel), adaptasi 6 agama |
| `operator_crud_test.dart` | Login operator (`19870003` / `operator123`), CRUD siswa/kelas/akun/materi/tugas/pengumuman/agenda/nilai, validasi nilai 0–100 dan non-finite, perlindungan kelas terakhir, pemindahan siswa saat kelas dihapus, data pribadi operator, grafis sekolah, persistensi array kosong, dan `subjectsForClass()` untuk kelas khusus |
| `storage_migration_test.dart` | Kunci `@karsa-demo-v1`, JSON kompatibel AsyncStorage, normalisasi `"IPA"`, seeding tugas/hasil demo, ketahanan terhadap JSON rusak |
| `app_state_auth_test.dart` | Autentikasi 5 peran + pesan galat, filter tugas per peran, rekap kehadiran, ringkasan offline, **ringkasan nilai kelas** (rata-rata, jumlah tugas dinilai, IPAS hanya kelas 3–6), **pengeditan data pribadi** (termasuk penolakan nama kosong), serta **cakupan notifikasi & materi per kelas** (siswa melihat kelas 5, orang tua kelas 1; notifikasi ditandai dibaca dan membuka detail tugas) |
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
Checks passed: 477
ALL PREVIEW CHECKS PASSED
```

Yang dipverifikasi:

* 40 layar terdaftar dan **seluruhnya** ter-render tanpa exception; daftar
  harapan lengkap diperiksa dua arah (tidak ada layar tak terdokumentasi);
* beranda operator: sapaan tepat di bawah judul, tidak ada banner guru,
  lima kartu pintasan mulai terlipat, tiap kartu membuka/menutup sendiri
  (bukan akordeon), status buka bertahan saat layar dirender ulang, tombol
  `Kelola`/`Ubah` membuka halaman terkait, dan section profil menampilkan
  keenam kolom beserta indikator kelengkapan;
* tab Profil operator (tab ke-6 di kanan Media): judul, identitas sekolah,
  enam kolom profil, indikator kelengkapan, empat baris pengaturan, tombol
  keluar; beranda tidak lagi merender kolom profil penuh dan hanya menyisakan
  pintasan ke tab tersebut;
* alias `#wali-rekap` → `wali-recap`;
* splash menjadwalkan timer **2300 ms** dan otomatis pindah ke **form login tunggal**
  (bukan layar pilih peran);
* form login tunggal: kelima akun demo masuk lewat form yang sama, peran
  dideteksi dari NIP/NISN, galat per kolom kosong, label NIP vs NISN, badge
  peran terdeteksi, serta "Ingat saya" yang menyimpan identitas tanpa kata
  sandi dan bertahan setelah state dimuat ulang;
* identitas tersimpan langsung mengisi kolom saat form dibuka (label ikut
  berubah jadi NISN untuk akun siswa), "Bukan saya" menghapusnya, dan logout
  mengembalikan pengguna ke form login dengan identitas masih terisi;
* 5 layar login (termasuk operator): input NIP/NISN + kata sandi berupa
  `<input>` asli, tombol mata,
  submit dengan **Enter**, pesan galat **"NIP/NISN atau kata sandi tidak sesuai."**
  saat kredensial salah, dan kotak akun demo berbeda per peran;
* bottom nav: 5/5/5/3/4 item untuk operator/wali/guru/siswa/orang tua;
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
* profil siswa: section "Nilai kelas" (rata-rata + nilai per mata pelajaran
  dari hasil kuis nyata), form "Informasi pribadi" yang bisa diedit (input
  nama asli, chip kelas, chip agama, tombol "Simpan perubahan") dan nama yang
  tersimpan langsung tampil di profil;
* notifikasi siswa: item notifikasi bisa diklik (membuka detail tugas/materi,
  label berubah dari "Baru" ke "Dibaca") dan hanya menampilkan notifikasi
  kelas siswa sendiri;
* materi: siswa melihat materi kelasnya sendiri ("Materi kelas 2", bukan 0);
* penyimpanan lokal: data pribadi tersimpan di `localStorage` pada kunci
  `@karsa-demo-v1`;
* **CRUD operator sekolah**: tambah/ubah/hapus siswa, kelas, akun guru/wali,
  materi, tugas, pengumuman, agenda, dan nilai; penghapusan materi benar-benar
  diklik lalu jumlah rekamannya diverifikasi berkurang satu; nilai di luar
  0–100 ditolak; kelas terakhir ditolak baik dari daftar maupun dari sheet form
  yang sedang terbuka; `restoreState()` tidak membangkitkan ulang data seed
  yang sengaja dihapus;
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
| T3 | `flutter test` → 5 berkas uji hijau | sukses |
| T4 | `flutter build apk --debug` dan `flutter build ios --no-codesign` | sukses |

### 3.2 Alur per peran (manual, perangkat nyata)

Untuk setiap peran: splash → form login tunggal (ketik NIP/NISN + kata sandi)
→ dashboard sesuai peran terdeteksi → setiap tab → logout → kembali ke form
login dengan identitas masih terisi.

| # | Peran | Kredensial | Yang diperiksa |
| --- | --- | --- | --- |
| M1 | Wali Kelas | `19870001` / `wali123` | 5 tab (Beranda, Anggota, Rekap, Agenda, Profil); hero "Tumbuh bersama, Kelas 1 🌱"; StatCard anggota & hadir; grafik 4 status; rata-rata nilai; isi kehadiran; agenda + kalender; profil |
| M2 | Guru | `19870002` / `guru123` | 5 tab (Beranda, Kelas, Tugas, Kalender, Profil); banner guru; chip "Semua kelas" + Kelas 1–6; 4 tile metrik kelas; rekap nilai + ekspor |
| M3 | Orang Tua | `10010001` / `ortu123` | 4 tab (Beranda, Tugas, Latihan, Profil); "RUANG TUMBUH"; bintang & mood; latihan esai |
| M4 | Siswa | `10050001` / `siswa123` | 3 tab (Beranda, Tugas, Profil); StudentHero; MissionCard + progres; 9 baris tugas per mapel; tips berganti; IPAS tidak muncul di kelas <3; **profil: "Data pribadi" bisa diedit (nama/kelas/agama) dan section "Nilai kelas" menampilkan rata-rata + nilai per mata pelajaran**; **notifikasi kelas 5 bisa diklik dan membuka detail tugas; "Materi kelas" menampilkan 2 materi** |
| M5 | Operator Sekolah | `19870003` / `operator123` | 6 tab (Beranda, Siswa, Kelas, Materi, Media, Profil); tambah/ubah/hapus siswa, kelas, akun guru/wali, materi, tugas, pengumuman, agenda; input nilai 0–100; unggah logo/banner; ubah data pribadi; muat ulang aplikasi dan pastikan perubahan (termasuk penghapusan) tetap ada |

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
| N11 | Operator menyimpan nilai `101`, `-1`, `NaN`, atau `abc` | Ditolak dengan pesan terlihat; nilai lama tetap tersimpan |
| N20 | Operator mengosongkan NIP atau mengisi NIP non-angka | Ditolak dengan `NIP tidak boleh kosong.` / `NIP harus berupa 6-20 angka.`; tidak ada yang tersimpan |
| N21 | Operator mengisi surel `bukan-surel` atau telepon `123` | Ditolak dengan pesan format yang terlihat; profil lama tetap utuh |
| N22 | Operator menyimpan profil lalu aplikasi dibuka ulang | Nama, NIP, jabatan, unit, surel, dan telepon tetap ada; data lama tanpa `operatorProfile` tetap terbaca |
| N12 | Operator menghapus kelas terakhir | Ditolak dengan `Minimal satu kelas sekolah harus tetap ada.`, form tetap terbuka |
| N13 | Operator menghapus siswa/kelas/akun seed lalu membuka ulang aplikasi | Data yang dihapus tidak muncul kembali |
| N14 | Operator membuat kelas bernama "Kelas Persiapan" | Semua mata pelajaran (termasuk IPAS) tersedia di form materi/tugas |
| N15 | Operator menyimpan tugas dengan tenggat `bukan tanggal` | Ditolak dengan `Isi tanggal tenggat dengan format YYYY-MM-DD.`; tugas tidak dibuat |
| N16 | Operator memilih IPAS untuk kelas bernomor 1–2 | Ditolak dengan `IPAS hanya boleh dipakai untuk kelas 3-6.`; form tetap terbuka |
| N17 | `Image(provider, ...)` atau field `final` tanpa parameter konstruktor ditambahkan | `tool/check_syntax.py` gagal dan menunjuk berkas/field yang salah |
| N18 | Kartu "Saya Operator Sekolah" di layar `welcome` (arsip) diklik | Pindah ke `login-operator`; medan masuk berlabel NIP dan kredensial `19870003` / `operator123` membuka beranda operator |
| N26 | Operator: ketuk tab **Profil** (paling kanan, di sebelah Media) | Tab ke-6 aktif; halaman Profil Operator berisi 6 kolom identitas, indikator kelengkapan, 4 pengaturan, dan tombol keluar |
| N27 | Operator: di Beranda, ketuk pintasan "Identitas kerja dan pengaturan ada di tab Profil" | Pindah ke tab Profil |
| N28 | Operator: gulir Beranda | Tidak ada lagi section profil penuh di ujung beranda |
| N22 | Beranda operator: ketuk kartu "Pengumuman sekolah" | Hanya kartu itu yang membuka rincian (3 judul pengumuman); kartu lain tetap terlipat |
| N23 | Beranda operator: buka "Agenda sekolah", lalu ganti mode gelap | Kartu tetap terbuka karena status buka disimpan di state |
| N24 | Beranda operator: gulir ke bawah | Section "Profil operator" menampilkan 6 kolom; kolom kosong berlabel "Belum diisi"; tombol Ubah membuka form |
| N25 | Beranda operator: periksa atas layar | Tidak ada banner "Semangat mengajar"; ada "Selamat datang, <nama operator>" tepat di bawah judul |
| N19 | Form login tunggal: ketik `19870003` lalu `operator123`, klik `Masuk` | Masuk ke beranda operator tanpa pernah memilih peran; badge "Operator sekolah" muncul begitu NIP dikenali |
| N20 | Centang "Ingat saya", masuk, lalu buka ulang aplikasi | Splash → form login dengan NIP sudah terisi dan kartu "Terakhir masuk sebagai"; kata sandi tetap kosong |
| N21 | Klik "Bukan saya" pada kartu tersimpan | Identitas terhapus dari form dan dari `@karsa-demo-v1` |
| N19 | Login staf (operator/wali/guru) dibuka | Kolom dan kotak akun demo berlabel **NIP**; hanya siswa/orang tua memakai NISN |

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
| P1 | Buka `http://localhost:8000` | Splash tampil, pindah otomatis ke form login tunggal dalam 2300 ms |
| P2 | Ganti layar lewat dropdown | Semua 40 layar terbuka tanpa error konsol |
| P3 | Login dengan 5 akun demo | Masuk ke beranda peran yang sesuai |
| P4 | Login dengan data salah | Galat tampil, tetap di layar login |
| P5 | Klik chip kelas/mapel, segmen, ketik di pencarian | Daftar tersaring |
| P6 | Klik tombol status kehadiran | Status tersorot & tersimpan |
| P7 | Kerjakan kuis sampai habis | Layar hasil menampilkan skor & rincian |
| P8 | Klik tombol mode gelap | Seluruh palet beralih ke mode gelap |
| P9 | Buka `#guru-tugas` langsung | Layar yang benar terbuka |
| P10 | Layar ponsel (375×667) & desktop (1440×900) | Shell 100dvh di ponsel, kolom 480px di desktop |
| P11 | Operator: tambah lalu hapus materi, simpan nilai, hapus kelas terakhir | Jumlah rekaman berubah sesuai aksi; galat validasi tampil di sheet; setelah refresh data tidak kembali ke seed |

---

## 4. Matriks ACCEPTANCE

| # | Kriteria | Bukti | Status |
| --- | --- | --- | --- |
| A1 | Identitas visual, layout, tipografi, claymorphism, mode terang/gelap dipertahankan 1:1 | `lib/core/theme/*` (token identik `App.js`), `DarkColorMapper` port `makeDarkStyle`, pratinjau `styles.css` | ✅ |
| A2 | Aset PNG asli dipakai | `karsa_app/assets/images/*.png` (6 berkas, salinan), font `Ionicons.ttf` asli | ✅ |
| A3 | Penyimpanan lokal `SharedPreferences`, kunci `@karsa-demo-v1`, JSON kompatibel | `lib/services/storage_service.dart`, `lib/models/karsa_store_data.dart`, `test/storage_migration_test.dart` | ✅ (uji belum dieksekusi) |
| A4 | Normalisasi `"IPA"` dan seeding demo | `KarsaStoreData.fromSavedJson()` | ✅ |
| A5 | 5 peran + kredensial + dashboard/tab/profil berbeda | `AppState.authenticate()`, `lib/features/dashboard/*`, `lib/features/settings/profile_tab.dart` | ✅ |
| A6 | Kurikulum utuh (9 mapel, 10 PG + 5 esai, 6 agama) | `lib/data/curriculum_data.dart` + `tool/generate_curriculum.py` | ✅ |
| A7 | Struktur Flutter modular, tanpa layar placeholder / tombol mati | 120 berkas Dart, `tool/check_syntax.py` lolos | ✅ |
| A8 | Pratinjau 40 layar, mobile-first, tanpa CDN, tanpa label "Pratinjau" | `karsa_app/preview/*`, `node karsa_app/preview/test_preview.js` (477 cek) | ✅ |
| A8b | Peran operator sekolah lengkap, CRUD persisten, validasi terlihat, 6 tab | `lib/features/operator/*`, `providers/app_state.dart`, `test/operator_crud_test.dart`, blok operator di harness pratinjau | ✅ (uji Flutter belum dieksekusi) |
| A9 | Ekspor XLSX & PDF benar-benar dapat dibuat & dibuka | `lib/services/grade_export_service.dart` | ⚠️ belum diuji di perangkat |
| A10 | `flutter analyze` / `flutter test` hijau | — | ❌ **belum dijalankan** (SDK tidak ada) |
| A11 | Perubahan tersimpan di branch kerja | `git status` pada `arena/c189c199-karsaapp` — belum ada commit/push/PR pada sesi ini | ✅ (belum dipublikasikan) |

---

## 5. Pelaporan ke pengguna

Setiap tahap harus melaporkan: pekerjaan yang selesai, berkas yang dibuat/diubah,
fitur yang berfungsi, kendala, cara menjalankan/menguji, dan hal yang **belum**
diuji. Tidak ada klaim "selesai" tanpa bukti eksekusi.

---

## 6. Riwayat Eksekusi (14 November 2026)

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Sintaks Dart | `python3 karsa_app/tool/check_syntax.py` | OK — 120 berkas / 16.623 baris / 148 class |
| Sintaks JS | `node --check` ×4 | OK |
| Harness pratinjau | `node karsa_app/preview/test_preview.js` | OK — 477 cek lulus |
| Regresi negatif | Varian scratch: perlindungan kelas terakhir dimatikan / penghapusan materi dibuat no-op / validasi IPAS-per-kelas dihapus / entri `operator` di `LOGIN_SCREEN` dihapus / label NIP staf dikembalikan ke NISN | Gagal sesuai dugaan (1, 3, 3, 4, dan 2 cek), membuktikan uji baru bermakna |
| Regresi statis | Varian scratch: guard `existing == null` dihapus / tiga field `KarsaStoreData` dihapus dari konstruktor / import `karsa_icons.dart` dihapus | `check_syntax.py` gagal dengan 4 cek yang tepat menunjuk penyebabnya |
| Server pratinjau | `curl` ×13 | OK — semua aset 200, `/healthz` 200 |
| `flutter analyze` | — | **tidak dijalankan** |
| `flutter test` | — | **tidak dijalankan** |
