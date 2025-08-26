import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttendanceMarkingWidget extends StatefulWidget {
  final Subject subject;
  final Function(Subject) onAttendanceMarked;
  final int index;

  AttendanceMarkingWidget({
    required this.subject,
    required this.onAttendanceMarked,
    required this.index,
  });

  @override
  _AttendanceMarkingWidgetState createState() =>
      _AttendanceMarkingWidgetState();
}

class _AttendanceMarkingWidgetState extends State<AttendanceMarkingWidget>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _AttendanceDialog(
          subject: widget.subject,
          onAttendanceMarked: widget.onAttendanceMarked,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: _showAttendanceDialog,
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: isTablet ? sw * 0.12 : sw * 0.15,
          height: isTablet ? sw * 0.12 : sw * 0.15,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: isTablet ? sw * 0.015 : sw * 0.025,
                offset: Offset(0, isTablet ? sh * 0.007 : sh * 0.005),
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: isTablet ? sw * 0.06 : sw * 0.08,
          ),
        ),
      ),
    );
  }
}

class _AttendanceDialog extends StatefulWidget {
  final Subject subject;
  final Function(Subject) onAttendanceMarked;

  const _AttendanceDialog({
    required this.subject,
    required this.onAttendanceMarked,
  });

  @override
  __AttendanceDialogState createState() => __AttendanceDialogState();
}

