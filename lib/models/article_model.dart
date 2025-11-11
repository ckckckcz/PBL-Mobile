class Article {
  final String title;
  final String description;
  final String iconEmoji;
  final String? imageUrl;

  Article({
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.imageUrl,
  });

  static List<Article> getSampleArticles() {
    return [
      Article(
        title: 'Pemilahan Sampah Organik',
        description:
            'Sampah organik adalah sampah yang berasal dari makhluk hidup dan dapat terurai secara alami. Contoh: sisa makanan, daun, dan kulit buah.',
        iconEmoji: '🌱',
      ),
      Article(
        title: 'Sampah Anorganik & Daur Ulang',
        description:
            'Sampah anorganik tidak dapat terurai secara alami. Pisahkan plastik, kertas, logam, dan kaca untuk didaur ulang.',
        iconEmoji: '♻️',
      ),
      Article(
        title: 'Kompos dari Rumah',
        description:
            'Ubah sampah organik menjadi kompos berkualitas untuk tanaman Anda. Proses sederhana yang berdampak besar!',
        iconEmoji: '🪴',
      ),
      Article(
        title: 'Kurangi Penggunaan Plastik',
        description:
            'Plastik membutuhkan ratusan tahun untuk terurai. Mari beralih ke alternatif ramah lingkungan seperti tas kain dan botol minum.',
        iconEmoji: '🛍️',
      ),
      Article(
        title: 'Dampak Sampah bagi Laut',
        description:
            'Setiap tahun, jutaan ton sampah plastik mencemari lautan kita. Ayo jaga kebersihan pantai dan laut!',
        iconEmoji: '🌊',
      ),
    ];
  }
}

class EcoTip {
  final String title;
  final String emoji;

  EcoTip({required this.title, required this.emoji});

  static List<EcoTip> getTips() {
    return [
      EcoTip(title: 'Pisahkan sampah organik & anorganik', emoji: '♻️'),
      EcoTip(title: 'Kurangi penggunaan plastik sekali pakai', emoji: '🛍️'),
      EcoTip(title: 'Buat kompos dari sampah dapur', emoji: '🌱'),
      EcoTip(title: 'Gunakan tas belanja yang bisa dipakai ulang', emoji: '👜'),
      EcoTip(title: 'Daur ulang kertas, botol, dan kaleng', emoji: '📦'),
    ];
  }
}
