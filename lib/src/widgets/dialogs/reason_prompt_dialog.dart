import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class ReasonPromptDialog extends StatefulWidget {
  const ReasonPromptDialog({
    super.key,
    this.orderFolio,
  });

  final String? orderFolio;

  static Future<String?> show(BuildContext context, {String? orderFolio}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => ReasonPromptDialog(orderFolio: orderFolio),
    );
  }

  @override
  State<ReasonPromptDialog> createState() => _ReasonPromptDialogState();
}

class _ReasonPromptDialogState extends State<ReasonPromptDialog> {
  final _reasonController = TextEditingController();

  final List<String> _quickReasons = const [
    'Cortesía Médico Referente',
    'Convenio Institucional',
    'Ajuste Comercial Autorizado',
    'Descuento Familiar',
    'Autorización Telefónica',
  ];

  String? _selectedQuickReason;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onChipSelected(String reason) {
    setState(() {
      if (_selectedQuickReason == reason) {
        _selectedQuickReason = null;
        _reasonController.clear();
      } else {
        _selectedQuickReason = reason;
        _reasonController.text = reason;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: ColorPalette.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Autorizar Orden',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.orderFolio != null)
                  Text(
                    widget.orderFolio!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona un motivo frecuente o ingresa una nota para la auditoría (opcional):',
              style: TextStyle(fontSize: 13, color: ColorPalette.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReasons.map((reason) {
                final isSelected = _selectedQuickReason == reason;
                return ChoiceChip(
                  label: Text(reason),
                  selected: isSelected,
                  onSelected: (_) => _onChipSelected(reason),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : ColorPalette.onSurface,
                  ),
                  selectedColor: ColorPalette.primary,
                  backgroundColor: ColorPalette.surfaceContainerLow,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ingresa un motivo o justificación...',
                labelText: 'Motivo de autorización',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.success,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 44),
          ),
          onPressed: () {
            final reasonText = _reasonController.text.trim();
            final finalReason = reasonText.isNotEmpty
                ? reasonText
                : 'Autorización móvil por supervisor';
            Navigator.of(context).pop(finalReason);
          },
          child: const Text('Autorizar'),
        ),
      ],
    );
  }
}
