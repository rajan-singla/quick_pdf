import 'package:flutter/material.dart';
import 'package:quick_pdf/src/features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuickPDFApp());
}

class QuickPDFApp extends StatelessWidget {
  const QuickPDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QuickPDF",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
