// presentation/widgets/story_trail_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';

class StoryTrailCard extends StatelessWidget {
  final StoryTrail storyTrail;

  const StoryTrailCard({super.key, required this.storyTrail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      shadowColor: theme.shadowColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior:
          Clip.antiAlias, // Ensures the image respects the border radius
      child: InkWell(
        onTap: () {
          // Navigate to the story player page with the specific trail ID
          context.go('/story-player/${storyTrail.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Banner
            SizedBox(
              height: 150,
              child: Image.network(
                storyTrail.imageUrl,
                fit: BoxFit.cover,
                // Add a loading builder for a better user experience
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // Add an error builder for broken image links
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surface.withOpacity(0.5),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            // Text Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storyTrail.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    storyTrail.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
