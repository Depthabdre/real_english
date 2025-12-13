import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/injection_container.dart'; // Adjust path to your sl
import '../bloc/immersion_bloc.dart';
import '../widgets/immersion_video_item.dart';

class ImmersionFeedPage extends StatelessWidget {
  const ImmersionFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Immersion always looks best in Dark Mode style (like TikTok/Reels),
    // even if the app is in Light Mode. We force a dark aesthetic for this page.
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocProvider<ImmersionBloc>(
        create: (context) =>
            sl<ImmersionBloc>()..add(const LoadImmersionFeed()),
        child: const _ImmersionView(),
      ),
    );
  }
}

class _ImmersionView extends StatelessWidget {
  const _ImmersionView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImmersionBloc, ImmersionState>(
      builder: (context, state) {
        if (state is ImmersionLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
          );
        } else if (state is ImmersionError) {
          return _buildErrorState(context, state.message);
        } else if (state is ImmersionLoaded) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.shorts.length,
            // Preload pages for smoother scrolling
            allowImplicitScrolling: true,
            itemBuilder: (context, index) {
              return ImmersionVideoItem(short: state.shorts[index]);
            },
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
          const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 50),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () =>
                context.read<ImmersionBloc>().add(const LoadImmersionFeed()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
