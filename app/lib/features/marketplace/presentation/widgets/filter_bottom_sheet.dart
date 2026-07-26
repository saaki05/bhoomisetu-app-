import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/listing_search_filters.dart';

class FilterResult {
  const FilterResult({required this.sortBy, required this.organicOnly, this.minPrice, this.maxPrice});

  final ListingSortOption sortBy;
  final bool organicOnly;
  final double? minPrice;
  final double? maxPrice;
}

Future<FilterResult?> showFilterBottomSheet(
  BuildContext context, {
  required ListingSortOption currentSort,
  required bool currentOrganicOnly,
  double? currentMinPrice,
  double? currentMaxPrice,
}) {
  return showModalBottomSheet<FilterResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FilterSheet(
      currentSort: currentSort,
      currentOrganicOnly: currentOrganicOnly,
      currentMinPrice: currentMinPrice,
      currentMaxPrice: currentMaxPrice,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.currentSort,
    required this.currentOrganicOnly,
    this.currentMinPrice,
    this.currentMaxPrice,
  });

  final ListingSortOption currentSort;
  final bool currentOrganicOnly;
  final double? currentMinPrice;
  final double? currentMaxPrice;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ListingSortOption _sortBy = widget.currentSort;
  late bool _organicOnly = widget.currentOrganicOnly;
  late final _minController = TextEditingController(text: widget.currentMinPrice?.toStringAsFixed(0) ?? '');
  late final _maxController = TextEditingController(text: widget.currentMaxPrice?.toStringAsFixed(0) ?? '');

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.spaceLg,
          right: AppConstants.spaceLg,
          top: AppConstants.spaceLg,
          bottom: AppConstants.spaceLg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter & sort', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceLg),
            Text('Sort by', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: 8,
              children: ListingSortOption.values.map((option) {
                return ChoiceChip(
                  label: Text(option.label),
                  selected: _sortBy == option,
                  onSelected: (_) => setState(() => _sortBy = option),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Organic only'),
              value: _organicOnly,
              onChanged: (value) => setState(() => _organicOnly = value),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text('Price range (per unit)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min ₹'),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max ₹'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceLg),
            AppButton(
              label: 'Apply filters',
              onPressed: () => Navigator.of(context).pop(FilterResult(
                sortBy: _sortBy,
                organicOnly: _organicOnly,
                minPrice: double.tryParse(_minController.text),
                maxPrice: double.tryParse(_maxController.text),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
