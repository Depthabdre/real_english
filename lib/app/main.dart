import 'package:flutter/material.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Setup router
  final appRouter = AppRouter();

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ethio English Learning',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Users can change this in settings
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.router,
    );
  }
}
