import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTile extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerTile({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
