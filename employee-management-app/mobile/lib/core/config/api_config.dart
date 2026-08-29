class ApiConfig {
  static const wifiBaseUrl = 'http://192.168.1.49:5000/api';
  static const usbBaseUrl = 'http://127.0.0.1:5000/api';
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:5000/api';

  static final List<String> candidateUrls = [
    usbBaseUrl,
    wifiBaseUrl,
    androidEmulatorBaseUrl,
  ];

  static String _activeBaseUrl = usbBaseUrl;

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return _activeBaseUrl;
  }

  static void setActiveBaseUrl(String url) {
    _activeBaseUrl = url;
  }
}
