import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/karsa_theme.dart';
import 'providers/app_state.dart';
import 'shared/widgets/main_shell.dart';

class KarsaApp extends StatefulWidget {
  final AppState? injectedState;

  const KarsaApp({super.key, this.injectedState});

  @override
  State<KarsaApp> createState() => _KarsaAppState();
}

class _KarsaAppState extends State<KarsaApp> with WidgetsBindingObserver {
  late final AppState _internalState;
  bool _ownsState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.injectedState != null) {
      _internalState = widget.injectedState!;
    } else {
      _internalState = AppState();
      _ownsState = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _internalState.refreshNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsState) {
      _internalState.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _internalState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final colors = state.isDark ? AppColors.dark : AppColors.light;
          final typography = AppTypography(colors);
          final overlayStyle = (state.isDark && state.screen != 'splash')
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: KarsaThemeScope(
              colors: colors,
              text: typography,
              child: MaterialApp(
                title: 'KARSA',
                debugShowCheckedModeBanner: false,
                theme: KarsaTheme.buildMaterialTheme(AppColors.light),
                darkTheme: KarsaTheme.buildMaterialTheme(AppColors.dark),
                themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
                home: const MainShell(),
              ),
            ),
          );
        },
      ),
    );
  }
}
