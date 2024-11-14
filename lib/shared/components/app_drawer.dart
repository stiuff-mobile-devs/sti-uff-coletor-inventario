// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/features/about/views/about_page.dart';
import 'package:stiuffcoletorinventario/features/camera/views/camera_page.dart';
import 'package:stiuffcoletorinventario/features/login/controller/auth_controller.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';
import 'package:stiuffcoletorinventario/shared/utils/custom_page_router.dart';
import 'package:stiuffcoletorinventario/features/home/views/home_page.dart';
import 'package:stiuffcoletorinventario/features/settings/views/settings_page.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;

  AppDrawer({super.key, required this.selectedIndex});

  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/icons/small-app-icon.png',
                    width: 42,
                    height: 42,
                  ),
                ),
                const Text(
                  'Coletor Inventário',
                  style: TextStyle(
                    color: Color.fromARGB(255, 41, 41, 41),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.home,
            title: 'Home',
            index: 0,
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Configurações',
            index: 1,
          ),
          _buildListTile(
            context,
            icon: Icons.info,
            title: 'Sobre',
            index: 2,
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.shadowColor,
            ),
            title: const Text(
              'Sair',
              style: TextStyle(color: AppColors.shadowColor),
            ),
            onTap: () async {
              bool? shouldLogout = await _showLogoutConfirmationDialog(context);

              if (shouldLogout == true) {
                await authController.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Confirmar saída',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Você tem certeza de que deseja sair?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile _buildListTile(BuildContext context,
      {required IconData icon, required String title, required int index}) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected ? AppColors.orangeSelectionColor : AppColors.shadowColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? AppColors.orangeSelectionColor
              : AppColors.shadowColor,
        ),
      ),
      selected: isSelected,
      onTap: () async {
        String routeName;
        switch (index) {
          case 0:
            routeName = '/home';
            break;
          case 1:
            routeName = '/settings';
            break;
          case 2:
            routeName = '/about';
            break;
          default:
            return;
        }
        Navigator.push(context, CustomPageRoute(page: _getPage(routeName)));
      },
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case '/home':
        return const HomePage();
      case '/settings':
        return const SettingsPage();
      case '/about':
        return const AboutPage();
      case '/camera':
        return const CameraPage();
      default:
        return const HomePage();
    }
  }
}
