import 'package:flutter/material.dart';

/// Reusable profile avatar widget that displays profile picture or initials
class ProfileAvatar extends StatelessWidget {
  final String? profilePicturePath;
  final String profileInitial;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileAvatar({
    super.key,
    this.profilePicturePath,
    required this.profileInitial,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF0FA4AF);
    final txtColor = textColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        image: profilePicturePath != null && profilePicturePath!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(profilePicturePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profilePicturePath == null || profilePicturePath!.isEmpty
          ? Center(
              child: Text(
                profileInitial,
                style: TextStyle(
                  color: txtColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
