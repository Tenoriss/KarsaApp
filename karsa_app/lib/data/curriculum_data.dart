// GENERATED FROM ../curriculum.js BY tool/generate_curriculum.py
// Materi contoh untuk demo. Bukan kurikulum atau penilaian resmi sekolah.
import 'package:flutter/painting.dart';
import '../models/practice_item.dart';
import '../models/quiz_question.dart';
import '../models/subject_model.dart';

class CurriculumData {
  CurriculumData._();

  static const Map<String, SubjectMeta> subjectInfo = <String, SubjectMeta>{
    'Pendidikan Agama dan Budi Pekerti': SubjectMeta(name: 'Pendidikan Agama dan Budi Pekerti', icon: '🙏', color: Color(0xFFF9E5E9), colorHex: '#F9E5E9'),
    'Pendidikan Pancasila': SubjectMeta(name: 'Pendidikan Pancasila', icon: '🇮🇩', color: Color(0xFFF8E7E4), colorHex: '#F8E7E4'),
    'Bahasa Indonesia': SubjectMeta(name: 'Bahasa Indonesia', icon: '📕', color: Color(0xFFF9E8E9), colorHex: '#F9E8E9'),
    'Matematika': SubjectMeta(name: 'Matematika', icon: '📘', color: Color(0xFFE4EEF7), colorHex: '#E4EEF7'),
    'Ilmu Pengetahuan Alam dan Sosial (IPAS)': SubjectMeta(name: 'Ilmu Pengetahuan Alam dan Sosial (IPAS)', icon: '🌿', color: Color(0xFFE7F1E9), colorHex: '#E7F1E9'),
    'Seni dan Budaya': SubjectMeta(name: 'Seni dan Budaya', icon: '🎨', color: Color(0xFFF4E8F5), colorHex: '#F4E8F5'),
    'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)': SubjectMeta(name: 'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)', icon: '⚽', color: Color(0xFFE6F2E9), colorHex: '#E6F2E9'),
    'Bahasa Inggris': SubjectMeta(name: 'Bahasa Inggris', icon: '🔤', color: Color(0xFFE8EFF9), colorHex: '#E8EFF9'),
    'Muatan Lokal': SubjectMeta(name: 'Muatan Lokal', icon: '🌾', color: Color(0xFFFFF1DF), colorHex: '#FFF1DF'),
  };

  static const List<String> subjects = <String>[
    'Pendidikan Agama dan Budi Pekerti',
    'Pendidikan Pancasila',
    'Bahasa Indonesia',
    'Matematika',
    'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
    'Seni dan Budaya',
    'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)',
    'Bahasa Inggris',
    'Muatan Lokal',
  ];

