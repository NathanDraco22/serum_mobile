import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

/// Barra de búsqueda reutilizable con diseño Material 3 y botón para limpiar.
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onClear,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _effectiveController;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _showClear = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      _effectiveController = widget.controller ?? TextEditingController();
      _effectiveController.addListener(_handleTextChange);
      _showClear = _effectiveController.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _showClear && mounted) {
      setState(() => _showClear = hasText);
    }
  }

  void _clear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _effectiveController,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ColorPalette.primary,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: _clear,
                )
              : null,
          filled: true,
          fillColor: ColorPalette.surfaceContainerHighest.withAlpha(50),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: ColorPalette.outlineVariant,
              width: 0.8,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: ColorPalette.outlineVariant,
              width: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
