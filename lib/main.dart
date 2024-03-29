import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';
import 'package:nagn_2/di.dart';
import 'package:nagn_2/ui/page/home_page.dart';
import 'package:nagn_2/ui/page/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.red,
            background: const Color.fromRGBO(33, 37, 48, 1)),
        useMaterial3: true,
      ),
      initialRoute: "/splash_screen",
      routes: {
        "/home": (context) => BlocProvider(
              create: (context) => getIt<HomeBloc>(),
              child: HomePage(),
            ),
        "/splash_screen": (context) => const SplashScreen()
      },
    );
  }
}