  static const List<String> religions = <String>[
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  static const Map<String, List<String>> faithExamples = <String, List<String>>{
    'Islam': <String>['masjid', 'salat'],
    'Kristen': <String>['gereja', 'berdoa'],
    'Katolik': <String>['gereja', 'mengasihi sesama'],
    'Hindu': <String>['pura', 'berdoa'],
    'Buddha': <String>['vihara', 'berbuat baik'],
    'Konghucu': <String>['kelenteng', 'menghormati sesama'],
  };

  static const Map<String, List<QuizQuestion>> quizBank = <String, List<QuizQuestion>>{
    'Pendidikan Agama dan Budi Pekerti': <QuizQuestion>[
      QuizQuestion(question: 'Saat teman berbeda agama sedang beribadah, sikap kita adalah ...', choices: <String>['menghormati', 'mengganggu', 'mengejek', 'melarang'], answerIndex: 0, explanation: 'Setiap orang berhak beribadah dengan tenang.'),
      QuizQuestion(question: 'Contoh sikap jujur di sekolah adalah ...', choices: <String>['mencontek', 'mengakui kesalahan', 'menyalahkan teman', 'berbohong'], answerIndex: 1, explanation: 'Jujur berarti berkata dan bertindak sesuai kenyataan.'),
      QuizQuestion(question: 'Ketika teman kesulitan, sebaiknya kita ...', choices: <String>['menertawakan', 'membantu sesuai kemampuan', 'mengabaikan', 'mengusir'], answerIndex: 1, explanation: 'Membantu adalah wujud kepedulian.'),
      QuizQuestion(question: 'Sebelum menggunakan barang milik teman, kita perlu ...', choices: <String>['meminjam tanpa izin', 'meminta izin', 'menyembunyikan', 'menukar diam-diam'], answerIndex: 1, explanation: 'Meminta izin adalah sikap menghargai milik orang lain.'),
      QuizQuestion(question: 'Jika melakukan kesalahan, sebaiknya ...', choices: <String>['meminta maaf', 'berpura-pura tidak tahu', 'menuduh teman', 'menjauh'], answerIndex: 0, explanation: 'Meminta maaf dan memperbaiki kesalahan adalah sikap bertanggung jawab.'),
      QuizQuestion(question: 'Contoh bersyukur adalah ...', choices: <String>['merawat apa yang dimiliki', 'merusak barang', 'menghina teman', 'membuang makanan'], answerIndex: 0, explanation: 'Merawat pemberian adalah salah satu cara bersyukur.'),
      QuizQuestion(question: 'Saat berdoa bersama, sikap yang baik adalah ...', choices: <String>['tenang dan menghormati', 'berteriak', 'mengganggu', 'bermain keras'], answerIndex: 0, explanation: 'Suasana tenang membantu setiap orang berdoa.'),
      QuizQuestion(question: 'Bagaimana menyikapi teman yang berbeda pendapat?', choices: <String>['mengejek', 'mendengarkan dengan sopan', 'memaksa', 'menjauhi'], answerIndex: 1, explanation: 'Menghormati pendapat orang lain menjaga persaudaraan.'),
      QuizQuestion(question: 'Membuang sampah pada tempatnya menunjukkan ...', choices: <String>['kepedulian terhadap lingkungan', 'sikap boros', 'ketidakpedulian', 'kemarahan'], answerIndex: 0, explanation: 'Menjaga lingkungan adalah tanggung jawab bersama.'),
      QuizQuestion(question: 'Saat menerima bantuan, kita sebaiknya berkata ...', choices: <String>['maaf', 'terima kasih', 'tidak peduli', 'pergi'], answerIndex: 1, explanation: 'Ucapan terima kasih menunjukkan penghargaan.'),
    ],
    'Pendidikan Pancasila': <QuizQuestion>[
      QuizQuestion(question: 'Lambang sila pertama Pancasila adalah ...', choices: <String>['bintang', 'rantai', 'pohon beringin', 'banteng'], answerIndex: 0, explanation: 'Sila pertama dilambangkan bintang.'),
      QuizQuestion(question: 'Bermusyawarah dilakukan untuk ...', choices: <String>['mencari kesepakatan', 'memaksa teman', 'bertengkar', 'mencari pemenang'], answerIndex: 0, explanation: 'Musyawarah mencari keputusan bersama.'),
      QuizQuestion(question: 'Contoh gotong royong adalah ...', choices: <String>['membersihkan kelas bersama', 'membiarkan teman bekerja sendiri', 'merusak taman', 'mengejek'], answerIndex: 0, explanation: 'Gotong royong berarti bekerja bersama.'),
      QuizQuestion(question: 'Aturan kelas perlu dipatuhi agar ...', choices: <String>['suasana tertib', 'bebas bertengkar', 'teman takut', 'tidak belajar'], answerIndex: 0, explanation: 'Aturan membantu menjaga ketertiban.'),
      QuizQuestion(question: 'Ketika teman berbeda suku, kita harus ...', choices: <String>['menghargai', 'menjauhi', 'mengejek', 'membeda-bedakan'], answerIndex: 0, explanation: 'Keberagaman harus dihargai.'),
      QuizQuestion(question: 'Hak siswa di sekolah antara lain ...', choices: <String>['mendapat pelajaran', 'mengganggu kelas', 'merusak fasilitas', 'melanggar aturan'], answerIndex: 0, explanation: 'Mendapat pendidikan adalah hak siswa.'),
      QuizQuestion(question: 'Contoh kewajiban siswa adalah ...', choices: <String>['menjaga kebersihan kelas', 'menuntut hadiah', 'memakai barang orang lain', 'mengabaikan tugas'], answerIndex: 0, explanation: 'Menjaga kebersihan merupakan tanggung jawab bersama.'),
      QuizQuestion(question: 'Warna bendera Indonesia adalah ...', choices: <String>['merah putih', 'biru putih', 'hijau kuning', 'merah biru'], answerIndex: 0, explanation: 'Bendera Indonesia berwarna merah dan putih.'),
      QuizQuestion(question: 'Sebelum keputusan bersama, kita sebaiknya ...', choices: <String>['mendengarkan pendapat', 'memotong pembicaraan', 'memaksa', 'meninggalkan rapat'], answerIndex: 0, explanation: 'Mendengar pendapat membantu musyawarah.'),
      QuizQuestion(question: 'Berbagi tugas secara adil mencerminkan ...', choices: <String>['keadilan', 'permusuhan', 'keegoisan', 'kemalasan'], answerIndex: 0, explanation: 'Keadilan berarti memperlakukan orang secara layak.'),
    ],
    'Bahasa Indonesia': <QuizQuestion>[
      QuizQuestion(question: 'Kalimat tanya diakhiri dengan tanda ...', choices: <String>['tanya', 'titik', 'koma', 'petik'], answerIndex: 0, explanation: 'Kalimat tanya menggunakan tanda tanya.'),
      QuizQuestion(question: 'Lawan kata besar adalah ...', choices: <String>['kecil', 'tinggi', 'lebar', 'panjang'], answerIndex: 0, explanation: 'Kecil adalah lawan kata besar.'),
      QuizQuestion(question: 'Ibu sedang ... buku.', choices: <String>['membaca', 'berenang', 'berlari', 'melompat'], answerIndex: 0, explanation: 'Buku dapat dibaca.'),
      QuizQuestion(question: 'Awal kalimat menggunakan ...', choices: <String>['huruf kapital', 'angka', 'huruf kecil saja', 'simbol'], answerIndex: 0, explanation: 'Awal kalimat diawali huruf kapital.'),
      QuizQuestion(question: 'Sapaan yang sopan adalah ...', choices: <String>['Selamat pagi, Bu.', 'Hei kamu!', 'Diam!', 'Pergi!'], answerIndex: 0, explanation: 'Sapaan sopan menunjukkan hormat.'),
      QuizQuestion(question: 'Gagasan utama adalah ...', choices: <String>['inti pembahasan paragraf', 'nama penulis', 'jumlah kata', 'tanda baca'], answerIndex: 0, explanation: 'Gagasan utama merupakan inti paragraf.'),
      QuizQuestion(question: 'Kata baku yang tepat adalah ...', choices: <String>['aktivitas', 'aktifitas', 'aktipitas', 'aktivitaz'], answerIndex: 0, explanation: 'Bentuk baku adalah aktivitas.'),
      QuizQuestion(question: 'Tanda titik digunakan di akhir ...', choices: <String>['kalimat pernyataan', 'kalimat tanya', 'judul saja', 'kata sambung'], answerIndex: 0, explanation: 'Kalimat pernyataan umumnya diakhiri titik.'),
      QuizQuestion(question: 'Persamaan kata senang adalah ...', choices: <String>['gembira', 'sedih', 'marah', 'takut'], answerIndex: 0, explanation: 'Gembira bermakna senang.'),
      QuizQuestion(question: 'Saat teman berbicara, kita sebaiknya ...', choices: <String>['mendengarkan', 'memotong', 'berteriak', 'mengejek'], answerIndex: 0, explanation: 'Mendengarkan adalah keterampilan berkomunikasi.'),
    ],
    'Matematika': <QuizQuestion>[
      QuizQuestion(question: '4 kotak berisi 7 pensil per kotak. Jumlah pensil adalah ...', choices: <String>['24', '28', '32', '26'], answerIndex: 1, explanation: '4 × 7 = 28.'),
      QuizQuestion(question: '36 apel dikurangi 9 apel menjadi ...', choices: <String>['25', '27', '29', '30'], answerIndex: 1, explanation: '36 − 9 = 27.'),
      QuizQuestion(question: '24 permen dibagi rata kepada 6 anak. Setiap anak mendapat ...', choices: <String>['3', '4', '5', '6'], answerIndex: 1, explanation: '24 ÷ 6 = 4.'),
      QuizQuestion(question: '12 + 3 × 5 = ...', choices: <String>['75', '27', '60', '30'], answerIndex: 1, explanation: 'Kerjakan perkalian lebih dahulu: 12 + 15 = 27.'),
      QuizQuestion(question: 'Keliling persegi panjang 14 m × 6 m adalah ...', choices: <String>['20 m', '40 m', '84 m', '28 m'], answerIndex: 1, explanation: 'Keliling = 2 × (14 + 6) = 40 m.'),
      QuizQuestion(question: 'Setengah dari 18 adalah ...', choices: <String>['8', '9', '10', '12'], answerIndex: 1, explanation: '18 ÷ 2 = 9.'),
      QuizQuestion(question: '3/4 ditambah 1/4 sama dengan ...', choices: <String>['1/4', '1', '1/2', '2'], answerIndex: 1, explanation: '4/4 sama dengan 1.'),
      QuizQuestion(question: 'Nilai 6 × 8 adalah ...', choices: <String>['42', '48', '54', '56'], answerIndex: 1, explanation: '6 × 8 = 48.'),
      QuizQuestion(question: 'Satu meter sama dengan ...', choices: <String>['10 cm', '100 cm', '1000 cm', '50 cm'], answerIndex: 1, explanation: '1 meter = 100 sentimeter.'),
      QuizQuestion(question: 'Rata-rata 6, 8 dan 10 adalah ...', choices: <String>['6', '8', '10', '12'], answerIndex: 1, explanation: '(6 + 8 + 10) ÷ 3 = 8.'),
    ],
    'Ilmu Pengetahuan Alam dan Sosial (IPAS)': <QuizQuestion>[
      QuizQuestion(question: 'Bagian tumbuhan yang menyerap air adalah ...', choices: <String>['daun', 'akar', 'bunga', 'buah'], answerIndex: 1, explanation: 'Akar menyerap air dan mineral.'),
      QuizQuestion(question: 'Tumbuhan menggunakan cahaya untuk ...', choices: <String>['berjalan', 'membuat makanan', 'berbicara', 'berenang'], answerIndex: 1, explanation: 'Tumbuhan membuat makanan melalui fotosintesis.'),
      QuizQuestion(question: 'Air yang dipanaskan dapat berubah menjadi ...', choices: <String>['uap', 'batu', 'tanah', 'daun'], answerIndex: 0, explanation: 'Air dapat menguap.'),
      QuizQuestion(question: 'Hewan yang bertelur adalah ...', choices: <String>['kucing', 'ayam', 'sapi', 'kambing'], answerIndex: 1, explanation: 'Ayam berkembang biak dengan bertelur.'),
      QuizQuestion(question: 'Sumber energi utama bagi bumi adalah ...', choices: <String>['bulan', 'matahari', 'tanah', 'awan'], answerIndex: 1, explanation: 'Matahari memberikan cahaya dan panas.'),
      QuizQuestion(question: 'Organ untuk bernapas pada manusia adalah ...', choices: <String>['jantung', 'paru-paru', 'lambung', 'tulang'], answerIndex: 1, explanation: 'Paru-paru berfungsi dalam pernapasan.'),
      QuizQuestion(question: 'Contoh kegiatan ekonomi adalah ...', choices: <String>['jual beli', 'tidur', 'bermain sendiri', 'berdiam'], answerIndex: 0, explanation: 'Jual beli merupakan kegiatan ekonomi.'),
      QuizQuestion(question: 'Air hujan berasal dari proses ...', choices: <String>['pengembunan uap air', 'pembakaran', 'pengeringan tanah', 'pembekuan batu'], answerIndex: 0, explanation: 'Uap air mengembun membentuk awan dan hujan.'),
      QuizQuestion(question: 'Menghemat listrik dapat dilakukan dengan ...', choices: <String>['mematikan lampu saat tidak dipakai', 'menyalakan lampu sepanjang hari', 'membuka kulkas terus', 'membiarkan televisi menyala'], answerIndex: 0, explanation: 'Mematikan alat saat tidak dipakai menghemat energi.'),
      QuizQuestion(question: 'Peta membantu kita mengetahui ...', choices: <String>['letak suatu tempat', 'rasa makanan', 'warna suara', 'umur pohon'], answerIndex: 0, explanation: 'Peta menunjukkan lokasi dan wilayah.'),
    ],
    'Seni dan Budaya': <QuizQuestion>[
      QuizQuestion(question: 'Eco-print memakai bahan alami seperti ...', choices: <String>['daun', 'plastik baru', 'kaca', 'besi'], answerIndex: 0, explanation: 'Daun dapat menghasilkan motif pada kain.'),
      QuizQuestion(question: 'Warna merah dan kuning dapat menghasilkan ...', choices: <String>['jingga', 'hijau', 'ungu', 'hitam'], answerIndex: 0, explanation: 'Campuran merah dan kuning menghasilkan jingga.'),
      QuizQuestion(question: 'Bahan bekas dapat dijadikan ...', choices: <String>['karya seni', 'sampah saja', 'udara', 'air'], answerIndex: 0, explanation: 'Bahan bekas dapat diolah menjadi karya.'),
      QuizQuestion(question: 'Alat untuk melukis adalah ...', choices: <String>['kuas', 'penggaris saja', 'sendok', 'sapu'], answerIndex: 0, explanation: 'Kuas digunakan untuk melukis.'),
      QuizQuestion(question: 'Garis, warna dan bentuk termasuk ...', choices: <String>['unsur seni rupa', 'jenis cuaca', 'alat olahraga', 'satuan waktu'], answerIndex: 0, explanation: 'Ketiganya merupakan unsur seni rupa.'),
      QuizQuestion(question: 'Karya tiga dimensi memiliki ...', choices: <String>['panjang lebar dan tinggi', 'panjang saja', 'suara saja', 'warna saja'], answerIndex: 0, explanation: 'Karya tiga dimensi memiliki ruang.'),
      QuizQuestion(question: 'Saat menggunakan gunting kita perlu ...', choices: <String>['berhati-hati', 'berlari', 'bercanda dengan ujung gunting', 'melemparnya'], answerIndex: 0, explanation: 'Gunting digunakan dengan hati-hati.'),
      QuizQuestion(question: 'Sikap terhadap karya teman adalah ...', choices: <String>['menghargai', 'mengejek', 'merobek', 'menyembunyikan'], answerIndex: 0, explanation: 'Setiap karya patut dihargai.'),
      QuizQuestion(question: 'Contoh bahan alami untuk kerajinan adalah ...', choices: <String>['biji-bijian', 'baterai', 'plastik', 'kaleng tajam'], answerIndex: 0, explanation: 'Biji-bijian berasal dari alam.'),
      QuizQuestion(question: 'Sebelum membuat karya sebaiknya ...', choices: <String>['merencanakan ide', 'langsung merusak bahan', 'membuang alat', 'mengganggu teman'], answerIndex: 0, explanation: 'Perencanaan membantu proses berkarya.'),
    ],
    'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)': <QuizQuestion>[
      QuizQuestion(question: 'Sebelum olahraga sebaiknya melakukan ...', choices: <String>['pemanasan', 'tidur', 'makan berlebihan', 'diam selamanya'], answerIndex: 0, explanation: 'Pemanasan membantu menyiapkan tubuh.'),
      QuizQuestion(question: 'Setelah berolahraga kita perlu ...', choices: <String>['minum air', 'membuang air', 'tidak istirahat', 'berlari tanpa henti'], answerIndex: 0, explanation: 'Minum membantu mengganti cairan tubuh.'),
      QuizQuestion(question: 'Permainan sepak bola menggunakan ...', choices: <String>['bola', 'raket', 'tongkat renang', 'kertas'], answerIndex: 0, explanation: 'Sepak bola dimainkan menggunakan bola.'),
      QuizQuestion(question: 'Gerak berpindah tempat disebut ...', choices: <String>['lokomotor', 'diam', 'istirahat', 'menggambar'], answerIndex: 0, explanation: 'Gerak lokomotor berpindah tempat.'),
      QuizQuestion(question: 'Mencuci tangan sebaiknya menggunakan ...', choices: <String>['sabun dan air', 'cat', 'pasir saja', 'tinta'], answerIndex: 0, explanation: 'Sabun dan air membantu membersihkan tangan.'),
      QuizQuestion(question: 'Makanan bergizi diperlukan untuk ...', choices: <String>['tumbuh dan sehat', 'mengotori kelas', 'merusak tubuh', 'tidak bergerak'], answerIndex: 0, explanation: 'Gizi seimbang membantu pertumbuhan.'),
      QuizQuestion(question: 'Saat bermain bersama, kita harus ...', choices: <String>['sportif', 'curang', 'mengejek', 'memukul'], answerIndex: 0, explanation: 'Sportif berarti jujur dan menghargai aturan.'),
      QuizQuestion(question: 'Pendinginan dilakukan ...', choices: <String>['sesudah olahraga', 'sebelum tidur saja', 'sebelum mandi saja', 'saat makan'], answerIndex: 0, explanation: 'Pendinginan membantu tubuh pulih setelah olahraga.'),
      QuizQuestion(question: 'Contoh gerak lokomotor adalah ...', choices: <String>['berlari', 'menekuk tangan di tempat', 'berdiri diam', 'duduk'], answerIndex: 0, explanation: 'Berlari berpindah tempat.'),
      QuizQuestion(question: 'Jika merasa pusing saat olahraga, sebaiknya ...', choices: <String>['berhenti dan beri tahu guru', 'memaksa diri', 'menyembunyikan', 'terus berlari'], answerIndex: 0, explanation: 'Berhenti dan meminta bantuan menjaga keselamatan.'),
    ],
    'Bahasa Inggris': <QuizQuestion>[
      QuizQuestion(question: 'Apa arti “book”?', choices: <String>['buku', 'meja', 'kursi', 'tas'], answerIndex: 0, explanation: 'Book berarti buku.'),
      QuizQuestion(question: 'Sapaan pagi dalam bahasa Inggris adalah ...', choices: <String>['Good morning', 'Good night', 'Goodbye', 'Sorry'], answerIndex: 0, explanation: 'Good morning digunakan pada pagi hari.'),
      QuizQuestion(question: 'Apa arti “thank you”?', choices: <String>['terima kasih', 'selamat tinggal', 'maaf', 'selamat malam'], answerIndex: 0, explanation: 'Thank you berarti terima kasih.'),
      QuizQuestion(question: 'Warna “red” berarti ...', choices: <String>['merah', 'biru', 'hijau', 'kuning'], answerIndex: 0, explanation: 'Red berarti merah.'),
      QuizQuestion(question: 'Angka “five” adalah ...', choices: <String>['lima', 'empat', 'enam', 'tujuh'], answerIndex: 0, explanation: 'Five berarti lima.'),
      QuizQuestion(question: '“I am a student” berarti ...', choices: <String>['Saya seorang siswa', 'Saya seorang guru', 'Saya sedang tidur', 'Saya punya buku'], answerIndex: 0, explanation: 'Student berarti siswa.'),
      QuizQuestion(question: 'Lawan kata “big” adalah ...', choices: <String>['small', 'tall', 'happy', 'long'], answerIndex: 0, explanation: 'Small berarti kecil.'),
      QuizQuestion(question: '“Goodbye” diucapkan saat ...', choices: <String>['berpisah', 'bangun tidur', 'berterima kasih', 'meminta bantuan'], answerIndex: 0, explanation: 'Goodbye adalah ucapan perpisahan.'),
      QuizQuestion(question: '“Cat” adalah ...', choices: <String>['kucing', 'anjing', 'burung', 'ikan'], answerIndex: 0, explanation: 'Cat berarti kucing.'),
      QuizQuestion(question: '“My name is ...” digunakan untuk ...', choices: <String>['memperkenalkan nama', 'menanyakan waktu', 'menghitung', 'menutup pintu'], answerIndex: 0, explanation: 'Ungkapan ini memperkenalkan nama.'),
    ],
    'Muatan Lokal': <QuizQuestion>[
      QuizQuestion(question: 'Dalam contoh bahasa Jawa, “matur nuwun” berarti ...', choices: <String>['terima kasih', 'selamat pagi', 'permisi', 'maaf'], answerIndex: 0, explanation: 'Matur nuwun adalah ucapan terima kasih.'),
      QuizQuestion(question: 'Bahasa daerah perlu ...', choices: <String>['dilestarikan', 'dilupakan', 'diejek', 'dilarang'], answerIndex: 0, explanation: 'Bahasa daerah merupakan bagian budaya.'),
      QuizQuestion(question: 'Kepada orang yang lebih tua, kita sebaiknya berbicara ...', choices: <String>['sopan', 'kasar', 'berteriak', 'mengejek'], answerIndex: 0, explanation: 'Berbahasa sopan menunjukkan hormat.'),
      QuizQuestion(question: 'Budaya daerah dapat dipelajari melalui ...', choices: <String>['cerita dan seni', 'merusak karya', 'mengejek bahasa', 'melupakan tradisi'], answerIndex: 0, explanation: 'Cerita dan seni membantu mengenal budaya.'),
      QuizQuestion(question: '“Sugeng enjing” merupakan sapaan ...', choices: <String>['selamat pagi', 'selamat malam', 'terima kasih', 'selamat tinggal'], answerIndex: 0, explanation: 'Sugeng enjing berarti selamat pagi.'),
      QuizQuestion(question: 'Menghargai tradisi daerah teman menunjukkan ...', choices: <String>['toleransi', 'permusuhan', 'kesombongan', 'kemalasan'], answerIndex: 0, explanation: 'Menghormati budaya lain menunjukkan toleransi.'),
      QuizQuestion(question: 'Kesenian daerah merupakan bagian dari ...', choices: <String>['warisan budaya', 'alat hitung', 'cuaca', 'satuan panjang'], answerIndex: 0, explanation: 'Kesenian daerah adalah warisan budaya.'),
      QuizQuestion(question: 'Cerita rakyat dapat menyampaikan ...', choices: <String>['pesan atau nilai', 'hanya angka', 'ukuran cuaca', 'jadwal kelas'], answerIndex: 0, explanation: 'Cerita rakyat sering mengandung nilai kehidupan.'),
      QuizQuestion(question: 'Belajar bahasa daerah dapat dilakukan dengan ...', choices: <String>['berlatih bersama', 'mengejek penutur', 'melarang teman', 'tidak mendengarkan'], answerIndex: 0, explanation: 'Latihan membantu memahami bahasa.'),
      QuizQuestion(question: 'Kita menghormati teman dari daerah lain dengan ...', choices: <String>['mengenal dan menghargai budayanya', 'menertawakan logatnya', 'memaksakan kebiasaan', 'menjauhinya'], answerIndex: 0, explanation: 'Keberagaman daerah patut dihargai.'),
    ],
  };

  static const Map<String, List<EssayPrompt>> practiceBank = <String, List<EssayPrompt>>{
    'Pendidikan Agama dan Budi Pekerti': <EssayPrompt>[
      EssayPrompt(prompt: 'Bagaimana cara menghormati teman yang berbeda agama?', sampleAnswer: 'Berikan kesempatan teman beribadah dan hargai perbedaannya.'),
      EssayPrompt(prompt: 'Ceritakan contoh tindakan jujur di sekolah.', sampleAnswer: 'Misalnya mengakui kesalahan kepada guru.'),
      EssayPrompt(prompt: 'Bagaimana kamu menunjukkan rasa syukur?', sampleAnswer: 'Menjaga kesehatan dan merawat pemberian.'),
      EssayPrompt(prompt: 'Apa yang dapat kamu lakukan saat teman membutuhkan bantuan?', sampleAnswer: 'Menawarkan bantuan sesuai kemampuan.'),
      EssayPrompt(prompt: 'Mengapa kita perlu meminta maaf?', sampleAnswer: 'Agar memperbaiki kesalahan dan menjaga hubungan baik.'),
    ],
    'Pendidikan Pancasila': <EssayPrompt>[
      EssayPrompt(prompt: 'Apa arti gotong royong?', sampleAnswer: 'Bekerja bersama untuk tujuan bersama.'),
      EssayPrompt(prompt: 'Berikan contoh musyawarah di kelas.', sampleAnswer: 'Berdiskusi untuk menentukan kegiatan kelas.'),
      EssayPrompt(prompt: 'Bagaimana menghargai keberagaman?', sampleAnswer: 'Berteman dan menghormati perbedaan.'),
      EssayPrompt(prompt: 'Sebutkan satu hak dan satu kewajiban siswa.', sampleAnswer: 'Hak mendapat pelajaran; kewajiban mematuhi aturan.'),
      EssayPrompt(prompt: 'Mengapa aturan kelas penting?', sampleAnswer: 'Agar kegiatan belajar berlangsung tertib.'),
    ],
    'Bahasa Indonesia': <EssayPrompt>[
      EssayPrompt(prompt: 'Ceritakan kegiatanmu sebelum sekolah.', sampleAnswer: 'Aku bangun, mandi, sarapan lalu berangkat.'),
      EssayPrompt(prompt: 'Buat kalimat dengan kata belajar.', sampleAnswer: 'Aku belajar membaca bersama ibu.'),
      EssayPrompt(prompt: 'Apa fungsi tanda titik?', sampleAnswer: 'Mengakhiri kalimat pernyataan.'),
      EssayPrompt(prompt: 'Apa gagasan utama paragraf?', sampleAnswer: 'Inti yang dibahas dalam paragraf.'),
      EssayPrompt(prompt: 'Buat kalimat tanya yang sopan.', sampleAnswer: 'Kapan kita mulai belajar, Bu?'),
    ],
    'Matematika': <EssayPrompt>[
      EssayPrompt(prompt: 'Mengapa 3 × 4 sama dengan 4 × 3?', sampleAnswer: 'Keduanya berjumlah 12 karena perkalian dapat ditukar.'),
      EssayPrompt(prompt: 'Bagaimana membagi 8 kue kepada 2 anak?', sampleAnswer: 'Setiap anak mendapat 4 kue.'),
      EssayPrompt(prompt: 'Apa arti setengah?', sampleAnswer: 'Satu dari dua bagian yang sama besar.'),
      EssayPrompt(prompt: 'Bagaimana menghitung keliling persegi dengan sisi 5 cm?', sampleAnswer: 'Kelilingnya 4 × 5 = 20 cm.'),
      EssayPrompt(prompt: 'Berikan contoh pecahan dalam kehidupan sehari-hari.', sampleAnswer: 'Setengah kue dapat ditulis 1/2.'),
    ],
    'Ilmu Pengetahuan Alam dan Sosial (IPAS)': <EssayPrompt>[
      EssayPrompt(prompt: 'Apa yang dibutuhkan tumbuhan untuk tumbuh?', sampleAnswer: 'Air, cahaya, udara, dan nutrisi.'),
      EssayPrompt(prompt: 'Apa fungsi akar?', sampleAnswer: 'Menyerap air dan menopang tumbuhan.'),
      EssayPrompt(prompt: 'Berikan contoh gaya yang membuat benda bergerak.', sampleAnswer: 'Mendorong meja membuatnya bergerak.'),
      EssayPrompt(prompt: 'Mengapa kita perlu menghemat listrik?', sampleAnswer: 'Agar energi digunakan dengan bijak.'),
      EssayPrompt(prompt: 'Jelaskan satu kegiatan ekonomi di sekitar rumah.', sampleAnswer: 'Jual beli sayur di pasar adalah kegiatan ekonomi.'),
    ],
    'Seni dan Budaya': <EssayPrompt>[
      EssayPrompt(prompt: 'Apa itu eco-print?', sampleAnswer: 'Membuat motif dengan bahan alami seperti daun.'),
      EssayPrompt(prompt: 'Bagaimana memanfaatkan bahan bekas untuk seni?', sampleAnswer: 'Mengolah kardus bekas menjadi hiasan.'),
      EssayPrompt(prompt: 'Sebutkan dua unsur seni rupa.', sampleAnswer: 'Garis dan warna.'),
      EssayPrompt(prompt: 'Mengapa kita perlu menghargai karya teman?', sampleAnswer: 'Setiap orang memiliki ide dan usaha berbeda.'),
      EssayPrompt(prompt: 'Ceritakan ide karya dari daun.', sampleAnswer: 'Menyusun daun menjadi bentuk hewan.'),
    ],
    'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)': <EssayPrompt>[
      EssayPrompt(prompt: 'Mengapa perlu pemanasan?', sampleAnswer: 'Untuk menyiapkan tubuh sebelum bergerak.'),
      EssayPrompt(prompt: 'Apa arti bermain sportif?', sampleAnswer: 'Bermain jujur dan menghargai aturan.'),
      EssayPrompt(prompt: 'Sebutkan contoh gerak berpindah tempat.', sampleAnswer: 'Berlari dan berjalan.'),
      EssayPrompt(prompt: 'Apa yang dilakukan setelah berolahraga?', sampleAnswer: 'Pendinginan dan minum air.'),
      EssayPrompt(prompt: 'Mengapa mencuci tangan penting?', sampleAnswer: 'Membantu membersihkan kotoran dan kuman.'),
    ],
    'Bahasa Inggris': <EssayPrompt>[
      EssayPrompt(prompt: 'Perkenalkan namamu dalam bahasa Inggris.', sampleAnswer: 'My name is Dimas.'),
      EssayPrompt(prompt: 'Apa arti thank you?', sampleAnswer: 'Terima kasih.'),
      EssayPrompt(prompt: 'Sebutkan tiga warna dalam bahasa Inggris.', sampleAnswer: 'Red, blue, and yellow.'),
      EssayPrompt(prompt: 'Apa yang kamu ucapkan pada pagi hari?', sampleAnswer: 'Good morning.'),
      EssayPrompt(prompt: 'Buat kalimat menggunakan kata book.', sampleAnswer: 'This is my book.'),
    ],
    'Muatan Lokal': <EssayPrompt>[
      EssayPrompt(prompt: 'Apa arti matur nuwun?', sampleAnswer: 'Terima kasih.'),
      EssayPrompt(prompt: 'Mengapa bahasa daerah perlu dilestarikan?', sampleAnswer: 'Bahasa daerah adalah bagian dari budaya.'),
      EssayPrompt(prompt: 'Bagaimana menyapa orang yang lebih tua?', sampleAnswer: 'Gunakan sapaan sopan sesuai kebiasaan setempat.'),
      EssayPrompt(prompt: 'Sebutkan contoh kesenian daerah yang kamu kenal.', sampleAnswer: 'Misalnya wayang atau tari daerah.'),
      EssayPrompt(prompt: 'Bagaimana cara menghargai budaya teman?', sampleAnswer: 'Belajar dan tidak mengejek perbedaannya.'),
    ],
  };

  static String normalizeSubject(String? raw) {
    if (raw == null || raw.isEmpty) return 'Matematika';
    if (raw == 'IPA') return 'Ilmu Pengetahuan Alam dan Sosial (IPAS)';
    return raw;
  }

  static List<String> subjectsForClass(String className) {
    final digits = className.replaceAll(RegExp(r'\D'), '');
    final grade = int.tryParse(digits) ?? 1;
    return subjects
        .where((s) => s != 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' || grade >= 3)
        .toList();
  }

  static SubjectMeta metaFor(String subject) {
    final normalized = normalizeSubject(subject);
    return subjectInfo[normalized] ?? subjectInfo['Matematika']!;
  }

  static List<QuizQuestion> questionsFor(String subject, String? religion) {
    final normalized = normalizeSubject(subject);
    final base = quizBank[normalized] ?? quizBank['Matematika']!;
    final faith = (religion != null && religion.isNotEmpty) ? faithExamples[religion] : null;
    if (normalized != 'Pendidikan Agama dan Budi Pekerti' || faith == null) {
      return base;
    }
    final QuizQuestion first = religion == 'Katolik'
        ? QuizQuestion(
            question: 'Dalam pembinaan iman Katolik, teladan Yesus mengajak kita untuk ...',
            choices: <String>['mengasihi sesama', 'mengejek teman', 'berbuat curang', 'mengabaikan teman'],
            answerIndex: 0,
            explanation: 'Mengasihi sesama merupakan bagian dari teladan Yesus.',
          )
        : QuizQuestion(
            question: 'Tempat ibadah yang dikenal dalam agama $religion adalah ...',
            choices: <String>[faith[0], 'perpustakaan', 'pasar', 'lapangan'],
            answerIndex: 0,
            explanation: '${faith[0]} merupakan salah satu tempat ibadah umat $religion.',
          );
    return <QuizQuestion>[first, ...base.skip(1)];
  }

  static List<EssayPrompt> exercisesFor(String subject, String? religion) {
    final normalized = normalizeSubject(subject);
    final base = practiceBank[normalized] ?? practiceBank['Matematika']!;
    final faith = (religion != null && religion.isNotEmpty) ? faithExamples[religion] : null;
    if (normalized != 'Pendidikan Agama dan Budi Pekerti' || faith == null) {
      return base;
    }
    final first = EssayPrompt(
      prompt: 'Ceritakan contoh ${faith[1]} dalam kehidupan sehari-hari sesuai ajaran $religion.',
      sampleAnswer: 'Jawaban dapat beragam. Diskusikan dengan guru dan keluarga sesuai ajaran $religion.',
    );
    return <EssayPrompt>[first, ...base.skip(1)];
  }
}
