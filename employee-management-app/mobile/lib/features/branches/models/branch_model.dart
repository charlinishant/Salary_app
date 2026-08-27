class BranchModel {
  final int id;
  final int companyId;
  final String name;
  final String code;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final double geofenceRadius;
  final String timezone;
  final int? managerId;
  final bool isActive;
  final int employeeCount;

  BranchModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.code,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.geofenceRadius = 100.0,
    this.timezone = 'Asia/Kolkata',
    this.managerId,
    this.isActive = true,
    this.employeeCount = 0,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      companyId: json['companyId'] ?? 1,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      geofenceRadius: json['geofenceRadius'] != null ? double.parse(json['geofenceRadius'].toString()) : 100.0,
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      managerId: json['managerId'],
      isActive: json['isActive'] ?? true,
      employeeCount: json['employeeCount'] ?? json['_count']?['employees'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'name': name,
        'code': code,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'phone': phone,
        'email': email,
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadius': geofenceRadius,
        'timezone': timezone,
        'managerId': managerId,
        'isActive': isActive,
      };
}
