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
  Timer? _ticker;
  bool _scheduled = false;

  /// Animasi logo: detak skala, cahaya yang berdenyut, cincin yang mengembang,
  /// dan kilau yang menyapu logo satu kali tiap putaran.
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: AppConstants.splashLogoCycle,
    )..repeat();
  }

  /// Sisa detik yang ditampilkan. Splash sengaja lama (lihat
  /// [AppConstants.splashDuration]), jadi pengguna diberi hitungan mundur agar
  /// tahu aplikasi sedang menyiapkan, bukan macet.
  int _secondsLeft = AppConstants.splashDuration.inSeconds;

  void _maybeSchedule(AppState state) {
    if (_scheduled || !state.loaded) return;
    _scheduled = true;
    _timer = Timer(AppConstants.splashDuration, () {
      if (mounted) {
        state.finishSplash();
      }
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _secondsLeft = (_secondsLeft - 1).clamp(0, 999);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker?.cancel();
    _logoController.dispose();
    super.dispose();
  }

  /// 0..1 untuk progress bar.
  double get _progress {
    final total = AppConstants.splashDuration.inSeconds;
    if (total <= 0) return 1;
    return ((total - _secondsLeft) / total).clamp(0.0, 1.0);
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
                  child: _AnimatedKarsaLogo(controller: _logoController),
                ),
              ),
            ),
            Positioned(
              // Dinaikkan agar tidak menabrak hitungan mundur di dasar layar.
              bottom: 40,
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
            // Progress bar tipis di dasar layar.
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
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB1445D), // rose KARSA
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            // Hitungan mundur di pojok kanan bawah.
            Positioned(
              right: 16,
              bottom: 18,
              child: Text(
                'Masuk dalam $_secondsLeft detik',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0x9E203E5A),
                  letterSpacing: 0.2,
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
class _AnimatedKarsaLogo extends StatelessWidget {
  const _AnimatedKarsaLogo({required this.controller});

  final AnimationController controller;

  /// Rasio lebar:tinggi logo (305x290 px) supaya tidak gepeng.
  static const double _logoAspect = 305 / 290;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        // Posisi & ukuran mengikuti logo yang dihapus dari splash-art:
        // x 95..566 (lebar 471) dari 654, y 88..348 (tinggi 260) dari 1048.
        final double artW = c.maxWidth;
        final double artH = c.maxHeight;
        final double logoW = artW * (471 / 654);
        final double logoH = logoW / _logoAspect;
        // Titik tengah logo lama: ((95+566)/2)/654 = 0.505, ((88+348)/2)/1048 = 0.208
        final double centerX = artW * 0.505;
        final double centerY = artH * 0.208;

        return Stack(
          children: <Widget>[
            Positioned(
              left: centerX - logoW / 2,
              top: centerY - logoH / 2,
              width: logoW,
              height: logoH,
              child: AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget? child) {
                  final double t = controller.value; // 0..1
                  // Detak: skala 0.97 -> 1.03, halus (sin, bukan patah-patah).
                  final double pulse = 1 + 0.03 * math.sin(t * 2 * math.pi);
                  // Cahaya di belakang logo ikut berdenyut.
                  final double glow = 0.30 + 0.16 * math.sin(t * 2 * math.pi - 0.6);
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Aura lembut: logo terasa "menyala" di langit.
                      Transform.scale(
                        scale: pulse * 1.06,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: <Color>[
                                Colors.white.withValues(alpha: glow),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Cincin yang mengembang lalu memudar, tiap putaran.
                      _ExpandingRing(progress: t, diameter: logoW * 0.92),
                      // Logo itu sendiri, dengan detak.
                      Transform.scale(scale: pulse, child: child),
                    ],
                  );
                },
                child: Image.asset(
                  AppConstants.assetLoginLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Cincin tipis yang mengembang dari dalam logo lalu memudar.
class _ExpandingRing extends StatelessWidget {
  const _ExpandingRing({required this.progress, required this.diameter});

  final double progress;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    // Hanya tampil di 55% awal putaran, sisanya istirahat.
    final double raw = (progress / 0.55).clamp(0.0, 1.0);
    if (progress > 0.55) return const SizedBox.shrink();
    final double eased = Curves.easeOutCubic.transform(raw);
    final double size = diameter * (0.55 + 0.75 * eased);
    final double opacity = (1 - eased) * 0.55;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: opacity),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
