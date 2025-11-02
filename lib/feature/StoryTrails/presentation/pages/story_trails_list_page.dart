// presentation/pages/story_trails_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import our dependency injection service locator
import '../../../../app/injection_container.dart';

import '../bloc/story_trails_list_bloc.dart';
import '../widgets/story_trail_card.dart';

class StoryTrailsListPage extends StatelessWidget {
  const StoryTrailsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Next Adventure'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      // ✅ --- PROVIDE THE BLOC HERE ---
      // We wrap only this page with a BlocProvider for StoryTrailsListBloc.
      body: BlocProvider<StoryTrailsListBloc>(
        // Use the service locator 'sl' to create a new instance of the BLoC.
        // This is where our dependency injection setup pays off!
        create: (context) => sl<StoryTrailsListBloc>()
          ..add(
            FetchStoryTrailsList(),
          ), // Immediately dispatch the event to load data.

        child: BlocBuilder<StoryTrailsListBloc, StoryTrailsListState>(
          builder: (context, state) {
            // --- Loading State ---
            if (state is StoryTrailsListLoading ||
                state is StoryTrailsListInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- Error State ---
            if (state is StoryTrailsListError) {
              return _buildErrorState(context, state.message);
            }

            // --- Loaded State ---
            if (state is StoryTrailsListLoaded) {
              if (state.storyTrails.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildLoadedState(context, state);
            }

            // Fallback for any other unhandled state
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

  // ... (All the _buildLoadedState, _buildErrorState, and _buildEmptyState helpers remain the same)

  Widget _buildLoadedState(BuildContext context, StoryTrailsListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StoryTrailsListBloc>().add(FetchStoryTrailsList());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: state.storyTrails.length,
        itemBuilder: (context, index) {
          final storyTrail = state.storyTrails[index];
          return StoryTrailCard(storyTrail: storyTrail);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              'Oh no!',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<StoryTrailsListBloc>().add(
                FetchStoryTrailsList(),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off_outlined,
              color: theme.textTheme.bodyMedium?.color,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Stories Here Yet',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'New adventures for this level are coming soon!',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
