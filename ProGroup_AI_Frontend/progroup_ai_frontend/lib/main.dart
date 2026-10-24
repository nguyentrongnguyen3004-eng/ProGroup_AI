import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';

import 'models/course_model.dart';
import 'models/group_model.dart';
import 'models/topic_model.dart';
import 'models/user_model.dart';

import 'screens/common/auth/forgot_password/forgot_password_screen.dart';
import 'screens/common/auth/login/login_screen.dart';
import 'screens/common/auth/otp/otp_screen.dart';
import 'screens/common/auth/reset_password/reset_password_screen.dart';

import 'screens/common/splash/splash_screen.dart';

import 'screens/sinh_vien/chat/chat_screen.dart';
import 'screens/sinh_vien/group/group_detail_screen.dart';
import 'screens/sinh_vien/group/group_screen.dart';
import 'screens/sinh_vien/home/student_main_screen.dart';
import 'screens/giang_vien/main/lecturer_main_screen.dart';
import 'screens/giao_vu/main/governance_main_screen.dart';
import 'screens/phong_dao_tao/main/training_main_screen.dart';
import 'screens/admin/main/admin_main_screen.dart';
import 'screens/sinh_vien/profile/profile_screen.dart';
import 'screens/sinh_vien/topic/topic_detail_screen.dart';
import 'screens/sinh_vien/topic/topic_screen.dart';

import 'package:progroup_ai_frontend/screens/sinh_vien/course/course_detail_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/create_group_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/group/join_group_screen.dart';
import 'package:progroup_ai_frontend/screens/sinh_vien/topic/propose_topic_screen.dart';

import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
    try {
      await FirebaseService.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase init error: $e');
      }
    }
  }
  runApp(const ProGroupApp());
}

class ProGroupApp extends StatelessWidget {
  const ProGroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ProGroup AI',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettings.instance.themeMode,

          initialRoute: AppRoutes.splash,

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.splash:
                return MaterialPageRoute(builder: (_) => const SplashScreen());

              case AppRoutes.login:
                return MaterialPageRoute(builder: (_) => const LoginScreen());

              case AppRoutes.forgotPassword:
                return MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                );

              case AppRoutes.otp:
                final email = settings.arguments as String;

                return MaterialPageRoute(
                  builder: (_) => OtpScreen(email: email),
                );

              case AppRoutes.resetPassword:
                final args = settings.arguments;
                String email = '';
                String otp = '';
                if (args is Map) {
                  email = args['email']?.toString() ?? '';
                  otp = args['otp']?.toString() ?? '';
                } else if (args is String) {
                  email = args;
                }

                return MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(email: email, otp: otp),
                );

              case AppRoutes.lecturerMain:
                final user = settings.arguments;
                if (user is! UserModel || user.role != 'LECTURER') {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }
                return MaterialPageRoute(
                  builder: (_) => const LecturerMainScreen(),
                );

              case AppRoutes.home:
                final user = settings.arguments;
                if (user is! UserModel || user.role != 'SINHVIEN') {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }
                return MaterialPageRoute(
                  builder: (_) => const StudentMainScreen(),
                );

              case AppRoutes.governanceMain:
                final user = settings.arguments;
                if (user is! UserModel || user.role != 'GIAOVU') {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }
                return MaterialPageRoute(
                  builder: (_) => const GovernanceMainScreen(),
                );

              case AppRoutes.trainingMain:
                final user = settings.arguments;
                if (user is! UserModel || user.role != 'PHONG_DAO_TAO') {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }
                return MaterialPageRoute(
                  builder: (_) => const TrainingMainScreen(),
                );

              case AppRoutes.adminMain:
                final user = settings.arguments;
                if (user is! UserModel || user.role != 'ADMIN') {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }
                return MaterialPageRoute(
                  builder: (_) => AdminMainScreen(user: user),
                );

              case AppRoutes.course:
                final args = settings.arguments;

                if (args is! CourseModel) {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }

                return MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(course: args),
                );

              case AppRoutes.group:
                return MaterialPageRoute(builder: (_) => const GroupScreen());

              case AppRoutes.groupDetail:
                final group = settings.arguments as GroupModel;

                return MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(group: group),
                );

              case AppRoutes.topic:
                final args = settings.arguments;

                final course = args is CourseModel ? args : null;

                return MaterialPageRoute(
                  builder: (_) => TopicScreen(course: course),
                );

              case AppRoutes.topicDetail:
                final topic = settings.arguments as TopicModel;

                final course = CourseModel(
                  id: topic.courseId,
                  code: 'LHP',
                  name: topic.title,
                  classCode: 'LHP-${topic.courseId}',
                  semester: 'HK1 2026-2027',
                  lecturer: topic.lecturerName ?? 'Giảng viên phụ trách',
                  status: 'Đang mở',
                );

                return MaterialPageRoute(
                  builder: (_) =>
                      TopicDetailScreen(topic: topic, course: course),
                );

              case AppRoutes.chat:
                final groupName = settings.arguments as String;

                return MaterialPageRoute(
                  builder: (_) => ChatScreen(groupName: groupName),
                );

              case AppRoutes.profile:
                return MaterialPageRoute(builder: (_) => const ProfileScreen());

              case AppRoutes.courseDetail:
                final course = settings.arguments as CourseModel;

                return MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(course: course),
                );

              case AppRoutes.createGroup:
                final args = settings.arguments;

                if (args is! CourseModel) {
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                }

                return MaterialPageRoute(
                  builder: (_) => CreateGroupScreen(course: args),
                );

              case AppRoutes.joinGroup:
                return MaterialPageRoute(
                  builder: (_) => const JoinGroupScreen(),
                );

              case AppRoutes.proposeTopic:
                return MaterialPageRoute(
                  builder: (_) => const ProposeTopicScreen(),
                );
              default:
                return MaterialPageRoute(builder: (_) => const LoginScreen());
            }
          },
        );
      },
    );
  }
}
