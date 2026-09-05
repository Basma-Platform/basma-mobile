import 'package:flutter/material.dart';

import '../language/app_localizations.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

enum TaskFilter { all, active, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];

  TaskFilter _currentFilter = TaskFilter.all;

  List<Task> get _filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;

      case TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();

      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
    }
  }

  Future<void> _addTask() async {
    final Task? newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );

    if (newTask != null) {
      setState(() {
        _tasks.add(newTask);
      });
    }
  }

  Future<void> _editTask(Task task) async {
    final Task? updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (updatedTask != null) {
      setState(() {});
    }
  }

  Future<void> _openDetails(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: task,
          onEdit: () => _editTask(task),
          onDelete: () => _deleteTask(task),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });
  }

  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.isCompleted = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.text('myTasks'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: strings.toggleLanguage,
            icon: const Icon(Icons.translate),
            label: Text(strings.languageToggleLabel),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          _buildFilterBar(),

          const SizedBox(height: 8),

          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return TaskCard(
                        task: task,
                        onTap: () => _openDetails(task),
                        onDelete: () => _deleteTask(task),
                        onChanged: (value) => _toggleTask(task, value),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).text('addTask')),
      ),
    );
  }

  Widget _buildFilterBar() {
    final strings = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<TaskFilter>(
        segments: [
          ButtonSegment(
            value: TaskFilter.all,
            label: Text(strings.text('all')),
          ),
          ButtonSegment(
            value: TaskFilter.active,
            label: Text(strings.text('active')),
          ),
          ButtonSegment(
            value: TaskFilter.completed,
            label: Text(strings.text('completed')),
          ),
        ],
        selected: {_currentFilter},
        onSelectionChanged: (selection) {
          setState(() {
            _currentFilter = selection.first;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final strings = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400),

          const SizedBox(height: 16),

          Text(
            strings.text('noTasksYet'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(strings.text('emptyStateMessage')),
        ],
      ),
    );
  }
}
