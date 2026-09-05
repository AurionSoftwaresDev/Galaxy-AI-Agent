import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import 'settings_controls.dart';

/// User profile tab in Settings window with live avatar preview, initials fallback, and account fields.
class UserProfileTab extends StatelessWidget {
    final TextEditingController usernameController;
    final TextEditingController emailController;
    final TextEditingController avatarUrlController;
    final VoidCallback onFieldsChanged;

    const UserProfileTab({
        super.key,
        required this.usernameController,
        required this.emailController,
        required this.avatarUrlController,
        required this.onFieldsChanged,
    });

    @override
    Widget build(BuildContext context) {
        final tempProfile = UserProfile(
            username: usernameController.text,
            email: emailController.text,
            avatarUrl: avatarUrlController.text.trim().isEmpty ? null : avatarUrlController.text.trim(),
        );

        return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Avatar Card with Initials Fallback
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                            children: [
                                // Avatar Display (image if valid URL, else neon initials)
                                _buildAvatarPreview(tempProfile),
                                const SizedBox(width: 18),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                tempProfile.username.isNotEmpty
                                                    ? tempProfile.username
                                                    : 'Jakir Bhai',
                                                style: const TextStyle(
                                                    color: Color(0xFFF1F5F9),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                tempProfile.email.isNotEmpty
                                                    ? tempProfile.email
                                                    : 'jakirbhai421@gmail.com',
                                                style: const TextStyle(
                                                    color: Color(0xFF94A3B8),
                                                    fontSize: 12,
                                                ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                                        width: 0.8,
                                                    ),
                                                ),
                                                child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            'Pro Agent Tier • Active',
                                                            style: TextStyle(
                                                                color: Color(0xFF6EE7B7),
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w500,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),

                    const SizedBox(height: 18),

                    // Username Input
                    SettingsInputField(
                        label: 'Username / Display Name',
                        controller: usernameController,
                        hint: 'e.g. Jakir Bhai',
                        icon: Icons.person_outline_rounded,
                        onChanged: (_) => onFieldsChanged(),
                    ),

                    const SizedBox(height: 14),

                    // Gmail Input
                    SettingsInputField(
                        label: 'Gmail / Account Email',
                        controller: emailController,
                        hint: 'e.g. jakirbhai421@gmail.com',
                        icon: Icons.email_outlined,
                        onChanged: (_) => onFieldsChanged(),
                    ),

                    const SizedBox(height: 14),

                    // Avatar Image URL (Optional, triggers initials fallback if empty)
                    SettingsInputField(
                        label: 'Profile Image URL (Optional — Falls back to Initials)',
                        controller: avatarUrlController,
                        hint: 'https://example.com/avatar.png',
                        icon: Icons.image_outlined,
                        onChanged: (_) => onFieldsChanged(),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                        'Note: If image URL is not provided or fails to load, Galaxy AI automatically renders initials from your first and last name (e.g. "JB").',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                ],
            ),
        );
    }

    Widget _buildAvatarPreview(UserProfile profile) {
        final bool hasImageUrl = profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;

        return Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                    ),
                ],
            ),
            child: ClipOval(
                child: hasImageUrl
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsFallback(profile.initials),
                    )
                    : _buildInitialsFallback(profile.initials),
            ),
        );
    }

    Widget _buildInitialsFallback(String initials) {
        return Center(
            child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                ),
            ),
        );
    }
}
