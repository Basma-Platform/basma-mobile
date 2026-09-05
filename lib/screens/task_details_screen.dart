import 'package:flutter/material.dart';

import '../language/app_localizations.dart';
import '../models/task.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final Future<void> Function() onEdit;
  final VoidCallback onDelete;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _deleteTask() {
    widget.onDelete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('taskDetails')),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editTask,
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              task.title,

              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            _buildStatus(),

            const SizedBox(height: 24),

            if (task.description.isNotEmpty) ...[
              Text(
                strings.text('description'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(task.description, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 24),
            ],

            _buildInfoTile(
              icon: Icons.flag_outlined,
              title: strings.text('priority'),
              value: strings.priorityText(task.priority),
            ),

            _buildInfoTile(
              icon: Icons.category_outlined,
              title: strings.text('category'),
              value: strings.categoryText(task.category),
            ),

            if (task.dueDate != null)
              _buildInfoTile(
                icon: Icons.calendar_today,
                title: strings.text('dueDate'),
                value: _formatDate(task.dueDate!),
              ),

            _buildInfoTile(
              icon: Icons.access_time,
              title: strings.text('created'),
              value: _formatDate(task.createdAt),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: _editTask,

                icon: const Icon(Icons.edit),

                label: Text(strings.text('editTask')),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: _showDeleteDialog,

                icon: const Icon(Icons.delete_outline),

                label: Text(strings.text('deleteTask')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTask() async {
    await widget.onEdit();

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildStatus() {
    return Row(
      children: [
        Checkbox(
          value: widget.task.isCompleted,

          onChanged: (value) {
            setState(() {
              widget.task.isCompleted = value ?? false;
            });
          },
        ),

        Text(
          widget.task.isCompleted
              ? AppLocalizations.of(context).text('completedStatus')
              : AppLocalizations.of(context).text('notCompletedStatus'),

          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(child: Icon(icon)),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

      subtitle: Text(value),
    );
  }

  Future<void> _showDeleteDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,

      builder: (context) {
        final strings = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(strings.text('deleteTaskQuestion')),

          content: Text(strings.text('deleteConfirmation')),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: Text(strings.text('cancel')),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: Text(strings.text('delete')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteTask();
    }
  }
}
