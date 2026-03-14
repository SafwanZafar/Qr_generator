part of 'scanner_bloc.dart';

abstract class ScannerEvent {
  const ScannerEvent();
}

class ScannerStarted extends ScannerEvent {
  const ScannerStarted();
}

class ScannerStopped extends ScannerEvent {
  const ScannerStopped();
}

class ScannerCodeDetected extends ScannerEvent {
  final String code;
  const ScannerCodeDetected(this.code);
}

class ScannerReset extends ScannerEvent {
  const ScannerReset();
}

class ScannerTorchToggled extends ScannerEvent {
  const ScannerTorchToggled();
}