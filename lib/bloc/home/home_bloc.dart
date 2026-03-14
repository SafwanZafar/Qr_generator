import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/history_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadEvent>(_onLoad);
    on<HomeDeleteHistoryEvent>(_onDelete);
    on<HomeClearHistoryEvent>(_onClear);
    on<HomeSearchEvent>(_onSearch);  // ← ADD
  }

  Future<void> _onLoad(
      HomeLoadEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(const HomeLoading());
    try {
      final history = await HistoryService.load();
      emit(HomeLoaded(
        history:  history,
        filtered: history,  // ← initially all show karo
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onDelete(
      HomeDeleteHistoryEvent event,
      Emitter<HomeState> emit,
      ) async {
    await HistoryService.delete(event.id);
    add(const HomeLoadEvent());
  }

  Future<void> _onClear(
      HomeClearHistoryEvent event,
      Emitter<HomeState> emit,
      ) async {
    await HistoryService.clearAll();
    add(const HomeLoadEvent());
  }

  // ── Search ────────────────────────────────────────────────────
  Future<void> _onSearch(
      HomeSearchEvent event,
      Emitter<HomeState> emit,
      ) async {
    final current = state;
    if (current is! HomeLoaded) return;

    final query    = event.query.toLowerCase().trim();
    final filtered = query.isEmpty
        ? current.history
        : current.history.where((item) =>
    item.label.toLowerCase().contains(query) ||
        item.type.toLowerCase().contains(query)  ||
        item.data.toLowerCase().contains(query),
    ).toList();

    emit(HomeLoaded(
      history:     current.history,
      filtered:    filtered,
      searchQuery: query,
    ));
  }
}