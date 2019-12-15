import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
// See https://github.com/long1eu/flutter_i18n/pull/33
// until this PR is merged, the country code must be specified in the ARB-files
import 'generated/i18n.dart';
import 'models/appstate.dart';
import 'ui/pages/home/index.dart';
import 'ui/pages/login/index.dart';
import 'ui/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // A breaking change in the platform messaging, as of Flutter 1.12.13+hotfix.5,
  // we need to explicitly initialise bindings to get access to the BinaryMessenger
  // This is needed by Crashlytics.
  // https://groups.google.com/forum/#!msg/flutter-announce/sHAL2fBtJ1Y/mGjrKH3dEwAJ
  WidgetsFlutterBinding.ensureInitialized();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // Get an instance so that globals is initialised
  var prefs =  await SharedPreferences.getInstance();
  var appState = new AppStateModel(prefs);
  var routes = <String, WidgetBuilder>{
    "/HomePage": (BuildContext context) => new ScopedModel<AppStateModel>(
        model: appState,
        child: new HomePage()
    ),
    "/LoginPage": (BuildContext context) => new ScopedModel<AppStateModel>(
        model: appState,
        child: new LoginPage()
    ),
  };

  runZoned<Future<Null>>(() async {
    runApp(new MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback: S.delegate.listResolution(fallback: const Locale('en', '')),
      localeResolutionCallback: S.delegate.resolution(fallback: const Locale('en', '')),
      home: new ScopedModel<AppStateModel>(
          model: appState,
          child: new HomePage()
      ),
      theme: appTheme,
      routes: routes,
    ));
  }, onError: Crashlytics.instance.recordError);

}
