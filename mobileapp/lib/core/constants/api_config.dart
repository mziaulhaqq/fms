class ApiConfig {
  // Base URL - Update this to your server IP when testing on physical device
  // For simulator: use 'http://localhost:3000'
  // For physical device: use your Mac's IP address
  static const String baseUrl = 'http://192.168.0.165:3000';
  
  // API Endpoints
  static const String clients = '/clients';
  static const String expenseCategories = '/expense-categories';
  static const String expenses = '/expenses';
  static const String equipment = '/equipment';
  static const String miningSites = '/mining-sites';
  static const String income = '/income';
  static const String workers = '/workers';
  static const String partners = '/partners';
  static const String partnerPayouts = '/partner-payouts';
  static const String production = '/production';
  static const String profitDistributions = '/profit-distributions';
  static const String siteSupervisors = '/site-supervisors';
  static const String truckDeliveries = '/truck-deliveries';
  static const String laborCosts = '/labor-costs';
  static const String users = '/users';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
