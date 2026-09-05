enum Priority {
  low,
  medium,
  high,
}

enum TaskCategory {
  work,
  personal,
  study,
  shopping,
  other,
}

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  Priority priority;
  TaskCategory category;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = Priority.medium,
    this.category = TaskCategory.other,
    this.isCompleted = false,
    required this.createdAt,
  });
}
