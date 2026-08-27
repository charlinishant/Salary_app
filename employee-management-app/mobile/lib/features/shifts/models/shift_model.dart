class ShiftModel {
  final int id;
  final int? companyId;
  final int? branchId;
  final String name;
  final String? code;
  final String startTime;
  final String endTime;
  final int graceMinutes;
  final double halfDayHours;
  final double fullDayHours;
  final int breakMinutes;
  final int earlyCheckInLimit;
  final int lateMarkAfter;
  final int earlyExitBefore;
  final int overtimeAfter;
  final String weeklyOff;
  final bool isOvernight;
  final bool isActive;
  final int assignedEmployeesCount;

  ShiftModel({
    required this.id,
    this.companyId,
    this.branchId,
    required this.name,
    this.code,
    required this.startTime,
    required this.endTime,
    this.graceMinutes = 15,
    this.halfDayHours = 4.0,
    this.fullDayHours = 8.0,
    this.breakMinutes = 60,
    this.earlyCheckInLimit = 60,
    this.lateMarkAfter = 15,
    this.earlyExitBefore = 15,
    this.overtimeAfter = 480,
    this.weeklyOff = 'Sunday',
    this.isOvernight = false,
    this.isActive = true,
    this.assignedEmployeesCount = 0,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      name: json['name'] ?? '',
      code: json['code'],
      startTime: json['startTime'] ?? '09:30',
      endTime: json['endTime'] ?? '18:30',
      graceMinutes: json['graceMinutes'] ?? 15,
      halfDayHours: (json['halfDayHours'] ?? 4.0).toDouble(),
      fullDayHours: (json['fullDayHours'] ?? 8.0).toDouble(),
      breakMinutes: json['breakMinutes'] ?? 60,
      earlyCheckInLimit: json['earlyCheckInLimit'] ?? 60,
      lateMarkAfter: json['lateMarkAfter'] ?? 15,
      earlyExitBefore: json['earlyExitBefore'] ?? 15,
      overtimeAfter: json['overtimeAfter'] ?? 480,
      weeklyOff: json['weeklyOff'] ?? 'Sunday',
      isOvernight: json['isOvernight'] ?? false,
      isActive: json['isActive'] ?? true,
      assignedEmployeesCount: json['assignedEmployeesCount'] ?? json['_count']?['employees'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'branchId': branchId,
        'name': name,
        'code': code,
        'startTime': startTime,
        'endTime': endTime,
        'graceMinutes': graceMinutes,
        'halfDayHours': halfDayHours,
        'fullDayHours': fullDayHours,
        'breakMinutes': breakMinutes,
        'earlyCheckInLimit': earlyCheckInLimit,
        'lateMarkAfter': lateMarkAfter,
        'earlyExitBefore': earlyExitBefore,
        'overtimeAfter': overtimeAfter,
        'weeklyOff': weeklyOff,
        'isOvernight': isOvernight,
        'isActive': isActive,
      };
}
