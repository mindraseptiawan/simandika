import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simandika/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3),
        () => Navigator.pushNamed(context, '/login'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo_new.png'),
                ),
              ),
            ),
            const SizedBox(
                height: 5), // Adds some space between the logo and the text
            Text(
              "Kerja Keras, Kerja Cerdas dan Kerja Ikhlas",
              style: primaryTextStyle.copyWith(
                fontSize: 24,
                fontWeight: semiBold,
                // color: Colors.black, // Adjust the color as needed
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
