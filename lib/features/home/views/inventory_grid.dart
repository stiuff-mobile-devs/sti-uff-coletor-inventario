import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';
import 'package:stiuffcoletorinventario/features/home/models/inventory_item.dart';

class InventoryGrid extends StatefulWidget {
  const InventoryGrid({super.key});

  @override
  InventoryGridState createState() => InventoryGridState();
}

class InventoryGridState extends State<InventoryGrid> {
  final List<InventoryItem> items = List.generate(
    20,
    (index) => InventoryItem(
      name: 'Item ${index + 1}',
      description: 'Descrição do Item ${index + 1}',
    ),
  );

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<List<InventoryItem>> pages = [];
    for (int i = 0; i < items.length; i += 9) {
      pages.add(items.sublist(i, i + 9 > items.length ? items.length : i + 9));
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
                              item.description,
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
