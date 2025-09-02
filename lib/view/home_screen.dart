// Updated Home Screen with Better Responsiveness and Enhanced Add Subject Button
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
import 'package:attendance_tracker/widgets/attendance_marking_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  UserData? userData;
  bool isLoading = true;
  bool isRefreshing = false;
  DateTime? lastRefreshTime;
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
      Future.delayed(Duration(milliseconds: 3000), () {
        _fabAnimationController.forward();
      });
    } else {
      // No stored user data — stop loading so UI can handle empty state.
      // If you prefer to create a default UserData instance here, you can do that.
      setState(() {
        isLoading = false;
      });
      _fabAnimationController.forward();
    }
  }

  _saveUserData() async {
    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData!.toJson()));
    }
  }

  _refreshData() async {
    // Check if refresh was done recently (within 5 seconds)
    if (lastRefreshTime != null &&
        DateTime.now().difference(lastRefreshTime!).inSeconds < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait before refreshing again'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isRefreshing = true;
    });

    // Show refreshing toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Refreshing data...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Simulate refresh delay and reload data from storage
      await Future.delayed(Duration(milliseconds: 1500));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        setState(() {
          userData = UserData.fromJson(jsonDecode(userDataString));
        });

        // Reset and replay list animation
        _listAnimationController.reset();
        _listAnimationController.forward();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Data refreshed successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Failed to refresh data'),
            ],
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isRefreshing = false;
      });
      lastRefreshTime = DateTime.now();
    }
  }

  _addSubject() {
    if (userData != null && userData!.subjects.length >= 10) {
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

  // Handle attendance marking from the new widget
  void _onAttendanceMarked(Subject updatedSubject, int index) {
    setState(() {
      userData!.subjects[index] = updatedSubject;
    });
    _saveUserData();
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
                  isTablet ? sw * 0.045 : sw * 0.04,
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
      body: (userData == null || userData!.subjects.isEmpty)
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
              'Hello, ${userData?.nickname ?? 'Student'}! 👋',
              style: AppTextStyles.medium(
                context,
                isTablet ? sw * 0.055 : sw * 0.045,
                Colors.white,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              userData?.collegeName ?? '',
              style: AppTextStyles.regular(
                context,
                isTablet ? sw * 0.035 : sw * 0.03,
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
            borderRadius:
                BorderRadius.circular(isTablet ? sw * 0.03 : sw * 0.025),
          ),
          child: IconButton(
            icon: isRefreshing
                ? SizedBox(
                    width: isTablet ? sw * 0.04 : sw * 0.055,
                    height: isTablet ? sw * 0.04 : sw * 0.055,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: isTablet ? sw * 0.04 : sw * 0.055,
                  ),
            onPressed: isRefreshing ? null : _refreshData,
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
          horizontal: sw * 0.08,
          vertical: sh * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration/Icon Container
            Container(
              width: isTablet ? sw * 0.3 : sw * 0.4,
              height: isTablet ? sw * 0.3 : sw * 0.4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: isTablet ? 30 : 20,
                    offset: Offset(0, isTablet ? 10 : 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                size: isTablet ? sw * 0.15 : sw * 0.2,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: sh * 0.05),

            // Title
            Text(
              'Start Your Journey',
              style: AppTextStyles.bold(
                context,
                isTablet ? sw * 0.07 : sw * 0.06,
                AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: sh * 0.015),

            // Subtitle
            Text(
              'Add your first subject to begin tracking your attendance and academic progress.',
              style: AppTextStyles.regular(
                context,
                isTablet ? sw * 0.04 : sw * 0.035,
                AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

            SizedBox(height: sh * 0.06),

            // Enhanced Add Subject Button
            Container(
              width: isTablet ? sw * 0.5 : sw * 0.7,
              height: isTablet ? sh * 0.08 : sh * 0.07,
              child: ElevatedButton(
                onPressed: _addSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.045 : sw * 0.04),
                  ),
                  elevation: isTablet ? 12 : 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.01 : sw * 0.008),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            isTablet ? sw * 0.02 : sw * 0.015),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: isTablet ? sw * 0.05 : sw * 0.045,
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Text(
                      'Add Your First Subject',
                      style: AppTextStyles.medium(
                        context,
                        isTablet ? sw * 0.045 : sw * 0.04,
                        Colors.white,
                      ),
                    ),
                  ],
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
          borderRadius: BorderRadius.circular(isTablet ? sw * 0.05 : sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isTablet ? sw * 0.05 : sw * 0.04,
              offset: Offset(0, isTablet ? sw * 0.015 : sw * 0.01),
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
                        isTablet ? sw * 0.055 : sw * 0.045,
                        AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),

                    // Attendance Count - RESPONSIVE
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                isTablet ? sw * 0.02 : sw * 0.015),
                          ),
                          child: Text(
                            '${subject.attendedLectures}',
                            style: AppTextStyles.bold(
                              context,
                              isTablet ? sw * 0.04 : sw * 0.035,
                              AppColors.success,
                            ),
                          ),
                        ),
                        Text(
                          ' / ',
                          style: AppTextStyles.regular(
                            context,
                            isTablet ? sw * 0.04 : sw * 0.035,
                            AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                isTablet ? sw * 0.02 : sw * 0.015),
                          ),
                          child: Text(
                            '${subject.totalLectures}',
                            style: AppTextStyles.bold(
                              context,
                              isTablet ? sw * 0.04 : sw * 0.035,
                              AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Text(
                          'lectures',
                          style: AppTextStyles.regular(
                            context,
                            isTablet ? sw * 0.04 : sw * 0.035,
                            AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Last Activity (RESPONSIVE)
                    if (subject.attendanceHistory.isNotEmpty) ...[
                      SizedBox(height: sh * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: isTablet ? sw * 0.04 : sw * 0.035,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            'Last: ${DateFormat('MMM dd, HH:mm').format(subject.attendanceHistory.first.markedAt)}',
                            style: AppTextStyles.regular(
                              context,
                              isTablet ? sw * 0.035 : sw * 0.03,
                              AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: sh * 0.015),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          isTablet ? sw * 0.03 : sw * 0.025),
                      child: LinearProgressIndicator(
                        value: subject.totalLectures > 0
                            ? subject.percentage / 100
                            : 0,
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
                          subject.totalLectures > 0
                              ? '${subject.percentage.toStringAsFixed(1)}%'
                              : 'No data',
                          style: AppTextStyles.medium(
                            context,
                            isTablet ? sw * 0.045 : sw * 0.04,
                            subject.totalLectures > 0
                                ? (subject.percentage >= 75
                                    ? AppColors.success
                                    : subject.percentage >= 50
                                        ? AppColors.warning
                                        : AppColors.accent)
                                : AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? sw * 0.025 : sw * 0.02,
                            vertical: isTablet ? sh * 0.008 : sh * 0.006,
                          ),
                          decoration: BoxDecoration(
                            color: subject.totalLectures > 0
                                ? (subject.percentage >= 75
                                    ? AppColors.success.withOpacity(0.1)
                                    : subject.percentage >= 50
                                        ? AppColors.warning.withOpacity(0.1)
                                        : AppColors.accent.withOpacity(0.1))
                                : AppColors.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                isTablet ? sw * 0.0375 : sw * 0.03),
                          ),
                          child: Text(
                            subject.totalLectures > 0
                                ? (subject.percentage >= 75
                                    ? 'Excellent'
                                    : subject.percentage >= 50
                                        ? 'Good'
                                        : 'Needs Attention')
                                : 'Getting Started',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? sw * 0.035 : sw * 0.03,
                              subject.totalLectures > 0
                                  ? (subject.percentage >= 75
                                      ? AppColors.success
                                      : subject.percentage >= 50
                                          ? AppColors.warning
                                          : AppColors.accent)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Streak Display (if applicable)
                    if (subject.getCurrentStreak() > 1) ...[
                      SizedBox(height: sh * 0.01),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: isTablet ? sw * 0.04 : sw * 0.035,
                            color: Colors.orange,
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            '${subject.getCurrentStreak()} day streak!',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? sw * 0.035 : sw * 0.03,
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
                  // NEW: Use the enhanced attendance marking widget
                  AttendanceMarkingWidget(
                    subject: subject,
                    onAttendanceMarked: (updatedSubject) =>
                        _onAttendanceMarked(updatedSubject, index),
                    index: index,
                  ),

                  SizedBox(height: sh * 0.015),

                  // Menu Button
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSubjectAction(value, index),
                    icon: Container(
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.015),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            isTablet ? sw * 0.02 : sw * 0.015),
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
                                color: AppColors.primary, size: sw * 0.05),
                            SizedBox(width: sw * 0.025),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: AppColors.warning, size: sw * 0.05),
                            SizedBox(width: sw * 0.025),
                            Text('Edit Subject'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reset',
                        child: Row(
                          children: [
                            Icon(Icons.refresh,
                                color: AppColors.warning, size: sw * 0.05),
                            SizedBox(width: sw * 0.025),
                            Text('Reset Attendance'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: AppColors.accent, size: sw * 0.05),
                            SizedBox(width: sw * 0.025),
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
                  isTablet ? sw * 0.055 : sw * 0.05,
                  AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will reset all attendance data for ${userData!.subjects[index].name}. This action cannot be undone.',
          style: AppTextStyles.regular(
            context,
            isTablet ? sw * 0.04 : sw * 0.035,
            AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium(
                context,
                isTablet ? sw * 0.04 : sw * 0.035,
                AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData!.subjects[index] = Subject(
                  name: userData!.subjects[index].name,
                  description: userData!.subjects[index].description,
                  targetPercentage: userData!.subjects[index].targetPercentage,
                  createdDate: userData!.subjects[index].createdDate,
                );
              });
              _saveUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.white, size: sw * 0.05),
                      SizedBox(width: sw * 0.02),
                      Text('Attendance reset successfully'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.03 : sw * 0.02),
              ),
            ),
            child: Text(
              'Reset',
              style: AppTextStyles.medium(
                context,
                isTablet ? sw * 0.04 : sw * 0.035,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(int index) {
    double sw = ResponsiveHelper.getWidth(context);
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
                  isTablet ? sw * 0.05 : sw * 0.045,
                  AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete ${userData!.subjects[index].name}? This action cannot be undone.',
          style: AppTextStyles.regular(
            context,
            isTablet ? sw * 0.04 : sw * 0.035,
            AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium(
                context,
                isTablet ? sw * 0.04 : sw * 0.035,
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
                      Icon(Icons.delete_forever,
                          color: Colors.white, size: sw * 0.05),
                      SizedBox(width: sw * 0.02),
                      Text('Subject deleted successfully'),
                    ],
                  ),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.03 : sw * 0.02),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.medium(
                context,
                isTablet ? sw * 0.04 : sw * 0.035,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
