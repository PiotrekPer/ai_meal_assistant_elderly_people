import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/onboarding/name_page.dart';
import 'screens/onboarding/email_page.dart';
import 'screens/onboarding/birthdate_page.dart';
import 'screens/onboarding/food_preferences_page.dart';
import 'screens/onboarding/allergies_page.dart';
import 'screens/onboarding/shop_preference_page.dart';
import 'screens/login_screen.dart';
import '../database_helper.dart';
import 'screens/dashboard.dart';
import 'screens/onboarding/weight_input_screen.dart';
import 'screens/onboarding/height_input_screen.dart';
import 'screens/onboarding/workout_frequency_page.dart';
import 'services/user_profile_service.dart';

const List<String> foodOptions = ['Wege', 'Vegan', 'Meat', 'Pescatarian'];
const List<String> allergenOptions = ['Gluten', 'Peanuts', 'Dairy', 'Soy'];
const List<String> shopOptions = ["Lidl", "Aldi", "Tesco", "Sainsbury's", "Waitrose"];
const List<String> workoutOptions = ['Not work out', '1-3', '3-5', 'Everyday'];

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_done') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6A4D), 
          primary: const Color(0xFF2E6A4D), 
          secondary: const Color(0xFFF2994A), 
          background: const Color(0xFFF2DD), 
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
          brightness: Brightness.light,
        ),
  scaffoldBackgroundColor: const Color(0xFFFFF2DD),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30 
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _isOnboardingDone(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.data! ? const HomeScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  List<String> _foodPrefs = [];
  List<String> _allergies = [];
  String? _shopPref;
  String? _workoutFreq;
  double _weight = 70.0; 
  double _height = 170.0; 
  int _index = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidName() => _nameCtrl.text.trim().length >= 2;
  bool _isValidEmail() => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailCtrl.text.trim());
  bool _isValidAge() {
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(_ageCtrl.text.trim())) {
      return false;
    }
    try {
      final parts = _ageCtrl.text.trim().split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      if (date.isAfter(now) || year < now.year - 120) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
  bool _isValidFoodPrefs() => _foodPrefs.isNotEmpty;
  bool _isValidAllergies() => true; 
  bool _isValidShopPref() => _shopPref != null && _shopPref!.isNotEmpty;
  bool _isValidWorkoutFreq() => _workoutFreq != null && _workoutFreq!.isNotEmpty;

  bool _canContinue(int page) {
    switch (page) {
      case 0: return _isValidName();
      case 1: return true; 
      case 2: return true; 
      case 3: return _isValidWorkoutFreq();
      case 4: return _isValidEmail();
      case 5: return _isValidAge();
      case 6: return _isValidFoodPrefs();
      case 7: return _isValidAllergies();
      case 8: return _isValidShopPref();
      default: return true;
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = DatabaseHelper();

 
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_email', _emailCtrl.text.trim());
    await prefs.setInt('user_age', int.tryParse(_ageCtrl.text.trim()) ?? 0);
    await prefs.setStringList('user_food_prefs', _foodPrefs);
    await prefs.setStringList('user_allergies', _allergies);
    await prefs.setString('user_shop_pref', _shopPref ?? '');
    await prefs.setString('user_workout_freq', _workoutFreq ?? '');
    await prefs.setBool('onboarding_done', true);


    final userId = await dbHelper.insertUser(
      _emailCtrl.text.trim(),
      'default_password', 
      _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()),
      foodPreferences: _foodPrefs,
      allergies: _allergies,
      shopPreference: _shopPref,
      weight: _weight,
      height: _height,
      workoutFrequency: _workoutFreq,
    );
    print('User inserted with ID: $userId');


    final user = await dbHelper.getUser(_emailCtrl.text.trim());

    if (!mounted) return;


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Dashboard(user: {
          'name': user?['name'],
          'email': user?['email'],
          'age': user?['age'],
          'food_preferences': user?['food_preferences'],
          'allergies': user?['allergies'],
          'shop_preference': user?['shop_preference'],
        }),
      ),
    );
  }

  void _next() {
    if (!_canContinue(_index)) return;
    
    if (_index == 1) {
      final weightScreen = context.findAncestorWidgetOfExactType<WeightInputScreen>();
      if (weightScreen != null) {
        final userProfileService = UserProfileService();
        userProfileService.updateWeight(_weight);
      }
    }
    
    if (_index < 8) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }



  @override
  Widget build(BuildContext context) {
    final canContinue = _canContinue(_index);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: Text('Already have an account?', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: (_index + 1) / 9),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  NamePage(controller: _nameCtrl, onChanged: () => setState(() {})),
                  HeightInputScreen(onNext: _next, onHeightChanged: (height) => _height = height),
                  WeightInputScreen(onNext: _next, onWeightChanged: (weight) => _weight = weight),
                  WorkoutFrequencyPage(options: workoutOptions, selected: _workoutFreq, onChanged: (v) => setState(() => _workoutFreq = v)),
                  EmailPage(controller: _emailCtrl, name: _nameCtrl.text, onChanged: () => setState(() {}), onSubmitted: _next),
                  BirthdatePage(controller: _ageCtrl, onChanged: () => setState(() {})),
                  FoodPreferencesPage(options: foodOptions, selected: _foodPrefs, onChanged: (v) => setState(() => _foodPrefs = v)),
                  AllergiesPage(options: allergenOptions, selected: _allergies, onChanged: (v) => setState(() => _allergies = v)),
                  ShopPreferencePage(options: shopOptions, selected: _shopPref, onChanged: (v) => setState(() => _shopPref = v)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _index == 0 ? null : _back,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: canContinue ? _next : null,
                    icon: Icon(_index == 8 ? Icons.check : Icons.arrow_forward),
                    label: Text(_index == 8 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'there',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final name = snap.data!['name']!;
        final email = snap.data!['email']!;
        return Scaffold(
          appBar: null,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome, $name 👋', style: Theme.of(context).textTheme.headlineSmall),
                if (email.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(email, style: Theme.of(context).textTheme.bodyMedium),
                ],
                SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('onboarding_done');
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => OnboardingScreen()),
                    );
                  },
                  child: Text('Reset onboarding (dev)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
