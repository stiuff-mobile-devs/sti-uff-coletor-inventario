import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/shared/components/app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: AppDrawer(selectedIndex: 2),
      body: const Center(
        child: Text('About Page Content'),
      ),
    );
  }
}
