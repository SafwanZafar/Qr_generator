import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/qr_template.dart';
import 'template_event.dart';
import 'template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc() : super(const TemplateInitial()) {
    on<TemplateFilterEvent>(_onFilter);
    on<TemplateSearchEvent>(_onSearch);

    // load all on init
    emit(TemplateLoaded(
      all:          kTemplates,
      filtered:     kTemplates,
      activeFilter: 'All',
    ));
  }

  List<QRTemplate> _apply(
      List<QRTemplate> all, String filter, String query) {
    var list = filter == 'All'
        ? all
        : all.where((t) => t.category == filter).toList();
    if (query.isNotEmpty) {
      list = list
          .where((t) =>
          t.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return list;
  }

  void _onFilter(
      TemplateFilterEvent event,
      Emitter<TemplateState> emit,
      ) {
    final current = state as TemplateLoaded;
    emit(current.copyWith(
      filtered:     _apply(current.all, event.filter,
          current.searchQuery),
      activeFilter: event.filter,
    ));
  }

  void _onSearch(
      TemplateSearchEvent event,
      Emitter<TemplateState> emit,
      ) {
    final current = state as TemplateLoaded;
    emit(current.copyWith(
      filtered:    _apply(current.all, current.activeFilter,
          event.query),
      searchQuery: event.query,
    ));
  }
}