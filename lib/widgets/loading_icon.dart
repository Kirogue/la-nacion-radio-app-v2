import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingIcon extends StatefulWidget {
  final double size;
  final EdgeInsetsGeometry? padding;
  final Color color;

  const LoadingIcon({super.key, this.size = 60, this.padding, this.color = Colors.white});

  @override
  State<LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RotationTransition(
          turns: _rotationController,
          child: SvgPicture.asset(
            'assets/icons/loading.svg',
            colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
