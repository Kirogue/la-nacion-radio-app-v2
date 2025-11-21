import 'package:flutter/material.dart';

class ContentWrapper extends StatelessWidget {
  final Widget child;
  const ContentWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    // Padding para que el contenido no quede detrás del AppBar ni del navbar flotante
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: kToolbarHeight + top + 10, // Espacio para AppBar transparente + status bar
        bottom: 80.0 + bottom // Espacio para el navbar flotante + padding del sistema
      ),
      child: child
    );
  }
}
