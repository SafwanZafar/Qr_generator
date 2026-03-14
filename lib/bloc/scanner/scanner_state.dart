part of 'scanner_bloc.dart';

enum ScannerStatus { idle, scanning, success, error }

class ScannerState {
  final ScannerStatus status;
  final String        scannedCode;
  final bool          torchOn;
  final String?       errorMessage;

  const ScannerState({
    this.status       = ScannerStatus.idle,
    this.scannedCode  = '',
    this.torchOn      = false,
    this.errorMessage,
  });

  bool get hasResult => scannedCode.isNotEmpty && status == ScannerStatus.success;

  ScannerState copyWith({
    ScannerStatus? status,
    String?        scannedCode,
    bool?          torchOn,
    String?        errorMessage,
  }) =>
      ScannerState(
        status:       status       ?? this.status,
        scannedCode:  scannedCode  ?? this.scannedCode,
        torchOn:      torchOn      ?? this.torchOn,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}