import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Subject Detail Screen with Calendar & History Tabs
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

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: isTablet ? sw * 0.035 : sw * 0.055,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          subject.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.calendar_today, size: isTablet ? 24 : 20),
              text: 'Calendar',
            ),
            Tab(
              icon: Icon(Icons.list_alt, size: isTablet ? 24 : 20),
              text: 'History',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(sw, sh, isTablet),
          _buildHistoryTab(sw, sh, isTablet),
        ],
      ),
    );
  }

  // Calendar Tab
  Widget _buildCalendarTab(double sw, double sh, bool isTablet) {
    // Calculate dynamic header text
    String getCalendarHeaderText() {
      if (subject.attendanceHistory.isEmpty) {
        return 'This Month Overview';
      }

      List<DateTime> attendanceDates =
          subject.attendanceHistory.map((record) => record.date).toList();

      DateTime earliestDate =
          attendanceDates.reduce((a, b) => a.isBefore(b) ? a : b);
      DateTime latestDate =
          attendanceDates.reduce((a, b) => a.isAfter(b) ? a : b);
      DateTime today = DateTime.now();

      // Extend to current date if needed
      if (latestDate.isBefore(today)) {
        latestDate = today;
      }

      // Calculate months
      int totalMonths = (latestDate.year - earliestDate.year) * 12 +
          latestDate.month -
          earliestDate.month +
          1;

      if (totalMonths == 1) {
        return DateFormat('MMMM yyyy').format(earliestDate) + ' Overview';
      } else if (totalMonths == 2) {
        return 'Last 2 Months Overview';
      } else if (totalMonths <= 12) {
        return 'Last $totalMonths Months Overview';
      } else {
        return 'Complete Attendance History';
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Header
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      color: AppColors.primary,
                      size: isTablet ? 28 : 24,
                    ),
                    SizedBox(width: sw * 0.02),
                    Text(
                      'Attendance Goal',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.025),

                // Target Percentage Row
                Container(
                  padding: EdgeInsets.all(sw * 0.03),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target:',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              // Decrease Button
                              GestureDetector(
                                onTap: () {
                                  if (subject.targetPercentage > 50) {
                                    setState(() {
                                      subject.targetPercentage -= 5;
                                    });
                                    widget.onSubjectUpdated(subject);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                                  decoration: BoxDecoration(
                                    color: subject.targetPercentage > 50
                                        ? AppColors.accent
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: isTablet ? 16 : 14,
                                  ),
                                ),
                              ),

                              SizedBox(width: sw * 0.03),

                              // Target Percentage
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.04,
                                  vertical: sh * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 12 : 10),
                                ),
                                child: Text(
                                  '${subject.targetPercentage}%',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              SizedBox(width: sw * 0.03),

                              // Increase Button
                              GestureDetector(
                                onTap: () {
                                  if (subject.targetPercentage < 100) {
                                    setState(() {
                                      subject.targetPercentage += 5;
                                    });
                                    widget.onSubjectUpdated(subject);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                                  decoration: BoxDecoration(
                                    color: subject.targetPercentage < 100
                                        ? AppColors.success
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: isTablet ? 16 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.02),

                      // Progress and Goal Info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current: ${subject.percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: sh * 0.005),

                                // Status Message
                                Text(
                                  _getGoalStatusMessage(),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: _getGoalStatusColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Goal Achievement Icon
                          Container(
                            padding: EdgeInsets.all(isTablet ? 12 : 10),
                            decoration: BoxDecoration(
                              color: _getGoalStatusColor().withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getGoalStatusIcon(),
                              color: _getGoalStatusColor(),
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.03),

          // Calendar Grid
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month/Year Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sh * 0.015,
                  ),
                  margin: EdgeInsets.only(bottom: sh * 0.02),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                        size: isTablet ? 20 : 18,
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        _getCalendarHeaderTitle(),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Days of week header
                Container(
                  padding: EdgeInsets.symmetric(vertical: sh * 0.01),
                  child: Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: sh * 0.02),

                // Calendar days - Start from Sunday
                _buildCalendarGrid(sw, sh, isTablet),
              ],
            ),
          ),

          SizedBox(height: sh * 0.03),

          // Legend
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legend',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sh * 0.02),
                Wrap(
                  spacing: sw * 0.04,
                  runSpacing: sh * 0.01,
                  children: [
                    _buildLegendItem(AppColors.success, 'Present',
                        Icons.check_circle, isTablet),
                    _buildLegendItem(
                        Colors.grey[300]!, 'Absent', Icons.cancel, isTablet),
                    _buildLegendItem(
                        AppColors.primary, 'Today', Icons.today, isTablet),
                    _buildLegendItem(
                        Colors.grey[100]!, 'Future', Icons.schedule, isTablet),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(double sw, double sh, bool isTablet) {
    // Get current month info
    DateTime today = DateTime.now();
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

    // Find the Sunday before the first day of the month
    int daysBeforeMonth = firstDayOfMonth.weekday % 7;
    DateTime firstSunday =
        firstDayOfMonth.subtract(Duration(days: daysBeforeMonth));

    // Calculate how many days we need to fill the calendar (6 weeks max)
    int daysInCalendar = 42; // 6 weeks
    List<DateTime> calendarDays = [];
    for (int i = 0; i < daysInCalendar; i++) {
      calendarDays.add(firstSunday.add(Duration(days: i)));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: isTablet ? 8 : 4,
        mainAxisSpacing: isTablet ? 8 : 4,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        DateTime date = calendarDays[index];
        bool isAttended = subject.isAttendedOn(date);
        bool isToday = _isToday(date);
        bool isFuture = date.isAfter(DateTime.now());
        bool isCurrentMonth =
            date.month == today.month && date.year == today.year;

        return Container(
          decoration: BoxDecoration(
            color: _getCalendarDayColor(
                isAttended, isToday, isFuture, isCurrentMonth),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            border:
                isToday ? Border.all(color: AppColors.primary, width: 2) : null,
            boxShadow: isAttended && isCurrentMonth
                ? [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: _getCalendarTextColor(
                        isAttended, isToday, isFuture, isCurrentMonth),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                if (isAttended && isCurrentMonth)
                  Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isTablet ? 12 : 10,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // History Tab
  Widget _buildHistoryTab(double sw, double sh, bool isTablet) {
    List<AttendanceRecord> sortedHistory = List.from(subject.attendanceHistory);
    sortedHistory.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // History Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.primary,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.01),
              Text(
                '${sortedHistory.length} total records',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // History List
        Expanded(
          child: sortedHistory.isEmpty
              ? _buildEmptyHistory(sw, sh, isTablet)
              : ListView.builder(
                  padding: EdgeInsets.all(sw * 0.04),
                  itemCount: sortedHistory.length,
                  itemBuilder: (context, index) {
                    AttendanceRecord record = sortedHistory[index];
                    return _buildHistoryItem(
                        record, index + 1, sw, sh, isTablet);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory(double sw, double sh, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? sw * 0.2 : sw * 0.3,
            height: isTablet ? sw * 0.2 : sw * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  BorderRadius.circular(isTablet ? sw * 0.05 : sw * 0.075),
            ),
            child: Icon(
              Icons.history_toggle_off,
              size: isTablet ? sw * 0.1 : sw * 0.15,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: sh * 0.03),
          Text(
            'No attendance history yet',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Start marking attendance to see your history here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AttendanceRecord record, int position, double sw,
      double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: isTablet ? 40 : 35,
            height: isTablet ? 40 : 35,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),

          // Date and Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(record.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isTablet ? 16 : 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: sw * 0.01),
                    Text(
                      'Marked at ${DateFormat('HH:mm').format(record.markedAt)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
                if (_isToday(record.date)) ...[
                  SizedBox(height: sh * 0.005),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status Icon
          Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: isTablet ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      Color color, String label, IconData icon, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 20 : 16,
          height: isTablet ? 20 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: color == Colors.grey[300]
                ? Colors.grey[600]
                : color == Colors.grey[100]
                    ? Colors.grey[400]
                    : Colors.white,
            size: isTablet ? 12 : 10,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getCalendarDayColor(
      bool isAttended, bool isToday, bool isFuture, bool isCurrentMonth) {
    if (!isCurrentMonth)
      return Colors.grey[50]!; // Very light gray for other month days
    if (isFuture) return Colors.grey[100]!;
    if (isAttended) return AppColors.success; // Green for attended days
    if (isToday) return AppColors.primary.withOpacity(0.3);
    return Colors.grey[200]!;
  }

  Color _getCalendarTextColor(
      bool isAttended, bool isToday, bool isFuture, bool isCurrentMonth) {
    if (!isCurrentMonth)
      return Colors.grey[300]!; // Light gray for other month days
    if (isFuture) return Colors.grey[400]!;
    if (isAttended) return Colors.white; // White text on green background
    if (isToday) return AppColors.primary;
    return AppColors.textPrimary;
  }

  // Helper Methods (add these to your class)
  String _getGoalStatusMessage() {
    double currentPercentage = subject.percentage;
    int targetPercentage = subject.targetPercentage;

    if (currentPercentage >= targetPercentage) {
      return '🎉 Goal Achieved!';
    } else {
      int lecturesNeeded = _calculateLecturesNeeded();
      if (lecturesNeeded == -1) {
        return 'Impossible to reach ${targetPercentage}%';
      } else if (lecturesNeeded == 0) {
        return 'Already at maximum attendance';
      } else if (lecturesNeeded == 1) {
        return 'Need 1 more lecture';
      } else {
        return 'Need $lecturesNeeded more lectures';
      }
    }
  }

  Color _getGoalStatusColor() {
    double currentPercentage = subject.percentage;
    int targetPercentage = subject.targetPercentage;

    if (currentPercentage >= targetPercentage) {
      return AppColors.success;
    } else {
      int needed = _calculateLecturesNeeded();
      if (needed == -1 || needed == 0) {
        return AppColors.accent;
      } else {
        return AppColors.warning;
      }
    }
  }

  IconData _getGoalStatusIcon() {
    double currentPercentage = subject.percentage;
    int targetPercentage = subject.targetPercentage;

    if (currentPercentage >= targetPercentage) {
      return Icons.celebration;
    } else {
      int needed = _calculateLecturesNeeded();
      if (needed == -1 || needed == 0) {
        return Icons.error_outline;
      } else {
        return Icons.trending_up;
      }
    }
  }

  int _calculateLecturesNeeded() {
    int attended = subject.attendedLectures;
    int total = subject.totalLectures;
    int targetPercentage = subject.targetPercentage;

    // If already attended all lectures
    if (attended >= total) {
      double currentPercentage = (attended / total) * 100;
      return currentPercentage >= targetPercentage ? 0 : -1;
    }

    // Calculate how many more lectures needed from remaining lectures
    int remainingLectures = total - attended;

    // Try attending different numbers of remaining lectures
    for (int additional = 1; additional <= remainingLectures; additional++) {
      int newAttended = attended + additional;
      double newPercentage = (newAttended / total) * 100;

      if (newPercentage >= targetPercentage) {
        return additional;
      }
    }

    // If even attending all remaining lectures won't reach target
    int maxPossibleAttended = total;
    double maxPossiblePercentage = (maxPossibleAttended / total) * 100;

    return maxPossiblePercentage >= targetPercentage ? remainingLectures : -1;
  }

  String _getCalendarHeaderTitle() {
    DateTime today = DateTime.now();

    if (subject.attendanceHistory.isEmpty) {
      // No attendance - show current month
      return DateFormat('MMMM yyyy').format(today);
    }

    // Get date range from attendance
    List<DateTime> attendanceDates =
        subject.attendanceHistory.map((record) => record.date).toList();

    DateTime earliestDate =
        attendanceDates.reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime latestDate =
        attendanceDates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Extend to current date if needed
    if (latestDate.isBefore(today)) {
      latestDate = today;
    }

    // If same month and year
    if (earliestDate.year == latestDate.year &&
        earliestDate.month == latestDate.month) {
      return DateFormat('MMMM yyyy').format(earliestDate);
    }

    // If same year, different months
    if (earliestDate.year == latestDate.year) {
      return '${DateFormat('MMM').format(earliestDate)} - ${DateFormat('MMM yyyy').format(latestDate)}';
    }

    // Different years
    return '${DateFormat('MMM yyyy').format(earliestDate)} - ${DateFormat('MMM yyyy').format(latestDate)}';
  }
}
