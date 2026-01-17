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
      backgroundColor: Colors.black,
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
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    // KeepPage: true prevents state loss during tab switching
    _pageController = PreloadPageController(keepPage: true);
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
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (state is ImmersionLoaded) {
          return Stack(
            children: [
              PreloadPageView.builder(
                key: const PageStorageKey('immersion_feed'),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                // The new strict physics
                physics: const FastScrollPhysics(),
                // Preload 1 allows the next Image to be ready, but not the Player
                preloadPagesCount: 1,
                itemCount: state.shorts.length,
                onPageChanged: (newIndex) {
                  final bloc = context.read<ImmersionBloc>();

                  // --- 1. Mark Previous Video as Watched ---
                  // _focusedIndex is currently the "Old" index (the one we are leaving)
                  if (_focusedIndex >= 0 &&
                      _focusedIndex < state.shorts.length) {
                    final previousShort = state.shorts[_focusedIndex];

                    // Optimization: Only fire event if it's not already watched
                    // to save API calls and state rebuilds.
                    if (!previousShort.isWatched) {
                      bloc.add(MarkShortAsWatched(previousShort.id));
                    }
                  }

                  // --- 2. Update Local State ---
                  setState(() => _focusedIndex = newIndex);

                  // --- 3. Load More Data ---
                  if (newIndex >= state.shorts.length - 2) {
                    bloc.add(const LoadMoreImmersionFeed());
                  }
                },
                itemBuilder: (context, index) {
                  return ImmersionVideoItem(
                    key: ValueKey('short-${state.shorts[index].id}'),
                    short: state.shorts[index],
                    // Pass the focus state down
                    isFocused: index == _focusedIndex,
                  );
                },
              ),

              // Simple Loading Indicator for infinite scroll
              if (context.read<ImmersionBloc>().isLoadingMore)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
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
}
