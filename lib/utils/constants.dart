import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

 
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentLight = Color(0xFF80E8FF);


  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color darkBg = Color(0xFF1A1A2E);


  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9A9DB0);
  static const Color textOnPrimary = Colors.white;


  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);

  
  static const Color completedTask = Color(0xFFE8F5E9);
  static const Color completedText = Color(0xFF81C784);
  static const Color pendingTask = Colors.white;
}

class AppDimensions {
  AppDimensions._();

  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double borderRadius = 12.0;
  static const double borderRadiusLG = 20.0;
  static const double borderRadiusXL = 28.0;

  static const double iconSize = 24.0;
  static const double iconSizeLG = 32.0;

  static const double minTouchTarget = 48.0;

  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
}

class AppStrings {
  AppStrings._();

  static const String appName = 'TaskFlow';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';
  static const String createAccount = 'Create Account';
  static const String welcomeBack = 'Welcome Back';
  static const String getStarted = 'Get Started';


  static const String myTasks = 'My Tasks';
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Description (optional)';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String deleteConfirmTitle = 'Delete Task';
  static const String deleteConfirmMessage = 'Are you sure you want to delete this task? This action cannot be undone.';

  
  static const String noTasks = 'No tasks yet';
  static const String noTasksSubtitle = 'Tap + to add your first task';
  static const String titleRequired = 'Task title is required';
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
}
