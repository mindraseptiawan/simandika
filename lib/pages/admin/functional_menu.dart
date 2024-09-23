import 'package:flutter/material.dart';
import 'package:simandika/theme.dart';

class FunctionalMenu extends StatelessWidget {
  final List menuItems;

  const FunctionalMenu({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: menuItems.map((item) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, item['route']);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey,
                ),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Image.asset(
                    item['icon'],
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['label'],
                    style: subtitleTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