class __AttendanceDialogState extends State<_AttendanceDialog>
    with TickerProviderStateMixin {
  int selectedLectureCount = 1;
  late AnimationController _dialogAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _dialogAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _dialogAnimationController, curve: Curves.easeOut),
    );
    _dialogAnimationController.forward();
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    super.dispose();
  }

  void _markAttendance(bool isPresent) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Update the subject
    Subject updatedSubject = Subject(
      name: widget.subject.name,
      attendedLectures: widget.subject.attendedLectures +
          (isPresent ? selectedLectureCount : 0),
      totalLectures: widget.subject.totalLectures + selectedLectureCount,
      description: widget.subject.description,
      targetPercentage: widget.subject.targetPercentage,
      attendanceHistory: List.from(widget.subject.attendanceHistory),
      createdDate: widget.subject.createdDate,
    );

    // Add to attendance history
    DateTime now = DateTime.now();
    for (int i = 0; i < selectedLectureCount; i++) {
      updatedSubject.attendanceHistory.add(AttendanceRecord(
        subjectName: widget.subject.name,
        date: now,
        markedAt: now,
        isPresent: isPresent,
        lectureNumber: widget.subject.totalLectures + i + 1,
      ));
    }

    // Close dialog
    Navigator.pop(context);

    // Call callback
    widget.onAttendanceMarked(updatedSubject);

    // Show success message
    _showSuccessSnackBar(isPresent, selectedLectureCount, updatedSubject);
  }

  void _showSuccessSnackBar(bool isPresent, int count, Subject subject) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    String actionText = isPresent ? 'Present' : 'Skipped';
    String lectureText = count == 1 ? 'lecture' : 'lectures';
    Color backgroundColor = isPresent ? AppColors.success : AppColors.accent;
    IconData icon = isPresent ? Icons.check_circle : Icons.cancel;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$actionText: $count $lectureText',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    ),
                  ),
                  Text(
                    '${subject.attendedLectures}/${subject.totalLectures} • ${subject.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.03),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.02,
        ),
        duration: Duration(milliseconds: 3000),
      ),
    );
  }

  Widget _buildPreview(bool isTablet, double sw, double sh) {
    int currentAttended = widget.subject.attendedLectures;
    int currentTotal = widget.subject.totalLectures;

    // Calculate what will happen after marking
    int newTotal = currentTotal + selectedLectureCount;
    int newAttendedIfPresent = currentAttended + selectedLectureCount;
    int newAttendedIfSkip = currentAttended;

    double newPercentageIfPresent =
        newTotal > 0 ? (newAttendedIfPresent / newTotal) * 100 : 0;
    double newPercentageIfSkip =
        newTotal > 0 ? (newAttendedIfSkip / newTotal) * 100 : 0;

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.03),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: sw * 0.0025,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppColors.textSecondary,
                size: isTablet ? sw * 0.035 : sw * 0.038,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Preview Changes',
                style: AppTextStyles.medium(
                  context,
                  isTablet ? sw * 0.03 : sw * 0.032,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.01),
          Row(
            children: [
              // Present Preview
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.015 : sw * 0.02),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'If Present',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? sw * 0.028 : sw * 0.028,
                          AppColors.success,
                        ),
                      ),
                      Text(
                        '$newAttendedIfPresent/$newTotal',
                        style: AppTextStyles.bold(
                          context,
                          isTablet ? sw * 0.032 : sw * 0.034,
                          AppColors.success,
                        ),
                      ),
                      Text(
                        '${newPercentageIfPresent.toStringAsFixed(1)}%',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? sw * 0.028 : sw * 0.028,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: sw * 0.02),

              // Skip Preview
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.015 : sw * 0.02),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'If Skip',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? sw * 0.028 : sw * 0.028,
                          AppColors.accent,
                        ),
                      ),
                      Text(
                        '$newAttendedIfSkip/$newTotal',
                        style: AppTextStyles.bold(
                          context,
                          isTablet ? sw * 0.032 : sw * 0.034,
                          AppColors.accent,
                        ),
                      ),
                      Text(
                        '${newPercentageIfSkip.toStringAsFixed(1)}%',
                        style: AppTextStyles.medium(
                          context,
                          isTablet ? sw * 0.028 : sw * 0.028,
                          AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: isTablet ? sw * 0.5 : sw * 0.9,
          constraints: BoxConstraints(
            maxWidth: isTablet ? sw * 0.5 : double.infinity,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius:
                BorderRadius.circular(isTablet ? sw * 0.03 : sw * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: sw * 0.05,
                offset: Offset(0, sh * 0.012),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? sw * 0.03 : sw * 0.05),
                    topRight: Radius.circular(isTablet ? sw * 0.03 : sw * 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            isTablet ? sw * 0.02 : sw * 0.03),
                      ),
                      child: Icon(
                        Icons.how_to_reg,
                        color: Colors.white,
                        size: isTablet ? sw * 0.04 : sw * 0.055,
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark Attendance',
                            style: AppTextStyles.bold(
                              context,
                              isTablet ? sw * 0.045 : sw * 0.048,
                              Colors.white,
                            ),
                          ),
                          Text(
                            widget.subject.name,
                            style: AppTextStyles.regular(
                              context,
                              isTablet ? sw * 0.03 : sw * 0.032,
                              Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:
                            EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.015),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              isTablet ? sw * 0.015 : sw * 0.02),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: isTablet ? sw * 0.045 : sw * 0.045,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                child: Column(
                  children: [
                    // Current Status
                    Container(
                      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            isTablet ? sw * 0.02 : sw * 0.03),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: sw * 0.0025,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Status',
                                style: AppTextStyles.medium(
                                  context,
                                  isTablet ? sw * 0.03 : sw * 0.032,
                                  AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${widget.subject.attendedLectures}/${widget.subject.totalLectures}',
                                style: AppTextStyles.bold(
                                  context,
                                  isTablet ? sw * 0.045 : sw * 0.048,
                                  AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.03,
                              vertical: sh * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: widget.subject.percentage >= 75
                                  ? AppColors.success
                                  : widget.subject.percentage >= 50
                                      ? AppColors.warning
                                      : AppColors.accent,
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.015 : sw * 0.025),
                            ),
                            child: Text(
                              '${widget.subject.percentage.toStringAsFixed(1)}%',
                              style: AppTextStyles.bold(
                                context,
                                isTablet ? sw * 0.035 : sw * 0.038,
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.025),

                    // Lecture Count Selector
                    Text(
                      'How many lectures?',
                      style: AppTextStyles.bold(
                        context,
                        isTablet ? sw * 0.04 : sw * 0.042,
                        AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: sh * 0.015),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        int count = index + 1;
                        bool isSelected = selectedLectureCount == count;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLectureCount = count;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: isTablet ? sw * 0.11 : sw * 0.12,
                            height: isTablet ? sw * 0.11 : sw * 0.12,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.015 : sw * 0.025),
                              border: Border.all(
                                color: AppColors.primary,
                                width: isSelected ? sw * 0.005 : sw * 0.0025,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        blurRadius: sw * 0.02,
                                        offset: Offset(0, sh * 0.005),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                count.toString(),
                                style: AppTextStyles.bold(
                                  context,
                                  isTablet ? sw * 0.04 : sw * 0.042,
                                  isSelected ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: sh * 0.03),

                    // Action Buttons
                    Row(
                      children: [
                        // Skip Button
                        Expanded(
                          child: Container(
                            height: isTablet ? sh * 0.08 : sh * 0.07,
                            child: ElevatedButton(
                              onPressed: () => _markAttendance(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      isTablet ? sw * 0.02 : sw * 0.03),
                                ),
                                elevation: isTablet ? sw * 0.01 : sw * 0.015,
                                shadowColor: AppColors.accent.withOpacity(0.4),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    size: isTablet ? sw * 0.045 : sw * 0.045,
                                  ),
                                  Text(
                                    'Skip',
                                    style: AppTextStyles.medium(
                                      context,
                                      isTablet ? sw * 0.035 : sw * 0.038,
                                      Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: sw * 0.04),

                        // Present Button
                        Expanded(
                          child: Container(
                            height: isTablet ? sh * 0.08 : sh * 0.07,
                            child: ElevatedButton(
                              onPressed: () => _markAttendance(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      isTablet ? sw * 0.02 : sw * 0.03),
                                ),
                                elevation: isTablet ? sw * 0.01 : sw * 0.015,
                                shadowColor: AppColors.success.withOpacity(0.4),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: isTablet ? sw * 0.045 : sw * 0.045,
                                  ),
                                  Text(
                                    'Present',
                                    style: AppTextStyles.medium(
                                      context,
                                      isTablet ? sw * 0.035 : sw * 0.038,
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

                    SizedBox(height: sh * 0.02),

                    // Preview
                    _buildPreview(isTablet, sw, sh),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
