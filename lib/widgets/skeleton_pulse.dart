import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/widgets/loading_icon.dart';

class SkeletonPulse extends StatefulWidget {
  final double width;
  final double height;
  final bool showErrorIcon;

  const SkeletonPulse({
    super.key,
    required this.width,
    required this.height,
    this.showErrorIcon = false,
  });

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    if (!widget.showErrorIcon) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat(reverse: true);

      _opacity = Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
    } else {
      _opacity = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xffb4b4b4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child:
            widget.showErrorIcon
                ? Icon(Icons.image_not_supported, color: Colors.white70, size: 40)
                : LoadingIcon(size: 40, color: AppConstants.surfaceColor),
      ),
    );

    return widget.showErrorIcon ? content : FadeTransition(opacity: _opacity, child: content);
  }
}
