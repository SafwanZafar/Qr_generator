import 'package:equatable/equatable.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();
  @override
  List<Object?> get props => [];
}

class TemplateFilterEvent extends TemplateEvent {
  final String filter;
  const TemplateFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class TemplateSearchEvent extends TemplateEvent {
  final String query;
  const TemplateSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}