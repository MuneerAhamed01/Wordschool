import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Shimmering placeholder block in the dark theme's surface colours.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 16,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MyColors.gameSurface,
      highlightColor: MyColors.gameSurfaceElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: MyColors.gameSurface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
