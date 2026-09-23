import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';
import '../providers/dip_density_provider.dart';
import '../../data/models/fuel_tank_model.dart';

class DensityEntryScreen extends StatefulWidget {
  const DensityEntryScreen({super.key});

  @override
  State<DensityEntryScreen> createState() => _DensityEntryScreenState();
}

class _DensityEntryScreenState extends State<DensityEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _densityController = TextEditingController();
  final _tempController = TextEditingController();
  final _densityResultController = TextEditingController();
  final _imagePicker = ImagePicker();

  FuelProduct? _selectedProduct;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _densityController.addListener(_onInputChanged);
    _tempController.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DipDensityProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _densityController.removeListener(_onInputChanged);
    _tempController.removeListener(_onInputChanged);
    _densityController.dispose();
    _tempController.dispose();
    _densityResultController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _calculateDensity();
    });
  }

  Future<void> _calculateDensity() async {
    final hydrometerText = _densityController.text;
    final tempText = _tempController.text;

    if (hydrometerText.isEmpty || tempText.isEmpty) {
      return;
    }

    final hydrometerVal = double.tryParse(hydrometerText);
    final tempVal = double.tryParse(tempText);

    if (hydrometerVal == null || tempVal == null) {
      return;
    }

    final provider = context.read<DipDensityProvider>();
    final result = await provider.calculateDensity(
      hydrometerReading: hydrometerVal,
      temperature: tempVal,
    );

    if (result != null && mounted) {
      setState(() {
        _densityResultController.text = result['density']?.toString() ?? '';
      });
    }
  }



  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProduct == null) {
      AppAlert.showWarning(
        context,
        message: "Please select a Product.",
      );
      return;
    }

    final provider = context.read<DipDensityProvider>();
    final success = await provider.submitDensity(
      tankCode: _selectedProduct!.fuelTypeCode,
      densityValue: double.parse(_densityController.text),
      temperature: double.parse(_tempController.text),
    );

    if (mounted) {
      if (success) {
        await AppAlert.showSuccess(
          context,
          message: "Density entry submitted successfully!",
        );
        if (mounted) context.go('/dashboard');
      } else {
        AppAlert.showError(
          context,
          message: provider.error ?? "Failed to submit density entry",
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
          "DENSITY ENTRY",
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
                              ? 'FETCHING PRODUCTS'
                              : 'SUBMITTING DENSITY ENTRY',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.isLoading
                              ? 'Fetching active products...'
                              : 'Recording your density data...',
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
        // Row 1: Product Selector
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Product",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<FuelProduct>(
          value: _selectedProduct,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(
            "Select Product",
            Icons.category,
          ),
          items: provider.products.map((FuelProduct product) {
            return DropdownMenuItem<FuelProduct>(
              value: product,
              child: Text(
                product.fuelTypeCode,
                style: const TextStyle(color: AppColors.textDark),
              ),
            );
          }).toList(),
          onChanged: (FuelProduct? val) {
            setState(() {
              _selectedProduct = val;
            });
          },
          validator: (value) => value == null ? "Please select a product" : null,
        ),
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Hydrometer reading (Kg/m³)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _densityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration(
            "Hydrometer reading (Kg/m³)",
            Icons.speed,
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
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Temperature (°C)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _tempController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration(
            "Temp value",
            Icons.thermostat,
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
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Density (Kg/m³)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _densityResultController,
          readOnly: true,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration(
            "Density (Kg/m³)",
            Icons.opacity,
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
          "SUBMIT DENSITY ENTRY",
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
