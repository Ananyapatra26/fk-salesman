import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import '../providers/dashboard_provider.dart';

class CheckoutFormPage extends StatefulWidget {
  const CheckoutFormPage({super.key});

  @override
  State<CheckoutFormPage> createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  static const Color _indigo = Color(0xFF3949AB);
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _startingReadings = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DashboardProvider>();
    for (var nozzle in provider.mySelectedNozzles) {
      _controllers[nozzle.id] = TextEditingController(
        text: nozzle.expectedClosingReadingNo != null
            ? nozzle.expectedClosingReadingNo!.toStringAsFixed(2)
            : "",
      );
      _startingReadings[nozzle.id] = nozzle.lastReadingNo ?? 0.0;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: _indigo),
                SizedBox(width: 10),
                Text(
                  "Confirm Checkout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to proceed ? This will finalize your shift readings.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "YES",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleSubmit() async {
    final provider = context.read<DashboardProvider>();

    // Validate inputs
    for (var nozzle in provider.mySelectedNozzles) {
      if (_controllers[nozzle.id]?.text.isEmpty ?? true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter closing reading for nozzle ${nozzle.number}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Show Confirmation Dialog
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
    });

    final List<Map<String, dynamic>> readingList = provider.mySelectedNozzles
        .map((nozzle) {
          return {
            'nozzle_code': nozzle.id,
            'closing_reading_no':
                double.tryParse(_controllers[nozzle.id]?.text ?? "0") ?? 0,
          };
        })
        .toList();

    final readings = {'nozzle_closing_readings': readingList};

    final success = await provider.checkoutWithReadings(readings);

    if (success && mounted) {
      // Refresh dashboard data immediately to reflect the shift closure state
      provider.fetchNozzles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked out successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/dashboard');
    } else if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to check out'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final nozzles = provider.mySelectedNozzles;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: _indigo,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Enter Closing Readings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: _indigo,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Enter Closing Readings",
                    //   style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      "Please enter the final meter readings for all active nozzles to complete your shift.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: nozzles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_gas_station_outlined,
                                size: 60, color: _indigo.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            const Text(
                              "No active nozzles found.",
                              style: TextStyle(color: Colors.black54, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: nozzles.length,
                        itemBuilder: (context, index) {
                          final nozzle = nozzles[index];
                          return _buildNozzleCard(nozzle);
                        },
                      ),
              ),

              // Persistent Bottom Action Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || nozzles.isEmpty)
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: _indigo.withOpacity(0.4),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "PROCEED",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: _indigo),
            ),
          ),
      ],
    );
  }

  Widget _buildNozzleCard(var nozzle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _indigo.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      color: _indigo,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nozzle ${nozzle.number}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        nozzle.fuelType.toLowerCase() == "motor spirit"
                            ? (nozzle.fuelTypeCode ?? "")
                            : nozzle.fuelTypeCode.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blueAccent.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "OPENING READING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 12),
                Text(
                  _startingReadings[nozzle.id]?.toStringAsFixed(2) ?? "0.00",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const Spacer(),
                // const Text("READ ONLY", style: TextStyle(fontSize: 9, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "CLOSING READING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers[nozzle.id],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Enter Closing Reading",
              hintStyle: const TextStyle(
                color: Colors.black26,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _indigo, width: 2),
              ),
              prefixIcon: const Icon(Icons.speed, color: _indigo, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
