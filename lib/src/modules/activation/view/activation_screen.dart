import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import '../cubit/activation_cubit.dart';

/// Pantalla móvil para la activación y enlace del dispositivo a una instancia de Serum LIS.
class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servinRepo = context.read<ServinRepository>();
    return BlocProvider(
      create: (context) => ActivationCubit(servinRepo),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivationCubit, ActivationState>(
      listener: (context, state) async {
        if (state is ActivationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorPalette.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state is ActivationSuccess) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(
                Icons.check_circle_rounded,
                color: ColorPalette.success,
                size: 52,
              ),
              title: const Text(
                'Dispositivo Vinculado',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Este dispositivo ha sido vinculado exitosamente a:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColorPalette.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPalette.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ColorPalette.primary.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      state.servin.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primary,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Continuar al Login'),
                ),
              ],
            ),
          );

          if (!context.mounted) return;
          context.read<AppSessionCubit>().initServinUnauthenticated(state.servin);
        }
      },
      child: const Scaffold(
        backgroundColor: ColorPalette.surface,
        body: _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _serverUrlController = TextEditingController();
  bool _obscureApiKey = true;
  bool _showAdvancedServer = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _apiKeyController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final serverUrl = _serverUrlController.text.trim();
    context.read<ActivationCubit>().activate(
          _apiKeyController.text,
          _nicknameController.text,
          originServerUrl: serverUrl.isNotEmpty ? serverUrl : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: ColorPalette.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phonelink_setup_rounded,
                      size: 40,
                      color: ColorPalette.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Activar Dispositivo',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColorPalette.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa las credenciales de tu laboratorio para enlazar esta aplicación móvil.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorPalette.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Card con Formulario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Datos de Enlace',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Solicita tu código al administrador del sistema',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorPalette.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Alias de Negocio
                          TextFormField(
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              labelText: 'Alias del Negocio',
                              hintText: 'ej. laboratorio-central',
                              prefixIcon: Icon(Icons.domain_rounded),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el alias del negocio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo API Key / Clave de Activación
                          TextFormField(
                            controller: _apiKeyController,
                            obscureText: _obscureApiKey,
                            decoration: InputDecoration(
                              labelText: 'Clave de Activación (API Key)',
                              hintText: 'Clave proporcionada',
                              prefixIcon: const Icon(Icons.key_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureApiKey
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureApiKey = !_obscureApiKey;
                                  });
                                },
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa la clave de activación';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Toggle de opciones avanzadas de servidor
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAdvancedServer = !_showAdvancedServer;
                                });
                              },
                              icon: Icon(
                                _showAdvancedServer
                                    ? Icons.keyboard_arrow_up
                                    : Icons.tune_rounded,
                                size: 16,
                              ),
                              label: Text(
                                _showAdvancedServer
                                    ? 'Ocultar ajustes'
                                    : 'Ajustes de servidor (opcional)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          if (_showAdvancedServer) ...[
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _serverUrlController,
                              decoration: const InputDecoration(
                                labelText: 'URL del Servidor',
                                hintText: 'ej. http://192.168.1.100:8000',
                                prefixIcon: Icon(Icons.dns_rounded),
                                helperText:
                                    'Opcional. Por defecto usa la URL del entorno',
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Botón Activar
                          BlocBuilder<ActivationCubit, ActivationState>(
                            builder: (context, state) {
                              final isLoading = state is ActivationLoading;
                              return ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.link_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text('Vincular y Activar'),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      size: 16,
                      color: ColorPalette.outline,
                    ),
                    Text(
                      'Licenciamiento institucional Serum LIS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
