/// Initialises project-level things and redirects to the [Landing] page.
///
/// Author: Aden McCusker

import 'package:flutter/material.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/page/onboarder.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'page/landing_page.dart';
import 'page/loading_page.dart';
import 'page/error_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;
  bool _error = false;

  /// Initialise and configure the Firebase backend for this app.
  Future<void> _initialiseFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  /// Initialise all app-level things before the UI is built.
  Future<void> _initialise() async {
    try {
      await initializeDateFormatting('en_AU');
      await _initialiseFirebase();

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  /// Determine which page to display based on the state of the initialisation.
  Widget _getPage() {
    return Onboarder(
        subject: SubjectModel(
            name: 'comp',
            code: '123',
            assessments: [
              RequestType(name: 'p1', type: 'type', id: '50'),
              RequestType(name: 'p2', type: 'type2', id: '100')
            ],
            semester: '2',
            year: '2023'));
    if (_error) {
      return const Error();
    }

    if (!_initialized) {
      return const Loading();
    }

    return const Landing();
  }

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Specon',
        theme: ThemeData.from(
            useMaterial3: true,
            colorScheme: const ColorScheme(
                brightness: Brightness.dark,
                primary: Color(0xFF385F71),
                onPrimary: Color(0xFFD4D4D4),
                secondary: Color(0xFFDF6C00),
                onSecondary: Color(0xFFD4D4D4),
                error: Color(0xFFB00020),
                onError: Color(0xFFD4D4D4),
                //background: Color(0xFF333333),
                background: Color(0xFF222222),
                onBackground: Color(0xFFD4D4D4),
                surface: Color(0xFFD4D4D4),
                onSurface: Color(0xFF000000))),
        home: _getPage());
  }
}
