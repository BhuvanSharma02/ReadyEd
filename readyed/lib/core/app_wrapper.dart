import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../features/auth/login_screen.dart';
import 'main_navigation.dart';
import '../features/teacher/teacher_dashboard_screen.dart';
import '../models/user_model.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<dynamic>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // User is authenticated, now check role
        return FutureBuilder<UserModel?>(
          future: authService.getUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final userData = userSnapshot.data;
            if (userData == null) {
              // Fallback to Student view if user data is not yet available
              return const MainNavigation();
            }

            if (userData.role == 'teacher') {
              return const TeacherDashboardScreen();
            } else {
              return const MainNavigation();
            }
          },
        );
      },
    );
  }
}
