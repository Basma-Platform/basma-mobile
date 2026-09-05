import 'package:flutter/material.dart';

import '../language/app_localizations.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  bool get isEditing => task != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _dueDate;

  Priority _priority = Priority.medium;

  TaskCategory _category = TaskCategory.other;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');

    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    _dueDate = task?.dueDate;

    _priority = task?.priority ?? Priority.medium;

    _category = task?.category ?? TaskCategory.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existingTask = widget.task;

    if (existingTask != null) {
      existingTask.title = _titleController.text.trim();

      existingTask.description = _descriptionController.text.trim();

      existingTask.dueDate = _dueDate;

      existingTask.priority = _priority;

      existingTask.category = _category;

      Navigator.pop(context, existingTask);
    } else {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),

        title: _titleController.text.trim(),

        description: _descriptionController.text.trim(),

        dueDate: _dueDate,

        priority: _priority,

        category: _category,

        createdAt: DateTime.now(),
      );

      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? strings.text('editTask') : strings.text('addTask'),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              TextFormField(
                controller: _titleController,

                decoration: InputDecoration(
                  labelText: strings.text('title'),
                  hintText: strings.text('enterTaskTitle'),
                  prefixIcon: const Icon(Icons.title),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.text('pleaseEnterTitle');
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,

                maxLines: 5,

                decoration: InputDecoration(
                  labelText: strings.text('description'),
                  hintText: strings.text('enterTaskDescription'),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              _buildDatePicker(),

              const SizedBox(height: 20),

              DropdownButtonFormField<Priority>(
                initialValue: _priority,

                decoration: InputDecoration(
                  labelText: strings.text('priority'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),

                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(strings.priorityText(priority)),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<TaskCategory>(
                initialValue: _category,

                decoration: InputDecoration(
                  labelText: strings.text('category'),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),

                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(strings.categoryText(category)),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,

                child: FilledButton.icon(
                  onPressed: _saveTask,

                  icon: const Icon(Icons.save),

                  label: Text(
                    isEditing
                        ? strings.text('updateTask')
                        : strings.text('saveTask'),
                  ),

                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final strings = AppLocalizations.of(context);

    return InkWell(
      onTap: _selectDate,

      borderRadius: BorderRadius.circular(12),

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: strings.text('dueDate'),
          prefixIcon: const Icon(Icons.calendar_today),
        ),

        child: Text(
          _dueDate == null
              ? strings.text('selectDate')
              : '${_dueDate!.day}/'
                    '${_dueDate!.month}/'
                    '${_dueDate!.year}',
        ),
      ),
    );
  }
}
