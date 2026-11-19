# KarsaApp — Pratinjau HTML Interaktif

Pratinjau web **offline-first** dari aplikasi KarsaApp (SD Karitas Purwokerto) versi
Flutter. Tujuannya: memeriksa tampilan dan alur aplikasi **tanpa** Flutter SDK,
tanpa browser automation, dan **tanpa satu pun dependensi CDN**.

---

## Menjalankan

```bash
cd karsa_app/preview
python3 serve.py                       # http://127.0.0.1:8000
python3 serve.py --host 0.0.0.0 --port 8080   # untuk pratinjau di jaringan
```

Endpoint kesehatan:

```bash
curl http://127.0.0.1:8000/healthz
# {"status":"ok","service":"karsa-preview"}
```

`serve.py` adalah server statis sederhana:

* header anti-cache (`no-cache, no-store, must-revalidate`) supaya setiap
  muat ulang menampilkan perubahan terbaru;
* MIME type UTF-8 untuk HTML/CSS/JS/JSON;
* rute `/assets/...` dipetakan ke folder aset Flutter (`karsa_app/assets/...`),
  sehingga PNG asli dan font `Ionicons.ttf` dipakai ulang **tanpa** menggandakan
  berkas biner di dalam repository (folder `preview/assets/` memang di-ignore
  oleh `.gitignore`).

---

## Struktur berkas

| Berkas | Isi |
| --- | --- |
| `index.html` | Kerangka halaman: bar pemilih layar + tombol mode gelap, viewport, bottom nav, dan sheet modal. |
| `styles.css` | Token claymorphism, palet terang/gelap, tipografi, dan komponen (1:1 dengan `lib/core/theme/*`). |
| `app.js` | Seluruh logika pratinjau: state, 39 layar, interaksi, router hash. |
| `curriculum-data.js` | **Berkas hasil generate** — bank soal, bank esai, info mata pelajaran, daftar agama, dan peta glif Ionicons. |
| `serve.py` | Server statis tanpa cache + `/healthz`. |
| `test_preview.js` | Harness verifikasi (mock DOM) — `node test_preview.js`. |

`curriculum-data.js` di-generate ulang dari `curriculum.js` (repo root) dengan:

```bash
node karsa_app/tool/generate_preview_data.js
```

---

## Prinsip tampilan

* **Mobile-first**: shell mengisi `100dvh` pada ponsel, menjadi kolom selebar
  `480px` (sama dengan `ConstrainedBox(maxWidth: 480)` di Flutter) pada layar
  lebar, serta memakai `env(safe-area-inset-*)`.
* **Bukan mock bingkai ponsel**: tidak ada frame perangkat, hanya shell aplikasi.
* **Bar atas hanya berisi** dropdown pemilih layar + tombol mode gelap.
  Tidak ada label "Pratinjau".
* **Tanpa CDN**: seluruh aset (logo, banner, splash art, font ikon) berasal dari
  `karsa_app/assets/`.

---

## Layar (39)

| # | Layar | Catatan |
| --- | --- | --- |
| 1 | `splash` |  |
| 2 | `login` | **satu form untuk 5 peran** |
| 3 | `welcome` | arsip, tak dijangkau dari splash |
| 4 | `login-operator` | deep link |
| 5 | `login-wali` | deep link |
| 6 | `login-guru` | deep link |
| 7 | `login-ortu` | deep link |
| 8 | `login-siswa` | deep link |
| 9 | `forgot` |  |
| 10 | `wali-beranda` |  |
| 11 | `wali-anggota` |  |
| 12 | `wali-recap` | alias `wali-rekap` |
| 13 | `wali-agenda` |  |
| 14 | `wali-profil` |  |
| 15 | `guru-beranda` |  |
| 16 | `guru-kelas` |  |
| 17 | `guru-tugas` |  |
| 18 | `guru-kalender` |  |
| 19 | `guru-profil` |  |
| 20 | `siswa-beranda` |  |
| 21 | `siswa-tugas` |  |
| 22 | `siswa-profil` |  |
| 23 | `ortu-beranda` |  |
| 24 | `ortu-tugas` |  |
| 25 | `ortu-latihan` |  |
| 26 | `ortu-profil` |  |
| 27 | `operator-beranda` |  |
| 28 | `operator-siswa` |  |
| 29 | `operator-kelas` |  |
| 30 | `operator-materi` |  |
| 31 | `operator-media` |  |
| 32 | `operator-tugas` |  |
| 33 | `operator-pengumuman` |  |
| 34 | `operator-agenda` |  |
| 35 | `operator-nilai` |  |
| 36 | `materi` |  |
| 37 | `notifikasi` |  |
| 38 | `kuis` |  |
| 39 | `hasil-kuis` |  |

