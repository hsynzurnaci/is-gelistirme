import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/note.dart';
import '../models/review.dart';
import '../services/notification_service.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Business business;
  final void Function(Business updatedBusiness)? onUpdate;
  final VoidCallback? onDelete;

  const BusinessDetailScreen(
      {super.key, required this.business, this.onUpdate, this.onDelete});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final _noteController = TextEditingController();
  final _reviewController = TextEditingController();
  final _reviewRatingController = TextEditingController();
  List<Note> notes = [];
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    reviews = widget.business.reviews;
  }

  void showEditDialog() {
    final nameController = TextEditingController(text: widget.business.name);
    final addressController =
        TextEditingController(text: widget.business.address);
    final descController =
        TextEditingController(text: widget.business.description);
    final ratingController =
        TextEditingController(text: widget.business.rating.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İşletmeyi Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Adı'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Adres'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Puan (0-5)'),
                  keyboardType: TextInputType.number,
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
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                final desc = descController.text.trim();
                final rating = double.tryParse(ratingController.text) ?? 0.0;
                if (name.isNotEmpty && address.isNotEmpty) {
                  final updated = Business(
                    id: widget.business.id,
                    name: name,
                    address: address,
                    description: desc,
                    documents: widget.business.documents,
                    rating: rating,
                    category: widget.business.category,
                  );
                  widget.onUpdate?.call(updated);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşletmeyi Sil'),
        content: const Text('Bu işletmeyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete?.call();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void addNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        notes.add(Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: _noteController.text,
          createdAt: DateTime.now(),
        ));
        _noteController.clear();
      });
    }
  }

  void deleteNote(String id) {
    setState(() {
      notes.removeWhere((note) => note.id == id);
    });
  }

  void addReview() {
    if (_reviewController.text.isNotEmpty &&
        _reviewRatingController.text.isNotEmpty) {
      final rating = double.tryParse(_reviewRatingController.text);
      if (rating != null && rating >= 0 && rating <= 5) {
        final review = Review(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          businessId: widget.business.id,
          userName: 'Kullanıcı',
          comment: _reviewController.text,
          rating: rating.toInt(),
          date: DateTime.now(),
        );

        setState(() {
          reviews.add(review);
          _reviewController.clear();
          _reviewRatingController.clear();
        });

        // İşletmenin ortalama puanını güncelle
        final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;
        widget.onUpdate?.call(widget.business.copyWith(
          rating: avgRating,
          category: widget.business.category,
        ));
      }
    }
  }

  void showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirme Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reviewRatingController,
              decoration: const InputDecoration(
                labelText: 'Puan (0-5)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Yorumunuz',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              addReview();
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void showAddReminderDialog() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hatırlatıcı Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDate = date;
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
                    selectedTime = time;
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
                final scheduledDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                NotificationService().scheduleNotification(
                  title: 'İşletme Hatırlatıcısı',
                  body:
                      '${widget.business.name} için planlanan görüşme zamanı geldi.',
                  scheduledDate: scheduledDate,
                  id: widget.business.id.hashCode,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hatırlatıcı eklendi'),
                  ),
                );
                Navigator.pop(context);
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
    // Notları tarihe göre sırala (en yeni en üstte)
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Değerlendirmeleri tarihe göre sırala (en yeni en üstte)
    reviews.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.business.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: showAddReminderDialog,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.business.photoUrl != null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.business.photoUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.business.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.business.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, widget.business.address),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.category, widget.business.category),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.description, widget.business.description),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Değerlendirmeler',
              Icons.rate_review,
              reviews.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Henüz değerlendirme yapılmamış.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.white, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          review.rating.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment),
                              const SizedBox(height: 8),
                              Text(
                                '${review.date.day}/${review.date.month}/${review.date.year}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Notlar',
              Icons.note,
              Column(
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Not ekle...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: addNote,
                    icon: const Icon(Icons.add),
                    label: const Text('Not Ekle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => deleteNote(note.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(note.content),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
