class ApiConfig {
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:5000/api';
  static const physicalDeviceBaseUrl = 'http://192.168.1.10:5000/api';
  static const productionBaseUrl = 'https://api.example.com/api';
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: androidEmulatorBaseUrl,
  );
}
