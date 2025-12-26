import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileIdentity identity;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.identity,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- FIX LOGIC START ---
    // Check if the URL is actually a valid web link
    final bool hasValidUrl =
        identity.avatarUrl.isNotEmpty &&
        (identity.avatarUrl.startsWith('http') ||
            identity.avatarUrl.startsWith('https'));

    final ImageProvider backgroundImage = hasValidUrl
        ? CachedNetworkImageProvider(identity.avatarUrl)
        : const AssetImage('assets/images/default_avatar.png') as ImageProvider;
    // --- FIX LOGIC END ---

    return Row(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: theme.cardColor,
            // Use the safe provider
            backgroundImage: backgroundImage,
          ),
        ),

        const SizedBox(width: 16),

        // Name Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                identity.fullName,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Gardener since ${identity.joinedAt.year}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEditPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: theme.primaryColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
