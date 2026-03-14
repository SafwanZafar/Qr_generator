import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/qr_config.dart';
import '../../models/qr_history.dart';
import '../../models/qr_type.dart';
import '../../services/history_service.dart';
import '../../services/qr_builder_service.dart';

part 'generator_event.dart';
part 'generator_state.dart';

class GeneratorBloc extends Bloc<GeneratorEvent, GeneratorState> {
  GeneratorBloc() : super(const GeneratorState()) {

    on<GeneratorTypeChanged>((event, emit) {
      emit(state.copyWith(
        type:   event.type,
        f1:     '',
        f2:     '',
        f3:     '',
        qrData: '',
        status: GeneratorStatus.initial,
      ));
    });

    on<GeneratorDataChanged>((event, emit) {
      emit(state.copyWith(
        f1: event.f1,
        f2: event.f2,
        f3: event.f3,
      ));
    });

    on<GeneratorConfigChanged>((event, emit) {
      emit(state.copyWith(config: event.config));
    });

    on<GeneratorSubmit>((event, emit) async {
      emit(state.copyWith(status: GeneratorStatus.loading));

      final err = QRBuilderService.validate(
        type: state.type,
        f1:   state.f1,
        f2:   state.f2,
      );

      if (err != null) {
        emit(state.copyWith(
          status:       GeneratorStatus.error,
          errorMessage: err,
        ));
        return;
      }

      final data = QRBuilderService.build(
        type: state.type,
        f1:   state.f1,
        f2:   state.f2,
        f3:   state.f3,
      );

      await HistoryService.save(QRHistory(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        type:      _typeLabel(state.type),
        data:      data,
        label:     _buildLabel(state.type, state.f1),
        createdAt: DateTime.now(),
      ));

      emit(state.copyWith(
        qrData: data,
        status: GeneratorStatus.success,
      ));
    });

    on<GeneratorReset>((event, emit) {
      emit(const GeneratorState());
    });
  }

  String _typeLabel(QRType type) {
    switch (type) {
      case QRType.website:  return 'Website';
      case QRType.whatsapp: return 'WhatsApp';
      case QRType.phone:    return 'Phone';
      case QRType.sms:      return 'SMS';
      case QRType.email:    return 'Email';
      case QRType.wifi:     return 'WiFi';
      case QRType.location: return 'Location';
      case QRType.contact:  return 'Contact';
      case QRType.text:     return 'Text';
    }
  }

  String _buildLabel(QRType type, String f1) {
    switch (type) {
      case QRType.website:
        final uri  = Uri.tryParse(f1);
        final host = uri?.host.replaceFirst('www.', '') ?? f1;
        return host.isNotEmpty ? host : 'My Website';
      case QRType.wifi:
        return f1.isNotEmpty ? f1 : 'WiFi Network';
      case QRType.contact:
        return f1.isNotEmpty ? f1 : 'My Contact';
      case QRType.whatsapp:
        return f1.isNotEmpty ? f1 : 'WhatsApp';
      case QRType.email:
        return f1.isNotEmpty ? f1 : 'My Email';
      case QRType.phone:
        return f1.isNotEmpty ? f1 : 'My Phone';
      case QRType.sms:
        return f1.isNotEmpty ? f1 : 'My SMS';
      case QRType.location:
        return 'My Location';
      case QRType.text:
        return f1.length > 20 ? '${f1.substring(0, 20)}...' : f1;
    }
  }
}