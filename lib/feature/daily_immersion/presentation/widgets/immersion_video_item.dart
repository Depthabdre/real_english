import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart'; // <--- IMPORT THIS
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
    // Register lifecycle observer to pause video when app goes to background
    WidgetsBinding.instance.addObserver(this);

    _controller = YoutubePlayerController(
      initialVideoId: widget.short.youtubeId,
      flags: const YoutubePlayerFlags(
        // CRITICAL FIX 1: Disable autoPlay here.
        // We will control playback manually based on visibility.
        autoPlay: false,
        mute: false,
        loop: true,
        hideControls: true,
        disableDragSeek: true,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Handle App Background/Foreground state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller.value.isFullScreen) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL FIX 2: Wrap everything in VisibilityDetector
    return VisibilityDetector(
      key: Key(widget.short.youtubeId),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!mounted) return;

        // CRITICAL FIX 3: Logic to manage the Decoder Resource
        // If more than 50% of the item is visible, play. Otherwise, pause.
        if (info.visibleFraction > 0.5) {
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
          // -----------------------------------------------------------
          // LAYER 1: The Video Player
          // -----------------------------------------------------------
          GestureDetector(
            onLongPressStart: (details) {
              _controller.pause();
              setState(() => _isTranslationVisible = true);
            },
            onLongPressEnd: (details) {
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
              // Optimization: Prevent reloading the webview constantly
              onReady: () {
                // Optional: Ensure it starts muted if needed, or precache
              },
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 2: Gradient
          // -----------------------------------------------------------
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 3: UI Content
          // -----------------------------------------------------------
          AnimatedOpacity(
            opacity: _isTranslationVisible ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: ImmersionOverlayContent(short: widget.short),
          ),

          // -----------------------------------------------------------
          // LAYER 4: Translation Modal
          // -----------------------------------------------------------
          if (_isTranslationVisible)
            TranslationModal(
              title: widget.short.title,
              description: widget.short.description,
            ),

          // -----------------------------------------------------------
          // LAYER 5: Progress Line
          // -----------------------------------------------------------
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
                  minHeight: 2,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF64B5F6),
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
