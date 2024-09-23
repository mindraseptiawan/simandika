import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/pages/home/home_page.dart';
import 'package:simandika/pages/home/layanan_page.dart';
import 'package:simandika/pages/home/profile_page.dart';
import 'package:simandika/pages/home/kandang_page.dart';
import 'package:simandika/providers/page_provider.dart';
import 'package:simandika/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    PageProvider pageProvider = Provider.of<PageProvider>(context);

    Widget customBottomNav() {
      return BottomNavigationBar(
        backgroundColor: backgroundColor1,
        currentIndex: pageProvider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          pageProvider.currentIndex = value;
        },
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color.fromARGB(255, 247, 245, 245),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          height: 2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          height: 2,
        ),
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon_home.png'),
              color: pageProvider.currentIndex == 0
                  ? primaryColor
                  : const Color.fromARGB(255, 244, 243, 243),
            ),
            activeIcon: ImageIcon(
              const AssetImage('assets/icon_home.png'),
              color: primaryColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon_cart.png'),
              color: pageProvider.currentIndex == 1
                  ? primaryColor
                  : const Color.fromARGB(255, 255, 255, 255),
            ),
            activeIcon: ImageIcon(
              const AssetImage('assets/icon_cart.png'),
              color: primaryColor,
            ),
            label: 'Kandang',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon_chat.png'),
              color: pageProvider.currentIndex == 2
                  ? primaryColor
                  : const Color.fromARGB(255, 245, 244, 244),
            ),
            activeIcon: ImageIcon(
              const AssetImage('assets/icon_chat.png'),
              color: primaryColor,
            ),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/icon_profile.png'),
              color: pageProvider.currentIndex == 3
                  ? primaryColor
                  : const Color.fromARGB(255, 248, 247, 247),
            ),
            activeIcon: ImageIcon(
              const AssetImage('assets/icon_profile.png'),
              color: primaryColor,
            ),
            label: 'Akun',
          ),
        ],
      );
    }

    Widget body() {
      switch (pageProvider.currentIndex) {
        case 0:
          return const HomePage();
        case 1:
          return const KandangPage();
        case 2:
          return const LayananPage();
        case 3:
          return const ProfilePage();
        default:
          return const HomePage();
      }
    }

    return Scaffold(
      backgroundColor:
          pageProvider.currentIndex == 0 ? backgroundColor1 : backgroundColor3,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: customBottomNav(),
      body: body(),
    );
  }
}
