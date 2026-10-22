import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/widgets/dialogs/confirm_action_dialog.dart';

/// Pantalla informativa mostrada cuando la instancia vinculada del laboratorio
/// ha sido desactivada o suspendida en el servidor central.
class InactiveScreen extends StatelessWidget {
  const InactiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionCubit = context.watch<AppSessionCubit>();
    final servinName = sessionCubit.servin?.name ?? 'este laboratorio';

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ColorPalette.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          size: 48,
                          color: ColorPalette.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Instancia Desactivada',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'El acceso al servicio de "$servinName" ha sido suspendido o deshabilitado por el administrador central.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por favor contacta a soporte técnico para verificar el estado de la suscripción.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.outline,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AppSessionCubit>().initSession();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar Conexión'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorPalette.error,
                              side: const BorderSide(color: ColorPalette.error),
                            ),
                            onPressed: () async {
                              final confirmed = await ConfirmActionDialog.show(
                                context,
                                title: '¿Desvincular Dispositivo?',
                                message:
                                    'Esta acción borrará las credenciales y el alias del laboratorio en este dispositivo móvil. Deberás volver a activarlo para ingresar.',
                                confirmLabel: 'Desvincular',
                                isDestructive: true,
                                icon: Icons.phonelink_erase_rounded,
                              );

                              if (confirmed && context.mounted) {
                                await context.read<AppSessionCubit>().exitBusiness();
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Desvincular Dispositivo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
