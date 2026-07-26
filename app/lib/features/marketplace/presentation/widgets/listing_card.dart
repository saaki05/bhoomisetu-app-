import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/crop_listing_entity.dart';
import '../providers/bookmarks_controller.dart';

class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing, required this.onTap, this.isBookmarked = false});

  final CropListingEntity listing;
  final VoidCallback onTap;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: listing.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: context.colors.surfaceContainerHigh,
                        highlightColor: context.colors.surfaceContainerLowest,
                        child: Container(color: context.colors.surfaceContainerHigh),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: context.colors.surfaceContainerHigh,
                        child: Icon(Icons.image_not_supported_outlined, color: context.colors.onSurfaceVariant),
                      ),
                    )
                  else
                    Container(
                      color: context.colors.surfaceContainerHigh,
                      child: Icon(Icons.eco_outlined, size: 40, color: context.colors.onSurfaceVariant),
                    ),
                  if (listing.isOrganic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(label: 'Organic', color: context.colors.tertiary),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                      onPressed: () => ref.read(bookmarksControllerProvider.notifier).toggle(listing.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (listing.district != null)
                    Text(
                      listing.district!,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit}',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                      if (listing.totalReviews > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                            Text(listing.avgRating.toStringAsFixed(1), style: context.textTheme.bodySmall),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(50)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
