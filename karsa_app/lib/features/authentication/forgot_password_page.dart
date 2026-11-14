import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/page_header.dart';
import '../../models/demo_account.dart';
import '../../models/user_role.dart';
import '../../providers/app_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final account = DemoAccount.forRole(state.role ?? UserRole.wali);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Lupa kata sandi?',
          sub: 'Akun ini hanya untuk demonstrasi',
          onBack: () => state.setScreen('login'),
        ),
        ClayCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Informasi akun demo', style: theme.text.itemTitle),
              const SizedBox(height: 6),
              Text(
                '${account.forgotFieldLabel}: ${account.id}',
                style: theme.text.muted,
              ),
              const SizedBox(height: 4),
              Text(
                'Kata sandi: ${account.password}',
                style: theme.text.muted,
              ),
              const SizedBox(height: 6),
              Text(
                'Belum tersedia pemulihan akun sungguhan.',
                style: theme.text.smallMuted,
              ),
            ],
          ),
        ),
        KarsaButton(
          title: 'Kembali masuk',
          onTap: () => state.setScreen('login'),
        ),
      ],
    );
  }
}
