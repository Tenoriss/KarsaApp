# KARSA App

Prototipe pendidikan React Native + Expo berdasarkan referensi `PEM.MOBILE.pdf` di folder Google Drive **referensi UI KarsaApp**.

## Menjalankan

```bash
npm install
npm start
```

Gunakan Expo Go yang kompatibel dengan Expo SDK 52 atau development build. Jalankan `npm run web` untuk pratinjau browser. Build produksi Android/iOS memerlukan lingkungan build dan penandatanganan masing-masing platform.

## Akun demo

| Peran | NIP / NISN anak | Kata sandi |
|---|---|---|
| Wali kelas | `19870001` | `wali123` |
| Guru mata pelajaran | `19870002` | `guru123` |
| Orang tua/wali (kelas 1–4) | `10010001` | `ortu123` |
| Siswa (kelas 5–6) | `10050001` | `siswa123` |

Akun ini hanya untuk simulasi: kredensial berada di dalam aplikasi dan **bukan autentikasi aman**. Guru demo dapat memilih mata pelajaran di Profil → Mata pelajaran. Akun demo wali kelas hanya menangani **Kelas 1**; guru mata pelajaran dapat memilih kelas 1–6; orang tua dapat memilih kelas anak 1–4 dan siswa dapat memilih kelas 5–6 di Profil → Informasi pribadi. Akun siswa difokuskan pada tugas, sedangkan latihan tersedia pada akun orang tua/wali. Karena contoh hanya memiliki satu profil anak, pemilihan kelas mensimulasikan penempatan anak tersebut, bukan pengelolaan banyak anak.

## Fitur

Wali kelas dan guru dapat melihat kelas, mencari dan membuat tugas, membuat latihan pada halaman mata pelajaran, membuat pengumuman, serta menandai hasil yang sudah diperiksa. Halaman tugas dan latihan menggunakan panel detail, kuis memberi umpan balik benar/salah, dan profil menampilkan ringkasan aktivitas serta pengaturan privasi. Orang tua dapat mendampingi anak mengerjakan kuis dan latihan, melihat hasil dan riwayat, mengumpulkan bintang, serta memilih perasaan hari ini. Kalender, pengumuman, dan profil dapat dicoba. Kuis contoh memiliki 10 soal dan latihan 5 soal per mata pelajaran; tenggat tugas menampilkan hitung mundur, tetapi tidak mengunci pengerjaan. Aktivitas dan bintang pada profil merupakan data demo satu anak, bukan data terpisah untuk setiap kelas.

Data tersimpan secara lokal menggunakan AsyncStorage. **Tidak ada backend**: akun sungguhan, pembatasan akses yang aman, notifikasi push, pengiriman jawaban, dan sinkronisasi antarperangkat belum tersedia. Peran berbagi data hanya jika dibuka pada perangkat/browser yang sama. Pemilihan kelas adalah simulasi dan bukan pembatasan akses aman. Gambar banner berasal dari referensi yang diberikan.

## Materi, lampiran, notifikasi, dan tampilan

Semua peran dapat mengubah mode terang/gelap di **Profil → Tampilan**, atau melalui ikon bulan/matahari saat login. Guru dapat membuat materi dan tugas secara terpisah, memilih PDF, DOCX, TXT, JPG, atau PNG, dan menambahkan ringkasan yang dapat diedit. Siswa dapat membuka file tugas dan menandai bahwa tugas telah dikerjakan; penanda itu **tidak mengunggah jawaban**. Di perangkat native file dibuka melalui menu berbagi/buka dengan aplikasi lain, dan di web file diunduh. Ukuran maksimum 10 MB per file pada perangkat atau 1 MB pada browser, dengan total data browser dibatasi sekitar 2,5 MB.

Saat tugas/materi ditambahkan, atau kuis/latihan selesai, aplikasi mencatat notifikasi lokal sesuai kelas dan mata pelajaran. Ini hanya terlihat ketika peran lain dibuka **pada perangkat atau browser yang sama**; tidak ada push notification atau sinkronisasi. Jawaban latihan tidak dikirim—hanya status selesai yang dicatat.

**Belum ada AI sungguhan.** Asisten tugas hanya memilih bank soal contoh, bukan menghasilkan soal dari file. Peringkas offline mengambil hingga tiga kalimat awal dari teks yang ditempel atau file TXT; PDF/DOCX tidak dibaca atau diringkas otomatis. Pemrosesan PDF otomatis dan AI memerlukan backend, layanan AI, serta pengaturan privasi dan akses. Aplikasi juga belum siap untuk data sekolah sebenarnya.

