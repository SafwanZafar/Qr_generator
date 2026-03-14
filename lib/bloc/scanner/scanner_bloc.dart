import 'package:flutter_bloc/flutter_bloc.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc() : super(const ScannerState()) {

    on<ScannerStarted>((event, emit) {
      emit(state.copyWith(status: ScannerStatus.scanning));
    });

    on<ScannerStopped>((event, emit) {
      emit(state.copyWith(status: ScannerStatus.idle));
    });

    on<ScannerCodeDetected>((event, emit) {
      emit(state.copyWith(
        status:      ScannerStatus.success,
        scannedCode: event.code,
      ));
    });

    on<ScannerTorchToggled>((event, emit) {
      emit(state.copyWith(torchOn: !state.torchOn));
    });

    on<ScannerReset>((event, emit) {
      emit(const ScannerState());
    });
  }
}