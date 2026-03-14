part of 'generator_bloc.dart';

abstract class GeneratorEvent {
  const GeneratorEvent();
}

class GeneratorTypeChanged extends GeneratorEvent {
  final QRType type;
  const GeneratorTypeChanged(this.type);
}

class GeneratorDataChanged extends GeneratorEvent {
  final String f1;
  final String f2;
  final String f3;
  const GeneratorDataChanged({
    this.f1 = '',
    this.f2 = '',
    this.f3 = '',
  });
}

class GeneratorSubmit extends GeneratorEvent {
  const GeneratorSubmit();
}

class GeneratorReset extends GeneratorEvent {
  const GeneratorReset();
}

class GeneratorConfigChanged extends GeneratorEvent {
  final QRConfig config;
  const GeneratorConfigChanged(this.config);
}