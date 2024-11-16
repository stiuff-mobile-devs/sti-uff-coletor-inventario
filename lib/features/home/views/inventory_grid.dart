import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';
import 'package:stiuffcoletorinventario/features/form/views/form_page.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';
import 'package:stiuffcoletorinventario/shared/utils/custom_page_router.dart';

class InventoryGrid extends StatefulWidget {
  const InventoryGrid({super.key});

  @override
  InventoryGridState createState() => InventoryGridState();
}

class InventoryGridState extends State<InventoryGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _loadInventory() async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final items = inventoryProvider.items;

    final List<List<InventoryItem>> pages = [];
    int itemCount = items.length;

    List<InventoryItem> firstPageItems = [
          InventoryItem(
            name: 'Adicionar Item',
            description: '',
            barcode: '',
            location: '',
            date: DateTime.now(),
          ),
        ] +
        items.take(8).toList();
    pages.add(firstPageItems);

    for (int i = 8; i < itemCount; i += 9) {
      pages.add(items.sublist(i, i + 9 > itemCount ? itemCount : i + 9));
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16.0, bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Inventário Local',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shadowColor,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              itemBuilder: (context, pageIndex) {
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: pages[pageIndex].length,
                  itemBuilder: (context, index) {
                    if (pageIndex == 0 && index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CustomPageRoute(
                            page: const FormPage(),
                          ));
                        },
                        child: const Card(
                          color: AppColors.appBarColor,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    } else {
                      final item = pages[pageIndex][index];
                      return Card(
                        color: AppColors.appBarColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          _buildPageIndicators(pages.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(int pageCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.orangeSelectionColor
                  : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
