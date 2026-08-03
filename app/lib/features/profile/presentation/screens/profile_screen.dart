import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _village = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  bool _editing = false;
  bool _saving = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _bio, _village, _district, _state, _pincode]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _populate(ProfileEntity profile) {
    if (_editing || _name.text.isNotEmpty) return;
    _name.text = profile.fullName;
    _phone.text = profile.phone ?? '';
    _bio.text = profile.bio ?? '';
    _village.text = profile.village ?? '';
    _district.text = profile.district ?? '';
    _state.text = profile.state ?? '';
    _pincode.text = profile.pincode ?? '';
  }

  Future<void> _useCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) context.showSnackBar('Turn on Location Services to use your current location.', isError: true);
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) context.showSnackBar('Location permission is needed to save your farm area.', isError: true);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      context.showSnackBar('Current location ready to save.');
    } catch (_) {
      if (mounted) context.showSnackBar('Could not get your current location. Please try again.', isError: true);
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (!kIsWeb) {
      final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
      final status = await permission.request();
      if (!status.isGranted && !status.isLimited) {
        if (mounted) context.showSnackBar('Please allow media access to update your profile photo.', isError: true);
        return;
      }
    }
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 82, maxWidth: 1440);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final failure = await ref.read(profileControllerProvider.notifier).uploadAvatar(
          bytes: bytes,
          fileName: picked.name,
          mimeType: picked.mimeType ?? 'image/jpeg',
        );
    if (!mounted) return;
    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    } else {
      context.showSnackBar('Profile photo updated.');
    }
  }

  Future<void> _showPhotoSources() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take a photo'),
            onTap: () { Navigator.pop(context); _pickAvatar(ImageSource.camera); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () { Navigator.pop(context); _pickAvatar(ImageSource.gallery); },
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final failure = await ref.read(profileControllerProvider.notifier).save(ProfileUpdate(
          fullName: _name.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          village: _village.text.trim().isEmpty ? null : _village.text.trim(),
          district: _district.text.trim().isEmpty ? null : _district.text.trim(),
          state: _state.text.trim().isEmpty ? null : _state.text.trim(),
          pincode: _pincode.text.trim().isEmpty ? null : _pincode.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
        ));
    if (!mounted) return;
    setState(() { _saving = false; _editing = failure != null; });
    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    } else {
      context.showSnackBar('Profile saved.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          if (!_editing)
            IconButton(onPressed: () => setState(() => _editing = true), icon: const Icon(Icons.edit_outlined), tooltip: 'Edit profile'),
        ],
      ),
      body: AsyncValueWidget<ProfileEntity>(
        value: profile,
        onRetry: () => ref.invalidate(profileControllerProvider),
        data: (value) {
          _populate(value);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              children: [
                Center(
                  child: Semantics(
                    button: true,
                    label: 'Change profile photo',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: _showPhotoSources,
                      child: Stack(children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: context.colors.primaryContainer,
                          backgroundImage: value.avatarUrl == null ? null : CachedNetworkImageProvider(value.avatarUrl!),
                          child: value.avatarUrl == null
                              ? Text(value.fullName.initials, style: context.textTheme.headlineMedium?.copyWith(color: context.colors.onPrimaryContainer))
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: context.colors.primary,
                            child: Icon(Icons.camera_alt_rounded, size: 18, color: context.colors.onPrimary),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Center(child: Text(value.role.label, style: context.textTheme.labelLarge?.copyWith(color: context.colors.primary))),
                const SizedBox(height: AppConstants.spaceXl),
                _sectionTitle('Account details'),
                AppTextField(controller: _name, label: 'Full name', enabled: _editing, validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name' : null),
                const SizedBox(height: AppConstants.spaceSm),
                AppTextField(controller: _phone, label: 'Mobile number', enabled: _editing, keyboardType: TextInputType.phone),
                const SizedBox(height: AppConstants.spaceSm),
                AppTextField(controller: _bio, label: 'About you', enabled: _editing, maxLines: 3, maxLength: 500),
                const SizedBox(height: AppConstants.spaceLg),
                _sectionTitle('Farm & contact location'),
                AppTextField(controller: _village, label: 'Village', enabled: _editing),
                const SizedBox(height: AppConstants.spaceSm),
                AppTextField(controller: _district, label: 'District', enabled: _editing),
                const SizedBox(height: AppConstants.spaceSm),
                AppTextField(controller: _state, label: 'State', enabled: _editing),
                const SizedBox(height: AppConstants.spaceSm),
                AppTextField(controller: _pincode, label: 'PIN code', enabled: _editing, keyboardType: TextInputType.number),
                if (_editing) ...[
                  const SizedBox(height: AppConstants.spaceSm),
                  OutlinedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(_latitude == null ? 'Use my current location' : 'Location ready to save'),
                  ),
                ],
                const SizedBox(height: AppConstants.spaceXl),
                if (_editing) ...[
                  AppButton(label: 'Save profile', isLoading: _saving, onPressed: _save),
                  const SizedBox(height: AppConstants.spaceSm),
                  TextButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel')),
                ] else ...[
                  _verificationRow('Email', value.isEmailVerified),
                  _verificationRow('Phone', value.isPhoneVerified),
                  const SizedBox(height: AppConstants.spaceLg),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
        child: Text(text, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      );

  Widget _verificationRow(String label, bool verified) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(verified ? Icons.verified_rounded : Icons.info_outline_rounded, color: verified ? Colors.green : context.colors.outline),
        title: Text('$label ${verified ? 'verified' : 'not verified'}'),
      );
}
