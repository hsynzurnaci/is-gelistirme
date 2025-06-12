import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/business.dart';
import 'business_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<Business> businesses;

  const CalendarScreen({super.key, required this.businesses});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Business>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    // Örnek olarak her işletmeye rastgele bir tarih atayalım
    for (var business in widget.businesses) {
      final date =
          DateTime.now().add(Duration(days: business.id.hashCode % 30));
      final dateKey = DateTime(date.year, date.month, date.day);
      if (_events[dateKey] == null) _events[dateKey] = [];
      _events[dateKey]!.add(business);
    }
  }

  List<Business> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showAddEventDialog(DateTime selectedDay) {
    final timeController = TextEditingController();
    Business? selectedBusiness;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Etkinlik Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Business>(
                decoration: const InputDecoration(
                  labelText: 'İşletme',
                  border: OutlineInputBorder(),
                ),
                items: widget.businesses.map((business) {
                  return DropdownMenuItem(
                    value: business,
                    child: Text(business.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBusiness = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Saat',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && context.mounted) {
                    timeController.text = time.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedBusiness != null &&
                    timeController.text.isNotEmpty) {
                  setState(() {
                    final dateKey = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                    if (_events[dateKey] == null) _events[dateKey] = [];
                    _events[dateKey]!.add(selectedBusiness!);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final business = _getEventsForDay(_selectedDay!)[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(business.name),
                    subtitle: Text(business.category),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _events[_selectedDay!]?.remove(business);
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessDetailScreen(
                            business: business,
                            onUpdate: (updatedBusiness) {
                              setState(() {
                                final i = _events[_selectedDay!]!.indexWhere(
                                    (b) => b.id == updatedBusiness.id);
                                if (i != -1) {
                                  _events[_selectedDay!]![i] = updatedBusiness;
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(_selectedDay!),
        child: const Icon(Icons.add),
      ),
    );
  }
}
