// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   // Add these to your class
//   late AudioPlayer _audioPlayer;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize audio player
//     _audioPlayer = AudioPlayer();
    
//     // Initialize pulse animation for button feedback
//     _pulseController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
    
//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.elasticOut,
//     ));
    
//     // Your existing initialization code...
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _pulseController.dispose();
//     // Your existing dispose code...
//     super.dispose();
//   }

//   // Enhanced attendance increment with sound and haptics
//   _incrementAttendance(int index) async {
//     if (userData!.subjects[index].attendedLectures <
//         userData!.subjects[index].totalLectures) {
      
//       // Trigger haptic feedback
//       HapticFeedback.lightImpact();
      
//       // Trigger pulse animation
//       _pulseController.forward().then((_) {
//         _pulseController.reverse();
//       });
      
//       // Play success sound
//       _playAttendanceSound();
      
//       setState(() {
//         userData!.subjects[index].attendedLectures++;
//       });
//       _saveUserData();

//       // Calculate if milestone reached
//       double newPercentage = userData!.subjects[index].percentage;
//       bool milestoneReached = (newPercentage >= 75 && newPercentage - (100 / userData!.subjects[index].totalLectures) < 75) ||
//                              (newPercentage >= 50 && newPercentage - (100 / userData!.subjects[index].totalLectures) < 50);

//       // Show enhanced success feedback
//       double sw = ResponsiveHelper.getWidth(context);
//       double sh = ResponsiveHelper.getHeight(context);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 milestoneReached ? Icons.star : Icons.check_circle,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               SizedBox(width: sw * 0.02),
//               Expanded(
//                 child: Text(
//                   milestoneReached 
//                     ? 'Milestone reached! 🎉 ${newPercentage.toStringAsFixed(1)}%'
//                     : 'Attendance marked! 🎉 ${newPercentage.toStringAsFixed(1)}%',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: milestoneReached ? AppColors.warning : AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: EdgeInsets.symmetric(
//             horizontal: sw * 0.04,
//             vertical: sh * 0.02,
//           ),
//           duration: Duration(milliseconds: milestoneReached ? 2500 : 1500),
//         ),
//       );
      
//       // Play special sound for milestones
//       if (milestoneReached) {
//         Future.delayed(Duration(milliseconds: 200), () {
//           _playMilestoneSound();
//         });
//       }
//     } else {
//       // Play completion sound when all lectures attended
//       HapticFeedback.mediumImpact();
//       _playCompletionSound();
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.celebration, color: Colors.white, size: 20),
//               SizedBox(width: ResponsiveHelper.getWidth(context) * 0.02),
//               Text('Perfect attendance! 🏆'),
//             ],
//           ),
//           backgroundColor: AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           duration: Duration(milliseconds: 2000),
//         ),
//       );
//     }
//   }

//   // Sound effect methods
//   void _playAttendanceSound() async {
//     try {
//       // You can use system sounds or custom audio files
//       await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      
//       // Alternative: Use system sound
//       // SystemSound.play(SystemSoundType.click);
//     } catch (e) {
//       // Fallback to system sound if custom sound fails
//       SystemSound.play(SystemSoundType.click);
//     }
//   }

//   void _playMilestoneSound() async {
//     try {
//       await _audioPlayer.play(AssetSource('sounds/milestone.mp3'));
//     } catch (e) {
//       // Fallback to multiple system sounds for celebration
//       SystemSound.play(SystemSoundType.click);
//       Future.delayed(Duration(milliseconds: 100), () {
//         SystemSound.play(SystemSoundType.click);
//       });
//     }
//   }

//   void _playCompletionSound() async {
//     try {
//       await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
//     } catch (e) {
//       // Fallback to system sound
//       SystemSound.play(SystemSoundType.click);
//     }
//   }

//   // Enhanced button with animation
//   Widget _buildAttendanceButton(Subject subject, int index, double sw, bool isTablet) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: GestureDetector(
//             onTap: () => _incrementAttendance(index),
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 200),
//               width: isTablet ? sw * 0.12 : sw * 0.15,
//               height: isTablet ? sw * 0.12 : sw * 0.15,
//               decoration: BoxDecoration(
//                 color: subject.attendedLectures < subject.totalLectures
//                     ? AppColors.primary
//                     : AppColors.success,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: (subject.attendedLectures < subject.totalLectures
//                             ? AppColors.primary
//                             : AppColors.success)
//                         .withOpacity(0.3),
//                     blurRadius: isTablet ? 12 : 10,
//                     offset: Offset(0, isTablet ? 6 : 4),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 subject.attendedLectures >= subject.totalLectures
//                     ? Icons.celebration
//                     : Icons.add,
//                 color: Colors.white,
//                 size: isTablet ? sw * 0.06 : sw * 0.08,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }