class LeaveTypeModel {
  final int id;
  final String name;
  final String? code;
  final bool isLimited;
  final bool isPaid;
  final double annualAllocation;
  final bool carryForward;
  final double maxCarryForward;
  final bool requiresApproval;
  final bool halfDayAllowed;
  final String? color;
  final bool isActive;

  LeaveTypeModel({
    required this.id,
    required this.name,
    this.code,
    this.isLimited = true,
    this.isPaid = true,
    this.annualAllocation = 12.0,
    this.carryForward = false,
    this.maxCarryForward = 0.0,
    this.requiresApproval = true,
    this.halfDayAllowed = true,
    this.color = '#3B82F6',
    this.isActive = true,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      isLimited: json['isLimited'] ?? true,
      isPaid: json['isPaid'] ?? true,
      annualAllocation: (json['annualAllocation'] ?? 12.0).toDouble(),
      carryForward: json['carryForward'] ?? false,
      maxCarryForward: (json['maxCarryForward'] ?? 0.0).toDouble(),
      requiresApproval: json['requiresApproval'] ?? true,
      halfDayAllowed: json['halfDayAllowed'] ?? true,
      color: json['color'] ?? '#3B82F6',
      isActive: json['isActive'] ?? true,
    );
  }
}

class LeavePolicyModel {
  final int id;
  final String name;
  final int? companyId;
  final int leaveTypeId;
  final double annualBalance;
  final double monthlyAccrual;
  final bool carryForward;
  final int maxConsecutiveDays;
  final int minNoticePeriodDays;
  final int docsRequiredAfterDays;
  final bool allowNegativeBalance;
  final bool approvalRequired;
  final String approvalFlow;
  final bool isActive;
  final LeaveTypeModel? leaveType;

  LeavePolicyModel({
    required this.id,
    required this.name,
    this.companyId,
    required this.leaveTypeId,
    required this.annualBalance,
    this.monthlyAccrual = 1.0,
    this.carryForward = false,
    this.maxConsecutiveDays = 14,
    this.minNoticePeriodDays = 1,
    this.docsRequiredAfterDays = 3,
    this.allowNegativeBalance = false,
    this.approvalRequired = true,
    this.approvalFlow = 'MANAGER_THEN_HR',
    this.isActive = true,
    this.leaveType,
  });

  factory LeavePolicyModel.fromJson(Map<String, dynamic> json) {
    return LeavePolicyModel(
      id: json['id'],
      name: json['name'] ?? '',
      companyId: json['companyId'],
      leaveTypeId: json['leaveTypeId'],
      annualBalance: (json['annualBalance'] ?? 12.0).toDouble(),
      monthlyAccrual: (json['monthlyAccrual'] ?? 1.0).toDouble(),
      carryForward: json['carryForward'] ?? false,
      maxConsecutiveDays: json['maxConsecutiveDays'] ?? 14,
      minNoticePeriodDays: json['minNoticePeriodDays'] ?? 1,
      docsRequiredAfterDays: json['docsRequiredAfterDays'] ?? 3,
      allowNegativeBalance: json['allowNegativeBalance'] ?? false,
      approvalRequired: json['approvalRequired'] ?? true,
      approvalFlow: json['approvalFlow'] ?? 'MANAGER_THEN_HR',
      isActive: json['isActive'] ?? true,
      leaveType: json['leaveType'] != null ? LeaveTypeModel.fromJson(json['leaveType']) : null,
    );
  }
}
