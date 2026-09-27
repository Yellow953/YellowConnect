import 'package:flutter/material.dart';

/// Placeholder dashboard. Replaced by the tool grid in Build Plan phase 5.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yellow Connect')),
      body: const Center(child: Text('Tools coming soon')),
    );
  }
}
