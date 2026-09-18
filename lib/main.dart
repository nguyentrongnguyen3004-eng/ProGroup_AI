import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'models/group_model.dart';
import 'models/topic_model.dart';

import 'screens/auth/forgot_password/forgot_password_screen.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/otp/otp_screen.dart';
import 'screens/auth/reset_password/reset_password_screen.dart';

import 'screens/chat/chat_screen.dart';
import 'screens/course/course_screen.dart';

import 'screens/group/group_detail_screen.dart';
import 'screens/group/group_screen.dart';

import 'screens/home/home_screen.dart';

import 'screens/profile/profile_screen.dart';

import 'screens/splash/splash_screen.dart';

import 'screens/topic/topic_detail_screen.dart';
import 'screens/topic/topic_screen.dart';

void main() {
  runApp(
    const ProGroupApp(),
  );
}

class ProGroupApp extends StatelessWidget {
  const ProGroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'ProGroup AI',

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(
              builder: (_) =>
                  const SplashScreen(),
            );

          case AppRoutes.login:
            return MaterialPageRoute(
              builder: (_) =>
                  const LoginScreen(),
            );

          case AppRoutes.forgotPassword:
            return MaterialPageRoute(
              builder: (_) =>
                  const ForgotPasswordScreen(),
            );

          case AppRoutes.otp:
            final email =
                settings.arguments as String;

            return MaterialPageRoute(
              builder: (_) => OtpScreen(
                email: email,
              ),
            );

          case AppRoutes.resetPassword:
            final email =
                settings.arguments as String;

            return MaterialPageRoute(
              builder: (_) =>
                  ResetPasswordScreen(
                email: email,
              ),
            );

          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) =>
                  const HomeScreen(),
            );

          case AppRoutes.course:
            return MaterialPageRoute(
              builder: (_) =>
                  const CourseScreen(),
            );

          case AppRoutes.group:
            return MaterialPageRoute(
              builder: (_) =>
                  const GroupScreen(),
            );

          case AppRoutes.groupDetail:
            final group =
                settings.arguments as GroupModel;

            return MaterialPageRoute(
              builder: (_) =>
                  GroupDetailScreen(
                group: group,
              ),
            );

          case AppRoutes.topic:
            return MaterialPageRoute(
              builder: (_) =>
                  const TopicScreen(),
            );

          case AppRoutes.topicDetail:
            final topic =
                settings.arguments as TopicModel;

            return MaterialPageRoute(
              builder: (_) =>
                  TopicDetailScreen(
                topic: topic,
              ),
            );

          case AppRoutes.chat:
            final groupName =
                settings.arguments as String;

            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                groupName: groupName,
              ),
            );

          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) =>
                  const ProfileScreen(),
            );

          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const LoginScreen(),
            );
        }
      },
    );
  }
}