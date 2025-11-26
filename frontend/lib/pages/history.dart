import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/scan_history_model.dart';
import '../services/scan_history_service.dart';
import '../widgets/history_widgets.dart';
import 'scan_result.dart';

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
    setState(() => _isLoading = true);

    final history = await _historyService.getHistory();

    // Add dummy data if history is empty (for demo purposes)
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
        description:
            'Sampah organik berupa sisa makanan yang dapat diuraikan secara alami. Cocok untuk dijadikan kompos.',
        tips: [
          {'title': 'Pisahkan dari sampah anorganik', 'color': '#4CAF50'},
          {
            'title': 'Dapat dijadikan kompos untuk pupuk tanaman',
            'color': '#4CAF50'
          },
          {
            'title': 'Simpan di tempat tertutup untuk menghindari bau',
            'color': '#4CAF50'
          },
        ],
        scanDate: now.subtract(const Duration(hours: 2)),
      ),
      ScanHistory(
        id: 'dummy_2',
        imageUri: 'assets/images/history/Anorganik.png',
        wasteType: 'Botol Plastik',
        category: 'Anorganik',
        confidence: 92.3,
        description:
            'Sampah anorganik berupa botol plastik yang dapat didaur ulang. Pastikan botol bersih sebelum didaur ulang.',
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
        description:
            'Sampah organik berupa dedaunan kering. Sangat baik untuk dijadikan kompos atau mulsa tanaman.',
        tips: [
          {'title': 'Cacah daun agar lebih cepat terurai', 'color': '#4CAF50'},
          {'title': 'Campurkan dengan tanah untuk kompos', 'color': '#4CAF50'},
          {
            'title': 'Dapat digunakan sebagai mulsa di taman',
            'color': '#4CAF50'
          },
        ],
        scanDate: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> _handleClearAllHistory() async {
    final confirmed = await HistoryDialogs.showClearAllConfirmation(context);

    if (confirmed == true) {
      await _historyService.clearHistory();
      await _loadHistory();

      if (mounted) {
        HistoryDialogs.showSuccessSnackBar(
          context,
          AppStrings.allHistoryDeleted,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return HistoryHeader(
      hasHistory: _historyList.isNotEmpty,
      onClearAll: _handleClearAllHistory,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_historyList.isEmpty) {
      return const HistoryEmptyState();
    }

    return _buildHistoryList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildHistoryList() {
    return HistoryList(
      historyList: _historyList,
      onRefresh: _loadHistory,
      onItemTap: _navigateToDetail,
    );
  }
}
