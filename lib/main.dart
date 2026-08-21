import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/theme/app_theme.dart';
import 'package:fk_salesman/core/router/app_router.dart';
import 'package:fk_salesman/features/auth/presentation/providers/auth_provider.dart';
import 'package:fk_salesman/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/calculated_sales_provider.dart';
import 'package:fk_salesman/core/utils/session_manager.dart';

import 'package:fk_salesman/features/credit/presentation/providers/credit_provider.dart';
import 'package:fk_salesman/features/dip_density/presentation/providers/dip_density_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CalculatedSalesProvider()),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
        ChangeNotifierProvider(create: (_) => DipDensityProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.read<AuthProvider>();
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // Let the container color show through
                statusBarIconBrightness: Brightness.light, 
                statusBarBrightness: Brightness.dark, // For iOS
              ),
              child: Container(
                color: AppColors.primary,
                child: SafeArea(
                  bottom: false,
                  child: MaterialApp.router(
                    title: 'fk_salesman',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    routerConfig: AppRouter.createRouter(authProvider),
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
