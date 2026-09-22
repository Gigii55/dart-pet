import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    return MaterialApp(
      title: 'App Pet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaHome(), 
    );
  }
}