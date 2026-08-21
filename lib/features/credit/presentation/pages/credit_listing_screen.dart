import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import '../providers/credit_provider.dart';
import '../../data/models/customer_credit_model.dart';

class CreditListingScreen extends StatefulWidget {
  const CreditListingScreen({super.key});

  @override
  State<CreditListingScreen> createState() => _CreditListingScreenState();
}

class _CreditListingScreenState extends State<CreditListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatMobile(String mobile) {
    // API mobile might already be formatted (e.g. 91-78xxxx1235)
    if (mobile.contains('x')) return mobile;
    
    if (mobile.length >= 12) {
      return mobile.substring(0, 3) + 'xxxxxx' + mobile.substring(mobile.length - 3);
    } else if (mobile.length >= 10) {
      return mobile.substring(0, 3) + 'xxxx' + mobile.substring(mobile.length - 3);
    }
    return mobile;
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creditProvider = context.watch<CreditProvider>();
    final apiCredits = creditProvider.apiCredits;
    final isLoading = creditProvider.isLoading;
    final error = creditProvider.error;

    final filteredCredits = apiCredits.where((credit) {
      final q = _searchQuery.toLowerCase();
      return credit.customerName.toLowerCase().contains(q) || 
             credit.customerMobile.contains(q) ||
             credit.customerUid.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          "CREDIT CUSTOMERS",
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.textDark,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () => creditProvider.fetchApiCredits(),
        //     icon: Icon(Icons.refresh, color: AppColors.primary, size: 22),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search by Name, Mobile or UID",
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close, color: AppColors.grey),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Error state
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Error: $error", style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () => creditProvider.fetchApiCredits(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),

            // Loading state
            if (isLoading && apiCredits.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else
              // Credit List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => creditProvider.fetchApiCredits(),
                  color: AppColors.primary,
                  child: filteredCredits.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No customers found",
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: filteredCredits.length,
                          itemBuilder: (context, index) {
                            final credit = filteredCredits[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.black.withOpacity(0.04)),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // Pass credit object to next screen
                                  context.push('/credit-entry', extra: credit);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primary, AppColors.accent],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Center(
                                          child: credit.customerPhoto != null
                                              ? ClipOval(
                                                  child: Image.network(
                                                    credit.customerPhoto!,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => 
                                                      const Icon(Icons.person, color: Colors.white, size: 28),
                                                  ),
                                                )
                                              : const Icon(Icons.person, color: Colors.white, size: 28),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              credit.customerName,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "ID: ${credit.customerUid}",
                                              style: AppTextStyles.caption.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone, size: 14, color: AppColors.grey),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _formatMobile(credit.customerMobile),
                                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: credit.status.toLowerCase() == 'pending' 
                                                ? Colors.orange.withOpacity(0.1) 
                                                : Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              credit.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: credit.status.toLowerCase() == 'pending' 
                                                  ? Colors.orange 
                                                  : Colors.green,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: AppColors.primary,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            if (isLoading && apiCredits.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
