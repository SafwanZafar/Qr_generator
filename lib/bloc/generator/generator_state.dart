part of 'generator_bloc.dart';

enum GeneratorStatus { initial, loading, success, error }

class GeneratorState {
  final QRType          type;
  final String          f1;
  final String          f2;
  final String          f3;
  final String          qrData;
  final QRConfig        config;
  final GeneratorStatus status;
  final String?         errorMessage;

  const GeneratorState({
    this.type         = QRType.website,
    this.f1           = '',
    this.f2           = '',
    this.f3           = '',
    this.qrData       = '',
    this.config       = const QRConfig(),
    this.status       = GeneratorStatus.initial,
    this.errorMessage,
  });

  bool get hasResult => qrData.isNotEmpty && status == GeneratorStatus.success;

  GeneratorState copyWith({
    QRType?          type,
    String?          f1,
    String?          f2,
    String?          f3,
    String?          qrData,
    QRConfig?        config,
    GeneratorStatus? status,
    String?          errorMessage,
  }) =>
      GeneratorState(
        type:         type         ?? this.type,
        f1:           f1           ?? this.f1,
        f2:           f2           ?? this.f2,
        f3:           f3           ?? this.f3,
        qrData:       qrData       ?? this.qrData,
        config:       config       ?? this.config,
        status:       status       ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}