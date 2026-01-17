import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/immersion_short.dart';
import 'immersion_overlay_content.dart';
import 'translation_modal.dart';

class ImmersionVideoItem extends StatefulWidget {
  final ImmersionShort short;
  final bool isFocused;

  const ImmersionVideoItem({
    super.key,
    required this.short,
    required this.isFocused,
  });

  @override
  State<ImmersionVideoItem> createState() => _ImmersionVideoItemState();
}

class _ImmersionVideoItemState extends State<ImmersionVideoItem> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isTranslationVisible = false;

  @override
  void initState() {
    super.initState();
    // Only init if this is the very first page loaded
    if (widget.isFocused) {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(covariant ImmersionVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scrolled INTO view
    if (widget.isFocused && !oldWidget.isFocused) {
      _initializePlayer();
    }

    // Scrolled OUT of view
    if (!widget.isFocused && oldWidget.isFocused) {
      _disposePlayer();
    }
  }

  void _initializePlayer() {
    if (_controller != null) return;

    // The Magic Delay:
    // Wait for the physics "snap" to finish before spawning the heavy WebView.
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !widget.isFocused) return;

      _controller = YoutubePlayerController(
        initialVideoId: widget.short.youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
          hideControls: true,
          disableDragSeek: true, // Crucial for vertical scroll
          forceHD: false,
          enableCaption: false,
        ),
      )..addListener(_listener);

      if (mounted) setState(() {});
    });
  }

  void _disposePlayer() {
    _controller?.dispose();
    _controller = null;
    _isPlayerReady = false;
    if (mounted) setState(() {});
  }

  void _listener() {
    if (_controller?.value.isReady == true && !_isPlayerReady) {
      if (mounted) setState(() => _isPlayerReady = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // --- 1. Background Thumbnail (Always visible) ---
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl:
                'https://img.youtube.com/vi/${widget.short.youtubeId}/maxresdefault.jpg',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => CachedNetworkImage(
              imageUrl:
                  'https://img.youtube.com/vi/${widget.short.youtubeId}/hqdefault.jpg',
              fit: BoxFit.cover,
            ),
            placeholder: (context, url) => Container(color: Colors.black26),
          ),
        ),

        // --- 2. Heavy Video Player (Only when focused) ---
        if (_controller != null)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isPlayerReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              // Use a transparent Listener to ensure gestures pass through if needed
              child: Listener(
                behavior: HitTestBehavior.translucent,
                child: GestureDetector(
                  // Tap Logic for Play/Pause
                  onTap: () {
                    if (_controller?.value.isPlaying ?? false) {
                      _controller?.pause();
                    } else {
                      _controller?.play();
                    }
                  },
                  // Long Press for Translation
                  onLongPressStart: (_) {
                    _controller?.pause();
                    setState(() => _isTranslationVisible = true);
                  },
                  onLongPressEnd: (_) {
                    setState(() => _isTranslationVisible = false);
                    _controller?.play();
                  },
                  // NOTE: We do NOT define onVerticalDrag here.
                  // This allows the drag to bubble up to the PageView immediately.
                  child: YoutubePlayer(
                    controller: _controller!,
                    aspectRatio: 9 / 16,
                    showVideoProgressIndicator: false,
                    onReady: () => _controller!.play(),
                  ),
                ),
              ),
            ),
          ),

        // --- 3. Gradient Overlay ---
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.6, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // --- 4. Content Overlays (Text, Buttons) ---
        AnimatedOpacity(
          opacity: _isTranslationVisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: ImmersionOverlayContent(short: widget.short),
        ),

        // --- 5. Modal ---
        if (_isTranslationVisible)
          TranslationModal(
            title: widget.short.title,
            description: widget.short.description,
          ),

        // --- 6. Progress Bar ---
        if (_controller != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<YoutubePlayerValue>(
              valueListenable: _controller!,
              builder: (context, value, child) {
                if (value.metaData.duration.inMilliseconds == 0) {
                  return const SizedBox.shrink();
                }

                final progress =
                    value.position.inMilliseconds /
                    value.metaData.duration.inMilliseconds;
                return LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 2,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
