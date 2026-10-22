import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

/// Tarjeta de cabecera con información del paciente y médico solicitante.
class OrderPatientHeaderCard extends StatelessWidget {
  final OrderInDb order;

  const OrderPatientHeaderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final patientName = order.patientInfo?.name.isNotEmpty == true
        ? order.patientInfo!.name
        : 'Paciente sin registrar';

    final doctorName = order.doctorInfo?.name.isNotEmpty == true
        ? order.doctorInfo!.name
        : 'Médico no especificado';

    final genderText =
        order.patientInfo?.gender == 'F' ? 'Femenino' : 'Masculino';
    final phoneText = order.patientInfo?.phone.isNotEmpty == true
        ? order.patientInfo!.phone
        : 'No registrado';
    final specialtyText = order.doctorInfo?.specialty ?? 'General';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorPalette.primary.withAlpha(20),
                  child: const Icon(
                    Icons.person_rounded,
                    color: ColorPalette.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Género: $genderText • Tel: $phoneText',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: ColorPalette.outlineVariant),
            Row(
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  size: 18,
                  color: ColorPalette.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Médico: $doctorName ($specialtyText)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
