part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

final class HomeGetBookInfo extends HomeState {
  final BookInfo book;
  HomeGetBookInfo(this.book);
}
