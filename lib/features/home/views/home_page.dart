import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/features/home/views/package_list_widget.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';
import 'package:stiuffcoletorinventario/shared/components/app_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stiuffcoletorinventario/features/camera/views/camera_page.dart';
import 'package:stiuffcoletorinventario/shared/components/info_carousel.dart';
import 'package:stiuffcoletorinventario/features/home/views/inventory_grid.dart';
import 'package:stiuffcoletorinventario/shared/utils/custom_page_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      drawer: AppDrawer(selectedIndex: 0),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: const SingleChildScrollView(
          child: Column(
            children: [
              InfoCarousel(),
              SizedBox(height: 20),
              InventoryGrid(),
              SizedBox(height: 20),
              PackageListWidget(),
              SizedBox(height: 85),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Leitor de Barras",
        backgroundColor: Colors.red,
        splashColor: AppColors.lightOrangeSplashColor,
        onPressed: () => Navigator.push(
          context,
          CustomPageRoute(page: const CameraPage()),
        ),
        child: SvgPicture.asset(
          'assets/icons/barcode.svg',
          width: 36,
          height: 36,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
