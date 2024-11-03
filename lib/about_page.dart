import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(selectedIndex: 2),
      body: const Center(
        child: Text('About Page Content'),
      ),
    );
  }
}
