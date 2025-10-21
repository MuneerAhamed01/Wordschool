import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerGridItem extends StatelessWidget {
  final double height;
  final double width;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerGridItem({
    super.key,
    this.height = 100,
    this.width = 100,
    this.baseColor = Colors.black,
    this.highlightColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[600]!,
            width: 6,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
