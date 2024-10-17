import 'package:flutter/material.dart';

enum SnackBarType { success, error }

class CustomSnackBar extends StatelessWidget {
  final String message;
  final SnackBarType type;

  const CustomSnackBar({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Icon icon;

    // Determine the background color and icon based on the type
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icon(Icons.check_circle_outline, color: Colors.white, size: 24);
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icon(Icons.error_outline, color: Colors.white, size: 24);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the custom snackbar
void showCustomSnackBar(
    BuildContext context, String message, SnackBarType type) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      width: MediaQuery.of(context).size.width - 32,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: CustomSnackBar(message: message, type: type),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(milliseconds: 2000), () {
    overlayEntry.remove();
  });
}
