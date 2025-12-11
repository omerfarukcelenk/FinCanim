import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profilePictureUrl;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onAvatarTap,
    this.profilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFFFFC107),
            child: profilePictureUrl == null
                ? Icon(
                    Icons.person,
                    color: const Color(0xFF4A148C),
                    size: ResponsiveSize.icon_48,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(44),
                    child: Image.network(
                      profilePictureUrl!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveSize.fontSize_32,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 0.3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        Text(
          email,
          style: TextStyle(
            fontSize: ResponsiveSize.fontSize_18,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 0.3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
