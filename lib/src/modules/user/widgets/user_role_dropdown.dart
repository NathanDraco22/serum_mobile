import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';

/// Campo desplegable para selección de rol clínico o administrativo en el alta de usuario.
class UserRoleDropdown extends StatelessWidget {
  final List<RoleInDb> roles;
  final RoleInDb? selectedRole;
  final ValueChanged<RoleInDb?> onChanged;

  const UserRoleDropdown({
    super.key,
    required this.roles,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RoleInDb>(
      initialValue: selectedRole,
      decoration: const InputDecoration(
        labelText: 'Rol Clínico / Administrativo *',
        prefixIcon: Icon(Icons.security_rounded),
      ),
      items: roles.map((r) {
        return DropdownMenuItem<RoleInDb>(
          value: r,
          child: Text('${r.name} (Nivel ${r.accessLevel})'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null && roles.isNotEmpty) {
          return 'Selecciona un rol';
        }
        return null;
      },
    );
  }
}
