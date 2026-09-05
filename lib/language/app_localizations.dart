import 'package:flutter/material.dart';

import '../models/task.dart';

class AppLocalizations extends InheritedWidget {
  const AppLocalizations({
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
    super.key,
  });

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  static AppLocalizations of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<AppLocalizations>();
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) {
    return oldWidget.locale != locale;
  }

  bool get isArabic => locale.languageCode == 'ar';

  String get languageToggleLabel => isArabic ? 'English' : 'العربية';

  void toggleLanguage() {
    onLocaleChanged(isArabic ? const Locale('en') : const Locale('ar'));
  }

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Todo App',
      'myTasks': 'My Tasks',
      'addTask': 'Add Task',
      'all': 'All',
      'active': 'Active',
      'completed': 'Completed',
      'noTasksYet': 'No tasks yet',
      'emptyStateMessage': 'Add your first task to get started.',
      'taskDetails': 'Task Details',
      'description': 'Description',
      'priority': 'Priority',
      'category': 'Category',
      'dueDate': 'Due Date',
      'created': 'Created',
      'editTask': 'Edit Task',
      'deleteTask': 'Delete Task',
      'deleteTaskQuestion': 'Delete Task?',
      'deleteConfirmation': 'Are you sure you want to delete this task?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'saveTask': 'Save Task',
      'updateTask': 'Update Task',
      'title': 'Title',
      'enterTaskTitle': 'Enter task title',
      'enterTaskDescription': 'Enter task description (optional)',
      'selectDate': 'Select date',
      'pleaseEnterTitle': 'Please enter a title',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'work': 'Work',
      'personal': 'Personal',
      'study': 'Study',
      'shopping': 'Shopping',
      'other': 'Other',
      'completedStatus': 'Completed',
      'notCompletedStatus': 'Not Completed',
      'updateExistingTask': 'Update Task',
      'addNewTask': 'Add Task',
    },
    'ar': {
      'appTitle': 'تطبيق المهام',
      'myTasks': 'مهامي',
      'addTask': 'إضافة مهمة',
      'all': 'الكل',
      'active': 'النشطة',
      'completed': 'المكتملة',
      'noTasksYet': 'لا توجد مهام بعد',
      'emptyStateMessage': 'أضف مهمتك الأولى للبدء.',
      'taskDetails': 'تفاصيل المهمة',
      'description': 'الوصف',
      'priority': 'الأولوية',
      'category': 'الفئة',
      'dueDate': 'تاريخ الاستحقاق',
      'created': 'تم الإنشاء',
      'editTask': 'تعديل المهمة',
      'deleteTask': 'حذف المهمة',
      'deleteTaskQuestion': 'حذف المهمة؟',
      'deleteConfirmation': 'هل أنت متأكد أنك تريد حذف هذه المهمة؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'saveTask': 'حفظ المهمة',
      'updateTask': 'تحديث المهمة',
      'title': 'العنوان',
      'enterTaskTitle': 'أدخل عنوان المهمة',
      'enterTaskDescription': 'أدخل وصف المهمة (اختياري)',
      'selectDate': 'اختر التاريخ',
      'pleaseEnterTitle': 'يرجى إدخال عنوان',
      'low': 'منخفض',
      'medium': 'متوسط',
      'high': 'عالي',
      'work': 'عمل',
      'personal': 'شخصي',
      'study': 'دراسة',
      'shopping': 'تسوق',
      'other': 'أخرى',
      'completedStatus': 'مكتملة',
      'notCompletedStatus': 'غير مكتملة',
      'updateExistingTask': 'تحديث المهمة',
      'addNewTask': 'إضافة مهمة',
    },
  };

  String text(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['en']![key]!;

  String priorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return text('low');
      case Priority.medium:
        return text('medium');
      case Priority.high:
        return text('high');
    }
  }

  String categoryText(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return text('work');
      case TaskCategory.personal:
        return text('personal');
      case TaskCategory.study:
        return text('study');
      case TaskCategory.shopping:
        return text('shopping');
      case TaskCategory.other:
        return text('other');
    }
  }
}
