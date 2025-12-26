import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'services/preferences_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration du statut bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialisation du widget menstruel
  MenstrualCycleWidget.init(
    secretKey: "cycletrack2024secretkey",
    ivKey: "ivkey2024cycletracker",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
        ),
        useMaterial3: true,
        fontFamily: 'System',
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final PreferencesService _prefsService = PreferencesService();
  bool _isLoading = true;
  bool _showSplash = true;
  bool _isFirstLaunch = true;
  bool _showCalendarAfterOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _prefsService.init();

    // Vérifier si c'est le premier lancement
    _isFirstLaunch = _prefsService.isFirstLaunch;

    // Si ce n'est pas le premier lancement, configurer le widget
    if (!_isFirstLaunch) {
      _configureWidget();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _configureWidget() {
    MenstrualCycleWidget.instance!.updateConfiguration(
      cycleLength: _prefsService.cycleLength,
      periodDuration: _prefsService.periodDuration,
      customerId: _prefsService.userId,
      defaultLanguage: Languages.english,
    );
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _onOnboardingComplete() {
    _configureWidget();
    setState(() {
      _isFirstLaunch = false;
      _showCalendarAfterOnboarding = true;
    });
  }

  void _onCalendarFinalize() {
    setState(() {
      _showCalendarAfterOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }

    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    if (_isFirstLaunch) {
      return OnboardingScreen(
        prefsService: _prefsService,
        onComplete: _onOnboardingComplete,
      );
    }

    if (_showCalendarAfterOnboarding) {
      return CalendarScreen(
        prefsService: _prefsService,
        onFinalize: _onCalendarFinalize,
      );
    }

    return HomeScreen(prefsService: _prefsService);
  }
}
