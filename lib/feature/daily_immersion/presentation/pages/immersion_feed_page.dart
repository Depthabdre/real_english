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
                onPageChanged: (index) {
                  setState(() => _focusedIndex = index);

                  // Load more when approaching end
                  if (index >= state.shorts.length - 2) {
                    context.read<ImmersionBloc>().add(
                      const LoadMoreImmersionFeed(),
                    );
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
