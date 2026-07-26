import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../authentication/domain/entities/user_role.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../../chat/presentation/providers/conversations_list_controller.dart';
import '../../../chat/presentation/screens/chat_thread_screen.dart';
import '../../../orders/presentation/screens/place_order_screen.dart';
import '../../domain/entities/crop_listing_entity.dart';
import '../providers/bookmarks_controller.dart';
import '../providers/listing_detail_provider.dart';
import '../widgets/report_listing_dialog.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final bookmarkedIds = ref.watch(bookmarksControllerProvider).valueOrNull?.map((b) => b.id).toSet() ?? {};
    final currentUser = ref.watch(authControllerProvider).valueOrNull;
    final loadedListing = listingAsync.valueOrNull;
    final canBuy = loadedListing != null &&
        currentUser != null &&
        currentUser.id != loadedListing.farmerId &&
        (currentUser.role == UserRole.buyer || currentUser.role == UserRole.admin) &&
        loadedListing.quantityAvailable > 0;

    return Scaffold(
      bottomNavigationBar: canBuy
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: AppButton(
                  label: 'Buy now',
                  icon: Icons.shopping_cart_checkout_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PlaceOrderScreen(listing: loadedListing)),
                  ),
                ),
              ),
            )
          : null,
      body: AsyncValueWidget<CropListingEntity>(
        value: listingAsync,
        onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        data: (listing) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(bookmarkedIds.contains(listing.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                  onPressed: () => ref.read(bookmarksControllerProvider.notifier).toggle(listing.id),
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => Share.share(
                    '${listing.title} — ₹${listing.pricePerUnit.toStringAsFixed(0)}/${listing.unit} on BhoomiSetu',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => showReportListingDialog(context, ref, listing.id),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: listing.images.isEmpty
                    ? Container(
                        color: context.colors.surfaceContainerHigh,
                        child: Icon(Icons.eco_outlined, size: 64, color: context.colors.onSurfaceVariant),
                      )
                    : PageView(
                        children: listing.images
                            .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                            .toList(),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (listing.isOrganic)
                          Chip(
                            label: const Text('Organic'),
                            backgroundColor: context.colors.tertiaryContainer,
                            labelStyle: TextStyle(color: context.colors.onTertiaryContainer),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      '₹${listing.pricePerUnit.toStringAsFixed(0)} / ${listing.unit}',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    _InfoGrid(listing: listing),
                    if (listing.description != null && listing.description!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spaceLg),
                      Text('Description', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(listing.description!, style: context.textTheme.bodyMedium),
                    ],
                    if (listing.farmer != null) ...[
                      const SizedBox(height: AppConstants.spaceXl),
                      Text('Sold by', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppConstants.spaceSm),
                      _FarmerCard(farmer: listing.farmer!, listingId: listing.id),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.listing});

  final CropListingEntity listing;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.scale_outlined, 'Available', '${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit}'),
      if (listing.harvestDate != null) (Icons.event_outlined, 'Harvest date', listing.harvestDate!),
      if (listing.district != null) (Icons.location_on_outlined, 'Location', listing.district!),
      if (listing.suggestedMarketPrice != null)
        (Icons.trending_up_rounded, 'Market avg', '₹${listing.suggestedMarketPrice!.toStringAsFixed(0)}'),
    ];

    return Wrap(
      spacing: AppConstants.spaceMd,
      runSpacing: AppConstants.spaceMd,
      children: items.map((item) {
        final (icon, label, value) = item;
        return SizedBox(
          width: 150,
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    Text(value, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FarmerCard extends ConsumerWidget {
  const _FarmerCard({required this.farmer, required this.listingId});

  final ListingFarmer farmer;
  final String listingId;

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final conversation = await ref
        .read(conversationsListControllerProvider.notifier)
        .startConversation(otherUserId: farmer.id, listingId: listingId);
    if (conversation == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatThreadScreen(conversation: conversation)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.secondaryContainer,
            backgroundImage: farmer.avatarUrl != null ? NetworkImage(farmer.avatarUrl!) : null,
            child: farmer.avatarUrl == null
                ? Text(farmer.fullName.initials, style: TextStyle(color: context.colors.onSecondaryContainer))
                : null,
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farmer.fullName, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (farmer.totalReviews > 0)
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text('${farmer.avgRating.toStringAsFixed(1)} (${farmer.totalReviews})',
                          style: context.textTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => _openChat(context, ref),
          ),
          if (farmer.phone != null) ...[
            const SizedBox(width: AppConstants.spaceSm),
            IconButton.filledTonal(
              icon: const Icon(Icons.call_rounded),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: farmer.phone)),
            ),
          ],
        ],
      ),
    );
  }
}
