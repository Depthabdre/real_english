import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import your app core files
import 'package:real_english/app/app_router.dart';
import 'package:real_english/app/app_theme.dart';
import 'package:real_english/app/bloc_observer.dart';
import 'package:real_english/app/injection_container.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_bloc.dart';

// Import your Hive Models
import 'package:real_english/feature/StoryTrails/data/models/challenge_attempt_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/choice_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/single_choice_challenge_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/story_progress_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/story_segment_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/story_trail_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/user_learning_profile_model.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // ADD THIS LINE:
  Bloc.observer = SimpleBlocObserver();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Register Hive Adapters
  Hive.registerAdapter(StoryTrailModelAdapter());
  Hive.registerAdapter(StorySegmentModelAdapter());
  Hive.registerAdapter(SegmentTypeAdapter());
  Hive.registerAdapter(ChallengeTypeAdapter());
  Hive.registerAdapter(SingleChoiceChallengeModelAdapter());
  Hive.registerAdapter(ChoiceModelAdapter());
  Hive.registerAdapter(StoryProgressModelAdapter());
  Hive.registerAdapter(ChallengeAttemptModelAdapter());
  Hive.registerAdapter(UserLearningProfileModelAdapter());

  // 4. Initialize Dependency Injection
  await init();

  // 5. Get the Router (which already has AuthBloc injected via DI)
  final appRouter = sl<AppRouter>();

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // We only CREATE the Bloc here.
        // We DO NOT add AppStarted here, because the SplashScreen will do that.
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      // No BlocListener needed here anymore.
      // The AppRouter listens to the stream internally.
      child: MaterialApp.router(
        title: 'Ethio English Learning',

        // Theme Config
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        debugShowCheckedModeBanner: false,

        // Router Config
        routerConfig: appRouter.router,
      ),
    );
  }
}
