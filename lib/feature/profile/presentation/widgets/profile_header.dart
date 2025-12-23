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

    return Row(
      children: [
        // Avatar with Border
        Container(
          padding: const EdgeInsets.all(2), // Space for border
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.primaryColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: theme.shadowColor,
            backgroundImage: identity.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(identity.avatarUrl)
                : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
          ),
        ),

        const SizedBox(width: 16),

        // Name & Join Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                identity.fullName,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Gardener since ${identity.joinedAt.year}",
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),

        // Edit Button (Icon only)
        IconButton(
          onPressed: onEditPressed,
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
