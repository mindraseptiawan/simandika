import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';
import 'package:simandika/widgets/loading_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();

  bool isLoading = false;
  bool _isObscure = true;

  Future<void> handleSignIn() async {
    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      username: controllerUsername.text,
      password: controllerPassword.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(context, '/home');
    } else {
      showCustomSnackBar(context, 'Gagal Masuk!', SnackBarType.error);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Masuk',
                style: primaryTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/logo_text.png',
                  width: 200,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Masukkan username yang terdaftar untuk masuk aplikasi',
                style: primaryTextStyle.copyWith(
                    fontSize: 16, fontWeight: semiBold),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Username',
                controller: controllerUsername,
                hintText: 'Username Anda',
                iconPath: 'assets/username.png',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Password',
                controller: controllerPassword,
                hintText: 'Password Anda',
                iconPath: 'assets/icon_password.png',
                obscureText: true,
              ),
              const SizedBox(height: 30),
              isLoading ? const LoadingButton() : _buildSignInButton(),
              const SizedBox(height: 30),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(fontSize: 16, fontWeight: medium),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor22,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Image.asset(iconPath, width: 17),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText ? _isObscure : false,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: subtitleTextStyle,
                    suffixIcon: obscureText
                        ? IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: handleSignIn,
        style: TextButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Masuk',
          style: primaryTextStyle.copyWith(fontSize: 16, fontWeight: bold),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tidak memiliki akun? ',
            style: subtitleTextStyle.copyWith(fontSize: 12),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              'Daftar',
              style: purpleTextStyle.copyWith(fontSize: 12, fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }
}
