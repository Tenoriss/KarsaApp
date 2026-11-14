import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/school_identity.dart';
import '../../models/demo_account.dart';
import '../../models/user_role.dart';
import '../../providers/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _userController;
  late final TextEditingController _passController;

  @override
  void initState() {
    super.initState();
    final st = context.read<AppState>();
    _userController = TextEditingController(text: st.username);
    _passController = TextEditingController(text: st.password);
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final activeRole = state.role ?? UserRole.wali;
    final account = DemoAccount.forRole(activeRole);
    final isEducator = activeRole.isTeacher;

    if (_userController.text != state.username) {
      _userController.value = TextEditingValue(
        text: state.username,
        selection: TextSelection.collapsed(offset: state.username.length),
      );
    }
    if (_passController.text != state.password) {
      _passController.value = TextEditingValue(
        text: state.password,
        selection: TextSelection.collapsed(offset: state.password.length),
      );
    }

    return Container(
      color: c.card,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned(
            bottom: -45,
            left: -40,
            right: -40,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: DarkColorMapper.surface(
                  const Color(0xFFF8DCE5),
                  isDark: c.isDark,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -35,
            right: -35,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: DarkColorMapper.surface(
                  const Color(0xFFE0EDF8),
                  isDark: c.isDark,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: ClayStyles.soft(
                    color: const Color(0xFFF9E8E9),
                    isDark: c.isDark,
                    customRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(55),
                      bottomRight: Radius.circular(55),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        right: -60,
                        top: -55,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: DarkColorMapper.surface(
                              const Color(0xFFF8DBE2),
                              isDark: c.isDark,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -60,
                        bottom: 12,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: DarkColorMapper.surface(
                              const Color(0xFFDCEBF6),
                              isDark: c.isDark,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 18,
                        left: 20,
                        child: MotionPressable(
                          semanticsLabel: 'Kembali',
                          onTap: () => state.setScreen('welcome'),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: ClayStyles.soft(
                              color: Colors.white,
                              isDark: c.isDark,
                              radius: 23,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              KarsaIcons.chevronBack,
                              color: c.ink,
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        AppConstants.assetLoginLogo,
                        width: 195,
                        height: 185,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SchoolIdentity(compact: true),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MotionPressable(
                          semanticsLabel: 'Ubah mode terang atau gelap',
                          onTap: state.toggleDarkMode,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              c.isDark
                                  ? KarsaIcons.sunnyOutline
                                  : KarsaIcons.moonOutline,
                              color: c.rose,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        account.loginTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          height: 34 / 27,
                          fontWeight: FontWeight.w800,
                          color: c.ink,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        account.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ClayStyles.inset(
                          color: Colors.white,
                          isDark: c.isDark,
                          radius: 17,
                          borderColor: const Color(0xFFE8DDD7),
                          borderWidth: 1,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              isEducator
                                  ? KarsaIcons.cardOutline
                                  : KarsaIcons.personOutline,
                              color: const Color(0xFF728CAB),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _userController,
                                onChanged: state.setUsername,
                                onSubmitted: (_) => state.authenticate(),
                                autocorrect: false,
                                enableSuggestions: false,
                                style: TextStyle(fontSize: 15, color: c.ink),
                                decoration: InputDecoration(
                                  hintText: account.idFieldLabel,
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF9AAABD),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ClayStyles.inset(
                          color: Colors.white,
                          isDark: c.isDark,
                          radius: 17,
                          borderColor: const Color(0xFFE8DDD7),
                          borderWidth: 1,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              KarsaIcons.lockClosedOutline,
                              color: Color(0xFF728CAB),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _passController,
                                onChanged: state.setPassword,
                                onSubmitted: (_) => state.authenticate(),
                                obscureText: !state.showPassword,
                                style: TextStyle(fontSize: 15, color: c.ink),
                                decoration: const InputDecoration(
                                  hintText: 'Kata sandi',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF9AAABD),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            MotionPressable(
                              semanticsLabel: state.showPassword
                                  ? 'Sembunyikan kata sandi'
                                  : 'Tampilkan kata sandi',
                              onTap: state.toggleShowPassword,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  state.showPassword
                                      ? KarsaIcons.eyeOffOutline
                                      : KarsaIcons.eyeOutline,
                                  color: const Color(0xFF728CAB),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            state.error,
                            style: TextStyle(
                              color: c.rose,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MotionPressable(
                          onTap: () => state.setScreen('forgot'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Lupa kata sandi?', style: theme.text.link),
                          ),
                        ),
                      ),
                      MotionPressable(
                        semanticsLabel: 'Masuk',
                        onTap: () => state.authenticate(),
                        child: Container(
                          height: 58,
                          margin: const EdgeInsets.only(top: 12),
                          decoration: ClayStyles.raised(
                            color: c.rose,
                            isDark: c.isDark,
                            radius: 18,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Masuk →',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 22),
                        padding: const EdgeInsets.all(16),
                        decoration: ClayStyles.soft(
                          color: const Color(0xFFF2F6F8),
                          isDark: c.isDark,
                          radius: 16,
                          borderColor: const Color(0xFFDCE9EE),
                          borderWidth: 1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Akun demo · ${account.label}',
                              style: theme.text.itemTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${account.idFieldLabel}: ${account.id}',
                              style: theme.text.muted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kata sandi: ${account.password}',
                              style: theme.text.muted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Akun contoh untuk mencoba aplikasi, bukan autentikasi aman.',
                              style: theme.text.smallMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
