import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../../core/widgets/states/shimmer_box.dart';
import '../../../authentication/domain/entities/user_role.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../../home/presentation/widgets/home_section_header.dart';
import '../../data/agrishop_mock_data.dart';
import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/entities/listing_search_filters.dart';
import '../providers/bookmarks_controller.dart';
import '../providers/listing_search_controller.dart';
import '../widgets/agrishop_tile.dart';
import '../widgets/category_chips_row.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

enum _ViewMode { grid, list }

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: AppConstants.searchDebounce);
  final _scrollController = ScrollController();
  _ViewMode _viewMode = _ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(listingSearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(listingSearchControllerProvider);
    final bookmarkedIds = ref.watch(bookmarksControllerProvider).valueOrNull?.map((b) => b.id).toSet() ?? {};
    final currentRole = ref.watch(authControllerProvider).valueOrNull?.role;
    final canCreateListing = currentRole == UserRole.farmer || currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: Icon(_viewMode == _ViewMode.grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: 'Toggle view',
            onPressed: () => setState(() => _viewMode = _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid),
          ),
        ],
      ),
      floatingActionButton: canCreateListing
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateListingScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('List a crop'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: const HomeSectionHeader(title: 'Agrishops nearby'),
          ),
          SizedBox(
            height: 118,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              scrollDirection: Axis.horizontal,
              itemCount: nearbyAgrishops.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
              itemBuilder: (_, index) => AgrishopTile(shop: nearbyAgrishops[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              0,
            ),
            child: const HomeSectionHeader(title: 'Browse products nearby'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search crops, farmers, districts…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) => _debouncer.run(
                      () => ref.read(listingSearchControllerProvider.notifier).setQuery(value),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                IconButton.filledTonal(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => _openFilterSheet(context, searchState.valueOrNull),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: CategoryChipsRow(
              selectedCategoryId: searchState.valueOrNull?.filters.categoryId,
              onSelected: (categoryId) => ref.read(listingSearchControllerProvider.notifier).setCategory(categoryId),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Expanded(
            child: AsyncValueWidget<ListingSearchState>(
              value: searchState,
              loading: () => const ShimmerGridPlaceholder(),
              onRetry: () => ref.read(listingSearchControllerProvider.notifier).refresh(),
              isEmpty: (state) => state.items.isEmpty,
              emptyMessage: 'No listings match your search',
              emptyIcon: Icons.storefront_outlined,
              data: (state) => RefreshIndicator(
                onRefresh: () => ref.read(listingSearchControllerProvider.notifier).refresh(),
                child: _viewMode == _ViewMode.grid
                    ? _buildGrid(state, bookmarkedIds)
                    : _buildList(state, bookmarkedIds),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ListingSearchState state, Set<String> bookmarkedIds) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.spaceMd,
        crossAxisSpacing: AppConstants.spaceMd,
        childAspectRatio: 0.68,
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const ShimmerBox(height: double.infinity, width: double.infinity, borderRadius: AppConstants.radiusLg);
        }
        final listing = state.items[index];
        return ListingCard(
          listing: listing,
          isBookmarked: bookmarkedIds.contains(listing.id),
          onTap: () => _openDetail(listing),
        );
      },
    );
  }

  Widget _buildList(ListingSearchState state, Set<String> bookmarkedIds) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppConstants.spaceMd),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const ShimmerBox(height: 200, borderRadius: AppConstants.radiusLg, width: double.infinity);
        }
        final listing = state.items[index];
        return SizedBox(
          height: 220,
          child: ListingCard(
            listing: listing,
            isBookmarked: bookmarkedIds.contains(listing.id),
            onTap: () => _openDetail(listing),
          ),
        );
      },
    );
  }

  void _openDetail(CropListingEntity listing) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: listing.id)));
  }

  Future<void> _openFilterSheet(BuildContext context, ListingSearchState? current) async {
    final result = await showFilterBottomSheet(
      context,
      currentSort: current?.filters.sortBy ?? ListingSortOption.newest,
      currentOrganicOnly: current?.filters.organicOnly ?? false,
      currentMinPrice: current?.filters.minPrice,
      currentMaxPrice: current?.filters.maxPrice,
    );
    if (result == null || !mounted) return;

    final notifier = ref.read(listingSearchControllerProvider.notifier);
    await notifier.setSort(result.sortBy);
    await notifier.setOrganicOnly(result.organicOnly);
    await notifier.setPriceRange(minPrice: result.minPrice, maxPrice: result.maxPrice);
  }
}
