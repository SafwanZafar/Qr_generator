import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/qr_history.dart';
import '../../services/history_service.dart';
import '../../services/gallery_services.dart';
import '../../services/share_services.dart';
import 'saved_event.dart';
import 'saved_state.dart';

class SavedBloc extends Bloc<SavedEvent, SavedState> {
  SavedBloc() : super(const SavedInitial()) {
    on<SavedLoadEvent>(_onLoad);
    on<SavedFilterEvent>(_onFilter);
    on<SavedDeleteEvent>(_onDelete);
    on<SavedShareImageEvent>(_onShare);
    on<SavedSaveImageEvent>(_onSaveImage);
  }

  List<QRHistory> _applyFilter(
      List<QRHistory> all, String filter) {
    if (filter == 'All') return all;
    return all.where((e) => e.type == filter).toList();
  }

  Future<void> _onLoad(
      SavedLoadEvent event,
      Emitter<SavedState> emit,
      ) async {
    emit(const SavedLoading());
    try {
      final all = await HistoryService.load();
      emit(SavedLoaded(
        all:          all,
        filtered:     all,
        activeFilter: 'All',
      ));
    } catch (e) {
      emit(SavedError(e.toString()));
    }
  }

  Future<void> _onFilter(
      SavedFilterEvent event,
      Emitter<SavedState> emit,
      ) async {
    final current = state as SavedLoaded;
    emit(current.copyWith(
      filtered:     _applyFilter(current.all, event.filter),
      activeFilter: event.filter,
    ));
  }

  Future<void> _onDelete(
      SavedDeleteEvent event,
      Emitter<SavedState> emit,
      ) async {
    await HistoryService.delete(event.id);
    add(const SavedLoadEvent());
  }

  Future<void> _onSaveImage(
      SavedSaveImageEvent event,
      Emitter<SavedState> emit,
      ) async {
    final current = state as SavedLoaded;
    emit(current.copyWith(
        savingIds: {...current.savingIds, event.id}));
    try {
      // bytes passed from UI via capture
    } finally {
      final updated = {...current.savingIds}..remove(event.id);
      emit(current.copyWith(savingIds: updated));
    }
  }

  Future<void> _onShare(
      SavedShareImageEvent event,
      Emitter<SavedState> emit,
      ) async {
    final current = state as SavedLoaded;
    emit(current.copyWith(
        sharingIds: {...current.sharingIds, event.id}));
    try {
      await ShareService.shareImage(event.bytes);
    } finally {
      final updated = {...current.sharingIds}..remove(event.id);
      emit(current.copyWith(sharingIds: updated));
    }
  }
}