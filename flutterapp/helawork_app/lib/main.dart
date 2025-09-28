import 'package:flutter/material.dart';
import 'package:helawork_app/providers/contract_provider.dart';
import 'package:helawork_app/providers/dashboard_provider.dart';
import 'package:helawork_app/providers/forgot_password_provider.dart';
import 'package:helawork_app/providers/payment_provider.dart';
import 'package:helawork_app/providers/proposal_provider.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:helawork_app/providers/task_provider.dart';
import 'package:helawork_app/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'home/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),  
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()) , 
        ChangeNotifierProvider(create: (_) => PaymentProvider()),   
        ChangeNotifierProvider(create: (_) => ProposalProvider()),
        ChangeNotifierProvider(create: (_) => ContractProvider()..fetchContracts()),
        ChangeNotifierProvider(create: (_) => RatingProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HELAWORK',
      theme: ThemeData.dark(),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return FutureBuilder(
              future: context.read<DashboardProvider>().loadData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );
                }
                return const DashboardPage();
              },
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}