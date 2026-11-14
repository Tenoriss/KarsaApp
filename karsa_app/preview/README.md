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
| `app.js` | Seluruh logika pratinjau: state, 28 layar, interaksi, router hash. |
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

## Layar (28)

| # | Layar | # | Layar |
| --- | --- | --- | --- |
| 1 | `splash` | 15 | `guru-tugas` |
| 2 | `welcome` | 16 | `guru-kalender` |
| 3 | `login-wali` | 17 | `guru-profil` |
| 4 | `login-guru` | 18 | `siswa-beranda` |
| 5 | `login-ortu` | 19 | `siswa-tugas` |
| 6 | `login-siswa` | 20 | `siswa-profil` |
| 7 | `forgot` | 21 | `ortu-beranda` |
| 8 | `wali-beranda` | 22 | `ortu-tugas` |
| 9 | `wali-anggota` | 23 | `ortu-latihan` |
| 10 | `wali-recap` (alias `wali-rekap`) | 24 | `ortu-profil` |
| 11 | `wali-agenda` | 25 | `materi` |
| 12 | `wali-profil` | 26 | `notifikasi` |
| 13 | `guru-beranda` | 27 | `kuis` |
| 14 | `guru-kelas` | 28 | `hasil-kuis` |

Deep link memakai hash: `index.html#guru-tugas`, `#wali-recap`, `#wali-rekap`,
`#ortu-latihan`, `#hasil-kuis`, dan seterusnya.

---

## Interaksi yang hidup

* **Login per peran** — kolom NIP/NISN dan kata sandi adalah `<input>` asli,
  lengkap dengan tombol mata sandi dan submit via tombol **Enter**.
  Kredensial divalidasi persis seperti `AppState.authenticate()`:

  | Peran | NIP / NISN | Kata sandi |
  | --- | --- | --- |
  | Wali Kelas | `19870001` | `wali123` |
  | Guru Mata Pelajaran | `19870002` | `guru123` |
  | Orang Tua/Wali | `10010001` | `ortu123` |
  | Siswa | `10050001` | `siswa123` |

  Jika tidak cocok → pesan galat **"NIP/NISN atau kata sandi tidak sesuai."**
  Kotak akun demo di bawahnya berbeda isi untuk tiap peran.

* **Bottom nav** — tiap peran punya tabnya sendiri (wali 5 tab, guru 5 tab,
  siswa 3 tab, orang tua 4 tab).
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

---

## Verifikasi

```bash
node karsa_app/preview/test_preview.js
```

Harness memakai **mock DOM** (tanpa browser) dan memverifikasi:
28 layar ter-render tanpa error, transisi splash 2300 ms, login 4 peran
(termasuk pesan galat), navigasi bawah, filter chip/segmen/pencarian,
pemilihan status kehadiran, pergantian tips, alur kuis → hasil, adaptasi agama,
deep link, dan toggle mode gelap.

---

## Batasan (jujur)

* Pratinjau **bukan** aplikasi Flutter. Ia hanya memvisualkan dan memverifikasi
  alur, token desain, dan isi soal.
* Pratinjau **tidak** memakai backend. Data hanya hidup di memori browser.
* Ekspor `.xlsx`/`.pdf` dan pemilihan berkas lampiran hanya ada di aplikasi
  Flutter (`lib/services/grade_export_service.dart` dan
  `lib/services/attachment_service.dart`).
