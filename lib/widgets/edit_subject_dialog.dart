// Edit Subject Dialog - Updated for New Subject Model
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditSubjectDialog extends StatefulWidget {
  final Subject subject;
  final Function(Subject) onSubjectUpdated;

  EditSubjectDialog({required this.subject, required this.onSubjectUpdated});

  @override
  _EditSubjectDialogState createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lecturesController;
  late Subject _editingSubject;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Create a copy of the subject for editing
    _editingSubject = Subject(
      name: widget.subject.name,
      totalLectures: widget.subject.totalLectures,
      attendanceHistory: List.from(widget.subject.attendanceHistory),
      createdDate: widget.subject.createdDate,
      description: widget.subject.description,
      targetPercentage: widget.subject.targetPercentage,
    );

    _nameController = TextEditingController(text: _editingSubject.name);
    _lecturesController =
        TextEditingController(text: _editingSubject.totalLectures.toString());

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lecturesController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  _updateSubject() async {
    if (_formKey.currentState!.validate()) {
      int newTotalLectures = int.parse(_lecturesController.text);
      int currentAttended = _editingSubject.attendedLectures;

      // Check if new total is less than current attended
      if (newTotalLectures < currentAttended) {
        _showTotalLecturesWarning(newTotalLectures, currentAttended);
        return;
      }

      await _slideController.reverse();

      // Update the subject
      _editingSubject.name = _nameController.text;
      _editingSubject.totalLectures = newTotalLectures;

      widget.onSubjectUpdated(_editingSubject);
      Navigator.pop(context);
    }
  }

  void _showTotalLecturesWarning(int newTotal, int currentAttended) {
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
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.accent,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                'Invalid Total',
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
              'Total lectures ($newTotal) cannot be less than already attended lectures ($currentAttended).',
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
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              child: Text(
                'Suggestion: Set total to at least $currentAttended or reset attendance first.',
                style: AppTextStyles.medium(
                  context,
                  isTablet ? 14 : 12,
                  AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.medium(
                context,
                isTablet ? 16 : 14,
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeAttendanceRecord(int index) {
    setState(() {
      _editingSubject.attendanceHistory.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double sw = ResponsiveHelper.getWidth(context);
    double sh = ResponsiveHelper.getHeight(context);
    bool isTablet = ResponsiveHelper.isTablet(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Container(
              width: isTablet ? sw * 0.7 : sw * 0.9,
              constraints: BoxConstraints(
                maxHeight: sh * 0.85,
                minHeight: sh * 0.5,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.04 : sw * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: isTablet ? 25 : 20,
                    offset: Offset(0, isTablet ? 15 : 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            width: isTablet ? sw * 0.08 : sw * 0.12,
                            height: isTablet ? sw * 0.08 : sw * 0.12,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.02 : sw * 0.03),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: AppColors.warning,
                              size: isTablet ? sw * 0.04 : sw * 0.06,
                            ),
                          ),
                          SizedBox(width: sw * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Subject',
                                  style: AppTextStyles.bold(
                                    context,
                                    isTablet ? 24 : 20,
                                    AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_editingSubject.attendedLectures} attendance records',
                                  style: AppTextStyles.regular(
                                    context,
                                    isTablet ? 14 : 12,
                                    AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.03),

                      // Form Fields
                      _buildEditTextField(
                        context: context,
                        controller: _nameController,
                        label: 'Subject Name',
                        hint: 'e.g., Mathematics, Physics',
                        icon: Icons.book,
                        sw: sw,
                        sh: sh,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: sh * 0.025),

                      _buildEditTextField(
                        context: context,
                        controller: _lecturesController,
                        label: 'Total Lectures',
                        hint: 'e.g., 60, 80',
                        icon: Icons.schedule,
                        isNumber: true,
                        sw: sw,
                        sh: sh,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: sh * 0.025),

                      // Current Stats
                      Container(
                        padding:
                            EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(isTablet ? 15 : 12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Statistics',
                                  style: AppTextStyles.medium(
                                    context,
                                    isTablet ? 16 : 14,
                                    AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '${_editingSubject.percentage.toStringAsFixed(1)}%',
                                  style: AppTextStyles.bold(
                                    context,
                                    isTablet ? 16 : 14,
                                    AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sh * 0.01),
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.success, size: 16),
                                SizedBox(width: sw * 0.02),
                                Text(
                                  'Attended: ${_editingSubject.attendedLectures}',
                                  style: AppTextStyles.regular(
                                    context,
                                    isTablet ? 14 : 12,
                                    AppColors.textSecondary,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.school,
                                    color: AppColors.primary, size: 16),
                                SizedBox(width: sw * 0.02),
                                Text(
                                  'Total: ${_editingSubject.totalLectures}',
                                  style: AppTextStyles.regular(
                                    context,
                                    isTablet ? 14 : 12,
                                    AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Recent Attendance Records (if any)
                      if (_editingSubject.attendanceHistory.isNotEmpty) ...[
                        SizedBox(height: sh * 0.025),
                        Text(
                          'Recent Attendance',
                          style: AppTextStyles.medium(
                            context,
                            isTablet ? 16 : 14,
                            AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: sh * 0.015),
                        Container(
                          constraints: BoxConstraints(maxHeight: sh * 0.15),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _editingSubject.attendanceHistory.length
                                .clamp(0, 3),
                            itemBuilder: (context, index) {
                              AttendanceRecord record = _editingSubject
                                  .attendanceHistory.reversed
                                  .toList()[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: sh * 0.01),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.03,
                                  vertical: sh * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: AppColors.success,
                                      size: 8,
                                    ),
                                    SizedBox(width: sw * 0.02),
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM dd, HH:mm')
                                            .format(record.date),
                                        style: AppTextStyles.regular(
                                          context,
                                          isTablet ? 14 : 12,
                                          AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeAttendanceRecord(
                                          _editingSubject
                                                  .attendanceHistory.length -
                                              1 -
                                              index),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.accent.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.accent,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (_editingSubject.attendanceHistory.length > 3)
                          Text(
                            '... and ${_editingSubject.attendanceHistory.length - 3} more records',
                            style: AppTextStyles.regular(
                              context,
                              isTablet ? 12 : 10,
                              AppColors.textSecondary,
                            ),
                          ),
                      ],

                      SizedBox(height: sh * 0.04),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: isTablet ? sh * 0.07 : sh * 0.065,
                              child: TextButton(
                                onPressed: () async {
                                  await _slideController.reverse();
                                  Navigator.pop(context);
                                },
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
                          SizedBox(width: sw * 0.04),
                          Expanded(
                            child: Container(
                              height: isTablet ? sh * 0.07 : sh * 0.065,
                              child: ElevatedButton(
                                onPressed: _updateSubject,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? sw * 0.025 : sw * 0.03),
                                  ),
                                  elevation: isTablet ? 10 : 8,
                                  shadowColor:
                                      AppColors.warning.withOpacity(0.3),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.04,
                                    vertical: sh * 0.015,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save,
                                      size: isTablet ? 20 : 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: sw * 0.02),
                                    Text(
                                      'Update',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required double sw,
    required double sh,
    required bool isTablet,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium(
            context,
            isTablet ? 16 : 14,
            AppColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.01),
        Container(
          height: isTablet ? sh * 0.075 : sh * 0.07,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: AppTextStyles.regular(
              context,
              isTablet ? 18 : 16,
              AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.regular(
                context,
                isTablet ? 16 : 14,
                AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.warning,
                size: isTablet ? sw * 0.035 : sw * 0.055,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.02,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
                borderSide: BorderSide(color: AppColors.warning, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
                borderSide: BorderSide(color: AppColors.accent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (isNumber) {
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) > 200) {
                  return 'Maximum 200 lectures allowed';
                }
              } else {
                if (value.length < 2) {
                  return 'Subject name must be at least 2 characters';
                }
                if (value.length > 50) {
                  return 'Subject name must be less than 50 characters';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
 