### Cakupan operator sekolah

Lima tab bawah: **Beranda, Siswa, Kelas, Materi, Media** (Foto & Grafis).
Halaman tambahan yang dibuka dari pintasan/form: tugas, pengumuman, agenda,
nilai, form siswa, form materi, form kelas, dan form akun guru/wali.

| Layar | Isi |
| --- | --- |
| `operator-beranda` | Ringkasan sekolah + pintasan kelola data, tugas, pengumuman, agenda, nilai |
| `operator-siswa` | Roster seluruh kelas, pencarian, filter, tambah/ubah/hapus |
| `operator-kelas` | Sub-tab **Kelas / Akun / Siswa** + form kelas & akun guru/wali |
| `operator-materi` | Materi seluruh kelas + tambah/ubah/hapus, lampiran URL/berkas |
| `operator-media` | Unggah logo sekolah, banner siswa & banner guru (pratinjau langsung) |
| `operator-tugas` | Tugas seluruh kelas + form tambah/ubah/hapus |
| `operator-pengumuman` | Pengumuman sekolah + form tambah/ubah/hapus |
| `operator-agenda` | Agenda sekolah + form tambah/ubah/hapus |
| `operator-nilai` | Input nilai 0-100 per siswa + rata-rata kelas |

Semua perubahan tersimpan di `localStorage` pada kunci `@karsa-demo-v1`
(kunci yang sama dengan `StorageService` di Flutter). Kelas terakhir tidak
bisa dihapus, dan data seed yang sengaja dihapus tidak dibangkitkan ulang.

Deep link memakai hash: `index.html#guru-tugas`, `#wali-recap`, `#wali-rekap`,
`#ortu-latihan`, `#hasil-kuis`, dan seterusnya.

---

## Interaksi yang hidup

* **Login per peran** — kolom NIP/NISN dan kata sandi adalah `<input>` asli,
  lengkap dengan tombol mata sandi dan submit via tombol **Enter**.
  Kredensial divalidasi persis seperti `AppState.authenticate()`:

  | Peran | NIP / NISN | Kata sandi |
  | --- | --- | --- |
  | Operator Sekolah | `19870003` | `operator123` |
  | Wali Kelas | `19870001` | `wali123` |
  | Guru Mata Pelajaran | `19870002` | `guru123` |
  | Orang Tua/Wali | `10010001` | `ortu123` |
  | Siswa | `10050001` | `siswa123` |

  Jika tidak cocok → pesan galat **"NIP/NISN atau kata sandi tidak sesuai."**
  Kotak akun demo di bawahnya berbeda isi untuk tiap peran.

* **Bottom nav** — tiap peran punya tabnya sendiri (operator 5 tab, wali 5
  tab, guru 5 tab, siswa 3 tab, orang tua 4 tab).
* **Chip kelas / mata pelajaran**, **segmen** (Semua/Berjalan/Selesai,
  Aktif/Riwayat, Kehadiran/Nilai), dan **pencarian** menyaring daftar tugas.
* **Tombol status kehadiran** (Hadir / Izin / Sakit / Alpa) bisa dipilih dan
  langsung tersimpan di state lokal.
* **Kartu tips belajar** berganti setiap diketuk.
* **Kuis** — pilih jawaban, periksa jawaban, lanjutkan sampai soal terakhir,
  lalu tampilkan layar hasil.
* **Mode gelap** — tombol di bar atas mengganti `data-theme` pada `<html>`.
* **Sheet modal** — detail tugas, nilai siswa, daftar siswa, materi,
  pengumuman, pengaturan, dan latihan esai.
* **Profil siswa** — kartu "Data pribadi" yang bisa diedit (input nama asli,
  chip kelas, chip agama, tombol "Simpan perubahan") dan section
  "Nilai kelas" (rata-rata kelas + nilai per mata pelajaran dari hasil kuis
  yang benar-benar dikerjakan).
* **Notifikasi** — setiap item bisa diklik: notifikasi ditandai "Dibaca" dan
  lembar isinya (detail tugas atau materi) langsung dibuka. Notifikasi hanya
  untuk kelas belajar masing-masing (siswa: kelasnya, orang tua: kelas
  anaknya).
* **Profil operator** — kartu identitas di beranda operator (avatar inisial,
  jabatan, NIP, indikator kelengkapan) membuka form "Informasi pribadi" yang
  berisi enam kolom: nama, NIP, jabatan, unit kerja, surel, dan telepon.
  Nama/NIP wajib, surel dan telepon divalidasi formatnya, dan semuanya
  tersimpan di `localStorage`.
