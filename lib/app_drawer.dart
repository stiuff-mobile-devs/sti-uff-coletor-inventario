import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/about_page.dart';
import 'package:stiuffcoletorinventario/app_colors.dart';
import 'package:stiuffcoletorinventario/custom_page_router.dart';
import 'package:stiuffcoletorinventario/home_page.dart';
import 'package:stiuffcoletorinventario/settings_page.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;

  const AppDrawer({super.key, required this.selectedIndex});

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
        ],
      ),
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
      default:
        return const HomePage();
    }
  }
}
