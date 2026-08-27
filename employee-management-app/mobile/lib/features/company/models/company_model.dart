class CompanyModel {
  final int id;
  final String name;
  final String? legalName;
  final String companyCode;
  final String? industry;
  final String? email;
  final String? phone;
  final String? website;
  final String? logo;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? gstin;
  final String? pan;
  final String? tan;
  final String? pfNumber;
  final String? esiNumber;
  final String? ptNumber;
  final String currency;
  final String timezone;
  final String weekStartDay;
  final int branchCount;
  final int departmentCount;
  final int employeeCount;

  CompanyModel({
    required this.id,
    required this.name,
    this.legalName,
    required this.companyCode,
    this.industry,
    this.email,
    this.phone,
    this.website,
    this.logo,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.gstin,
    this.pan,
    this.tan,
    this.pfNumber,
    this.esiNumber,
    this.ptNumber,
    this.currency = 'INR',
    this.timezone = 'Asia/Kolkata',
    this.weekStartDay = 'Monday',
    this.branchCount = 0,
    this.departmentCount = 0,
    this.employeeCount = 0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? {};
    return CompanyModel(
      id: json['id'],
      name: json['name'] ?? '',
      legalName: json['legalName'],
      companyCode: json['companyCode'] ?? '',
      industry: json['industry'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      logo: json['logo'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      gstin: json['gstin'],
      pan: json['pan'],
      tan: json['tan'],
      pfNumber: json['pfNumber'],
      esiNumber: json['esiNumber'],
      ptNumber: json['ptNumber'],
      currency: json['currency'] ?? 'INR',
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      weekStartDay: json['weekStartDay'] ?? 'Monday',
      branchCount: count['branches'] ?? 0,
      departmentCount: count['departments'] ?? 0,
      employeeCount: count['employees'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'legalName': legalName,
        'companyCode': companyCode,
        'industry': industry,
        'email': email,
        'phone': phone,
        'website': website,
        'logo': logo,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'gstin': gstin,
        'pan': pan,
        'tan': tan,
        'pfNumber': pfNumber,
        'esiNumber': esiNumber,
        'ptNumber': ptNumber,
        'currency': currency,
        'timezone': timezone,
        'weekStartDay': weekStartDay,
      };
}
