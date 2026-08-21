import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import '../providers/dip_density_provider.dart';
import '../../data/models/fuel_tank_model.dart';

class DipEntryScreen extends StatefulWidget {
  const DipEntryScreen({super.key});

  @override
  State<DipEntryScreen> createState() => _DipEntryScreenState();
}

class _DipEntryScreenState extends State<DipEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dipController = TextEditingController();
  final _waterDipController = TextEditingController();
  final _fuelStockController = TextEditingController();
  final _dipVolumeController = TextEditingController();
  final _waterDipVolumeController = TextEditingController();
  final _imagePicker = ImagePicker();

  FuelTank? _selectedTank;
  File? _dipLevelPhoto;
  File? _waterLevelPhoto;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _dipController.addListener(_onInputChanged);
    _waterDipController.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DipDensityProvider>().fetchTanks();
    });
  }

  @override
  void dispose() {
    _dipController.removeListener(_onInputChanged);
    _waterDipController.removeListener(_onInputChanged);
    _dipController.dispose();
    _waterDipController.dispose();
    _fuelStockController.dispose();
    _dipVolumeController.dispose();
    _waterDipVolumeController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _calculateStockAndVolume();
    });
  }

  Future<void> _calculateStockAndVolume() async {
    final tank = _selectedTank;
    final dipText = _dipController.text;
    final waterDipText = _waterDipController.text;

    if (tank == null || dipText.isEmpty || waterDipText.isEmpty) {
      return;
    }

    final dipVal = double.tryParse(dipText);
    final waterDipVal = double.tryParse(waterDipText);

    if (dipVal == null || waterDipVal == null) {
      return;
    }

    final provider = context.read<DipDensityProvider>();
    final result = await provider.calculateFuelStock(
      tankCode: tank.code,
      dipValue: dipVal,
      waterDipValue: waterDipVal,
    );

    if (result != null && mounted) {
      setState(() {
        _fuelStockController.text = result['fuel_stock']?.toString() ?? '';
        _dipVolumeController.text = result['dip_volume']?.toString() ?? '';
        _waterDipVolumeController.text = result['water_dip_volume']?.toString() ?? '';
      });
    }
  }

  Future<void> _pickImage(ImageSource source, {required bool isDipPhoto}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Image size must be less than 1MB"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        setState(() {
          if (isDipPhoto) {
            _dipLevelPhoto = file;
          } else {
            _waterLevelPhoto = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Fuel Tank.")),
      );
      return;
    }

    if (_dipLevelPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload Dip level photo.")),
      );
      return;
    }

    if (_waterLevelPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload Water level photo.")),
      );
      return;
    }

    final provider = context.read<DipDensityProvider>();
    final success = await provider.submitDip(
      tankCode: _selectedTank!.code,
      dipValue: double.parse(_dipController.text),
      waterDipValue: double.parse(_waterDipController.text),
      dipLevelPhoto: _dipLevelPhoto!,
      waterLevelPhoto: _waterLevelPhoto!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("DIP entry submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? "Failed to submit DIP entry"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DipDensityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          "DIP ENTRY",
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.textDark,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEntryFields(provider),
                    const SizedBox(height: 32),
                    _buildImageUploadSection(),
                    const SizedBox(height: 48),
                    _buildSubmitButton(provider),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (provider.isLoading || provider.isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          provider.isLoading
                              ? 'FETCHING FUEL TANKS'
                              : 'SUBMITTING DIP ENTRY',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.isLoading
                              ? 'Fetching active fuel tanks...'
                              : 'Recording your DIP data...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildEntryFields(DipDensityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Fuel Tank Selector
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Fuel Tank",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<FuelTank>(
          value: _selectedTank,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(
            "Select Fuel Tank",
            Icons.propane_tank,
          ),
          items: provider.tanks.map((FuelTank tank) {
            return DropdownMenuItem<FuelTank>(
              value: tank,
              child: Text(
                tank.displayName,
                style: const TextStyle(color: AppColors.textDark),
              ),
            );
          }).toList(),
          onChanged: (FuelTank? val) {
            setState(() {
              _selectedTank = val;
            });
            _calculateStockAndVolume();
          },
          validator: (value) => value == null ? "Please select a tank" : null,
        ),
        const SizedBox(height: 24),

        // Row 2: Dip and Water Dip fields side-by-side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Dip level (mm)",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _dipController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _inputDecoration(
                      "Dip level (mm)",
                      Icons.straighten,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      if (double.tryParse(value) == null) {
                        return "Invalid number";
                      }
                      return null;
                    },
                  ),
                  if (provider.isCalculating)
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 8),
                      child: Text(
                        "Calculating volume...",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else if (_dipVolumeController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 8),
                      child: Text(
                        "Volume: ${_dipVolumeController.text} Ltr",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Water Dip level (mm)",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _waterDipController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _inputDecoration(
                      "Water Dip level (mm)",
                      Icons.water,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      if (double.tryParse(value) == null) {
                        return "Invalid number";
                      }
                      return null;
                    },
                  ),
                  if (provider.isCalculating)
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 8),
                      child: Text(
                        "Calculating volume...",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else if (_waterDipVolumeController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 8),
                      child: Text(
                        "Volume: ${_waterDipVolumeController.text} Ltr",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Fuel stock (Ltr)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _fuelStockController,
          readOnly: true,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration(
            "Fuel stock (Ltr)",
            Icons.local_gas_station,
            suffix: provider.isCalculating
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Dip Level Photo",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildImagePickerTile(_dipLevelPhoto, isDipPhoto: true),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Water Level Photo",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildImagePickerTile(_waterLevelPhoto, isDipPhoto: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerTile(File? image, {required bool isDipPhoto}) {
    return GestureDetector(
      onTap: () {
        if (image != null) {
          _showImagePreviewDialog(image, isDipPhoto: isDipPhoto);
        } else {
          _pickImage(ImageSource.camera, isDipPhoto: isDipPhoto);
        }
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey.shade300,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDipPhoto ? "Add Dip photo" : "Add Water photo",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          if (isDipPhoto) {
                            _dipLevelPhoto = null;
                          } else {
                            _waterLevelPhoto = null;
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showImagePreviewDialog(File image, {required bool isDipPhoto}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.file(
                image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, isDipPhoto: isDipPhoto);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "CHANGE",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "CONFIRM",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(DipDensityProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (provider.isSubmitting || provider.isCalculating) ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: const Text(
          "SUBMIT DIP ENTRY",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffix,
      hintStyle: const TextStyle(
        color: Colors.black26,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: AppColors.primary.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
