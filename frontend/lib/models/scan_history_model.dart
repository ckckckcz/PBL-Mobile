class ScanHistory {
  final String id;
  final String imageUri;
  final String wasteType;
  final String category;
  final double confidence;
  final String description;
  final List<Map<String, String>> tips;
  final DateTime scanDate;

  ScanHistory({
    required this.id,
    required this.imageUri,
    required this.wasteType,
    required this.category,
    required this.confidence,
    required this.description,
    required this.tips,
    required this.scanDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUri': imageUri,
      'wasteType': wasteType,
      'category': category,
      'confidence': confidence,
      'description': description,
      'tips': tips,
      'scanDate': scanDate.toIso8601String(),
    };
  }

  // Create from JSON
  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] as String,
      imageUri: json['imageUri'] as String,
      wasteType: json['wasteType'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String,
      tips: (json['tips'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      scanDate: DateTime.parse(json['scanDate'] as String),
    );
  }

  // Format date for display
  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${scanDate.day} ${months[scanDate.month - 1]} ${scanDate.year}';
  }

  // Get icon based on category
  String get iconPath {
    final categoryLower = category.toLowerCase();
    // Handle both "Organik" and "Sampah Organik" formats
    if (categoryLower.contains('organik') &&
        !categoryLower.contains('anorganik')) {
      return 'assets/images/history/Organik.png';
    } else if (categoryLower.contains('anorganik')) {
      return 'assets/images/history/Anorganik.png';
    } else {
      return 'assets/images/history/Organik.png'; // default
    }
  }
}
