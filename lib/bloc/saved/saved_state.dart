import 'package:equatable/equatable.dart';
import '../../models/qr_history.dart';

abstract class SavedState extends Equatable {
  const SavedState();
  @override
  List<Object?> get props => [];
}

class SavedInitial extends SavedState {
  const SavedInitial();
}

class SavedLoading extends SavedState {
  const SavedLoading();
}

class SavedLoaded extends SavedState {
  final List<QRHistory> all;
  final List<QRHistory> filtered;
  final String          activeFilter;
  final Set<String>     savingIds;
  final Set<String>     sharingIds;

  const SavedLoaded({
    required this.all,
    required this.filtered,
    required this.activeFilter,
    this.savingIds  = const {},
    this.sharingIds = const {},
  });

  SavedLoaded copyWith({
    List<QRHistory>? all,
    List<QRHistory>? filtered,
    String?          activeFilter,
    Set<String>?     savingIds,
    Set<String>?     sharingIds,
  }) =>
      SavedLoaded(
        all:          all          ?? this.all,
        filtered:     filtered     ?? this.filtered,
        activeFilter: activeFilter ?? this.activeFilter,
        savingIds:    savingIds    ?? this.savingIds,
        sharingIds:   sharingIds   ?? this.sharingIds,
      );

  @override
  List<Object?> get props =>
      [all, filtered, activeFilter, savingIds, sharingIds];
}

class SavedError extends SavedState {
  final String message;
  const SavedError(this.message);
  @override
  List<Object?> get props => [message];
}