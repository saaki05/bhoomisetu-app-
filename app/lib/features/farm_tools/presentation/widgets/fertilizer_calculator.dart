import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../screens/farm_tools_screen.dart';

/// Representative N-P-K doses in kg/acre per crop group. These are general
/// agronomy reference figures (the kind published by state agriculture
/// extension services), not a soil-tested prescription — the UI says so.
const Map<String, (double n, double p, double k)> _npkPerAcre = {
  'Cereals': (50, 25, 25),
  'Vegetables': (60, 40, 40),
  'Fruits': (40, 20, 20),
  'Pulses': (20, 40, 20),
  'Oilseeds': (40, 20, 20),
  'Spices': (30, 30, 30),
  'Cash crops': (80, 40, 40),
  'Flowers': (50, 50, 50),
  'Other': (40, 20, 20),
};

class FertilizerCalculator extends StatefulWidget {
  const FertilizerCalculator({super.key});

  @override
  State<FertilizerCalculator> createState() => _FertilizerCalculatorState();
}

class _FertilizerCalculatorState extends State<FertilizerCalculator> {
  String _crop = 'Cereals';
  final _acresController = TextEditingController(text: '1');
  ({double urea, double dap, double mop})? _result;

  @override
  void dispose() {
    _acresController.dispose();
    super.dispose();
  }

  void _calculate() {
    final acres = double.tryParse(_acresController.text.trim());
    if (acres == null || acres <= 0) {
      setState(() => _result = null);
      return;
    }

    final (n, p, k) = _npkPerAcre[_crop]!;
    final nRequired = n * acres;
    final pRequired = p * acres;
    final kRequired = k * acres;

    // Standard fertilizer-grade conversions: DAP is 18% N / 46% P2O5, MOP is
    // 60% K2O, Urea is 46% N. DAP is applied first for phosphorus (and
    // credited for the nitrogen it happens to supply), then Urea tops up
    // whatever nitrogen is still needed.
    final dapKg = pRequired / 0.46;
    final nFromDap = dapKg * 0.18;
    final ureaKg = ((nRequired - nFromDap).clamp(0, double.infinity)) / 0.46;
    final mopKg = kRequired / 0.60;

    setState(() => _result = (urea: ureaKg, dap: dapKg, mop: mopKg));
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
                Text('Your plot', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: _crop,
                  decoration: const InputDecoration(labelText: 'Crop type'),
                  items: _npkPerAcre.keys
                      .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                      .toList(),
                  onChanged: (value) => setState(() => _crop = value ?? _crop),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                FarmToolNumberField(controller: _acresController, label: 'Plot size', unitHint: 'acres'),
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
                  Text('Recommended fertilizer', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppConstants.spaceSm),
                  FarmToolResultRow(label: 'Urea', value: _formatBags(result.urea)),
                  FarmToolResultRow(label: 'DAP', value: _formatBags(result.dap)),
                  FarmToolResultRow(label: 'MOP', value: _formatBags(result.mop)),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'General reference doses, not a soil-tested prescription. For '
              'best results, pair with a local soil test.',
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  String _formatBags(double kg) {
    final bags = kg / 50;
    return '${kg.toStringAsFixed(1)} kg (~${bags.toStringAsFixed(1)} bags)';
  }
}
