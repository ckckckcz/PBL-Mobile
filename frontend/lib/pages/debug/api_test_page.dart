import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final _apiService = ApiService();
  bool _isRunning = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _addLog('API Test Page initialized');
    _addLog('Base URL: ${ApiService.baseUrl}');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('Logs cleared');
  }

  Future<void> _runAllTests() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _clearLogs();
    _addLog('🔥 Starting comprehensive diagnostics...');
    _addLog('');

    try {
      await _apiService.runDiagnostics();
      _addLog('');
      _addLog('✅ All diagnostics completed!');
    } catch (e) {
      _addLog('❌ Diagnostics error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testHealthCheck() async {
    _addLog('');
    _addLog('🏥 Testing Health Check...');
    try {
      final result = await _apiService.testConnection();
      _addLog(result ? '✅ Health check PASSED' : '❌ Health check FAILED');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testAuthEndpoint() async {
    _addLog('');
    _addLog('🔐 Testing Auth Endpoint...');
    try {
      final result = await _apiService.testAuthEndpoint();
      if (result['success']) {
        _addLog('✅ Auth endpoint accessible');
        _addLog('   Response: ${result['data']}');
      } else {
        _addLog('❌ Auth endpoint failed');
        _addLog('   Error: ${result['error']}');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testLogin() async {
    _addLog('');
    _addLog('🔑 Testing Login Endpoint...');
    _addLog('   Using test credentials...');
    try {
      final result = await _apiService.login(
        email: 'test@example.com',
        password: 'testpass123',
      );

      if (result['success'] == true) {
        _addLog('✅ Login successful (unexpected - test credentials)');
      } else {
        // Expected to fail with invalid credentials
        _addLog('✅ Login endpoint reachable');
        _addLog('   Response: ${result['message']}');
        _addLog('   (This is expected with test credentials)');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Diagnostics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: 'Copy Logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoSection(),
          _buildTestButtons(),
          const Divider(height: 1),
          _buildLogsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Server Configuration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Base URL', ApiService.baseUrl),
          _buildInfoRow('Login Endpoint', ApiService.loginEndpoint),
          _buildInfoRow('Full Login URL',
              '${ApiService.baseUrl}${ApiService.loginEndpoint}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runAllTests,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Running Tests...' : 'Run All Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRunning ? null : _testHealthCheck,
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text('Health', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRunning ? null : _testAuthEndpoint,
                  icon: const Icon(Icons.security, size: 18),
                  label: const Text('Auth', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRunning ? null : _testLogin,
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Login', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    return Expanded(
      child: Container(
        color: Colors.black,
        child: _logs.isEmpty
            ? const Center(
                child: Text(
                  'No logs yet. Run tests to see output.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color textColor = Colors.white;

                  if (log.contains('✅')) {
                    textColor = Colors.greenAccent;
                  } else if (log.contains('❌')) {
                    textColor = Colors.redAccent;
                  } else if (log.contains('⚠️')) {
                    textColor = Colors.orangeAccent;
                  } else if (log.contains('🔥') ||
                      log.contains('🏥') ||
                      log.contains('🔐') ||
                      log.contains('🔑')) {
                    textColor = Colors.cyanAccent;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: SelectableText(
                      log,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
