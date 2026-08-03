import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/product_verification_registry.dart';
import '../screens/farm_tools_screen.dart';

class VerifyProduct extends StatefulWidget {
  const VerifyProduct({super.key});

  @override
  State<VerifyProduct> createState() => _VerifyProductState();
}

class _VerifyProductState extends State<VerifyProduct> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  final _codeController = TextEditingController();
  VerifiedProduct? _result;
  bool _checked = false;

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;
    _codeController.text = rawValue;
    _verify(rawValue);
  }

  void _verify(String code) {
    if (code.trim().isEmpty) return;
    setState(() {
      _result = lookupVerifiedProduct(code);
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Scan a product QR code', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) => _CameraUnavailable(error: error),
                  ),
                  IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          FarmToolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Or enter the code manually', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceMd),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Product code', hintText: 'e.g. BHS-0001'),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppButton(
                  label: 'Verify',
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: () => _verify(_codeController.text),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  'Demo codes: BHS-0001 to BHS-0006',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (_checked) ...[
            const SizedBox(height: AppConstants.spaceLg),
            _ResultCard(result: _result),
          ],
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 32),
          const SizedBox(height: AppConstants.spaceSm),
          const Text(
            'Camera unavailable — enter the code manually below',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final VerifiedProduct? result;

  @override
  Widget build(BuildContext context) {
    final product = result;
    final isGenuine = product != null;
    final color = isGenuine ? const Color(0xFF2E7D4F) : context.colors.error;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isGenuine ? Icons.verified_rounded : Icons.error_outline_rounded, color: color, size: 32),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGenuine ? 'Genuine product' : 'Not verified',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  product != null
                      ? '${product.name} · ${product.brand}\n${product.category}'
                      : "This code isn't registered. Buy only from verified sellers.",
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
