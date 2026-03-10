import 'dart:developer' as developer;

import 'package:firebase_database/firebase_database.dart';

import '../models/task_model.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  
  DatabaseReference _tasksRef(String userId) {
    return _database.ref('users/$userId/tasks');
  }


  Future<void> createTask(String userId, String title, String description) async {
    try {
      final now = DateTime.now().toIso8601String();
      final newTaskRef = _tasksRef(userId).push();
      await newTaskRef.set({
        'title': title.trim(),
        'description': description.trim(),
        'completed': false,
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (e) {
      developer.log('Create task error: $e', name: 'DatabaseService');
      throw 'Failed to create task. Please try again.';
    }
  }

  
  Future<void> updateTask(
      String userId, String taskId, String title, String description) async {
    try {
      await _tasksRef(userId).child(taskId).update({
        'title': title.trim(),
        'description': description.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Update task error: $e', name: 'DatabaseService');
      throw 'Failed to update task. Please try again.';
    }
  }

  
  Future<void> toggleComplete(
      String userId, String taskId, bool currentStatus) async {
    try {
      await _tasksRef(userId).child(taskId).update({
        'completed': !currentStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Toggle task error: $e', name: 'DatabaseService');
      throw 'Failed to update task status. Please try again.';
    }
  }

  
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksRef(userId).child(taskId).remove();
    } catch (e) {
      developer.log('Delete task error: $e', name: 'DatabaseService');
      throw 'Failed to delete task. Please try again.';
    }
  }


  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksRef(userId).onValue.map((event) {
      final List<TaskModel> tasks = [];
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            tasks.add(TaskModel.fromMap(
              key as String,
              userId,
              value,
            ));
          }
        });
      }
      
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }
}
