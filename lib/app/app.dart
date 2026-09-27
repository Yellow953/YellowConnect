import 'package:flutter/material.dart';

import '../features/onboarding/view/onboarding_view.dart';
import 'app_shell.dart';
import 'dependencies.dart';
import 'splash_overlay.dart';
import 'theme.dart';

class YellowConnectApp extends StatelessWidget {
  const YellowConnectApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: SplashOverlay(
        child: ListenableBuilder(
          listenable: deps.onboarding,
          builder: (context, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: deps.onboarding.completed
                ? AppShell(deps: deps)
                : OnboardingView(presenter: deps.onboarding),
          ),
        ),
      ),
    );
  }
}
