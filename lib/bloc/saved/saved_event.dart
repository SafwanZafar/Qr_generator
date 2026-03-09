import 'package:equatable/equatable.dart';
import 'dart:typed_data';

abstract class SavedEvent extends Equatable {
  const SavedEvent();
  @override
  List<Object?> get props => [];
}

class SavedLoadEvent extends SavedEvent {
  const SavedLoadEvent();
}

class SavedFilterEvent extends SavedEvent {
  final String filter;
  const SavedFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class SavedDeleteEvent extends SavedEvent {
  final String id;
  const SavedDeleteEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class SavedSaveImageEvent extends SavedEvent {
  final String id;
  const SavedSaveImageEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class SavedShareImageEvent extends SavedEvent {
  final String    id;
  final Uint8List bytes;
  const SavedShareImageEvent(this.id, this.bytes);
  @override
  List<Object?> get props => [id, bytes];
}