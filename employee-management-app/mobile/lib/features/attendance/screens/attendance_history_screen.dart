import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    context.read<AttendanceProvider>().loadHistory(
          month: _selectedMonth,
          year: _selectedYear,
        );
  }

  void _onMonthYearPickerTap() async {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Month & Year', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setStateModal(() => _selectedYear--),
                  ),
                  Text('$_selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setStateModal(() => _selectedYear++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final isSelected = _selectedMonth == index + 1;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMonth = index + 1;
                      });
                      Navigator.pop(ctx);
                      _loadHistory();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00BFA5) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        months[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateDetailModal(DateTime date, Map<String, dynamic>? record) {
    final formattedFull = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final isPresent = record != null && (record['status'] == 'PRESENT' || record['status'] == 'LATE');
    final isLeave = record != null && record['status'] == 'LEAVE';
    final isLate = record != null && record['status'] == 'LATE';
    final isFuture = date.isAfter(DateTime.now());

    String statusText;
    Color statusColor;

    if (isFuture) {
      statusText = 'UPCOMING';
      statusColor = Colors.grey;
    } else if (isPresent) {
      statusText = isLate ? 'LATE' : 'PRESENT';
      statusColor = isLate ? Colors.orange.shade800 : const Color(0xFF10B981);
    } else if (isLeave) {
      statusText = 'ON LEAVE';
      statusColor = Colors.purple;
    } else {
      statusText = 'ABSENT';
      statusColor = const Color(0xFFEF4444);
    }

    final inTime = record?['checkIn'] ?? (isPresent ? '09:30 AM' : '--:--');
    final outTime = record?['checkOut'] ?? (isPresent ? '06:30 PM' : '--:--');
    final hours = record?['workingHours'] ?? (isPresent ? '8h 00m' : '--');
    final lateMins = record?['lateMinutes'] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedFull,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'General Day Shift (09:30 AM - 06:30 PM)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // In / Out / Hours Grid
            Row(
              children: [
                _buildDetailStatCard('PUNCH IN', inTime, Icons.login, const Color(0xFF00BFA5)),
                const SizedBox(width: 12),
                _buildDetailStatCard('PUNCH OUT', outTime, Icons.logout, Colors.orange),
                const SizedBox(width: 12),
                _buildDetailStatCard('DURATION', hours, Icons.timer_outlined, const Color(0xFF1E293B)),
              ],
            ),
            const SizedBox(height: 18),

            // Additional Info Rows
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Late Mark', isLate ? '$lateMins mins Late' : 'On Time', isLate ? Colors.orange.shade800 : Colors.green),
                  const Divider(height: 16),
                  _buildDetailRow('Verification Mode', 'Front Camera Selfie + Geo Location', Colors.black87),
                  const Divider(height: 16),
                  _buildDetailRow('Attendance Status', statusText, statusColor),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String val, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            val,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final employee = authProvider.state.data;
    final empName = employee?.name ?? AppSession.instance.selectedEmployeeName ?? 'Nishant More';
    final initialLetter = empName.isNotEmpty ? empName[0].toUpperCase() : 'N';

    final attProvider = context.watch<AttendanceProvider>();
    final state = attProvider.historyState;
    final List recordsList = state.data ?? [];

    // Map records by day number
    final Map<int, Map<String, dynamic>> recordsByDay = {};
    for (var r in recordsList) {
      if (r is Map) {
        final dStr = r['date'] ?? r['attendanceDate'];
        if (dStr != null) {
          final dt = DateTime.tryParse(dStr.toString());
          if (dt != null && dt.month == _selectedMonth && dt.year == _selectedYear) {
            recordsByDay[dt.day] = Map<String, dynamic>.from(r);
          }
        }
      }
    }

    final totalDaysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0, Mon = 1, ...

    // Calculate metric counts
    int presentCount = 0;
    int absentCount = 0;
    int halfDayCount = 0;
    double paidLeaveCount = 0.0;
    int weekOffCount = 0;

    final now = DateTime.now();
    for (int day = 1; day <= totalDaysInMonth; day++) {
      final date = DateTime(_selectedYear, _selectedMonth, day);
      final isWeekdaySunday = date.weekday == DateTime.sunday;
      final record = recordsByDay[day];

      if (isWeekdaySunday) {
        weekOffCount++;
      } else if (record != null) {
        final status = record['status']?.toString().toUpperCase();
        if (status == 'PRESENT' || status == 'LATE') {
          presentCount++;
        } else if (status == 'HALF_DAY') {
          halfDayCount++;
        } else if (status == 'LEAVE' || status == 'PAID_LEAVE') {
          paidLeaveCount += 1.0;
        } else {
          absentCount++;
        }
      } else {
        if (!date.isAfter(now)) {
          absentCount++;
        }
      }
    }

    final monthNameShort = DateFormat('MMM').format(DateTime(_selectedYear, _selectedMonth));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE57373),
              child: Text(
                initialLetter,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              empName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pale Yellow "Attendance For" Strip (Matches Screenshot)
              Container(
                color: const Color(0xFFFFFBEB),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Attendance For',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _onMonthYearPickerTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text(
                              '$monthNameShort $_selectedYear',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Summary Metric Badges with Vertical Accent Bars (Matches Screenshot)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      _buildSummaryItem('Present', '$presentCount', const Color(0xFF10B981), const Color(0xFFECFDF5)),
                      _buildSummaryItem('Absent', '$absentCount', const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
                      _buildSummaryItem('Half day', '$halfDayCount', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                      _buildSummaryItem('Paid Leave', paidLeaveCount.toStringAsFixed(1), const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                      _buildSummaryItem('Week Off', '$weekOffCount', const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Weekday Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekdayText('Sun'),
                    _WeekdayText('Mon'),
                    _WeekdayText('Tue'),
                    _WeekdayText('Wed'),
                    _WeekdayText('Thu'),
                    _WeekdayText('Fri'),
                    _WeekdayText('Sat'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 4. Calendar Grid of Day Badges (Matches Screenshot)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: firstWeekday + totalDaysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) {
                      return const SizedBox.shrink();
                    }

                    final day = index - firstWeekday + 1;
                    final date = DateTime(_selectedYear, _selectedMonth, day);
                    final record = recordsByDay[day];
                    final isPresent = record != null && (record['status'] == 'PRESENT' || record['status'] == 'LATE');
                    final isHalfDay = record != null && record['status'] == 'HALF_DAY';
                    final isLeave = record != null && (record['status'] == 'LEAVE' || record['status'] == 'PAID_LEAVE');
                    final isSunday = date.weekday == DateTime.sunday;
                    final isFuture = date.isAfter(DateTime.now());

                    Color badgeBg;
                    Color badgeText;

                    if (isFuture) {
                      badgeBg = const Color(0xFFE2E8F0);
                      badgeText = const Color(0xFF94A3B8);
                    } else if (isPresent) {
                      badgeBg = const Color(0xFF10B981); // Solid Green
                      badgeText = Colors.white;
                    } else if (isHalfDay) {
                      badgeBg = const Color(0xFFF59E0B); // Yellow
                      badgeText = Colors.white;
                    } else if (isLeave) {
                      badgeBg = const Color(0xFF8B5CF6); // Purple
                      badgeText = Colors.white;
                    } else if (isSunday) {
                      badgeBg = const Color(0xFFEF4444); // Red Sunday/Absent
                      badgeText = Colors.white;
                    } else {
                      badgeBg = const Color(0xFFEF4444); // Solid Red Absent
                      badgeText = Colors.white;
                    }

                    final dayStr = day < 10 ? '0$day' : '$day';

                    return InkWell(
                      onTap: () => _showDateDetailModal(date, record),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayStr,
                          style: TextStyle(
                            color: badgeText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Tap instructions
              Center(
                child: Text(
                  'Tap any date to view in-time, out-time, working hours & late marks',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color accentColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  const _WeekdayText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          fontSize: 13,
        ),
      ),
    );
  }
}
