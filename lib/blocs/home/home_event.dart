part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

final class OnAddFile extends HomeEvent {
  final File file;
  OnAddFile(this.file);
}

final class OnSaveFile extends HomeEvent{}

final class HomeInit extends HomeEvent {}
