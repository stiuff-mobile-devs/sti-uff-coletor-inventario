import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/features/home/models/package_item.dart';

class PackageList extends StatefulWidget {
  final Map<String, List<Package>> groupedPackages;

  const PackageList({super.key, required this.groupedPackages});

  @override
  PackageListState createState() => PackageListState();
}

class PackageListState extends State<PackageList> {
  final Map<String, bool> expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.groupedPackages.keys.length,
      itemBuilder: (context, index) {
        String monthYear = widget.groupedPackages.keys.elementAt(index);
        List<Package> packages = widget.groupedPackages[monthYear]!;

        bool isExpanded = expandedGroups[monthYear] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(4),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  )),
                ),
                onPressed: () {
                  setState(() {
                    expandedGroups[monthYear] = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Column(
                children: packages
                    .map((package) => PackageItem(package: package))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}
