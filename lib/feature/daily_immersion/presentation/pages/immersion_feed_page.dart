import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../../../app/injection_container.dart';
import '../bloc/immersion_bloc.dart';
import '../widgets/immersion_video_item.dart';
import '../widgets/shorts_skeleton_loader.dart';
import '../widgets/fast_scroll_physics.dart';

class ImmersionFeedPage extends StatelessWidget {
  const ImmersionFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Video background
      // No AppBar, we want full immersion
      body: BlocProvider(
        create: (_) => sl<ImmersionBloc>()..add(const LoadImmersionFeed()),
        child: const _ImmersionView(),
      ),
    );
  }
}

class _ImmersionView extends StatefulWidget {
  const _ImmersionView();

  @override
  State<_ImmersionView> createState() => _ImmersionViewState();
}

class _ImmersionViewState extends State<_ImmersionView> {
  late final PreloadPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImmersionBloc, ImmersionState>(
      builder: (context, state) {
        if (state is ImmersionLoading) {
          return const ShortsSkeletonLoader();
        }

        if (state is ImmersionError) {
          return _buildErrorState(context, state.message);
        }

        if (state is ImmersionLoaded) {
          final bloc = context.read<ImmersionBloc>();

          return Stack(
            children: [
              PreloadPageView.builder(
                key: const PageStorageKey('immersion_feed'),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const FastScrollPhysics(),
                preloadPagesCount: 1,
                itemCount: state.shorts.length,
                onPageChanged: (index) {
                  if (index >= state.shorts.length - 2) {
                    bloc.add(const LoadMoreImmersionFeed());
                  }
                },
                itemBuilder: (context, index) {
                  final short = state.shorts[index];
                  return ImmersionVideoItem(
                    key: ValueKey('short-${short.id}'),
                    short: short,
                  );
                },
              ),

              if (bloc.isLoadingMore)
                Positioned(
                  bottom: 100, // Move up above Nav Bar
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_wifi_off_rounded, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () =>
                context.read<ImmersionBloc>().add(const LoadImmersionFeed()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