## Wali kelas

Akun wali kelas demo (`19870001` / `wali123`) terikat pada **Kelas 1** dan memiliki beranda grafik kehadiran dan nilai, menu **Anggota**, **Rekap**, **Agenda**, dan **Profil**. Ada tiga siswa contoh. Kehadiran dicatat per tanggal dengan status Hadir/Izin/Sakit/Alpa; nilai ringkas 0–100 diisi manual per siswa dan rata-rata hanya dihitung dari nilai yang sudah diisi. Ini bukan nilai resmi atau per mata pelajaran. Agenda kelas dapat dibuat untuk tanggal tertentu. Semua data dan pemberitahuan hanya tersimpan pada perangkat/browser yang sama, dan data wali kelas tidak tersinkronisasi dengan layanan sekolah atau perangkat lain. Akun lain untuk wali kelas belum dibuat dan pembatasan kelas ini bukan sistem otorisasi aman.

Logo SD Karitas Purwokerto pada pemilihan peran, login, dan beranda setiap peran berasal dari gambar yang diberikan pengguna. Toggle tema tersedia di halaman pemilihan peran serta di samping lonceng beranda.

### Mapel, tugas, dan latihan contoh
- Beranda siswa kelas 5–6 mengelompokkan tugas aktif menurut sembilan mata pelajaran. Ketuk mapel untuk membuka tugas tersaring, riwayat, dan latihan mapel tersebut. IPAS hanya untuk kelas 3–6. Data aktif dan riwayat berlabel **contoh**, termasuk nilai riwayat, bukan nilai siswa sesungguhnya.
- Kuis contoh berisi 10 soal dan latihan contoh 5 soal esai per mapel; instruksi pada formulir guru menyebutkan ketentuan ini. Bank soal bersifat contoh lintas kelas, belum dikurasi sebagai kurikulum resmi atau dihasilkan AI, dan perlu ditinjau guru sebelum digunakan. Tugas berbentuk file tetap mengikuti isi file unggahan.
- Pada Profil → Informasi pribadi, siswa/orang tua dapat memilih agama siswa secara opsional. Contoh Pendidikan Agama menyesuaikan satu soal dan satu latihan, termasuk pembinaan iman Katolik; sisanya budi pekerti umum, bukan pengganti materi agama masing-masing yang ditinjau guru. Pilihan disimpan lokal.
- Guru memasukkan tanggal tenggat terpisah dari durasi pengerjaan. Tenggat disimpan sebagai akhir hari pada zona waktu perangkat saat dibuat, dengan hitung mundur dan status terlewat; tugas lama tanpa tenggat tetap dapat dibuka. Demo tidak mengunci tugas setelah tenggat. Data contoh dibuat sekali dan tanggalnya tidak diperbarui saat aplikasi dibuka kembali.
- Semua data, lampiran, hasil, dan notifikasi tetap lokal di perangkat/browser; belum ada akun produksi, sinkronisasi antarpengguna, push, pengiriman jawaban, atau asisten AI nyata.

### Rekap nilai guru mata pelajaran

Pada **Tugas → Semua**, guru dapat membuka tugas untuk melihat nilai per siswa pada kelas tugas tersebut. Tombol **Rekap nilai per kelas** juga tersedia di daftar dan detail tugas. Pilih kelas, lalu ekspor sebagai Excel (.xlsx) atau PDF. Rekap hanya memuat tugas mata pelajaran guru dan kelas yang dipilih, dengan satu baris per siswa dan tugas. Nilai kuis dinormalisasi ke skala 0–100; tanda kosong berarti belum ada nilai, bukan nilai nol. Tugas file yang hanya ditandai selesai belum dinilai.

Daftar anggota adalah contoh, bukan data kelas resmi; aplikasi masih menyimulasikan satu profil siswa lokal, dan hasil contoh diberi label. Hasil lama yang belum menyimpan identitas ditandai sebagai profil lama dan tidak boleh dianggap sebagai nilai siswa tertentu. Di iOS/Android, file dibuka pada menu berbagi untuk dipilih sendiri penerimanya; di web file diunduh untuk dibagikan secara manual. Tidak ada pengiriman langsung, konfirmasi penerimaan, atau sinkronisasi ke wali kelas. Pastikan kelas, penerima, dan privasi data sebelum membagikan file.
