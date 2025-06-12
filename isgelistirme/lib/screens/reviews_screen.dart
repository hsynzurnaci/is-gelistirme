import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/business.dart';

class ReviewsScreen extends StatefulWidget {
  final List<Business> businesses;

  const ReviewsScreen({super.key, required this.businesses});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> reviews = [];
  String filter = 'Tümü';
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _loadReviews() {
    reviews = [
      Review(
        id: '1',
        businessId: '1',
        rating: 5,
        comment: 'Harika bir deneyimdi!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userName: 'Ahmet Y.',
        response: 'Teşekkür ederiz, sizi tekrar ağırlamaktan mutluluk duyarız.',
        responseDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Review(
        id: '2',
        businessId: '2',
        rating: 4,
        comment: 'Güzel bir mekan.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        userName: 'Mehmet K.',
      ),
    ];
  }

  void _showResponseDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yanıt Yaz'),
        content: TextField(
          controller: _responseController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Yanıtınızı buraya yazın...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _responseController.clear();
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_responseController.text.isNotEmpty) {
                setState(() {
                  final index = reviews.indexWhere((r) => r.id == review.id);
                  if (index != -1) {
                    reviews[index] = review.copyWith(
                      response: _responseController.text,
                      responseDate: DateTime.now(),
                    );
                  }
                });
                Navigator.pop(context);
                _responseController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Yorumlar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
              });
            },
            itemBuilder: (context) => [
              'Tümü',
              '5 Yıldız',
              '4 Yıldız',
              '3 Yıldız',
              '2 Yıldız',
              '1 Yıldız',
              'Yanıtlanmamış',
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
          _buildRatingSummary(),
          Expanded(
            child: _buildReviewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    final totalReviews = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) / totalReviews;
    final ratingCounts = List.generate(5, (index) {
      return reviews.where((review) => review.rating == 5 - index).length;
    });

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor()
                              ? Icons.star
                              : index < averageRating.ceil()
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: const Color(0xFFF57C00),
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '($totalReviews yorum)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) {
                  final count = ratingCounts[index];
                  final percentage =
                      totalReviews > 0 ? count / totalReviews : 0.0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${5 - index}',
                        style: const TextStyle(
                          color: Color(0xFFF57C00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          color: Color(0xFFF57C00), size: 16),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF57C00)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final filteredReviews = reviews.where((review) {
      if (filter == 'Tümü') return true;
      if (filter == 'Yanıtlanmamış') return review.response == null;
      final rating = int.parse(filter[0]);
      return review.rating == rating;
    }).toList();

    if (filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz yorum yok.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReviews.length,
      itemBuilder: (context, index) {
        final review = filteredReviews[index];
        final business = widget.businesses.firstWhere(
          (b) => b.id == review.businessId,
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
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFF57C00),
                            size: 20,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${review.date.day}/${review.date.month}/${review.date.year}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (review.response != null) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yanıt:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(review.response!),
                        const SizedBox(height: 4),
                        Text(
                          '${review.responseDate!.day}/${review.responseDate!.month}/${review.responseDate!.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (review.response == null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showResponseDialog(review),
                      icon: const Icon(Icons.reply),
                      label: const Text('Yanıtla'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
