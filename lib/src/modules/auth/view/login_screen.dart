import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/widgets/dialogs/confirm_action_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AppSessionCubit>().login(
            _identifierController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final servin = context.watch<AppSessionCubit>().servin;

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (servin != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Desvincular o cambiar de laboratorio',
                icon: const Icon(
                  Icons.phonelink_erase_rounded,
                  color: ColorPalette.outline,
                ),
                onPressed: () async {
                  final confirmed = await ConfirmActionDialog.show(
                    context,
                    title: '¿Desvincular Dispositivo?',
                    message:
                        '¿Deseas desvincular este dispositivo de "${servin.name}"? Requerirá un nuevo código de activación para ingresar.',
                    confirmLabel: 'Desvincular',
                    isDestructive: true,
                    icon: Icons.phonelink_erase_rounded,
                  );

                  if (confirmed && context.mounted) {
                    await context.read<AppSessionCubit>().exitBusiness();
                  }
                },
              ),
            ),
        ],
      ),
      body: BlocConsumer<AppSessionCubit, AppSessionState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            final isPermissionsError =
                state.status == AppSessionStatus.insufficientPermissions;

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                icon: Icon(
                  isPermissionsError
                      ? Icons.admin_panel_settings_rounded
                      : Icons.error_outline_rounded,
                  color: isPermissionsError
                      ? ColorPalette.warning
                      : ColorPalette.error,
                  size: 40,
                ),
                title: Text(
                  isPermissionsError
                      ? 'Nivel de Acceso Insuficiente'
                      : 'Error de Autenticación',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AppSessionStatus.loading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Header
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: ColorPalette.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            size: 44,
                            color: ColorPalette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Serum Mobile',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (state.servin != null) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColorPalette.primary.withAlpha(45),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.domain_rounded,
                                  size: 15,
                                  color: ColorPalette.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    state.servin!.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'Supervisión y Control Médico Ejecutivo',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Card de Formulario
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Ingreso de Supervisor',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Acceso restringido para nivel > 3',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ColorPalette.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Usuario o Correo
                                TextFormField(
                                  controller: _identifierController,
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Usuario o correo electrónico',
                                    prefixIcon: Icon(Icons.person_outline_rounded),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingresa tu usuario';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Contraseña
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 28),

                                // Botón Iniciar Sesión
                                ElevatedButton(
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
                                      : const Text('Iniciar Sesión'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: ColorPalette.outline,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Conexión segura con Serum LIS Core',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: ColorPalette.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
