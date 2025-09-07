import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helawork_app/screens/login_screen.dart';
import 'package:helawork_app/home/dashboard_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HELAWORK',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _showLoginButton = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt("loginTime");
      final username = prefs.getString("username");

      bool loggedIn = false;

      if (loginTime != null && username != null && username.isNotEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final sevenDays = 7 * 24 * 60 * 60 * 1000; 

        if (now - loginTime < sevenDays) {
          loggedIn = true;
        } else {
          await prefs.clear();
        }
      }

      // Add a small delay to show the loading animation
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
        _showLoginButton = !loggedIn; 
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
        _showLoginButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    
    if (_isLoggedIn) {
      return const DashboardPage();
    }

    
    return _showLoginButton 
        ? MyHomePageWithLogin(title: 'Helawork') 
        : const MyHomePage(title: 'Helawork');
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1B5E20)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "HELAWORK",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    "assets/images/image.png",
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePageWithLogin extends StatelessWidget {
  final String title;
  const MyHomePageWithLogin({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1B5E20)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "HELAWORK",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Hero(
                      tag: "logo",
                      child: Image.asset(
                        "assets/images/image.png",
                        height: 200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Login button at the bottom (like Airtel Money)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}