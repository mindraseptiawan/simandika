import 'package:flutter/material.dart';
import 'package:simandika/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/theme.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    // String imageUrl = user.profilePhotoUrl ??
    //     'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&color=7F9CF5&background=EBF4FF';

    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      width: double.infinity, // Ensure full width
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/logo_text.png', width: 200),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(user.name,
                      style: primaryTextStyle.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/notif.png',
            width: 30.0,
            height: 30.0,
          ),
        ],
      ),
    );
  }
}
