import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/logo.dart';
import '../presenter/onboarding_presenter.dart';

/// First launch. Dark, so it continues straight on from the splash screen.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key, required this.presenter});

  final OnboardingPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: presenter,
            builder: (context, _) => LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 28,
                  ),
                  child: IntrinsicHeight(child: _content()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Center(child: _GlowingLogo()),
        const SizedBox(height: 36),
        Text(
          'Yellow Connect',
          textAlign: TextAlign.center,
          style: AppText.style(
            32,
            weight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your own VPN, speed test and IP checker.',
          textAlign: TextAlign.center,
          style: AppText.style(16, color: AppColors.text2, height: 1.4),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkRaised,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            children: [
              _Feature(
                icon: Icons.shield_rounded,
                title: 'Private VPN',
                caption: 'Keeps what you do online private',
              ),
              _Feature(
                icon: Icons.speed_rounded,
                title: 'Speed test',
                caption: 'Download and upload, Wi-Fi or mobile',
              ),
              _Feature(
                icon: Icons.public_rounded,
                title: 'IP checker',
                caption: 'What websites see about you',
              ),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        if (presenter.failure case final failure?)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              failure.message,
              textAlign: TextAlign.center,
              style: AppText.style(14, color: AppColors.red),
            ),
          ),
        FilledButton(
          onPressed: presenter.working ? null : presenter.grantVpnPermission,
          child: const Text('Allow VPN'),
        ),
        const SizedBox(height: 10),
        Text(
          'Your phone asks once to let the app set up a VPN.',
          textAlign: TextAlign.center,
          style: AppText.style(13, color: AppColors.text2),
        ),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.white),
          onPressed: presenter.working ? null : presenter.skip,
          child: const Text('Skip for now'),
        ),
      ],
    );
  }
}

class _GlowingLogo extends StatelessWidget {
  const _GlowingLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -60,
          right: -60,
          top: -45,
          bottom: -45,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.yellow.withValues(alpha: 0.22),
                  AppColors.yellow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        const Logo(height: 140),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 22, color: AppColors.yellow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.style(
                    16,
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(caption, style: AppText.style(14, color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
