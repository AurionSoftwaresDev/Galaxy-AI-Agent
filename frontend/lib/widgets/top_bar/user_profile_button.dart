import 'package:flutter/material.dart';
import '../../models/user_profile.dart';

/// User profile trigger button in top navbar displaying avatar / initials, username, and email.
class UserProfileButton extends StatelessWidget {
    final UserProfile userProfile;
    final VoidCallback onOpenSettings;

    const UserProfileButton({
        super.key,
        required this.userProfile,
        required this.onOpenSettings,
    });

    @override
    Widget build(BuildContext context) {
        return Tooltip(
            message: '${userProfile.username}\n${userProfile.email}\nClick to manage profile',
            waitDuration: const Duration(milliseconds: 300),
            child: InkWell(
                onTap: onOpenSettings,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Avatar display with initials fallback
                            _buildAvatarBadge(),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            userProfile.username,
                                            style: const TextStyle(
                                                color: Color(0xFFE2E8F0),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                            userProfile.email,
                                            style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Color(0xFF64748B),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildAvatarBadge() {
        final bool hasImage = userProfile.avatarUrl != null && userProfile.avatarUrl!.isNotEmpty;

        return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                ),
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        blurRadius: 6,
                    ),
                ],
            ),
            child: ClipOval(
                child: hasImage
                    ? Image.network(
                        userProfile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsText(),
                    )
                    : _buildInitialsText(),
            ),
        );
    }

    Widget _buildInitialsText() {
        return Center(
            child: Text(
                userProfile.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                ),
            ),
        );
    }
}
