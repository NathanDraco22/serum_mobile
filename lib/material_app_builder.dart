import 'package:flutter/material.dart';

/// Builder global que controla el escalado de tipografía con clamp
/// para prevenir desbordamientos visuales en pantallas móviles de alta densidad.
Widget materialAppBuilder(BuildContext context, Widget? child) {
  final mediaQueryData = MediaQuery.of(context);
  final systemTextScalerFactor = mediaQueryData.textScaler;

  final Widget childWidget = child ?? const SizedBox.shrink();

  return MediaQuery(
    data: mediaQueryData.copyWith(
      textScaler: systemTextScalerFactor.clamp(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.2,
      ),
    ),
    child: childWidget,
  );
}
