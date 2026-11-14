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
  bool _scheduled = false;

  void _maybeSchedule(AppState state) {
    if (_scheduled || !state.loaded) return;
    _scheduled = true;
    _timer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        state.finishSplash();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          ],
        ),
      ),
    );
  }
}
