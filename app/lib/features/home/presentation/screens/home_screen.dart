import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../../core/widgets/states/empty_view.dart';
import '../../../../core/widgets/states/shimmer_box.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../providers/home_controller.dart';
import '../widgets/home_section_header.dart';
import '../widgets/market_price_card.dart';
import '../widgets/nearby_buyer_tile.dart';
import '../widgets/scheme_detail_sheet.dart';
import '../widgets/scheme_preview_tile.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BhoomiSetu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: AsyncValueWidget<HomeSummaryEntity>(
              value: summary,
              loading: () => const _HomeLoadingSkeleton(),
              onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
              data: (data) => RefreshIndicator(
                onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  children: [
                    Text(
                      'Namaste, ${data.greeting.fullName.split(' ').first}',
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      data.greeting.role.label,
                      style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    WeatherCard(weather: data.weather),
                    const SizedBox(height: AppConstants.spaceXl),
                    HomeSectionHeader(title: "Today's market prices"),
                    const SizedBox(height: AppConstants.spaceSm),
                    _MarketPricesRow(prices: data.marketPrices),
                    const SizedBox(height: AppConstants.spaceXl),
                    if (data.greeting.role.apiValue == 'farmer') ...[
                      HomeSectionHeader(title: 'Nearby buyers'),
                      const SizedBox(height: AppConstants.spaceSm),
                      _NearbyBuyersRow(buyers: data.nearbyBuyers),
                      const SizedBox(height: AppConstants.spaceXl),
                    ],
                    HomeSectionHeader(title: 'Government schemes'),
                    const SizedBox(height: AppConstants.spaceSm),
                    _SchemesList(schemes: data.governmentSchemes),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketPricesRow extends StatelessWidget {
  const _MarketPricesRow({required this.prices});

  final List<MarketPrice> prices;

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return const EmptyView(message: 'No market prices available yet', icon: Icons.storefront_outlined);
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prices.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
        itemBuilder: (_, index) => MarketPriceCard(price: prices[index]),
      ),
    );
  }
}

class _NearbyBuyersRow extends StatelessWidget {
  const _NearbyBuyersRow({required this.buyers});

  final List<NearbyBuyer> buyers;

  @override
  Widget build(BuildContext context) {
    if (buyers.isEmpty) {
      return const EmptyView(message: 'No nearby buyers found yet', icon: Icons.storefront_outlined);
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: buyers.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
        itemBuilder: (_, index) => NearbyBuyerTile(buyer: buyers[index]),
      ),
    );
  }
}

class _SchemesList extends StatelessWidget {
  const _SchemesList({required this.schemes});

  final List<GovernmentSchemePreview> schemes;

  @override
  Widget build(BuildContext context) {
    if (schemes.isEmpty) {
      return const EmptyView(message: 'No active schemes right now', icon: Icons.account_balance_outlined);
    }
    return Column(
      children: schemes
          .map((scheme) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: SchemePreviewTile(scheme: scheme, onTap: () => showSchemeDetailSheet(context, scheme)),
              ))
          .toList(),
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: [
        const ShimmerBox(width: 180, height: 24),
        const SizedBox(height: AppConstants.spaceLg),
        const ShimmerBox(height: 110, borderRadius: AppConstants.radiusLg),
        const SizedBox(height: AppConstants.spaceXl),
        const ShimmerBox(width: 160, height: 20),
        const SizedBox(height: AppConstants.spaceSm),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
            itemBuilder: (_, _) => const ShimmerBox(width: 160, height: 150, borderRadius: AppConstants.radiusMd),
          ),
        ),
      ],
    );
  }
}
