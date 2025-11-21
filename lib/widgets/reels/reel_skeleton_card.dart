import 'package:flutter/material.dart';
import 'package:la_nacion/widgets/skeleton_pulse.dart';

class ReelSkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;

  const ReelSkeletonCard({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? MediaQuery.of(context).size.width * 0.85;
    final height = this.height ?? MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black),
      clipBehavior: Clip.hardEdge,
      child: Stack(fit: StackFit.expand, children: [SkeletonPulse(width: width, height: height)]),
    );
  }
}
