import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer skeleton block. Compose several of these (via
/// [ShimmerListPlaceholder]/[ShimmerGridPlaceholder] or feature-specific
/// layouts) to build a loading state that mirrors the eventual content shape.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHigh,
      highlightColor: colors.surfaceContainerLowest,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A vertical list of skeleton "cards" — used for feeds like orders,
/// notifications, or scheme lists while data is loading.
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({super.key, this.itemCount = 6, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => ShimmerBox(height: itemHeight, borderRadius: 16, width: double.infinity),
    );
  }
}

/// A grid of skeleton cards — used for the marketplace grid view while
/// crop listings are loading.
class ShimmerGridPlaceholder extends StatelessWidget {
  const ShimmerGridPlaceholder({super.key, this.itemCount = 6, this.crossAxisCount = 2});

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, _) => ShimmerBox(height: double.infinity, borderRadius: 16, width: double.infinity),
    );
  }
}
