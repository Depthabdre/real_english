import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_english/app/app_router.dart';
import 'package:real_english/app/app_theme.dart';
import 'package:real_english/app/injection_container.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_bloc.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_event.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");
  await init(); // Initializes all dependencies via GetIt

  // Get the singleton AppRouter instance from the service locator
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
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AppStarted()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            appRouter.isAuthenticated.value = true;
          } else if (state is Unauthenticated || state is AuthError) {
            appRouter.isAuthenticated.value = false;
          }
        },
        child: MaterialApp.router(
          title: 'Ethio English Learning',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter.router,
        ),
      ),
    );
  }
}
