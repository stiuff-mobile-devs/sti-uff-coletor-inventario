import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/shared/components/app_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(selectedIndex: 1),
      body: const Center(
        child: Text('Settings Page Content'),
      ),
    );
  }
}
