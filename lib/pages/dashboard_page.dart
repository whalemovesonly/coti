import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard',
      role: 'viewer', // Static or default role
      child: const Center(
        child: Text(
          'This is Dashboard screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}