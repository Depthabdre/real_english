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

    // Validate URL Logic
    final bool hasValidUrl =
        identity.avatarUrl.isNotEmpty &&
        (identity.avatarUrl.startsWith('http') ||
            identity.avatarUrl.startsWith('https'));

    final ImageProvider backgroundImage = hasValidUrl
        ? CachedNetworkImageProvider(identity.avatarUrl)
        : const AssetImage('assets/images/default_avatar.png') as ImageProvider;

    return Row(
      children: [
        // Avatar with "Organic" Border
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4), // Gap between image and ring
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: backgroundImage,
              ),
            ),
            // Edit Badge (Floating Bubble)
            GestureDetector(
              onTap: onEditPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 20),

        // Text Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                identity.fullName,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Gardener since ${identity.joinedAt.year}",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
