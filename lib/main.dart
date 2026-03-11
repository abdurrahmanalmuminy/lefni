import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lefni/config/app_router.dart';
import 'package:lefni/config/app_config.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/theme/app_theme.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment configuration
  await AppConfig.initialize();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar'); // Default to Arabic
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  late final UserSessionProvider _userSessionProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create user session provider
    _userSessionProvider = UserSessionProvider();
    // Create router with refreshListenable to listen to auth state changes
    _router = AppRouter.createRouter(_userSessionProvider);
    // Set up locale callback for router
    AppRouter.setLocaleCallback((locale) {
      setState(() {
        _locale = locale;
      });
    });
    // Set up theme mode callback for router
    AppRouter.setThemeModeCallback((themeMode) {
      setState(() {
        _themeMode = themeMode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _userSessionProvider,
      child: MaterialApp.router(
        title: 'خبراء القانون للمحاماة والاستشارات القانونية',
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        
        // Router configuration
        routerConfig: _router,
        
        // Localization configuration
        locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
        ],
        
        // RTL support - use the selected locale
        localeResolutionCallback: (locale, supportedLocales) {
          // Always use the selected locale
          return _locale;
        },
      ),
    );
  }
}