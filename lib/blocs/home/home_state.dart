part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

final class HomeGetBookInfo extends HomeState {
  final BookInfo book;
  HomeGetBookInfo(this.book);
}

final class HomeLoadStatus extends HomeState {
  final bool isLoading;
  final bool isSave;
  HomeLoadStatus(this.isLoading, this.isSave);
}

final class HomeGetFilesStatus extends HomeState {
  final ProcessStatus status ;
  final String message;
  HomeGetFilesStatus(this.status, this.message);
}

final class HomeSaveStatus extends HomeState {
  final ProcessStatus status;
  HomeSaveStatus(this.status);
}

enum ProcessStatus {
  failed, success
}
