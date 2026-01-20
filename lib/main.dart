import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:lefni/config/app_router.dart';
import 'package:lefni/l10n/app_localizations.dart';
import 'package:lefni/theme/app_theme.dart';
import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    // Set up locale callback for router
    AppRouter.setLocaleCallback((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserSessionProvider(),
      child: MaterialApp.router(
        title: 'Control Panel',
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        
        // Router configuration
        routerConfig: AppRouter.router,
        
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