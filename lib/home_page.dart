import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/app_colors.dart';
import 'package:stiuffcoletorinventario/app_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stiuffcoletorinventario/info_carousel.dart';
import 'package:stiuffcoletorinventario/inventory_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(selectedIndex: 0),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            InfoCarousel(),
            SizedBox(height: 20),
            InventoryGrid(),
            SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Leitor de Barras",
        backgroundColor: AppColors.appBarColor,
        splashColor: AppColors.lightOrangeSplashColor,
        onPressed: () => {},
        child: SvgPicture.asset(
          'assets/icons/barcode.svg',
          width: 36,
          height: 36,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
