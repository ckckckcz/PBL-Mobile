import 'package:flutter/material.dart';
import '../models/scan_history_model.dart';
import '../services/scan_history_service.dart';
import 'scan_result.dart';
import 'dart:io';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScanHistoryService _historyService = ScanHistoryService();
  List<ScanHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await _historyService.getHistory();

    // Add dummy data if history is empty
    if (history.isEmpty) {
      final dummyData = _createDummyData();
      setState(() {
        _historyList = dummyData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _historyList = history;
        _isLoading = false;
      });
    }
  }

  List<ScanHistory> _createDummyData() {
    final now = DateTime.now();

    return [
      ScanHistory(
        id: 'dummy_1',
        imageUri: 'assets/images/history/Organik.png',
        wasteType: 'Sisa Makanan',
        category: 'Organik',
        confidence: 95.8,
        description: 'Sampah organik berupa sisa makanan yang dapat diuraikan secara alami. Cocok untuk dijadikan kompos.',
        tips: [
          {'title': 'Pisahkan dari sampah anorganik', 'color': '#4CAF50'},
          {'title': 'Dapat dijadikan kompos untuk pupuk tanaman', 'color': '#4CAF50'},
          {'title': 'Simpan di tempat tertutup untuk menghindari bau', 'color': '#4CAF50'},
        ],
        scanDate: now.subtract(const Duration(hours: 2)),
      ),
      ScanHistory(
        id: 'dummy_2',
        imageUri: 'assets/images/history/Anorganik.png',
        wasteType: 'Botol Plastik',
        category: 'Anorganik',
        confidence: 92.3,
        description: 'Sampah anorganik berupa botol plastik yang dapat didaur ulang. Pastikan botol bersih sebelum didaur ulang.',
        tips: [
          {'title': 'Cuci botol sebelum didaur ulang', 'color': '#2196F3'},
          {'title': 'Lepaskan label dan tutup botol', 'color': '#2196F3'},
          {'title': 'Kumpulkan dan jual ke bank sampah', 'color': '#2196F3'},
        ],
        scanDate: now.subtract(const Duration(days: 1)),
      ),
      ScanHistory(
        id: 'dummy_3',
        imageUri: 'assets/images/history/Organik.png',
        wasteType: 'Daun Kering',
        category: 'Organik',
        confidence: 88.5,
        description: 'Sampah organik berupa dedaunan kering. Sangat baik untuk dijadikan kompos atau mulsa tanaman.',
        tips: [
          {'title': 'Cacah daun agar lebih cepat terurai', 'color': '#4CAF50'},
          {'title': 'Campurkan dengan tanah untuk kompos', 'color': '#4CAF50'},
          {'title': 'Dapat digunakan sebagai mulsa di taman', 'color': '#4CAF50'},
        ],
        scanDate: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> _deleteScan(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.deleteScan(id);
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus')),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua riwayat berhasil dihapus')),
        );
      }
    }
  }

  void _navigateToDetail(ScanHistory scan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultPage(
          imageUri: scan.imageUri,
          wasteType: scan.wasteType,
          category: scan.category,
          confidence: scan.confidence,
          description: scan.description,
          tips: scan.tips,
        ),
      ),
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _historyList.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Riwayat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3A2F),
            ),
          ),
          if (_historyList.isNotEmpty)
            IconButton(
              onPressed: _clearAllHistory,
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFF607D6B),
              ),
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A2F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai pindai sampah untuk melihat riwayat di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF607D6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final scan = _historyList[index];
          return _buildHistoryItem(scan);
        },
      ),
    );
  }

  Widget _buildHistoryItem(ScanHistory scan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(scan),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFF5F5F5),
                    child: _buildHistoryImage(scan),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.wasteType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3A2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          scan.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            scan.formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF607D6B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.verified,
                            size: 12,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${scan.confidence.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  onPressed: () => _deleteScan(scan.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryImage(ScanHistory scan) {
    // Check if it's an asset image
    if (scan.imageUri.startsWith('assets/')) {
      return Image.asset(
        scan.imageUri,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            scan.category.toLowerCase().contains('organik')
                ? Icons.eco
                : Icons.recycling,
            color: const Color(0xFF4CAF50),
            size: 32,
          );
        },
      );
    }

    // Check if it's a file path
    final file = File(scan.imageUri);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }

    // Fallback icon
    return Icon(
      scan.category.toLowerCase().contains('organik')
          ? Icons.eco
          : Icons.recycling,
      color: const Color(0xFF4CAF50),
      size: 32,
    );
  }
}
