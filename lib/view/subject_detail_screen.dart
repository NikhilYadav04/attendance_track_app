import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubjectDetailScreenComplete extends StatefulWidget {
  final Subject subject;
  final Function(Subject) onSubjectUpdated;

  SubjectDetailScreenComplete({
    required this.subject,
    required this.onSubjectUpdated,
  });

  @override
  _SubjectDetailScreenCompleteState createState() =>
      _SubjectDetailScreenCompleteState();
}

class _SubjectDetailScreenCompleteState
    extends State<SubjectDetailScreenComplete>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Subject subject;

  @override
  void initState() {
    super.initState();
    subject = widget.subject;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _attendanceStatusOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    for (final r in subject.attendanceHistory) {
      final d = r.date;
      final rd = DateTime(d.year, d.month, d.day);
      if (rd == day) return r.isPresent ? 1 : 2;
    }
    return 0;
  }

  double _percentageFromHistory() {
    final history = subject.attendanceHistory;
    if (history.isEmpty) return subject.percentage;
    int present = history.where((r) => r.isPresent).length;
    int total = history.length;
    return total == 0 ? 0.0 : (present / total) * 100;
  }

  Widget _buildCalendarGrid(double sw, double sh, bool isTablet) {
    DateTime today = DateTime.now();
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
    int daysBeforeMonth = firstDayOfMonth.weekday % 7;
    DateTime firstSunday =
        firstDayOfMonth.subtract(Duration(days: daysBeforeMonth));
    const daysInCalendar = 42;
    final calendarDays = List.generate(
        daysInCalendar, (i) => firstSunday.add(Duration(days: i)));

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: isTablet ? sw * 0.01 : sw * 0.01,
        mainAxisSpacing: isTablet ? sw * 0.01 : sw * 0.01,
      ),
      itemCount: daysInCalendar,
      itemBuilder: (context, index) {
        final date = calendarDays[index];
        final status = _attendanceStatusOn(date); // 0 none, 1 present, 2 absent
        final isToday = _isToday(date);
        final isFuture = date.isAfter(DateTime.now());
        final inCurrentMonth =
            date.month == today.month && date.year == today.year;

        Color bg;
        Color textColor;
        if (!inCurrentMonth) {
          bg = Colors.grey[50]!;
          textColor = Colors.grey[300]!;
        } else if (isFuture) {
          bg = Colors.grey[100]!;
          textColor = Colors.grey[400]!;
        } else if (status == 1) {
          bg = AppColors.success;
          textColor = Colors.white;
        } else if (status == 2) {
          bg = Colors.grey[350]!;
          textColor = Colors.white;
        } else if (isToday) {
          bg = AppColors.primary.withOpacity(0.15);
          textColor = AppColors.primary;
        } else {
          bg = Colors.grey[200]!;
          textColor = AppColors.textPrimary;
        }

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(isTablet ? sw * 0.015 : sw * 0.02),
            border:
                isToday ? Border.all(color: AppColors.primary, width: sw * 0.005) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  ),
                ),
                if (status == 1)
                  Icon(Icons.check,
                      color: Colors.white, size: isTablet ? sw * 0.015 : sw * 0.025),
                if (status == 2)
                  Icon(Icons.close,
                      color: Colors.white, size: isTablet ? sw * 0.015 : sw * 0.025),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
      AttendanceRecord r, int pos, double sw, double sh, bool isTablet) {
    final present = r.isPresent;
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.03),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: sw * 0.02,
              offset: Offset(0, sh * 0.0025))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? sw * 0.05 : sw * 0.09,
            height: isTablet ? sw * 0.05 : sw * 0.09,
            decoration: BoxDecoration(
              color: present ? AppColors.success : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$pos',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(r.date),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                      color: AppColors.textPrimary),
                ),
                SizedBox(height: sh * 0.005),
                Row(children: [
                  Icon(Icons.access_time,
                      size: isTablet ? sw * 0.02 : sw * 0.035, color: AppColors.textSecondary),
                  SizedBox(width: sw * 0.01),
                  Text('Marked at ${DateFormat('HH:mm').format(r.markedAt)}',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? sw * 0.018 : sw * 0.03)),
                ]),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.01 : sw * 0.015),
            decoration: BoxDecoration(
                color: present
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(sw * 0.02)),
            child: Icon(present ? Icons.check_circle : Icons.cancel,
                color: present ? AppColors.success : Colors.grey[600],
                size: isTablet ? sw * 0.03 : sw * 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(double sw, double sh, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppColors.success, 'Present', Icons.check_circle, isTablet, sw),
        _legendItem(Colors.grey[350]!, 'Absent', Icons.cancel, isTablet, sw),
        _legendItem(AppColors.primary, 'Today', Icons.today, isTablet, sw),
      ],
    );
  }

  Widget _legendItem(Color color, String label, IconData icon, bool isTablet, double sw) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: isTablet ? sw * 0.025 : sw * 0.04,
            height: isTablet ? sw * 0.025 : sw * 0.04,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(sw * 0.01)),
            child: Icon(icon, color: Colors.white, size: isTablet ? sw * 0.015 : sw * 0.025)),
        SizedBox(width: sw * 0.02),
        Text(label,
            style: TextStyle(
                fontSize: isTablet ? sw * 0.018 : sw * 0.03, color: AppColors.textPrimary)),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isTablet = sw >= 600;
    final percentToShow = _percentageFromHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.025),
          decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(isTablet ? sw * 0.015 : sw * 0.025)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                color: AppColors.textPrimary,
                size: isTablet ? sw * 0.035 : sw * 0.055),
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(subject.name,
            style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? sw * 0.028 : sw * 0.045,
                fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: sh * 0.003,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
              fontSize: isTablet ? sw * 0.02 : sw * 0.035, fontWeight: FontWeight.w600),
          tabs: [
            Tab(
                icon: Icon(Icons.calendar_today, size: isTablet ? sw * 0.03 : sw * 0.05),
                text: 'Calendar'),
            Tab(
                icon: Icon(Icons.list_alt, size: isTablet ? sw * 0.03 : sw * 0.05),
                text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.04)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.track_changes,
                              color: AppColors.primary,
                              size: isTablet ? sw * 0.035 : sw * 0.06),
                          SizedBox(width: sw * 0.02),
                          Expanded(
                            child: Text('Attendance',
                                style: TextStyle(
                                    fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    '${subject.attendedLectures} / ${subject.totalLectures} lectures',
                                    style: TextStyle(
                                        fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: sh * 0.005),
                                Text('${percentToShow.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: subject.isGoalAchieved
                                            ? AppColors.success
                                            : (subject.percentage >= 50
                                                ? AppColors.warning
                                                : AppColors.accent))),
                              ]),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sh * 0.03),
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.04)),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.02, vertical: sh * 0.015),
                        margin: EdgeInsets.only(bottom: sh * 0.02),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.03),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: sw * 0.0025)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month,
                                  color: AppColors.primary,
                                  size: isTablet ? sw * 0.025 : sw * 0.045),
                              SizedBox(width: sw * 0.02),
                              Text(_getCalendarHeaderTitle(),
                                  style: TextStyle(
                                      fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            ]),
                      ),
                      Container(child: _buildCalendarGrid(sw, sh, isTablet)),
                    ],
                  ),
                ),
                SizedBox(height: sh * 0.03),
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.04)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Legend',
                            style: TextStyle(
                                fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        SizedBox(height: sh * 0.02),
                        _buildLegend(sw, sh, isTablet),
                      ]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.04),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Row(children: [
                      Icon(Icons.history,
                          color: AppColors.primary, size: isTablet ? sw * 0.035 : sw * 0.06),
                      SizedBox(width: sw * 0.02),
                      Text('Attendance History',
                          style: TextStyle(
                              fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary))
                    ]),
                    SizedBox(height: sh * 0.01),
                    Text('${subject.attendanceHistory.length} total records',
                        style: TextStyle(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: subject.attendanceHistory.isEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Icon(Icons.history_toggle_off,
                                size: isTablet ? sw * 0.1 : sw * 0.15,
                                color: Colors.grey[400]),
                            SizedBox(height: sh * 0.03),
                            Text('No attendance history yet',
                                style: TextStyle(
                                    fontSize: isTablet ? sw * 0.028 : sw * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary))
                          ]))
                    : ListView.builder(
                        padding: EdgeInsets.all(sw * 0.04),
                        itemCount: subject.attendanceHistory.length,
                        itemBuilder: (context, index) {
                          final sorted = List.from(subject.attendanceHistory)
                            ..sort((a, b) => b.date.compareTo(a.date));
                          final record = sorted[index];
                          return _buildHistoryItem(
                              record, index + 1, sw, sh, isTablet);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCalendarHeaderTitle() {
    final today = DateTime.now();
    if (subject.attendanceHistory.isEmpty)
      return DateFormat('MMMM yyyy').format(today);
    final dates = subject.attendanceHistory.map((r) => r.date).toList();
    var earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    var latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    if (latest.isBefore(today)) latest = today;
    if (earliest.year == latest.year && earliest.month == latest.month)
      return DateFormat('MMMM yyyy').format(earliest);
    if (earliest.year == latest.year)
      return '${DateFormat('MMM').format(earliest)} - ${DateFormat('MMM yyyy').format(latest)}';
    return '${DateFormat('MMM yyyy').format(earliest)} - ${DateFormat('MMM yyyy').format(latest)}';
  }
}