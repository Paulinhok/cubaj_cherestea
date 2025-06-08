import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:flutter/material.dart';
import 'package:scandura/pages/menu.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:scandura/pages/new_cubbing.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_ad/flutter_native_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/l10n/app_localizations.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(const Duration(seconds: 5));
  FlutterNativeAd.init();
  //unawaited(MobileAds.instance.initialize());
  MobileAds.instance.initialize();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  DatabaseHelper().initDB();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ro', '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ro', ''), // Romanian
        Locale('en', ''), // English
        Locale('fr', ''), // French
        Locale('es', ''), // Spanish
        
      ],
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        // '/': (context) => HomePage(),
        '/menu': (context) => const MenuPage(),
        '/new_cubbing': (context) => NewCubbingPage(numeLista: ''),
        '/list_of_cubbing': (context) => ListOfCubbingPage(),
        '/liste_cubaj': (context) => ListeCubaj()
      },
    );
  }
}
