import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditSubjectDialog extends StatefulWidget {
  final Subject subject;
  final Function(Subject) onSubjectUpdated;

  EditSubjectDialog({
    required this.subject,
    required this.onSubjectUpdated,
  });

  @override
  _EditSubjectDialogState createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _attendedController;
  late TextEditingController _totalController;
  late int _targetPercentage;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _descriptionController =
        TextEditingController(text: widget.subject.description ?? '');
    _attendedController =
        TextEditingController(text: widget.subject.attendedLectures.toString());
    _totalController =
        TextEditingController(text: widget.subject.totalLectures.toString());
    _targetPercentage = widget.subject.targetPercentage;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _attendedController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateSubject() {
    if (_formKey.currentState!.validate()) {
      int newAttended = int.parse(_attendedController.text);
      int newTotal = int.parse(_totalController.text);

      // Create updated subject
      Subject updatedSubject = Subject(
        name: _nameController.text.trim(),
        attendedLectures: newAttended,
        totalLectures: newTotal,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetPercentage: _targetPercentage,
        attendanceHistory: widget.subject.attendanceHistory,
        createdDate: widget.subject.createdDate,
      );

      widget.onSubjectUpdated(updatedSubject);
      Navigator.pop(context);

      // Show success message
      // Show success message with fixed sizes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Subject updated successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
          // UPDATED: Increased the width for both mobile and tablet
          width: isTablet ? sw * 0.75 : sw * 0.95,
          constraints: BoxConstraints(
            maxHeight: sh * 0.9,
            // UPDATED: Adjusted maxWidth for tablet to accommodate the new width
            maxWidth: isTablet ? sw * 0.8 : double.infinity,
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
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
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
                            isTablet ? sw * 0.025 : sw * 0.03),
                      ),
                      child: Icon(
                        Icons.edit,
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
                            'Edit Subject',
                            style: AppTextStyles.bold(
                              context,
                              isTablet ? sw * 0.03 : sw * 0.05,
                              Colors.white,
                            ),
                          ),
                          SizedBox(height: sh * 0.005),
                          Text(
                            'Update subject details',
                            style: AppTextStyles.regular(
                              context,
                              isTablet ? sw * 0.02 : sw * 0.035,
                              Colors.white70,
                            ),
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
                              isTablet ? sw * 0.015 : sw * 0.022),
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

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Name Field
                        _buildInputLabel('Subject Name', true, isTablet, sw),
                        SizedBox(height: sh * 0.01),
                        _buildTextFormField(
                          controller: _nameController,
                          hintText: 'Enter subject name',
                          icon: Icons.subject,
                          isRequired: true,
                          isTablet: isTablet,
                          sw: sw,
                          sh: sh,
                        ),

                        SizedBox(height: sh * 0.025),

                        // Attendance Numbers Section
                        _buildInputLabel(
                            'Attendance Numbers', true, isTablet, sw),
                        SizedBox(height: sh * 0.01),

                        Row(
                          children: [
                            // Attended Lectures
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attended',
                                    style: AppTextStyles.medium(
                                      context,
                                      isTablet ? sw * 0.03 : sw * 0.032,
                                      AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: sh * 0.005),
                                  _buildNumberField(
                                    controller: _attendedController,
                                    icon: Icons.check_circle,
                                    color: AppColors.success,
                                    isTablet: isTablet,
                                    sw: sw,
                                    sh: sh,
                                    validator: (value) =>
                                        _validateAttended(value),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: sw * 0.04),

                            // Total Lectures
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: AppTextStyles.medium(
                                      context,
                                      isTablet ? sw * 0.03 : sw * 0.032,
                                      AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: sh * 0.005),
                                  _buildNumberField(
                                    controller: _totalController,
                                    icon: Icons.library_books,
                                    color: AppColors.primary,
                                    isTablet: isTablet,
                                    sw: sw,
                                    sh: sh,
                                    validator: (value) => _validateTotal(value),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: sh * 0.02),

                        // Percentage Display
                        _buildPercentageDisplay(isTablet, sw, sh),

                        SizedBox(height: sh * 0.025),

                        // Description Field (Optional)
                        _buildInputLabel(
                            'Description (Optional)', false, isTablet, sw),
                        SizedBox(height: sh * 0.01),
                        _buildTextFormField(
                          controller: _descriptionController,
                          hintText: 'Add notes about this subject',
                          icon: Icons.notes,
                          isRequired: false,
                          maxLines: 3,
                          isTablet: isTablet,
                          sw: sw,
                          sh: sh,
                        ),

                        SizedBox(height: sh * 0.025),

                        // Target Percentage
                        _buildInputLabel(
                            'Target Percentage', true, isTablet, sw),
                        SizedBox(height: sh * 0.01),
                        _buildTargetPercentageSelector(isTablet, sw, sh),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: isTablet ? sh * 0.07 : sh * 0.065,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.025 : sw * 0.03),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.medium(
                              context,
                              isTablet ? sw * 0.04 : sw * 0.042,
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
                            elevation: isTablet ? sw * 0.01 : sw * 0.015,
                            shadowColor: AppColors.warning.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save,
                                  size: isTablet ? sw * 0.045 : sw * 0.045),
                              SizedBox(width: sw * 0.02),
                              Text(
                                'Save',
                                style: AppTextStyles.medium(
                                  context,
                                  isTablet ? sw * 0.04 : sw * 0.042,
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
        ),
      ),
    );
  }

  Widget _buildInputLabel(
      String label, bool isRequired, bool isTablet, double sw) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyles.medium(
          context,
          isTablet ? sw * 0.035 : sw * 0.038,
          AppColors.textPrimary,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.accent),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isRequired,
    required bool isTablet,
    required double sw,
    required double sh,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.regular(
        context,
        isTablet ? sw * 0.035 : sw * 0.038,
        AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.regular(
          context,
          isTablet ? sw * 0.035 : sw * 0.038,
          AppColors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(left: sw * 0.03, right: sw * 0.02),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: isTablet ? sw * 0.05 : sw * 0.055,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: isTablet ? sw * 0.12 : sw * 0.12,
          minHeight: isTablet ? sw * 0.12 : sw * 0.12,
        ),
        filled: true,
        fillColor: AppColors.textSecondary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: sw * 0.0025,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: sw * 0.0025,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: sw * 0.005,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: sw * 0.0025,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: sw * 0.005,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.04 : sw * 0.04,
          vertical: isTablet ? sh * 0.02 : sh * 0.018,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required bool isTablet,
    required double sw,
    required double sh,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTextStyles.bold(
        context,
        isTablet ? sw * 0.04 : sw * 0.042,
        AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: color,
          size: isTablet ? sw * 0.045 : sw * 0.048,
        ),
        filled: true,
        fillColor: color.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
          borderSide: BorderSide(color: color, width: sw * 0.0025),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
          borderSide:
              BorderSide(color: color.withOpacity(0.5), width: sw * 0.0025),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
          borderSide: BorderSide(color: color, width: sw * 0.005),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
          borderSide: BorderSide(color: AppColors.accent, width: sw * 0.0025),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
          borderSide: BorderSide(color: AppColors.accent, width: sw * 0.005),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical: isTablet ? sh * 0.015 : sh * 0.012,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPercentageDisplay(bool isTablet, double sw, double sh) {
    int attended = int.tryParse(_attendedController.text) ?? 0;
    int total = int.tryParse(_totalController.text) ?? 0;
    double percentage = total > 0 ? (attended / total) * 100 : 0;

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            percentage >= 75
                ? AppColors.success.withOpacity(0.1)
                : percentage >= 50
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.accent.withOpacity(0.1),
            percentage >= 75
                ? AppColors.success.withOpacity(0.05)
                : percentage >= 50
                    ? AppColors.warning.withOpacity(0.05)
                    : AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
        border: Border.all(
          color: percentage >= 75
              ? AppColors.success.withOpacity(0.3)
              : percentage >= 50
                  ? AppColors.warning.withOpacity(0.3)
                  : AppColors.accent.withOpacity(0.3),
          width: sw * 0.0025,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            color: percentage >= 75
                ? AppColors.success
                : percentage >= 50
                    ? AppColors.warning
                    : AppColors.accent,
            size: isTablet ? sw * 0.055 : sw * 0.055,
          ),
          SizedBox(width: sw * 0.02),
          Text(
            'Current: ${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.bold(
              context,
              isTablet ? sw * 0.04 : sw * 0.042,
              percentage >= 75
                  ? AppColors.success
                  : percentage >= 50
                      ? AppColors.warning
                      : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetPercentageSelector(bool isTablet, double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.03),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          width: sw * 0.0025,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    color: AppColors.primary,
                    size: isTablet ? sw * 0.045 : sw * 0.048,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Target:',
                    style: AppTextStyles.medium(
                      context,
                      isTablet ? sw * 0.035 : sw * 0.038,
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: sh * 0.008,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.028),
                ),
                child: Text(
                  '$_targetPercentage%',
                  style: AppTextStyles.bold(
                    context,
                    isTablet ? sw * 0.04 : sw * 0.042,
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: isTablet ? sw * 0.025 : sw * 0.025,
              ),
              trackHeight: isTablet ? sh * 0.008 : sh * 0.006,
            ),
            child: Slider(
              value: _targetPercentage.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _targetPercentage = value.round();
                });
              },
            ),
          ),
          SizedBox(height: sh * 0.005),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '50%',
                style: AppTextStyles.regular(
                  context,
                  isTablet ? sw * 0.03 : sw * 0.032,
                  AppColors.textSecondary,
                ),
              ),
              Text(
                '100%',
                style: AppTextStyles.regular(
                  context,
                  isTablet ? sw * 0.03 : sw * 0.032,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateAttended(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    int? attended = int.tryParse(value);
    if (attended == null || attended < 0) {
      return 'Invalid number';
    }
    int? total = int.tryParse(_totalController.text);
    if (total != null && attended > total) {
      return 'Cannot exceed total';
    }
    return null;
  }

  String? _validateTotal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    int? total = int.tryParse(value);
    if (total == null || total < 0) {
      return 'Invalid number';
    }
    int? attended = int.tryParse(_attendedController.text);
    if (attended != null && total < attended) {
      return 'Cannot be less than attended';
    }
    return null;
  }
}
