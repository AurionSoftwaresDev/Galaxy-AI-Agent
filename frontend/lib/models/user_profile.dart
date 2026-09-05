/// User profile representation for Galaxy AI.
///
/// Handles avatar fallback initials from first and last name when image is not provided.
class UserProfile {
    final String username;
    final String email;
    final String? avatarUrl;
    final String tier;

    const UserProfile({
        required this.username,
        required this.email,
        this.avatarUrl,
        this.tier = 'Pro Agent Tier',
    });

    /// Derives initials from first and last name.
    ///
    /// E.g. "Jakir Bhai" -> "JB"
    /// "Jakir" -> "J"
    /// "" -> "U"
    String get initials {
        final cleanName = username.trim();
        if (cleanName.isEmpty) return 'U';

        final parts = cleanName.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
            final first = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
            final last = parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
            final result = '$first$last';
            return result.isNotEmpty ? result : 'U';
        } else if (parts.length == 1 && parts.first.isNotEmpty) {
            return parts.first[0].toUpperCase();
        }
        return 'U';
    }

    UserProfile copyWith({
        String? username,
        String? email,
        String? avatarUrl,
        String? tier,
    }) {
        return UserProfile(
            username: username ?? this.username,
            email: email ?? this.email,
            avatarUrl: avatarUrl ?? this.avatarUrl,
            tier: tier ?? this.tier,
        );
    }
}
