import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _urlController;
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final current = ApiService.workingBaseUrl ?? ApiService.baseUrls.first;
    _urlController = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _runPingTest([String? targetUrl]) async {
    final url = targetUrl ?? _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final stopwatch = Stopwatch()..start();
    final ok = await ApiService.testConnection(url);
    stopwatch.stop();

    if (!mounted) return;

    setState(() {
      _testing = false;
      _testSuccess = ok;
      if (ok) {
        _testResult = 'Kết nối thành công (${stopwatch.elapsedMilliseconds} ms)';
      } else {
        _testResult = 'Không thể kết nối. Vui lòng kiểm tra lại URL hoặc kết nối mạng.';
      }
    });
  }

  Future<void> _save() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    await ApiService.saveCustomBaseUrl(url);
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã kết nối máy chủ: $url'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resetDefault() async {
    await ApiService.clearCustomBaseUrl();
    if (!mounted) return;

    setState(() {
      _urlController.text = ApiService.baseUrls.first;
      _testResult = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã khôi phục địa chỉ máy chủ mặc định'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dns_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấu hình Máy chủ Backend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tùy chỉnh IP hoặc đường hầm kết nối',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Input field
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Địa chỉ Backend API (URL)',
                hintText: 'https://... hoặc http://192.168.x.x:5094',
                prefixIcon: const Icon(Icons.link_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Kiểm tra kết nối',
                  icon: _testing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt_rounded, color: Colors.orange),
                  onPressed: _testing ? null : () => _runPingTest(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.url,
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _testSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _testSuccess
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 18,
                      color: _testSuccess
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: _testSuccess
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            const Text(
              'Gợi ý máy chủ đang khả dụng:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Quick select chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.wifi_rounded, size: 16, color: Colors.blue),
                  label: const Text('Wi-Fi LAN (192.168.1.109:5094)'),
                  onPressed: () {
                    _urlController.text = ApiService.currentLanIpUrl;
                    _runPingTest(ApiService.currentLanIpUrl);
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.cloud_queue_rounded, size: 16, color: Colors.purple),
                  label: const Text('Cloudflare Tunnel (Internet/4G)'),
                  onPressed: () {
                    _urlController.text = ApiService.currentCloudflareUrl;
                    _runPingTest(ApiService.currentCloudflareUrl);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetDefault,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Mặc định'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Lưu & Áp dụng'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
