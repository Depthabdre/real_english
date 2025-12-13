import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/immersion_short.dart';
import 'immersion_overlay_content.dart';
import 'translation_modal.dart';

class ImmersionVideoItem extends StatefulWidget {
  final ImmersionShort short;

  const ImmersionVideoItem({super.key, required this.short});

  @override
  State<ImmersionVideoItem> createState() => _ImmersionVideoItemState();
}

class _ImmersionVideoItemState extends State<ImmersionVideoItem> {
  late YoutubePlayerController _controller;
  bool _isTranslationVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.short.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
        hideControls: true, // Hides YouTube UI for "Real English" feel
        disableDragSeek: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- INTERACTION LOGIC ---

  void _onLongPressStart(LongPressStartDetails details) {
    // 1. Pause Video
    _controller.pause();
    // 2. Show Overlay
    setState(() => _isTranslationVisible = true);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // 1. Hide Overlay
    setState(() => _isTranslationVisible = false);
    // 2. Resume Video
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // -----------------------------------------------------------
        // LAYER 1: The Video Player (Interactive Wrapper)
        // -----------------------------------------------------------
        GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          onTap: () {
            // Optional: Tap to pause/play like Instagram
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          },
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 9 / 16, // Force Vertical Short Aspect Ratio
            showVideoProgressIndicator: false, // We build our own custom one
            // Clean UI: Remove standard overlays
            bottomActions: const [],
            topActions: const [],
          ),
        ),

        // -----------------------------------------------------------
        // LAYER 2: The Gradient (Visibility Protection)
        // -----------------------------------------------------------
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8), // Bottom Shadow
                  ],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // -----------------------------------------------------------
        // LAYER 3: The Main UI Content (Text, Buttons)
        // -----------------------------------------------------------
        // We hide this when the translation card is visible to reduce clutter
        AnimatedOpacity(
          opacity: _isTranslationVisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: ImmersionOverlayContent(short: widget.short),
        ),

        // -----------------------------------------------------------
        // LAYER 4: The Translation Modal (Long Press)
        // -----------------------------------------------------------
        if (_isTranslationVisible)
          TranslationModal(
            title: widget.short.title,
            description: widget.short.description,
          ),

        // -----------------------------------------------------------
        // LAYER 5: The "Progress Line" (Bottom)
        // -----------------------------------------------------------
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          // CHANGE: Use ValueListenableBuilder instead of StreamBuilder
          child: ValueListenableBuilder<YoutubePlayerValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              // 'value' is the current state of the player
              if (value.metaData.duration.inMilliseconds == 0) {
                return const SizedBox.shrink();
              }

              final progress =
                  value.position.inMilliseconds /
                  value.metaData.duration.inMilliseconds;

              return LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0), // Safety clamp
                minHeight: 2,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF64B5F6),
                ), // Light Blue
              );
            },
          ),
        ),
      ],
    );
  }
}
