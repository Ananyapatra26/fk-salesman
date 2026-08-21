import 'session_manager.dart';

class ApiConstants {
  static String get baseUrl => SessionManager.getBaseUrl();
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  // Dashboard Endpoints
  static const String dashboard = '/nozzles';
  static const String dashboardInfo = '/dashboard';
  static const String profile = '/profile';
  // Sales Endpoints
  static const String storeSales = '/nozzleWiseSales';
  static const String selectedNozzles = '/selectedNozzles';
  static const String selectNozzle = '/selectNozzles';
  static const String deselectNozzle = '/deselectNozzles';
  static const String markAttendance = '/markAttendance';
  static const String attendanceRecords = '/attendanceRecords';
  static const String nozzleTestingInfo = '/nozzleWiseTestingInfo';
  static const String myNozzleWiseSales = '/myNozzleWiseSales';
  static const String nozzlesForTesting = '/nozzlesForTesting';
  static const String calculatedSales = '/salesmanCalculatedSalesAmounts';
  static const String closeShift = '/salesmanCloseShift';
  static const String paymentMethods = '/paymentMethods';
  static const String shiftWiseSales = '/shiftWiseSales';
  static const String customerCredits = '/customerCredits';
  static const String customerCreditNewTransaction = '/customerCreditNewTransaction';
  // DIP & Density Endpoints
  static const String fuelTanks = '/dipInfo';
  static const String densityInfo = '/densityInfo';
  static const String dipEntry = '/dipWiseEntry';
  static const String densityEntry = '/densityWiseEntry';
  static const String calculateFuelStock = '/calculateFuelStock';
  static const String calculateDensity = '/calculateDensity';
}
