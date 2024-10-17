import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/user_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  UserManagementPageState createState() => UserManagementPageState();
}

class UserManagementPageState extends State<UserManagementPage> {
  final UserService userService = UserService();
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    setState(() {
      isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      users = await userService.getUsers(token!);
    } catch (e) {
      showCustomSnackBar(context, 'Failed to load users', SnackBarType.error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(int userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      await userService.deleteUser(userId, token!);
      getUsers();
    } catch (e) {
      showCustomSnackBar(context, 'Failed to delete user!', SnackBarType.error);
    }
  }

  Future<void> toggleUserStatus(UserModel user) async {
    try {
      UserModel updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username,
        phone: user.phone,
        profilePhotoUrl: user.profilePhotoUrl,
        token: user.token == null ? 'active' : null, // Toggles status
      );
      await UserService.updateUser(updatedUser);
      getUsers();
    } catch (e) {
      showCustomSnackBar(
          context, 'Failed to update user status!', SnackBarType.error);
    }
  }

  Future<void> assignUserRole(int userId, String role) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    try {
      await userService.assignRole(userId, role, token!);

      showCustomSnackBar(
          context, 'Role assigned successfully!', SnackBarType.success);
    } catch (e) {
      showCustomSnackBar(context, 'Failed to assign role!', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management', style: primaryTextStyle),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: backgroundColor1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(user.name,
                                  style: primaryTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: bold,
                                  )),
                              subtitle:
                                  Text(user.username, style: primaryTextStyle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      user.token != null
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: user.token != null
                                          ? Colors.green
                                          : alertColor,
                                    ),
                                    onPressed: () => toggleUserStatus(user),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: alertColor),
                                    onPressed: () => deleteUser(user.id),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (role) =>
                                        assignUserRole(user.id, role),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'Pimpinan',
                                        child: Text('Pimpinan'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Operator',
                                        child: Text('Operator'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Karyawan',
                                        child: Text('Karyawan'),
                                      ),
                                    ],
                                    child: Icon(Icons.more_vert,
                                        color: backgroundColor22),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
