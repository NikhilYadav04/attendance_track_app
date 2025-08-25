// Complete Enhanced Home Screen
import 'dart:convert';
import 'package:attendance_tracker/view/subject_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/http/models/user.dart';
import 'package:attendance_tracker/widgets/add_subject_dialog.dart';
import 'package:attendance_tracker/widgets/edit_subject_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  UserData? userData;
  bool isLoading = true;
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _loadUserData();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      setState(() {
        userData = UserData.fromJson(jsonDecode(userDataString));
        isLoading = false;
      });
      _listAnimationController.forward();
      Future.delayed(Duration(milliseconds: 500), () {
        _fabAnimationController.forward();
      });
    }
  }

  _saveUserData() async {
    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData!.toJson()));
    }
  }

  _addSubject() {
    if (userData!.subjects.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 10 subjects allowed'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: animation1.value,
          child: Opacity(
            opacity: animation1.value,
            child: AddSubjectDialog(
              onSubjectAdded: (subject) {
                setState(() {
                  userData!.subjects.add(subject);
                });
                _saveUserData();
                _listAnimationController.reset();
                _listAnimationController.forward();
              },
            ),
          ),
        );
      },
    );
  }

  // Enhanced increment attendance with date tracking
  _incrementAttendance(int index) {
    Subject subject = userData!.subjects[index];
    DateTime today = DateTime.now();

    // Check if already marked today
    bool alreadyMarkedToday = subject.attendanceHistory.any((record) =>
        record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day);

    if (alreadyMarkedToday) {
      _showAlreadyMarkedDialog(subject.name);
      return;
    }

    if (subject.attendedLectures < subject.totalLectures) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        subject.markAttendance();
      });
      _saveUserData();

      // Show success feedback with date and percentage
      _showSuccessSnackBar(subject);
    } else {
      // Play completion feedback when all lectures attended
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white, size: 20),
              SizedBox(width: ResponsiveHelper.getWidth(context) * 0.02),
              Text('Perfect attendance! 🏆'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  void _showAlreadyMarkedDialog(String subjectName) {
    double sw = ResponsiveHelper.getWidth(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                'Already Marked',
                style: AppTextStyles.bold(
                    context, isTablet ? 20 : 18, AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          'You have already marked attendance for $subjectName today (${DateFormat('MMM dd, yyyy').format(DateTime.now())}).',
          style: AppTextStyles.regular(
              context, isTablet ? 16 : 14, AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.medium(
                  context, isTablet ? 16 : 14, AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(Subject subject) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    double percentage = subject.percentage;
    bool milestoneReached = (percentage >= 75 &&
            percentage - (100 / subject.totalLectures) < 75) ||
        (percentage >= 50 && percentage - (100 / subject.totalLectures) < 50);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              milestoneReached ? Icons.star : Icons.check_circle,
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    milestoneReached
                        ? 'Milestone Reached! 🎉'
                        : 'Attendance Marked! ✅',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM dd').format(DateTime.now())} • ${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            milestoneReached ? AppColors.warning : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.02,
        ),
        duration: Duration(milliseconds: milestoneReached ? 3000 : 2000),
      ),
    );
  }

  // Navigate to detail screen
  void _showSubjectDetail(Subject subject, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailScreenComplete(
          subject: subject,
          onSubjectUpdated: (updatedSubject) {
            setState(() {
              userData!.subjects[index] = updatedSubject;
            });
            _saveUserData();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: isTablet ? 4 : 3,
              ),
              SizedBox(height: sh * 0.03),
              Text(
                'Loading your data...',
                style: AppTextStyles.medium(
                  context,
                  isTablet ? 18 : 16,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, sw, sh, isTablet),
      body: userData!.subjects.isEmpty
          ? _buildEmptyState(context, sw, sh, isTablet)
          : _buildSubjectsList(context, sw, sh, isTablet),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: _addSubject,
          backgroundColor: AppColors.secondary,
          elevation: isTablet ? 12 : 8,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: isTablet ? sw * 0.045 : sw * 0.065,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, double sw, double sh, bool isTablet) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: isTablet ? sh * 0.1 : sh * 0.08,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
      ),
      title: Container(
        padding: EdgeInsets.symmetric(vertical: sh * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${userData!.nickname}! 👋',
              style: AppTextStyles.medium(
                context,
                isTablet ? 22 : 18,
                Colors.white,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              userData!.collegeName,
              style: AppTextStyles.regular(
                context,
                isTablet ? 14 : 12,
                Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: sw * 0.02,
            vertical: sh * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.analytics,
              color: Colors.white,
              size: isTablet ? sw * 0.04 : sw * 0.055,
            ),
            onPressed: () {
              // Analytics functionality can be added here
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, double sw, double sh, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.05,
          vertical: sh * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? sw * 0.2 : sw * 0.35,
              height: isTablet ? sw * 0.2 : sw * 0.35,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.05 : sw * 0.08),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.book,
                size: isTablet ? sw * 0.1 : sw * 0.18,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: sh * 0.04),
            Text(
              'No Subjects Added Yet',
              style: AppTextStyles.bold(
                context,
                isTablet ? 28 : 24,
                AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.015),
            Container(
              width: isTablet ? sw * 0.7 : sw * 0.9,
              child: Text(
                'Add your subjects to start tracking attendance and never miss your target percentage!',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(
                  context,
                  isTablet ? 18 : 16,
                  AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: sh * 0.05),
            Container(
              width: isTablet ? sw * 0.4 : sw * 0.7,
              height: isTablet ? sh * 0.08 : sh * 0.07,
              constraints: BoxConstraints(
                minHeight: isTablet ? 65 : 55,
                maxHeight: isTablet ? 75 : 65,
              ),
              child: ElevatedButton.icon(
                onPressed: _addSubject,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
                label: Text(
                  'Add Your First Subject',
                  style: AppTextStyles.medium(
                    context,
                    isTablet ? 18 : 16,
                    Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
                  ),
                  elevation: isTablet ? 12 : 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.06,
                    vertical: sh * 0.02,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList(
      BuildContext context, double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.02,
          ),
          itemCount: userData!.subjects.length,
          itemBuilder: (context, index) {
            Subject subject = userData!.subjects[index];

            final animation = Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _listAnimationController,
              curve: Interval(
                (index / userData!.subjects.length) * 0.5,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            ));

            return SlideTransition(
              position: animation,
              child:
                  _buildEnhancedSubjectCard(subject, index, sw, sh, isTablet),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedSubjectCard(
      Subject subject, int index, double sw, double sh, bool isTablet) {
    return GestureDetector(
      onTap: () => _showSubjectDetail(subject, index),
      child: Container(
        margin: EdgeInsets.only(bottom: sh * 0.02),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isTablet ? 20 : 15,
              offset: Offset(0, isTablet ? 6 : 4),
              spreadRadius: isTablet ? 1 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Name
                    Text(
                      subject.name,
                      style: AppTextStyles.bold(
                        context,
                        isTablet ? 22 : 18,
                        AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),

                    // Attendance Count
                    Text(
                      '${subject.attendedLectures}/${subject.totalLectures} lectures',
                      style: AppTextStyles.regular(
                        context,
                        isTablet ? 16 : 14,
                        AppColors.textSecondary,
                      ),
                    ),

                    // Last Attended Date (NEW)
                    if (subject.attendanceHistory.isNotEmpty) ...[
                      SizedBox(height: sh * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: isTablet ? 16 : 14,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            'Last: ${DateFormat('MMM dd, HH:mm').format(subject.attendanceHistory.last.date)}',
                            style: AppTextStyles.regular(
                              context,
                              isTablet ? 14 : 12,
                              AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: sh * 0.015),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                      child: LinearProgressIndicator(
                        value: subject.percentage / 100,
                        minHeight: isTablet ? sh * 0.012 : sh * 0.01,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          subject.percentage >= 75
                              ? AppColors.success
                              : subject.percentage >= 50
                                  ? AppColors.warning
                                  : AppColors.accent,
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.008),

                    // Percentage and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${subject.percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.medium(
                            context,
                            isTablet ? 18 : 16,
                            subject.percentage >= 75
                                ? AppColors.success
                                : subject.percentage >= 50
                                    ? AppColors.warning
                                    : AppColors.accent,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? sw * 0.025 : sw * 0.02,
                            vertical: isTablet ? sh * 0.008 : sh * 0.006,
                          ),
                          decoration: BoxDecoration(
                            color: subject.percentage >= 75
                                ? AppColors.success.withOpacity(0.1)
                                : subject.percentage >= 50
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.accent.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 15 : 12),
                          ),
                          child: Text(
                            subject.percentage >= 75
                                ? 'Excellent'
                                : subject.percentage >= 50
                                    ? 'Good'
                                    : 'Needs Attention',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? 14 : 12,
                              subject.percentage >= 75
                                  ? AppColors.success
                                  : subject.percentage >= 50
                                      ? AppColors.warning
                                      : AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Streak Display (NEW)
                    if (subject.getCurrentStreak() > 1) ...[
                      SizedBox(height: sh * 0.01),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: isTablet ? 16 : 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            '${subject.getCurrentStreak()} day streak!',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? 14 : 12,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: sw * 0.04),

              // Attendance Button and Menu
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _incrementAttendance(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: isTablet ? sw * 0.12 : sw * 0.15,
                      height: isTablet ? sw * 0.12 : sw * 0.15,
                      decoration: BoxDecoration(
                        color: subject.attendedLectures < subject.totalLectures
                            ? AppColors.primary
                            : AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (subject.attendedLectures <
                                        subject.totalLectures
                                    ? AppColors.primary
                                    : AppColors.success)
                                .withOpacity(0.3),
                            blurRadius: isTablet ? 12 : 10,
                            offset: Offset(0, isTablet ? 6 : 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        subject.attendedLectures >= subject.totalLectures
                            ? Icons.celebration
                            : Icons.add,
                        color: Colors.white,
                        size: isTablet ? sw * 0.06 : sw * 0.08,
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.015),

                  // Menu Button
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSubjectAction(value, index),
                    icon: Container(
                      padding: EdgeInsets.all(isTablet ? 8 : 6),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: isTablet ? sw * 0.035 : sw * 0.045,
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: AppColors.warning, size: 20),
                            SizedBox(width: 10),
                            Text('Edit Subject'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reset',
                        child: Row(
                          children: [
                            Icon(Icons.refresh,
                                color: AppColors.warning, size: 20),
                            SizedBox(width: 10),
                            Text('Reset Attendance'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: AppColors.accent, size: 20),
                            SizedBox(width: 10),
                            Text('Delete Subject'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubjectAction(String action, int index) {
    switch (action) {
      case 'detail':
        _showSubjectDetail(userData!.subjects[index], index);
        break;
      case 'edit':
        _editSubject(index);
        break;
      case 'reset':
        _resetAttendance(index);
        break;
      case 'delete':
        _deleteSubject(index);
        break;
    }
  }

  void _editSubject(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: animation1.value,
          child: Opacity(
            opacity: animation1.value,
            child: EditSubjectDialog(
              subject: userData!.subjects[index],
              onSubjectUpdated: (updatedSubject) {
                setState(() {
                  userData!.subjects[index] = updatedSubject;
                });
                _saveUserData();
              },
            ),
          ),
        );
      },
    );
  }

  void _resetAttendance(int index) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? sw * 0.04 : sw * 0.05),
        ),
        contentPadding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
        titlePadding: EdgeInsets.fromLTRB(
          isTablet ? sw * 0.04 : sw * 0.05,
          isTablet ? sh * 0.025 : sh * 0.02,
          isTablet ? sw * 0.04 : sw * 0.05,
          sh * 0.01,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          isTablet ? sw * 0.04 : sw * 0.05,
          0,
          isTablet ? sw * 0.04 : sw * 0.05,
          isTablet ? sh * 0.02 : sh * 0.015,
        ),
        title: Row(
          children: [
            Container(
              width: isTablet ? sw * 0.08 : sw * 0.1,
              height: isTablet ? sw * 0.08 : sw * 0.1,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.025),
              ),
              child: Icon(
                Icons.refresh,
                color: AppColors.warning,
                size: isTablet ? sw * 0.04 : sw * 0.05,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                'Reset Attendance',
                style: AppTextStyles.bold(
                  context,
                  isTablet ? 22 : 20,
                  AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: isTablet ? sw * 0.6 : sw * 0.8,
          constraints: BoxConstraints(
            maxHeight: sh * 0.3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to reset attendance for',
                style: AppTextStyles.regular(
                  context,
                  isTablet ? 18 : 16,
                  AppColors.textSecondary,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sh * 0.01,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.025),
                ),
                child: Text(
                  userData!.subjects[index].name,
                  style: AppTextStyles.bold(
                    context,
                    isTablet ? 18 : 16,
                    AppColors.warning,
                  ),
                ),
              ),
              SizedBox(height: sh * 0.015),
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.025),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                      child: Text(
                        'This will clear all ${userData!.subjects[index].attendanceHistory.length} attendance records.',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? 14 : 12,
                          AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: isTablet ? sh * 0.065 : sh * 0.06,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isTablet ? sw * 0.025 : sw * 0.03),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.015,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? 18 : 16,
                          AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Container(
                    height: isTablet ? sh * 0.065 : sh * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          userData!.subjects[index].attendanceHistory.clear();
                        });
                        _saveUserData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                                SizedBox(width: sw * 0.02),
                                Expanded(
                                  child: Text(
                                    'Attendance reset successfully',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.025 : sw * 0.03),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: sw * 0.04,
                              vertical: sh * 0.02,
                            ),
                            duration: Duration(milliseconds: 2000),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isTablet ? sw * 0.025 : sw * 0.03),
                        ),
                        elevation: isTablet ? 6 : 4,
                        shadowColor: AppColors.warning.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.015,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: isTablet ? 20 : 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: sw * 0.02),
                          Text(
                            'Reset',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? 18 : 16,
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(int index) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? sw * 0.04 : sw * 0.05),
        ),
        title: Row(
          children: [
            Container(
              width: isTablet ? sw * 0.08 : sw * 0.1,
              height: isTablet ? sw * 0.08 : sw * 0.1,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.025),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.accent,
                size: isTablet ? sw * 0.04 : sw * 0.05,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                'Delete Subject',
                style: AppTextStyles.bold(
                  context,
                  isTablet ? 20 : 18,
                  AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete ${userData!.subjects[index].name}?',
              style: AppTextStyles.regular(
                context,
                isTablet ? 16 : 14,
                AppColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.015),
            Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.025),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.accent,
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: sw * 0.02),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All attendance data will be lost.',
                      style: AppTextStyles.medium(
                        context,
                        isTablet ? 14 : 12,
                        AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium(
                context,
                isTablet ? 16 : 14,
                AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData!.subjects.removeAt(index);
              });
              _saveUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.white, size: 20),
                      SizedBox(width: sw * 0.02),
                      Text('Subject deleted successfully'),
                    ],
                  ),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.medium(
                context,
                isTablet ? 16 : 14,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Subject Detail Screen (Simple version - you can expand this)

Widget _buildStatCard(String title, String value, Color color, IconData icon,
    double sw, bool isTablet) {
  return Container(
    padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.04),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
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
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          ),
          child: Icon(
            icon,
            color: color,
            size: isTablet ? 28 : 24,
          ),
        ),
        SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
