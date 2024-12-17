// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with empty strings
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Use a delayed initialization to ensure data is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      UserModel user = authProvider.user;

      // Initialize controllers with user data
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        AuthProvider authProvider =
            Provider.of<AuthProvider>(context, listen: false);

        // Call the updateProfile method
        bool success = await authProvider.updateProfile(
          name: _nameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );

        if (success) {
          // Show a success message

          showCustomSnackBar(context, 'Berhasil Memperbarui Data Profil!',
              SnackBarType.success);
          Navigator.pop(context); // Go back to the previous screen
        } else {
          // Show an error message

          showCustomSnackBar(
              context, 'Gagal Memperbarui Data Profil', SnackBarType.error);
        }
      } catch (e) {
        // Handle errors

        showCustomSnackBar(context, 'Terjadi Error $e', SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    AppBar header() {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Edit Profil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: secondaryColor,
            ),
            onPressed: _saveProfile, // Trigger save profile
          )
        ],
      );
    }

    Widget nameInput() {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama',
              style: secondaryTextStyle.copyWith(fontSize: 13),
            ),
            TextFormField(
              controller: _nameController,
              style: primaryTextStyle,
              decoration: InputDecoration(
                hintText: 'Masukkan Nama Anda',
                hintStyle: primaryTextStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: subtitleColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tolong Masukkan Nama';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    Widget usernameInput() {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username',
              style: secondaryTextStyle.copyWith(fontSize: 13),
            ),
            TextFormField(
              controller: _usernameController,
              style: primaryTextStyle,
              decoration: InputDecoration(
                hintText: 'Masukkan username',
                hintStyle: primaryTextStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: subtitleColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tolong Masukkan Username';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    Widget emailInput() {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alamat Email',
              style: secondaryTextStyle.copyWith(fontSize: 13),
            ),
            TextFormField(
              controller: _emailController,
              style: primaryTextStyle,
              decoration: InputDecoration(
                hintText: 'Masukkan Email Anda',
                hintStyle: primaryTextStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: subtitleColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tolong Masukkan Email';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    Widget phoneInput() {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor HP',
              style: secondaryTextStyle.copyWith(fontSize: 13),
            ),
            TextFormField(
              controller: _phoneController,
              style: primaryTextStyle,
              decoration: InputDecoration(
                hintText: 'Masukkan Nomor HP',
                hintStyle: primaryTextStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: subtitleColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tolong Masukkan Nomor HP';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    Widget content() {
      String imageUrl = user.profilePhotoUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&color=7F9CF5&background=EBF4FF';

      return Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(top: defaultMargin),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(imageUrl),
                  ),
                ),
              ),
              nameInput(),
              usernameInput(),
              emailInput(),
              phoneInput()
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor3,
      appBar: header(),
      body: content(),
      resizeToAvoidBottomInset: false,
    );
  }
}
