import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  final ServinRepository servinRepository;

  ActivationCubit(this.servinRepository) : super(ActivationInitial());

  Future<void> activate(
    String apiKey,
    String nickname, {
    String? originServerUrl,
  }) async {
    final cleanNickname = nickname.trim();
    final cleanApiKey = apiKey.trim();
    final cleanServerUrl = originServerUrl?.trim();

    if (cleanNickname.isEmpty) {
      emit(ActivationError('Por favor ingresa el alias del negocio o laboratorio.'));
      return;
    }
    if (cleanApiKey.isEmpty) {
      emit(ActivationError('Por favor ingresa la clave de activación provista.'));
      return;
    }

    emit(ActivationLoading());
    try {
      final servin = await servinRepository.getActiveServin(
        cleanApiKey,
        cleanNickname,
        originServerUrl: (cleanServerUrl != null && cleanServerUrl.isNotEmpty)
            ? cleanServerUrl
            : null,
      );
      emit(ActivationSuccess(servin));
    } catch (error) {
      emit(ActivationError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}
