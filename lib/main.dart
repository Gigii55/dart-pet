import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trabalho/telaCadastro.dart';
import 'telaInicio.dart';
import 'telaHome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
    ),
  );

  runApp(const MeuAppPet());
}

class MeuAppPet extends StatelessWidget {
  const MeuAppPet({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = ColorScheme.fromSeed(seedColor: Colors.teal);

    return MaterialApp(
      title: 'App Pet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: cores,
        scaffoldBackgroundColor: const Color(0xFFF6F8F8),
        appBarTheme: AppBarTheme(
          backgroundColor: cores.primary,
          foregroundColor: cores.onPrimary,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const TelaInicio(),
    );
  }
}
