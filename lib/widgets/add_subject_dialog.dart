// Add Subject Dialog with Animation - Fully Responsive
import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/main.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:flutter/material.dart';

class AddSubjectDialog extends StatefulWidget {
  final Function(Subject) onSubjectAdded;

  AddSubjectDialog({required this.onSubjectAdded});

  @override
  _AddSubjectDialogState createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lecturesController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _lecturesController.dispose();
    super.dispose();
  }

  _addSubject() async {
    if (_formKey.currentState!.validate()) {
      await _slideController.reverse();
      Subject newSubject = Subject(
        name: _nameController.text,
        totalLectures: int.parse(_lecturesController.text),
      );
      widget.onSubjectAdded(newSubject);
      Navigator.pop(context);
    }
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              child: Container(
                width: isTablet ? sw * 0.6 : sw * 0.9,
                constraints: BoxConstraints(
                  maxHeight: sh * 0.7,
                  minHeight: sh * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: isTablet ? 25 : 20,
                      offset: Offset(0, isTablet ? 15 : 10),
                      spreadRadius: isTablet ? 2 : 1,
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
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.02 : sw * 0.03,
                                ),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primary,
                                size: isTablet ? sw * 0.04 : sw * 0.06,
                              ),
                            ),
                            SizedBox(width: sw * 0.04),
                            Expanded(
                              child: Text(
                                'Add New Subject',
                                style: AppTextStyles.bold(
                                  context,
                                  isTablet ? 24 : 20,
                                  AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sh * 0.03),

                        // Subject Name Field
                        _buildDialogTextField(
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

                        // Total Lectures Field
                        _buildDialogTextField(
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
                                        isTablet ? 15 : 12,
                                      ),
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
                                  onPressed: _addSubject,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 15 : 12,
                                      ),
                                    ),
                                    elevation: isTablet ? 10 : 8,
                                    shadowColor:
                                        AppColors.primary.withOpacity(0.3),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.04,
                                      vertical: sh * 0.015,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: isTablet ? 20 : 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: sw * 0.02),
                                      Text(
                                        'Add',
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

                        SizedBox(height: sh * 0.01),

                        // Helper Text (for tablets)
                        if (isTablet) ...[
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: sh * 0.02),
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.04,
                                vertical: sh * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                  SizedBox(width: sw * 0.02),
                                  Text(
                                    'You can add up to 10 subjects',
                                    style: AppTextStyles.regular(
                                      context,
                                      12,
                                      AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
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
                color: AppColors.primary,
                size: isTablet ? sw * 0.035 : sw * 0.055,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.02,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                borderSide: BorderSide(color: AppColors.accent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (isNumber) {
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) > 50) {
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
