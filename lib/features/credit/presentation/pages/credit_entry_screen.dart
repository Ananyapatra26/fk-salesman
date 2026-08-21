import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/models/credit_models.dart';
import '../../data/models/customer_credit_model.dart';
import '../providers/credit_provider.dart';

class CreditEntryScreen extends StatefulWidget {
  final CustomerCredit creditCard;

  const CreditEntryScreen({super.key, required this.creditCard});

  @override
  State<CreditEntryScreen> createState() => _CreditEntryScreenState();
}

class _CreditEntryScreenState extends State<CreditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _remarkController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedNozzleCode;
  File? _image1;
  File? _image2;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateQuantity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch fresh details from API
      context.read<CreditProvider>().fetchCreditDetail(widget.creditCard.code).then((_) {
        _updateQuantity();
      });

      // Pre-select first nozzle if available from DashboardProvider
      final nozzles = context.read<DashboardProvider>().mySelectedNozzles;
      if (nozzles.isNotEmpty) {
        setState(() {
          _selectedNozzleCode = nozzles.first.number;
        });
        _updateQuantity();
      }
    });
  }

  void _updateQuantity() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final dashboardProvider = context.read<DashboardProvider>();
    final allNozzles = [
      ...dashboardProvider.mySelectedNozzles,
      ...dashboardProvider.nozzles,
    ];

    final creditDetail = context.read<CreditProvider>().currentCreditDetail ?? widget.creditCard;
    final activeNozzleCode = (creditDetail.nozzleCode.isNotEmpty)
        ? creditDetail.nozzleCode
        : _selectedNozzleCode;

    double unitPrice = 0.0;
    if (activeNozzleCode != null && activeNozzleCode.isNotEmpty) {
      try {
        final nozzle = allNozzles.firstWhere((n) => n.number == activeNozzleCode);
        unitPrice = nozzle.unitPrice;
      } catch (_) {}
    }

    if (unitPrice > 0) {
      _unitPriceController.text = unitPrice.toStringAsFixed(2);
      if (amount > 0) {
        final qty = amount / unitPrice;
        _quantityController.text = qty.toStringAsFixed(2);
      } else {
        _quantityController.text = '';
      }
    } else {
      _unitPriceController.text = '';
      _quantityController.text = '';
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateQuantity);
    _amountController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  String _formatMobile(String mobile) {
    if (mobile.contains('x')) return mobile;
    if (mobile.length >= 12) {
      return mobile.substring(0, 3) + 'xxxxxx' + mobile.substring(mobile.length - 3);
    } else if (mobile.length >= 10) {
      return mobile.substring(0, 3) + 'xxxx' + mobile.substring(mobile.length - 3);
    }
    return mobile;
  }

  Future<void> _pickImage(int index, ImageSource source) async {
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
          if (index == 1) {
            _image1 = file;
          } else {
            _image2 = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image1 == null || _image2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture both photo attachments"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final creditProvider = context.read<CreditProvider>();
    final creditDetail = creditProvider.currentCreditDetail ?? widget.creditCard;
    final activeNozzleCode = (creditDetail.nozzleCode.isNotEmpty)
        ? creditDetail.nozzleCode
        : _selectedNozzleCode;

    if (activeNozzleCode == null || activeNozzleCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a nozzle"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final fuelTypeUnitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
      
      final success = await creditProvider.submitCredit(
        creditCode: widget.creditCard.code,
        nozzle: activeNozzleCode,
        amount: amount,
        quantity: quantity,
        fuelTypeUnitPrice: fuelTypeUnitPrice,
        image1: _image1,
        image2: _image2,
      );

      if (success && mounted) {
        // Refresh the listing page
        creditProvider.fetchApiCredits();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credit entry submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        final error = creditProvider.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? "Submission failed"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final creditProvider = context.watch<CreditProvider>();
    
    final availableNozzles = dashboardProvider.mySelectedNozzles.isNotEmpty
        ? dashboardProvider.mySelectedNozzles
        : dashboardProvider.nozzles;

    // Use detailed data if available, otherwise fallback to widget property
    final creditDetail = creditProvider.currentCreditDetail ?? widget.creditCard;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "CREDIT ENTRY",
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
            child: creditProvider.isLoading && creditProvider.currentCreditDetail == null
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerCard(creditDetail),
                          const SizedBox(height: 15),
                          _buildFormFields(availableNozzles, creditProvider.currentCreditDetail),
                          const SizedBox(height: 20),
                          _buildPhotoUploadSection(),
                          const SizedBox(height: 18),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
          ),
          if (_isSubmitting)
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
                          'SUBMITTING CREDIT',
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Saving your credit entry...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
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

  Widget _buildCustomerCard(CustomerCredit credit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: credit.customerPhoto != null
                  ? ClipOval(
                      child: Image.network(
                        credit.customerPhoto!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CREDIT CARD HOLDER",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  credit.customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white.withOpacity(0.6), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatMobile(credit.customerMobile),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(List<dynamic> nozzles, CustomerCredit? creditDetail) {
    // Check if the credit is already assigned a nozzle/fuel type from the API
    final assignedNozzle = creditDetail?.nozzleCode;
    final assignedFuelType = creditDetail?.fuelTypeCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show assigned info if available
        if (assignedNozzle != null && assignedNozzle.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ASSIGNED FUEL & NOZZLE",
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${assignedFuelType ?? 'Fuel'} - Nozzle $assignedNozzle",
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          // Dropdown to select nozzles if not assigned
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Select Nozzle",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedNozzleCode,
                hint: const Text(
                  "Choose a nozzle",
                  style: TextStyle(color: Colors.black26, fontSize: 14),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: nozzles.map<DropdownMenuItem<String>>((nozzle) {
                  return DropdownMenuItem<String>(
                    value: nozzle.number,
                    child: Row(
                      children: [
                        const Icon(Icons.local_gas_station, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "${nozzle.number} - ${nozzle.fuelTypeCode?.toUpperCase() ?? nozzle.fuelType?.toUpperCase() ?? 'FUEL'}",
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedNozzleCode = val);
                  _updateQuantity();
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Amount text field
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Credit Amount (₹)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration("Enter credit amount", Icons.currency_rupee),
          validator: (value) {
            if (value == null || value.isEmpty) return "Please enter amount";
            if (double.tryParse(value) == null) return "Enter a valid amount";
            return null;
          },
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            // Unit Price field (Read-only)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Unit Price (₹/L)",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _unitPriceController,
                    readOnly: true,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _inputDecoration("Unit price", Icons.sell).copyWith(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Quantity field (Read-only)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Quantity (Liters)",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _quantityController,
                    readOnly: true,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _inputDecoration("Quantity", Icons.local_gas_station).copyWith(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Remark textarea field (Internal use)
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Remark / Notes",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: _remarkController,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
          decoration: _inputDecoration("Enter internal remarks", Icons.edit_note),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Evidence / Invoice Photos (2 Required)",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildImageTile(1, _image1)),
            const SizedBox(width: 16),
            Expanded(child: _buildImageTile(2, _image2)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageTile(int number, File? image) {
    return GestureDetector(
      onTap: () {
        if (image != null) {
          _showImagePreviewDialog(number, image);
        } else {
          _pickImage(number, ImageSource.camera);
        }
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 1.0),
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Capture Image $number",
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image, fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          if (number == 1) {
                            _image1 = null;
                          } else {
                            _image2 = null;
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showImagePreviewDialog(int imageNumber, File image) {
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
                height: MediaQuery.of(context).size.height * 0.45,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(imageNumber, ImageSource.camera);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "Change",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: const Text(
          "SUBMIT CREDIT ENTRY",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12, width: 1.0),
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
