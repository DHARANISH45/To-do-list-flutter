import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _tasksSubscription;
  String? _currentUserId;


  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateAuthStatus(String? userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    if (userId != null) {
      loadTasks(userId);
    } else {
      clearTasks();
    }
  }

  
  void loadTasks(String userId) {
    _isLoading = true;
    notifyListeners();

    _tasksSubscription?.cancel();
    _tasksSubscription = _databaseService.getTasksStream(userId).listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load tasks. Please try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }


  Future<bool> addTask(String userId, String title, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.createTask(userId, title, description);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

 
  Future<bool> updateTask(
      String userId, String taskId, String title, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateTask(userId, taskId, title, description);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  
  Future<void> toggleComplete(
      String userId, String taskId, bool currentStatus) async {
    _errorMessage = null;

    try {
      await _databaseService.toggleComplete(userId, taskId, currentStatus);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  
  Future<bool> deleteTask(String userId, String taskId) async {
    _errorMessage = null;

    try {
      await _databaseService.deleteTask(userId, taskId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  
  void clearTasks() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _tasks = [];
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
