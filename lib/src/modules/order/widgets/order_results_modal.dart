import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/widgets/common/medical_flag_badge.dart';
import 'package:serum_mobile/src/widgets/common/status_badge.dart';

class OrderResultsModal extends StatelessWidget {
  const OrderResultsModal({
    super.key,
    required this.order,
  });

  final OrderInDb order;

  static void show(BuildContext context, OrderInDb order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderResultsModal(order: order),
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final folio = order.id.length >= 8
        ? 'FOL-${order.id.substring(0, 8).toUpperCase()}'
        : 'FOL-${order.id.toUpperCase()}';

    final patientName = order.patientInfo?.name.isNotEmpty == true
        ? order.patientInfo!.name
        : 'Paciente sin registrar';

    final doctorName = order.doctorInfo?.name.isNotEmpty == true
        ? order.doctorInfo!.name
        : 'Médico no especificado';

    return Container(
      height: size.height * 0.88,
      decoration: const BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: ColorPalette.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          folio,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ColorPalette.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: order.status),
                        if (order.isBlocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorPalette.warningContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Retenida',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(order.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.outline,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.outlineVariant),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de Datos Demográficos
                  Card(
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
                                      'Género: ${order.patientInfo?.gender == 'F' ? 'Femenino' : 'Masculino'} • Tel: ${order.patientInfo?.phone.isNotEmpty == true ? order.patientInfo!.phone : 'No registrado'}',
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
                                  'Médico: $doctorName (${order.doctorInfo?.specialty ?? 'General'})',
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
                  ),
                  const SizedBox(height: 18),

                  // Estudios Solicitados
                  Text(
                    'Estudios Solicitados (${order.items.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: order.items.map((item) {
                      return Chip(
                        label: Text(item.name),
                        backgroundColor: ColorPalette.surfaceContainerLow,
                        side: const BorderSide(color: ColorPalette.outlineVariant, width: 0.8),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Parámetros y Resultados Analíticos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados Analíticos (${order.results.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.results.isNotEmpty)
                        Text(
                          'Capturados por Laboratorio',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (order.results.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 40,
                            color: ColorPalette.outline.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Pendiente de Procesamiento Analítico',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Las muestras aún no cuentan con resultados capturados en el banco de análisis.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: ColorPalette.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.results.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: ColorPalette.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          final result = order.results[index];
                          final hasValue = result.resultValue?.isNotEmpty == true;

                          String rangeText = '';
                          if (result.referenceValues.isNotEmpty) {
                            final ref = result.referenceValues.first;
                            rangeText = '${ref.minValue} - ${ref.maxValue} ${result.unitOfMeasure}';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.parameterName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (rangeText.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Ref: $rangeText',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: ColorPalette.outline,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hasValue
                                          ? '${result.resultValue} ${result.unitOfMeasure}'
                                          : 'Pendiente',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: hasValue
                                            ? ColorPalette.onSurface
                                            : ColorPalette.outline,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    MedicalFlagBadge(flag: result.alertFlag, compact: true),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  if (order.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Observaciones / Notas Clínicas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
                      ),
                      child: Text(
                        order.notes!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
