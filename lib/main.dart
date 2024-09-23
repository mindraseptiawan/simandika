import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/pages/edit_profile_page.dart';
import 'package:simandika/pages/home/main_page.dart';
import 'package:simandika/pages/inventaris/kandang_page.dart';
import 'package:simandika/pages/auth/sign_in_page.dart';
import 'package:simandika/pages/inventaris/form_pakan_page.dart';
import 'package:simandika/pages/auth/sign_up_page.dart';
import 'package:simandika/pages/home/splash_page.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/providers/kandang_provider.dart';
import 'package:simandika/providers/page_provider.dart';
import 'package:simandika/providers/pemeliharaan_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PageProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, KandangProvider>(
          create: (context) => KandangProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, kandangProvider) =>
              KandangProvider(authProvider: authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PemeliharaanProvider>(
          create: (context) => PemeliharaanProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, pemeliharaanProvider) =>
              PemeliharaanProvider(authProvider: authProvider),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const SignInPage(),
          '/register': (context) => const SignUpPage(),
          '/home': (context) => const MainPage(),
          '/kandang': (context) => const KandangPage(),
          '/edit-profile': (context) => const EditProfilePage(),
          '/add-pakan': (context) => const FormPakanPage()
        },
      ),
    );
  }
}
