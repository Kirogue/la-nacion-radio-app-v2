import 'package:flutter/material.dart';
import '../../config/constants.dart';

class ConnectionErrorDialog extends StatefulWidget {
  final VoidCallback onRetry;

  const ConnectionErrorDialog({super.key, required this.onRetry});

  @override
  State<ConnectionErrorDialog> createState() => _ConnectionErrorDialogState();
}

class _ConnectionErrorDialogState extends State<ConnectionErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Color normal -> color saturado (más brillante)
    _colorAnimation = ColorTween(
      begin: AppConstants.errorColor,
      end: AppConstants.errorColor.withRed(255).withGreen(50).withBlue(50),
      // O cualquier color más brillante/saturado que quieras
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 0, offset: Offset(0, 12)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) {
                    return Icon(Icons.wifi_off, color: _colorAnimation.value, size: 64);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verifica tu conexión a Internet o intenta más tarde.',
                  style: TextStyle(fontSize: 16, color: AppConstants.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onRetry();
                    },
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.errorColor,
                      foregroundColor: AppConstants.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
