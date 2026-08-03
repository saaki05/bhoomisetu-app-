import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../screens/farm_tools_screen.dart';

class ProfitCalculator extends StatefulWidget {
  const ProfitCalculator({super.key});

  @override
  State<ProfitCalculator> createState() => _ProfitCalculatorState();
}

class _ProfitCalculatorState extends State<ProfitCalculator> {
  final _revenueController = TextEditingController();
  final _seedCostController = TextEditingController();
  final _fertilizerCostController = TextEditingController();
  final _labourCostController = TextEditingController();
  final _otherCostController = TextEditingController();
  ({double revenue, double costs, double profit, double marginPercent})? _result;

  @override
  void dispose() {
    _revenueController.dispose();
    _seedCostController.dispose();
    _fertilizerCostController.dispose();
    _labourCostController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _calculate() {
    final revenue = _parse(_revenueController);
    final costs = _parse(_seedCostController) +
        _parse(_fertilizerCostController) +
        _parse(_labourCostController) +
        _parse(_otherCostController);
    final profit = revenue - costs;
    final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

    setState(() => _result = (revenue: revenue, costs: costs, profit: profit, marginPercent: margin));
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FarmToolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Expected revenue', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _revenueController, label: 'Total sale value', unitHint: '₹'),
                const SizedBox(height: AppConstants.spaceLg),
                Text('Costs', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _seedCostController, label: 'Seeds', unitHint: '₹'),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _fertilizerCostController, label: 'Fertilizer & inputs', unitHint: '₹'),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _labourCostController, label: 'Labour', unitHint: '₹'),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _otherCostController, label: 'Other costs', unitHint: '₹'),
                const SizedBox(height: AppConstants.spaceLg),
                FarmToolCalculateButton(onPressed: _calculate),
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: AppConstants.spaceLg),
            FarmToolCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FarmToolResultRow(label: 'Revenue', value: '₹${result.revenue.toStringAsFixed(0)}'),
                  FarmToolResultRow(label: 'Total costs', value: '₹${result.costs.toStringAsFixed(0)}'),
                  const Divider(),
                  FarmToolResultRow(
                    label: 'Estimated profit',
                    value: '₹${result.profit.toStringAsFixed(0)}',
                    emphasize: true,
                  ),
                  FarmToolResultRow(label: 'Margin', value: '${result.marginPercent.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
