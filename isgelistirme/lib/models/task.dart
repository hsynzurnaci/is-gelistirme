import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String businessId;
  final String? assignedTo;
  final Priority priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.businessId,
    this.assignedTo,
    this.priority = Priority.medium,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? businessId,
    String? assignedTo,
    Priority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      businessId: businessId ?? this.businessId,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'businessId': businessId,
      'assignedTo': assignedTo,
      'priority': priority.index,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      businessId: json['businessId'],
      assignedTo: json['assignedTo'],
      priority: Priority.values[json['priority']],
    );
  }
}

enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  String get name {
    switch (this) {
      case Priority.low:
        return 'Düşük';
      case Priority.medium:
        return 'Orta';
      case Priority.high:
        return 'Yüksek';
    }
  }
}
