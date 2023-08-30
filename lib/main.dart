import 'package:flutter/material.dart';
import 'package:nagn_2/ui/page/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.red,
            background: const Color.fromRGBO(33, 37, 48, 1)),
        useMaterial3: true,
      ),
      initialRoute: "/home",
      routes: {"/home": (context) => HomePage()},
    );
  }
}
