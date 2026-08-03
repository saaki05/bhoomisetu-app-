import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/cultivation_tips.dart';
import '../widgets/disease_alerts.dart';
import '../widgets/fertilizer_calculator.dart';
import '../widgets/profit_calculator.dart';
import '../widgets/verify_product.dart';

/// Two self-contained, offline calculators farmers can reach from Home's
/// quick actions — no backend involved, everything computes locally.
class FarmToolsScreen extends StatefulWidget {
  const FarmToolsScreen({super.key});

  @override
  State<FarmToolsScreen> createState() => _FarmToolsScreenState();
}

class _FarmToolsScreenState extends State<FarmToolsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm tools'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Fertilizer', icon: Icon(Icons.science_outlined)),
            Tab(text: 'Profit', icon: Icon(Icons.trending_up_rounded)),
            Tab(text: 'Cultivation', icon: Icon(Icons.timeline_rounded)),
            Tab(text: 'Disease alerts', icon: Icon(Icons.warning_amber_rounded)),
            Tab(text: 'Verify', icon: Icon(Icons.qr_code_scanner_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FertilizerCalculator(),
          ProfitCalculator(),
          CultivationTips(),
          DiseaseAlerts(),
          VerifyProduct(),
        ],
      ),
    );
  }
}

/// Shared card shell so both calculators look like one consistent tool
/// rather than two unrelated forms bolted together.
class FarmToolCard extends StatelessWidget {
  const FarmToolCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class FarmToolResultRow extends StatelessWidget {
  const FarmToolResultRow({super.key, required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
          Text(
            value,
            style: emphasize
                ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: context.colors.primary)
                : context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Reusable "quantity" field with a submit button, shared layout for both
/// calculators' plot-size / revenue-style numeric inputs.
class FarmToolNumberField extends StatelessWidget {
  const FarmToolNumberField({super.key, required this.controller, required this.label, this.unitHint});

  final TextEditingController controller;
  final String label;
  final String? unitHint;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: unitHint,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

class FarmToolCalculateButton extends StatelessWidget {
  const FarmToolCalculateButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(label: 'Calculate', icon: Icons.calculate_outlined, onPressed: onPressed);
  }
}
