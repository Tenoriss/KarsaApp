import 'dart:async';
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

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  Timer? _ticker;
  bool _scheduled = false;

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
            Align(
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
            Positioned(
              bottom: 20,
              // Hitungan mundur + progress bar: splash 18 detik harus terasa
              // hidup, bukan seperti aplikasi berhenti.
              child: Container(
                margin: const EdgeInsets.only(bottom: 26),
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
