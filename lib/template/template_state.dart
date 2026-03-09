import 'package:equatable/equatable.dart';
import '../../models/qr_template.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();
  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {
  const TemplateInitial();
}

class TemplateLoaded extends TemplateState {
  final List<QRTemplate> all;
  final List<QRTemplate> filtered;
  final String           activeFilter;
  final String           searchQuery;

  const TemplateLoaded({
    required this.all,
    required this.filtered,
    required this.activeFilter,
    this.searchQuery = '',
  });

  TemplateLoaded copyWith({
    List<QRTemplate>? all,
    List<QRTemplate>? filtered,
    String?           activeFilter,
    String?           searchQuery,
  }) =>
      TemplateLoaded(
        all:          all          ?? this.all,
        filtered:     filtered     ?? this.filtered,
        activeFilter: activeFilter ?? this.activeFilter,
        searchQuery:  searchQuery  ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [all, filtered, activeFilter, searchQuery];
}