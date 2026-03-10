import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/empty_task_list.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text('Are you sure you want to logout? You will need to sign in again to access your tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    await auth.signOut();
    taskProvider.clearTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Logged out successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          AppStrings.myTasks,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppDimensions.paddingSM),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: AppStrings.logout,
              onPressed: _logout,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: _buildBody(auth, taskProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          AppStrings.addTask,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: AppDimensions.elevationMD,
      ),
    );
  }

  Widget _buildBody(AuthProvider auth, TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (taskProvider.errorMessage != null && taskProvider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                taskProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              TextButton.icon(
                onPressed: () {
                  taskProvider.clearError();
                  if (auth.userId != null) {
                    taskProvider.loadTasks(auth.userId!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (taskProvider.tasks.isEmpty) {
      return const EmptyTaskList();
    }

    return Column(
      children: [
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingMD,
          ),
          child: Row(
            children: [
              Text(
                '${taskProvider.tasks.length} task${taskProvider.tasks.length == 1 ? '' : 's'}',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${taskProvider.tasks.where((t) => t.completed).length} completed',
                style: GoogleFonts.poppins(
                  color: AppColors.completedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
       
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return TaskTile(
                task: task,
                onToggle: () {
                  if (auth.userId != null) {
                    taskProvider.toggleComplete(
                      auth.userId!,
                      task.id,
                      task.completed,
                    );
                  }
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditTaskScreen(task: task),
                    ),
                  );
                },
                onDelete: () {
                  if (auth.userId != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    taskProvider.deleteTask(auth.userId!, task.id).then((success) {
                      if (!success && mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              taskProvider.errorMessage ?? AppStrings.genericError,
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
