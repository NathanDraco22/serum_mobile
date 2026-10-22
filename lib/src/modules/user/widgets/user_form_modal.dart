import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/user/widgets/user_branch_selector.dart';
import 'package:serum_mobile/src/modules/user/widgets/user_role_dropdown.dart';

class UserFormModal extends StatefulWidget {
  final List<RoleInDb> roles;
  final List<BranchInDb> branches;
  final Future<bool> Function(CreateUser newUser) onSubmit;

  const UserFormModal({
    super.key,
    required this.roles,
    required this.branches,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required List<RoleInDb> roles,
    required List<BranchInDb> branches,
    required Future<bool> Function(CreateUser newUser) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserFormModal(
        roles: roles,
        branches: branches,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isActive = true;
  bool _isLoading = false;

  RoleInDb? _selectedRole;
  final Set<String> _selectedBranchIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.roles.isNotEmpty) {
      _selectedRole = widget.roles.first;
    }
    for (final b in widget.branches) {
      _selectedBranchIds.add(b.id);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final roleName = _selectedRole?.name ?? 'Operador';
    final accessLevel = _selectedRole?.accessLevel ?? 3;

    final newUser = CreateUser(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      role: roleName,
      accessLevel: accessLevel,
      branches: _selectedBranchIds.toList(),
      isActive: _isActive,
    );

    final success = await widget.onSubmit(newUser);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomInset + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ColorPalette.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Título y Cerrar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: ColorPalette.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Alta de Nuevo Colaborador',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 16),

          // Formulario con Scroll
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo *',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'Ej. Dra. Martha Ruiz',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Usuario *',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                              hintText: 'mruiz',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              if (value.trim().contains(' ')) {
                                return 'Sin espacios';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña *',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Mín. 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: 'mruiz@laboratorio.com',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: '5512345678',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Selector Modular de Rol
                    UserRoleDropdown(
                      roles: widget.roles,
                      selectedRole: _selectedRole,
                      onChanged: (role) => setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: 14),

                    // Selector Modular de Sucursales
                    UserBranchSelector(
                      branches: widget.branches,
                      selectedBranchIds: _selectedBranchIds,
                      onChanged: (updated) => setState(() {
                        _selectedBranchIds.clear();
                        _selectedBranchIds.addAll(updated);
                      }),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Usuario Activo para Operar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Permitir inicio de sesión inmediato',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Registrar Colaborador',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
