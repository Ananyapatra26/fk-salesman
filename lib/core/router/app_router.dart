import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/features/auth/presentation/pages/login_page.dart';
import 'package:fk_salesman/features/auth/presentation/pages/otp_page.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:fk_salesman/features/dashboard/domain/models/nozzle_model.dart';

import 'package:fk_salesman/features/dashboard/presentation/pages/add_nozzles_screen.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/attendance_screen.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/my_attendance_screen.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/checkout_form_page.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/sales_history_screen.dart';
import 'package:fk_salesman/features/dashboard/presentation/pages/calculated_details_screen.dart';
import 'package:fk_salesman/features/sales/presentation/pages/nozzle_testing_screen.dart';
import 'package:fk_salesman/features/sales/presentation/pages/log_test_info_screen.dart';
import '../../features/sales/sales_form_page.dart';

import 'package:fk_salesman/core/utils/session_manager.dart';
import 'package:fk_salesman/features/credit/domain/models/credit_models.dart';
import 'package:fk_salesman/features/credit/data/models/customer_credit_model.dart';
import 'package:fk_salesman/features/credit/presentation/pages/credit_listing_screen.dart';
import 'package:fk_salesman/features/credit/presentation/pages/credit_entry_screen.dart';
import 'package:fk_salesman/features/sales/presentation/pages/sales_entry_form_screen.dart';
import 'package:fk_salesman/features/dip_density/presentation/pages/dip_entry_screen.dart';
import 'package:fk_salesman/features/dip_density/presentation/pages/density_entry_screen.dart';

class AppRouter {
  static GoRouter createRouter(Listenable authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool loggedIn = SessionManager.isLoggedIn();
        final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';

        if (!loggedIn) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phone = state.extra as String? ?? '';
            return OtpPage(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/sales-form',
          builder: (context, state) {
            if (state.extra is Map) {
              final data = state.extra as Map;
              final List<Nozzle> selectedNozzles = (data['selectedNozzles'] as List).cast<Nozzle>();
              return SalesFormPage(
                selectedNozzles: selectedNozzles,
                initialIndex: data['initialIndex'] as int?,
              );
            }
            if (state.extra is List<Nozzle>) {
              return SalesFormPage(
                selectedNozzles: state.extra as List<Nozzle>,
              );
            }
            return const Scaffold(body: Center(child: Text("Invalid Nozzle Data")));
          },
        ),
        GoRoute(
          path: '/add-nozzles',
          builder: (context, state) => const AddNozzlesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const AttendanceScreen(),
        ),
        GoRoute(
          path: '/my-attendance',
          builder: (context, state) => const MyAttendanceScreen(),
        ),
        GoRoute(
          path: '/nozzle-testing',
          builder: (context, state) {
            if (state.extra is String) {
              return NozzleTestingScreen(nozzleCode: state.extra as String);
            }
            return const Scaffold(body: Center(child: Text("Invalid Nozzle Code")));
          },
        ),
        GoRoute(
          path: '/log-test-info',
          builder: (context, state) => const LogTestInfoScreen(),
        ),
        GoRoute(
          path: '/checkout-form',
          builder: (context, state) => const CheckoutFormPage(),
        ),
        GoRoute(
          path: '/sales-history',
          builder: (context, state) => const SalesHistoryScreen(),
        ),
        GoRoute(
          path: '/calculated-details',
          builder: (context, state) => const CalculatedDetailsScreen(),
        ),
        GoRoute(
          path: '/credit-cards',
          builder: (context, state) => const CreditListingScreen(),
        ),
        GoRoute(
          path: '/credit-entry',
          builder: (context, state) {
            if (state.extra is CustomerCredit) {
              return CreditEntryScreen(creditCard: state.extra as CustomerCredit);
            }
            // Fallback or handle CreditCard if still needed
            return const Scaffold(body: Center(child: Text("Invalid Credit Data")));
          },
        ),
        GoRoute(
          path: '/sales-entry',
          builder: (context, state) => const SalesEntryFormScreen(),
        ),
        GoRoute(
          path: '/dip-entry',
          builder: (context, state) => const DipEntryScreen(),
        ),
        GoRoute(
          path: '/density-entry',
          builder: (context, state) => const DensityEntryScreen(),
        ),
      ],
    );
  }
}
