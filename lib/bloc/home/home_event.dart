import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadEvent extends HomeEvent {
  const HomeLoadEvent();
}

class HomeDeleteHistoryEvent extends HomeEvent {
  final String id;
  const HomeDeleteHistoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class HomeClearHistoryEvent extends HomeEvent {
  const HomeClearHistoryEvent();
}

// ── Search event ──────────────────────────────────────────────
class HomeSearchEvent extends HomeEvent {
  final String query;
  const HomeSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}