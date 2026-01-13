import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../domain/entities/immersion_short.dart';
import 'immersion_overlay_content.dart';
import 'translation_modal.dart';

class ImmersionVideoItem extends StatefulWidget {
  final ImmersionShort short;

  const ImmersionVideoItem({super.key, required this.short});

  @override
  State<ImmersionVideoItem> createState() => _ImmersionVideoItemState();
}

class _ImmersionVideoItemState extends State<ImmersionVideoItem>
    with WidgetsBindingObserver {
  late YoutubePlayerController _controller;
  bool _isTranslationVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = YoutubePlayerController(
      initialVideoId: widget.short.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        loop: true,
        hideControls: true,
        disableDragSeek: true,
        forceHD: true,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VisibilityDetector(
      key: Key('video-${widget.short.youtubeId}'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!mounted) return;
        if (info.visibleFraction > 0.6) {
          if (!_controller.value.isPlaying && !_isTranslationVisible) {
            _controller.play();
          }
        } else {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. Video Layer ---
          GestureDetector(
            onLongPressStart: (_) {
              _controller.pause();
              setState(() => _isTranslationVisible = true);
            },
            onLongPressEnd: (_) {
              setState(() => _isTranslationVisible = false);
              _controller.play();
            },
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 9 / 16,
              showVideoProgressIndicator: false,
              bottomActions: const [],
              topActions: const [],
            ),
          ),

          // --- 2. Cinematic Gradient (Softer) ---
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.8,
                      ), // Darker bottom for text contrast
                    ],
                    stops: const [0.0, 0.6, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // --- 3. Overlay Content (Text & Buttons) ---
          AnimatedOpacity(
            opacity: _isTranslationVisible ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: ImmersionOverlayContent(short: widget.short),
          ),

          // --- 4. Modal Layer (Translation) ---
          if (_isTranslationVisible)
            TranslationModal(
              title: widget.short.title,
              description: widget.short.description,
            ),

          // --- 5. Custom Progress Bar (Bottom Edge) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<YoutubePlayerValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                if (value.metaData.duration.inMilliseconds == 0) {
                  return const SizedBox.shrink();
                }
                final progress =
                    value.position.inMilliseconds /
                    value.metaData.duration.inMilliseconds;

                return LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 3, // Slightly thicker
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.secondary, // Use Brand Amber/Yellow
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
