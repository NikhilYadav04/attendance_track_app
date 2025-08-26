import 'package:attendance_tracker/core/appColors.dart';
import 'package:attendance_tracker/http/models/subject.dart';
import 'package:attendance_tracker/main.dart';
import 'package:flutter/material.dart';

class AddSubjectDialog extends StatefulWidget {
  final Function(Subject) onSubjectAdded;

  const AddSubjectDialog({
    Key? key,
    required this.onSubjectAdded,
  }) : super(key: key);

  @override
  _AddSubjectDialogState createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _targetPercentage = 75;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    super.dispose();
  }

  void _addSubject() {
    if (_formKey.currentState!.validate()) {
      Subject newSubject = Subject(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetPercentage: _targetPercentage,
        // If your Subject model expects attended/total fields, ensure it has defaults
        // or pass them here (e.g. attendedLectures: 0, totalLectures: 0).
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: isTablet ? sw * 0.7 : sw * 0.94,
          constraints: BoxConstraints(
            maxHeight: sh * 0.85,
            minHeight: sh * 0.5,
            maxWidth: isTablet ? sw * 0.75 : sw * 0.95,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(sw * (isTablet ? 0.035 : 0.05)),
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
                padding: EdgeInsets.symmetric(
                  horizontal: sw * (isTablet ? 0.04 : 0.05),
                  vertical: sh * (isTablet ? 0.025 : 0.022),
                ),
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
                    topLeft: Radius.circular(sw * (isTablet ? 0.035 : 0.05)),
                    topRight: Radius.circular(sw * (isTablet ? 0.035 : 0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * (isTablet ? 0.015 : 0.025)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            sw * (isTablet ? 0.02 : 0.03)),
                      ),
                      child: Icon(
                        Icons.add_box,
                        color: Colors.white,
                        size: sw * (isTablet ? 0.04 : 0.055),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Subject',
                            style: AppTextStyles.bold(
                              context,
                              sw * (isTablet ? 0.032 : 0.048),
                              Colors.white,
                            ),
                          ),
                          SizedBox(height: sh * 0.003),
                          Text(
                            'Start tracking your attendance',
                            style: AppTextStyles.regular(
                              context,
                              sw * (isTablet ? 0.02 : 0.029),
                              Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(sw * (isTablet ? 0.01 : 0.015)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              sw * (isTablet ? 0.012 : 0.02)),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: sw * (isTablet ? 0.025 : 0.043),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * (isTablet ? 0.04 : 0.05),
                    vertical: sh * (isTablet ? 0.025 : 0.02),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Name Field
                        _buildInputLabel('Subject Name', true, isTablet, sw),
                        SizedBox(height: sh * 0.012),
                        _buildTextFormField(
                          controller: _nameController,
                          hintText: 'e.g., Mathematics, Physics, Chemistry',
                          icon: Icons.subject,
                          isRequired: true,
                          isTablet: isTablet,
                          sw: sw,
                          sh: sh,
                        ),

                        SizedBox(height: sh * 0.03),

                        // Description Field (Optional)
                        _buildInputLabel(
                            'Description (Optional)', false, isTablet, sw),
                        SizedBox(height: sh * 0.012),
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

                        SizedBox(height: sh * 0.03),

                        // Target Percentage
                        _buildInputLabel(
                            'Target Percentage', true, isTablet, sw),
                        SizedBox(height: sh * 0.012),
                        _buildTargetPercentageSelector(isTablet, sw, sh),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * (isTablet ? 0.04 : 0.05),
                  vertical: sh * (isTablet ? 0.02 : 0.018),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: sh * (isTablet ? 0.065 : 0.06),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  sw * (isTablet ? 0.02 : 0.03)),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.medium(
                              context,
                              sw * (isTablet ? 0.025 : 0.038),
                              AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    Expanded(
                      child: Container(
                        height: sh * (isTablet ? 0.065 : 0.06),
                        child: ElevatedButton(
                          onPressed: _addSubject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  sw * (isTablet ? 0.02 : 0.03)),
                            ),
                            elevation: sw * (isTablet ? 0.01 : 0.015),
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,
                                    size: sw * (isTablet ? 0.025 : 0.043)),
                                SizedBox(width: sw * 0.02),
                                Text(
                                  'Add',
                                  style: AppTextStyles.medium(
                                    context,
                                    sw * (isTablet ? 0.025 : 0.038),
                                    Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
          sw * (isTablet ? 0.022 : 0.033),
          AppColors.textPrimary,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: const TextStyle(color: AppColors.accent),
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
        sw * (isTablet ? 0.022 : 0.033),
        AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.regular(
          context,
          sw * (isTablet ? 0.022 : 0.033),
          AppColors.textSecondary.withOpacity(0.7),
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(left: sw * 0.03, right: sw * 0.02),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: sw * (isTablet ? 0.03 : 0.048),
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: sw * (isTablet ? 0.07 : 0.11),
          minHeight: sw * (isTablet ? 0.07 : 0.11),
        ),
        filled: true,
        fillColor: AppColors.textSecondary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * (isTablet ? 0.02 : 0.018),
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

  Widget _buildTargetPercentageSelector(bool isTablet, double sw, double sh) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * (isTablet ? 0.025 : 0.035),
        vertical: sh * (isTablet ? 0.015 : 0.012),
      ),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(sw * (isTablet ? 0.02 : 0.03)),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          width: 1,
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
                    size: sw * (isTablet ? 0.025 : 0.043),
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Target:',
                    style: AppTextStyles.medium(
                      context,
                      sw * (isTablet ? 0.022 : 0.033),
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.035,
                  vertical: sh * 0.006,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(sw * (isTablet ? 0.015 : 0.025)),
                ),
                child: Text(
                  '$_targetPercentage%',
                  style: AppTextStyles.bold(
                    context,
                    sw * (isTablet ? 0.025 : 0.038),
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.01),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: sw * (isTablet ? 0.015 : 0.025),
              ),
              trackHeight: sw * (isTablet ? 0.008 : 0.01),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '50%',
                  style: AppTextStyles.regular(
                    context,
                    sw * (isTablet ? 0.019 : 0.029),
                    AppColors.textSecondary,
                  ),
                ),
                Text(
                  '100%',
                  style: AppTextStyles.regular(
                    context,
                    sw * (isTablet ? 0.019 : 0.029),
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
