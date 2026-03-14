import 'package:equatable/equatable.dart';
import '../../models/qr_history.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<QRHistory> history;
  final List<QRHistory> filtered;
  final String          searchQuery;

  HomeLoaded({
    required this.history,
    List<QRHistory>?  filtered,      // ← nullable
    this.searchQuery = '',
  }) : filtered = filtered ?? history; // ← default = history

  @override
  List<Object?> get props => [history, filtered, searchQuery];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}