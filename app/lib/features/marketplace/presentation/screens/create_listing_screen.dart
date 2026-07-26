import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/listing_draft.dart';
import '../providers/categories_provider.dart';
import '../providers/create_listing_controller.dart';
import '../providers/listing_search_controller.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: 'quintal');
  final _quantityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _categoryId;
  bool _isOrganic = false;
  bool _saveAsDraft = false;
  bool _isSubmitting = false;
  final List<File> _images = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= AppConstants.maxImagesPerListing) return;
    final picked = await _imagePicker.pickMultiImage(
      imageQuality: AppConstants.imageQuality,
      maxWidth: AppConstants.imageMaxDimension.toDouble(),
      maxHeight: AppConstants.imageMaxDimension.toDouble(),
    );
    if (picked.isEmpty) return;
    setState(() {
      final remaining = AppConstants.maxImagesPerListing - _images.length;
      _images.addAll(picked.take(remaining).map((x) => File(x.path)));
    });
  }

  Future<void> _submit({required bool asDraft}) async {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      if (_categoryId == null) context.showSnackBar('Please select a category', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _saveAsDraft = asDraft;
    });

    final draft = ListingDraft(
      categoryId: _categoryId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      pricePerUnit: double.parse(_priceController.text),
      unit: _unitController.text.trim().isEmpty ? 'quintal' : _unitController.text.trim(),
      quantityAvailable: double.parse(_quantityController.text),
      isOrganic: _isOrganic,
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
      state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      status: asDraft ? 'draft' : 'active',
    );

    final result = await ref.read(createListingControllerProvider.notifier).submit(draft: draft, images: _images);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (listing) {
        ref.invalidate(listingSearchControllerProvider);
        context.showSnackBar(asDraft ? 'Saved as draft' : 'Listing published successfully');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('List a crop')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Photos', style: context.textTheme.labelLarge),
                const SizedBox(height: AppConstants.spaceSm),
                _ImagePickerGrid(images: _images, onAdd: _pickImages, onRemove: (i) => setState(() => _images.removeAt(i))),
                const SizedBox(height: AppConstants.spaceLg),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (categories) => _CategoryDropdown(
                    categories: categories,
                    value: _categoryId,
                    onChanged: (id) => setState(() => _categoryId = id),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g. Fresh Alphonso Mangoes',
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _priceController,
                        label: 'Price per unit (₹)',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.positiveNumber(v, fieldName: 'Price'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: AppTextField(controller: _unitController, label: 'Unit'),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _quantityController,
                  label: 'Quantity available',
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Quantity'),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(child: AppTextField(controller: _districtController, label: 'District (optional)')),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(child: AppTextField(controller: _stateController, label: 'State (optional)')),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Organic certified'),
                  value: _isOrganic,
                  onChanged: (value) => setState(() => _isOrganic = value),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(
                  label: 'Publish listing',
                  isLoading: _isSubmitting && !_saveAsDraft,
                  onPressed: () => _submit(asDraft: false),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                AppButton(
                  label: 'Save as draft',
                  variant: AppButtonVariant.outlined,
                  isLoading: _isSubmitting && _saveAsDraft,
                  onPressed: () => _submit(asDraft: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.categories, required this.value, required this.onChanged});

  final List<CategoryEntity> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Category'),
      items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
      onChanged: onChanged,
    );
  }
}

class _ImagePickerGrid extends StatelessWidget {
  const _ImagePickerGrid({required this.images, required this.onAdd, required this.onRemove});

  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < images.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.spaceSm),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    child: Image.file(images[i], width: 90, height: 90, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (images.length < AppConstants.maxImagesPerListing)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: context.colors.outlineVariant),
                ),
                child: Icon(Icons.add_a_photo_outlined, color: context.colors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
