import 'package:firebase_core/firebase_core.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CatchClickerApp());
}

class CatchClickerApp extends StatelessWidget {
  const CatchClickerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
    ),
    home: const ClickerScreen(),
  );
}
