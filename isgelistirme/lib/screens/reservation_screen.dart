import 'package:flutter/material.dart';
import '../models/reservation.dart' as res;
import '../models/business.dart';

class ReservationScreen extends StatefulWidget {
  final List<Business> businesses;

  const ReservationScreen({super.key, required this.businesses});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<res.Reservation> reservations = [];
  String filter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    // Örnek rezervasyonlar
    reservations = [
      res.Reservation(
        id: '1',
        businessId: '1',
        customerName: 'Ahmet Yılmaz',
        customerPhone: '555-0001',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '19:00',
        partySize: 4,
        status: res.ReservationStatus.confirmed,
      ),
      res.Reservation(
        id: '2',
        businessId: '2',
        customerName: 'Mehmet Demir',
        customerPhone: '555-0002',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '20:00',
        partySize: 2,
        status: res.ReservationStatus.pending,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Rezervasyon Yönetimi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Takvim görünümüne geç
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          Expanded(
            child: _buildReservationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReservationDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Rezervasyon'),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Toplam',
            reservations.length.toString(),
            Icons.calendar_today,
            Theme.of(context).primaryColor,
          ),
          _buildStatItem(
            'Onaylı',
            reservations
                .where((r) => r.status == res.ReservationStatus.confirmed)
                .length
                .toString(),
            Icons.check_circle,
            const Color(0xFF43A047),
          ),
          _buildStatItem(
            'Bekleyen',
            reservations
                .where((r) => r.status == res.ReservationStatus.pending)
                .length
                .toString(),
            Icons.hourglass_empty,
            const Color(0xFFF57C00),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReservationsList() {
    final filteredReservations = reservations.where((reservation) {
      if (filter == 'Tümü') return true;
      if (filter == 'Bugün') {
        final now = DateTime.now();
        return reservation.date.year == now.year &&
            reservation.date.month == now.month &&
            reservation.date.day == now.day;
      }
      if (filter == 'Bu Hafta') {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return reservation.date.isAfter(weekStart) &&
            reservation.date.isBefore(weekEnd);
      }
      return true;
    }).toList();

    if (filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz rezervasyon yok.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReservations.length,
      itemBuilder: (context, index) {
        final reservation = filteredReservations[index];
        final business = widget.businesses.firstWhere(
          (b) => b.id == reservation.businessId,
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
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: reservation.status ==
                                res.ReservationStatus.confirmed
                            ? Colors.green.withAlpha(25)
                            : Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reservation.status == res.ReservationStatus.confirmed
                            ? 'Onaylı'
                            : 'Bekliyor',
                        style: TextStyle(
                          color: reservation.status ==
                                  res.ReservationStatus.confirmed
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      reservation.customerName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      reservation.customerPhone,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      reservation.time,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.group, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${reservation.partySize} Kişi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Rezervasyonu düzenle
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Düzenle'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Rezervasyonu iptal et
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('İptal Et'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              onTap: () {
                setState(() {
                  filter = 'Tümü';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Bugün'),
              onTap: () {
                setState(() {
                  filter = 'Bugün';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Bu Hafta'),
              onTap: () {
                setState(() {
                  filter = 'Bu Hafta';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReservationDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final partySizeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedBusinessId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Rezervasyon'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Müşteri Adı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: partySizeController,
                      decoration: const InputDecoration(
                        labelText: 'Kişi Sayısı',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
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
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        partySizeController.text.isNotEmpty &&
                        selectedBusinessId != null) {
                      final newReservation = res.Reservation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        businessId: selectedBusinessId!,
                        customerName: nameController.text,
                        customerPhone: phoneController.text,
                        date: selectedDate,
                        time: selectedTime.format(context),
                        partySize: int.parse(partySizeController.text),
                        status: res.ReservationStatus.pending,
                      );
                      setState(() {
                        reservations.add(newReservation);
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
}
