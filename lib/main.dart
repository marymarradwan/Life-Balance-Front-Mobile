import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/view/SplashScreen.dart';

import 'Util/cache_helper.dart';
import 'Util/http/constant.dart';
import 'Util/language_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await CashHelper.init();
  if (CashHelper.getData(key: ChangeTheme) == null) {
    CashHelper.saveData(key: ChangeTheme, value: false);
    print(CashHelper.saveData(key: ChangeTheme, value: false));
  }

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {});
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    },
  );
  HttpOverrides.global = MyHttpOverrides();
  runApp(EasyLocalization(
      supportedLocales: [LanguageHelper.kEnglishLocale, LanguageHelper.kArabicLocale],
      // supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translation', // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool iconBool = CashHelper.getData(key: ChangeTheme) ?? false;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _lightTheme;
  ThemeData _DarkTheme;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String lang = context.deviceLocale.toString().split('_').first;
    print(lang);
    if (CashHelper.getData(key: LanguageValue) == null) {
      CashHelper.saveData(key: LanguageValue, value: lang);

      if (lang == 'en') {
        context.locale == LanguageHelper.kEnglishLocale;
        context.setLocale(LanguageHelper.kEnglishLocale);
      } else if (lang == 'ar') {
        context.locale == LanguageHelper.kArabicLocale;
        context.setLocale(LanguageHelper.kArabicLocale);
      }
    }
    _lightTheme = ThemeData(
        fontFamily: "Subjective",
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(displayColor: Colors.yellow),
        // primarySwatch: Colors.amber,
        brightness: Brightness.light);
    _DarkTheme = ThemeData(
        fontFamily: "Subjective",
        scaffoldBackgroundColor: AppColor.darkModePrim,
        textTheme: Theme.of(context).textTheme.apply(displayColor: Colors.yellow),
        brightness: Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 752),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget child) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: 'C App',
        //theme: ThemeData(),
        //darkTheme: ThemeData.dark(),

        theme: CashHelper.getData(key: ChangeTheme) ? _lightTheme : _DarkTheme,
        themeMode: _themeMode,

        home: Builder(builder: (context) {
          return SplashScreen();
        }),
      ),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
