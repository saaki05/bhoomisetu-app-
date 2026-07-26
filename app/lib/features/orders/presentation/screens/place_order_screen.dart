import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../marketplace/domain/entities/crop_listing_entity.dart';
import '../providers/create_order_controller.dart';
import '../providers/orders_list_controller.dart';
import 'order_detail_screen.dart';

class PlaceOrderScreen extends ConsumerStatefulWidget {
  const PlaceOrderScreen({super.key, required this.listing});

  final CropListingEntity listing;

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 0;
  double get _total => _quantity * widget.listing.pricePerUnit;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quantity > widget.listing.quantityAvailable) {
      context.showSnackBar('Only ${widget.listing.quantityAvailable.toStringAsFixed(0)} ${widget.listing.unit} available', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref.read(createOrderControllerProvider.notifier).submit(
          listingId: widget.listing.id,
          quantity: _quantity,
          deliveryAddress: _addressController.text.trim(),
          contactPhone: _phoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (order) {
        ref.invalidate(ordersListControllerProvider);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm order')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.listing.title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '₹${widget.listing.pricePerUnit.toStringAsFixed(0)}/${widget.listing.unit} · '
                  '${widget.listing.quantityAvailable.toStringAsFixed(0)} ${widget.listing.unit} available',
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppTextField(
                  controller: _quantityController,
                  label: 'Quantity (${widget.listing.unit})',
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Quantity'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _addressController,
                  label: 'Delivery address',
                  maxLines: 2,
                  validator: (v) => Validators.required(v, fieldName: 'Delivery address'),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _phoneController,
                  label: 'Contact number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.indianPhone,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(controller: _notesController, label: 'Notes (optional)', maxLines: 2),
                const SizedBox(height: AppConstants.spaceLg),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: context.textTheme.titleMedium),
                      Text(
                        '₹${_total.toStringAsFixed(0)}',
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(label: 'Place order', isLoading: _isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