* **CRUD operator sekolah** — tambah/ubah/hapus siswa, kelas, akun guru/wali,
  materi, tugas, pengumuman, agenda, dan input nilai; semua lewat sheet form
  dengan validasi terlihat (kolom wajib, nilai 0-100, minimal satu kelas) dan
  langsung tersimpan di state lokal.
* **Media sekolah** — pratinjau mengganti logo/banner siswa/banner guru dari
  pilihan berkas atau URL, lalu menyimpan sumbernya agar tetap tampil setelah
  dimuat ulang.
* **Login tunggal + "Ingat saya"** — satu form melayani kelima peran; peran
  dideteksi dari NIP/NISN yang diketik (badge peran muncul begitu identitas
  dikenali), dan kotak centang "Ingat saya" menyimpan identitas + peran di
  `localStorage` agar tidak perlu diketik ulang. Kata sandi tidak pernah
  disimpan; kartu "Terakhir masuk sebagai" punya tombol "Bukan saya" untuk
  berganti akun.
* **Penyimpanan lokal** — data pribadi, status notifikasi, dan seluruh hasil
  CRUD operator disimpan di `localStorage` pada kunci `@karsa-demo-v1`
  (kunci yang sama dengan aplikasi Flutter), jadi tetap ada setelah halaman
  dimuat ulang.

---

## Verifikasi

```bash
node karsa_app/preview/test_preview.js
```

Harness memakai **mock DOM** (tanpa browser) dan memverifikasi:
39 layar ter-render tanpa error, transisi splash 2300 ms yang langsung membuka
form login tunggal, deteksi peran dari NIP/NISN (kelima akun masuk lewat form
yang sama, termasuk pesan galat per kolom kosong), "Ingat saya" yang menyimpan
identitas tanpa kata sandi, navigasi bawah, filter chip/segmen/pencarian,
pemilihan status kehadiran, pergantian tips, alur kuis → hasil, adaptasi agama,
deep link, toggle mode gelap, dan seluruh CRUD operator sekolah (tugas,
materi, pengumuman, agenda, nilai, kelas, akun guru/wali, siswa) termasuk
validasi nilai 0-100, tenggat bertanggal salah, IPAS yang hanya untuk kelas
3-6 (kelas khusus tanpa angka tingkat tetap boleh semua mapel), kelas terakhir
yang tidak boleh dihapus, dan fakta bahwa data yang dihapus operator tidak
dibangkitkan kembali saat pemuatan ulang. Lima kartu peran di layar `welcome`
(arsip) tetap diuji satu per satu: masing-masing harus membuka layar login
perannya sendiri (regresi untuk kartu Operator Sekolah yang sempat tidak
bereaksi), dan label medan masuk harus NIP untuk staf vs NISN untuk
siswa/orang tua.
Total **433 pemeriksaan**.

---

## Alur login terbaru

Splash (2300 ms) → **satu form login** → dashboard sesuai peran. Tidak ada lagi
layar pilih peran di jalur utama.

| Langkah | Perilaku |
| --- | --- |
| Peran | Dideteksi dari NIP/NISN + kata sandi (`roleForCredentials`), bukan dipilih lebih dulu |
| Label kolom | NIP untuk staf (wali/guru/operator), NISN untuk siswa/orang tua — ikut berubah saat mengetik |
| Badge peran | Muncul di bawah kolom identitas begitu NIP/NISN dikenali |
| Akun demo | Satu kotak berisi kelima akun; ketuk untuk mengisi form |
| Ingat saya | Menyimpan `identifier` + `roleName` di `@karsa-demo-v1`, **tanpa kata sandi** |
| Terakhir masuk | Kartu dengan tombol "Bukan saya" untuk menghapus identitas tersimpan |
| Logout | Kembali ke form login dengan identitas masih terisi, kata sandi kosong |

Pesan galat: `Isi NIP atau NISN terlebih dahulu.` / `Isi kata sandi terlebih
dahulu.` / `NIP/NISN atau kata sandi tidak sesuai.`

---

## Batasan (jujur)

* Pratinjau **bukan** aplikasi Flutter. Ia hanya memvisualkan dan memverifikasi
  alur, token desain, dan isi soal.
* Pratinjau **tidak** memakai backend. Data hidup di `localStorage` browser
  (bukan memori semata), sehingga bertahan saat halaman dimuat ulang.
* Ekspor `.xlsx`/`.pdf` dan pemilihan berkas lampiran hanya ada di aplikasi
  Flutter (`lib/services/grade_export_service.dart` dan
  `lib/services/attachment_service.dart`).
