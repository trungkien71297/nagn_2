import 'package:get_it/get_it.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';

GetIt getIt = GetIt.instance;
void setUp() {
  getIt.registerSingleton<HomeBloc>(HomeBloc());
}