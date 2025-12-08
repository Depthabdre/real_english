import 'dart:async';
import 'package:flutter/material.dart';

class RobustStoryImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  const RobustStoryImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<RobustStoryImage> createState() => _RobustStoryImageState();
}

class _RobustStoryImageState extends State<RobustStoryImage> {
  int _attempt = 0;
  bool _hasError = false;
  Key _key = UniqueKey(); // Used to force-reload the image

  void _retry() {
    if (!mounted) return;
    setState(() {
      _attempt++;
      _hasError = false;
      _key = UniqueKey(); // Force image widget to rebuild and fetch again
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.imageUrl,
      key: _key,
      fit: widget.fit,
      // 1. Loading Builder
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
            color: Colors.blueAccent,
          ),
        );
      },
      // 2. Error Builder (The Magic Part)
      errorBuilder: (context, error, stackTrace) {
        // If we haven't tried 3 times yet, retry automatically with delay
        if (_attempt < 3) {
          // Exponential backoff: Wait 2s, then 4s, then 6s
          final delay = Duration(seconds: (_attempt + 1) * 2);

          Future.delayed(delay, () {
            if (mounted) _retry();
          });

          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Loading... (Attempt ${_attempt + 1})",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // If failed 3 times, show manual retry button
        return Container(
          color: Colors.grey[900],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, color: Colors.white54),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Reset attempts and try again
                    setState(() {
                      _attempt = 0;
                    });
                    _retry();
                  },
                  child: const Text(
                    "Tap to Reload Image",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
