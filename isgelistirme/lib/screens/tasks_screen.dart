import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/business.dart';

class TasksScreen extends StatefulWidget {
  final List<Business> businesses;

  const TasksScreen({super.key, required this.businesses});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  String filter = 'Tümü';

  @override
  void initState() {
    super.initState();
    // Örnek görevler
    tasks = [
      Task(
        id: '1',
        title: 'Müşteri görüşmesi',
        description: 'Yeni müşteri ile görüşme planla',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        businessId: '1',
        priority: Priority.high,
      ),
      Task(
        id: '2',
        title: 'Rapor hazırla',
        description: 'Aylık satış raporunu hazırla',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        businessId: '2',
        priority: Priority.medium,
      ),
    ];
  }

  void showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedBusinessId;
    Priority selectedPriority = Priority.medium;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Görev Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedBusinessId,
                      decoration: const InputDecoration(
                        labelText: 'İşletme',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.businesses.map((business) {
                        return DropdownMenuItem(
                          value: business.id,
                          child: Text(business.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBusinessId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Tarih'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Saat'),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() {
                            selectedTime = time;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Priority>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Öncelik',
                        border: OutlineInputBorder(),
                      ),
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: priority.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(priority.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedBusinessId != null) {
                      final dueDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      setState(() {
                        tasks.add(Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          description: descriptionController.text,
                          dueDate: dueDate,
                          businessId: selectedBusinessId!,
                          priority: selectedPriority,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Task> getFilteredTasks() {
    return tasks.where((task) {
      switch (filter) {
        case 'Tümü':
          return true;
        case 'Bugün':
          final now = DateTime.now();
          return task.dueDate.year == now.year &&
              task.dueDate.month == now.month &&
              task.dueDate.day == now.day;
        case 'Bu Hafta':
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return task.dueDate.isAfter(weekStart) &&
              task.dueDate.isBefore(weekEnd);
        case 'Bu Ay':
          final now = DateTime.now();
          return task.dueDate.year == now.year &&
              task.dueDate.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
              });
            },
            itemBuilder: (context) => [
              'Tümü',
              'Bugün',
              'Bu Hafta',
              'Bu Ay',
            ].map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filtre: '),
                const SizedBox(width: 8),
                Chip(
                  label: Text(filter),
                  backgroundColor: Theme.of(context).primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz görev yok.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final business = widget.businesses.firstWhere(
                        (b) => b.id == task.businessId,
                        orElse: () => const Business(
                          id: '',
                          name: 'Bilinmeyen İşletme',
                          address: '',
                          description: '',
                          rating: 0,
                          category: '',
                          documents: [],
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: task.priority.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(business.name),
                              Text(
                                '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} ${task.dueDate.hour}:${task.dueDate.minute}',
                                style: TextStyle(
                                  color: task.dueDate.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    final index = tasks
                                        .indexWhere((t) => t.id == task.id);
                                    if (index != -1) {
                                      tasks[index] = task.copyWith(
                                        isCompleted: value ?? false,
                                      );
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    tasks.removeWhere((t) => t.id == task.id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
    );
  }
}
