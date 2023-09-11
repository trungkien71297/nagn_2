import 'package:get_it/get_it.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';
import 'package:nagn_2/utils/method_channel.dart';

GetIt getIt = GetIt.instance;
void setUp() {
  getIt.registerSingleton<HomeBloc>(HomeBloc());
  getIt.registerSingleton(MethodChannelExecutor());
}
