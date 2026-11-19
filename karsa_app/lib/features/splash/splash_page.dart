import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/clay_styles.dart';
import '../../providers/app_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _scheduled = false;

  /// Satu controller untuk seluruh splash.
  ///
  /// Animasi logo tidak memakai satu pola berulang: tiap lapis (melayang,
  /// detak, aura, dua cincin, sapuan cahaya) punya ritme sendiri yang
  /// dihitung dari nilai controller ini. Controller juga menggerakkan progress
  /// bar, jadi tidak perlu timer per detik dan tidak ada angka yang ditampilkan.
  late final AnimationController _splashController;

  @override
  void initState() {
    super.initState();
    _splashController = AnimationController(
      vsync: this,
      duration: AppConstants.splashDuration,
    )..forward();
  }

  void _maybeSchedule(AppState state) {
    if (_scheduled || !state.loaded) return;
    _scheduled = true;
    _timer = Timer(AppConstants.splashDuration, () {
      if (mounted) {
        state.finishSplash();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    _maybeSchedule(state);

    return Semantics(
      label: 'KARSA, Karitas Sahabat Belajar. Memuat aplikasi.',
      child: Container(
        color: AppColors.splashSky, // #A2D7FB
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Background splash: ilustrasi sekolah + siswa, warna asli.
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 654 / 1048,
                  child: Image.asset(
                    AppConstants.assetSplashArt,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Logo beranimasi, menggantikan logo tercetak yang ada di
            // ilustrasi aslinya (sudah dibersihkan dari aset).
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 654 / 1048,
                  child: _AnimatedKarsaLogo(controller: _splashController),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: ClayStyles.soft(
                  color: const Color(0xE6FFFAF7),
                  isDark: false,
                  radius: 24,
                  borderColor: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (int i = 0; i < 3; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: 7),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8526D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Menyiapkan pengalaman belajar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7F8A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Progress bar tipis di dasar layar. Angka hitungan mundur sengaja
            // tidak ditampilkan (permintaan pemilik produk).
            Positioned(
              bottom: 8,
              child: Container(
                width: 180,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0x99FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _splashController,
                  builder: (BuildContext context, Widget? _) {
                    return FractionallySizedBox(
                      widthFactor: _splashController.value.clamp(0.0, 1.0),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB1445D), // rose KARSA
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo KARSA yang beranimasi di atas background splash.
///
/// Background splash-art sudah dibersihkan dari logo tercetak, jadi logo ini
/// mengisi area yang sama dan boleh beranimasi tanpa membuat dua logo tampil.
///
/// Animasi terdiri dari beberapa lapis dengan ritme berbeda supaya gerakannya
/// variatif, bukan satu pola yang berulang terus:
///   1. melayang naik-turun + sedikit miring   (3,4 detik)
///   2. detak skala dengan kurva tidak simetris (2,5 detik)
///   3. aura putih menguat-melemah              (4,2 detik)
///   4. dua cincin mengembang, fase berbeda     (2,9 & 4,6 detik)
///   5. sapuan cahaya yang lewat sesekali       (5,0 detik)
class _AnimatedKarsaLogo extends StatelessWidget {
  const _AnimatedKarsaLogo({required this.controller});

  final AnimationController controller;

  /// Rasio isi logo setelah tepi transparannya dipotong (298x275 px).
  static const double _logoAspect = 298 / 275;

  /// Posisi logo KARSA yang tercetak di ilustrasi asli (splash-art.png,
  /// 654x1048): x 202..405, y 105..298 -- tengah (303.5, 201.5).
  ///
  /// Ukurannya dinaikkan ke 40% lebar ilustrasi (aslinya 31%): pada layar
  /// ponsel ukuran asli terlalu kecil untuk animasi, sementara 72% (percobaan
  /// pertama) terlalu besar dan menutupi awan.
  static const double _artAspect = 654 / 1048;
  static const double _logoWidthRatio = 0.40;
  static const double _logoCenterXRatio = 303.5 / 654; // 0.4641
  static const double _logoCenterYRatio = 201.5 / 1048; // 0.1923

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        // Ilustrasi digambar dengan BoxFit.contain di dalam kotak ini, jadi
        // hitung dulu kotak ilustrasi yang sebenarnya agar logo tetap menempel
        // pada posisinya di ilustrasi (juga di tablet/layar lebar).
        final double artW = c.maxWidth.clamp(0.0, double.infinity);
        final double artH = c.maxHeight;
        double boxW = artW;
        double boxH = artW / _artAspect;
        if (boxH > artH) {
          boxH = artH;
          boxW = artH * _artAspect;
        }
        final double left = (artW - boxW) / 2;
        final double top = (artH - boxH); // rata bawah (Alignment.bottomCenter)

        final double logoW = boxW * _logoWidthRatio;
        final double logoH = logoW / _logoAspect;
        final double centerX = left + boxW * _logoCenterXRatio;
        final double centerY = top + boxH * _logoCenterYRatio;

        return Stack(
          children: <Widget>[
            Positioned(
              left: centerX - logoW / 2,
              top: centerY - logoH / 2,
              width: logoW,
              height: logoH,
              child: _LogoAnimation(
                controller: controller,
                logoW: logoW,
                logoH: logoH,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Isi animasi logo: semua lapis digambar di sini.
class _LogoAnimation extends StatelessWidget {
  const _LogoAnimation({
    required this.controller,
    required this.logoW,
    required this.logoH,
  });

  final AnimationController controller;
  final double logoW;
  final double logoH;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        // Waktu global splash 0..1, dipakai bersama progress bar.
        final double seconds =
            controller.value * AppConstants.splashDuration.inSeconds;

        // Lapis 1: melayang naik-turun + sedikit miring (3,4 detik).
        final double floatPhase = (seconds / 3.4) % 1.0;
        final double floatY =
            -0.022 * math.sin(floatPhase * 2 * math.pi) * logoH;
        final double tilt = 0.012 * math.sin(floatPhase * 2 * math.pi + 0.7);

        // Lapis 2: detak skala, puncak tidak di tengah (2,5 detik).
        final double pulsePhase = (seconds / 2.5) % 1.0;
        final double pulse = 0.985 + 0.05 * _bell(pulsePhase, 0.45, 0.5);

        // Lapis 3: aura putih menguat-melemah (4,2 detik).
        final double haloPhase = (seconds / 4.2) % 1.0;
        final double glow = (0.30 + 0.34 * _bell(haloPhase, 0.40, 0.55))
            .clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.rotate(
            angle: tilt,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Aura lembut: logo terasa "menyala" di langit.
                Opacity(
                  opacity: glow,
                  child: Container(
                    width: logoW * 1.28,
                    height: logoW * 1.28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          Color(0x66FFFFFF),
                          Color(0x1AFFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: <double>[0.0, 0.42, 0.72],
                      ),
                    ),
                  ),
                ),
                // Dua cincin dengan ritme & fase berbeda.
                _ExpandingRing(
                  seconds: seconds,
                  cycle: 2.9,
                  delay: 0.0,
                  diameter: logoW,
                  maxScale: 1.75,
                  baseOpacity: 0.6,
                  strokeWidth: 2.5,
                ),
                _ExpandingRing(
                  seconds: seconds,
                  cycle: 4.6,
                  delay: 1.7,
                  diameter: logoW * 0.78,
                  maxScale: 1.9,
                  baseOpacity: 0.45,
                  strokeWidth: 2,
                ),
                // Sapuan cahaya yang lewat sesekali (5 detik).
                _LogoShine(
                  seconds: seconds,
                  cycle: 5.0,
                  width: logoW,
                  height: logoH,
                ),
                // Logo itu sendiri, dengan detak.
                Transform.scale(scale: pulse, child: child),
              ],
            ),
          ),
        );
      },
      child: Image.asset(
        AppConstants.assetLoginLogo,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Kurva "lonceng" 0..1: naik ke puncak di [peak], lalu turun lagi.
///
/// Dipakai agar detak dan aura punya ritme yang tidak simetris (tidak terasa
/// seperti animasi bolak-balik yang kaku).
double _bell(double phase, double peak, double sharpness) {
  final double d = (phase - peak).abs();
  final double window = d / sharpness.clamp(0.01, 1.0);
  if (window >= 1) return 0;
  final double x = 1 - window;
  return x * x * (3 - 2 * x); // smoothstep
}

/// Cincin tipis yang mengembang dari dalam logo lalu memudar.
///
/// [cycle] menentukan lama satu putaran (detik) dan [delay] menggeser fasenya,
/// jadi dua cincin bisa bergerak dengan ritme berbeda.
class _ExpandingRing extends StatelessWidget {
  const _ExpandingRing({
    required this.seconds,
    required this.cycle,
    required this.delay,
    required this.diameter,
    required this.maxScale,
    required this.baseOpacity,
    required this.strokeWidth,
  });

  final double seconds;
  final double cycle;
  final double delay;
  final double diameter;
  final double maxScale;
  final double baseOpacity;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final double phase = ((seconds + delay) / cycle) % 1.0;
    // Tampil di 62% awal putaran, sisanya istirahat.
    if (phase > 0.62) return const SizedBox.shrink();
    final double raw = (phase / 0.62).clamp(0.0, 1.0);
    final double eased = Curves.easeOutCubic.transform(raw);
    final double size = diameter * (0.55 + (maxScale - 0.55) * eased);
    final double opacity = (1 - eased) * baseOpacity;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: opacity),
            width: strokeWidth,
          ),
        ),
      ),
    );
  }
}

/// Sorot cahaya yang menyapu logo sesekali, bukan terus-menerus.
///
/// Muncul di 55%..90% setiap putaran [cycle], bergerak dari kanan ke kiri.
class _LogoShine extends StatelessWidget {
  const _LogoShine({
    required this.seconds,
    required this.cycle,
    required this.width,
    required this.height,
  });

  final double seconds;
  final double cycle;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double phase = (seconds / cycle) % 1.0;
    if (phase < 0.55 || phase > 0.90) return const SizedBox.shrink();
    final double local = ((phase - 0.55) / 0.35).clamp(0.0, 1.0);
    // Puncak kecerahan di tengah sapuan (segitiga 0 -> 0.55 -> 0).
    final double opacity = (1 - (local - 0.5).abs() * 2) * 0.55;
    final double dx = width * (1.2 - 2.4 * local);
    return IgnorePointer(
      child: ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.rotate(
              angle: -0.42,
              child: Container(
                width: width * 0.34,
                height: height * 1.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      const Color(0x00FFFFFF),
                      const Color(0xFFFFFFFF).withValues(alpha: opacity),
                      const Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
