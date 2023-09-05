import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';
import 'package:nagn_2/di.dart';
import 'package:nagn_2/ui/page/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
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
      routes: {"/home": (context) => BlocProvider(create: (context) => getIt<HomeBloc>(), child: HomePage(),)},
    );
  }
}
