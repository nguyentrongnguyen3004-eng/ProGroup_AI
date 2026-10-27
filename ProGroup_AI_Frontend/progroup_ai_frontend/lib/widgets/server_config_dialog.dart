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

  static const String usbUrl = 'http://127.0.0.1:5094';
  static const String lanUrl = ApiService.currentLanIpUrl; // http://192.168.1.109:5094
  static const String cloudflareUrl = ApiService.currentCloudflareUrl;

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
        _testResult = 'Không thể kết nối. Kiểm tra URL hoặc dịch vụ Backend.';
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
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã áp dụng máy chủ: $url',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _resetDefault() async {
    await ApiService.clearCustomBaseUrl();
    if (!mounted) return;

    setState(() {
      _urlController.text = usbUrl;
      _testResult = null;
    });

    _runPingTest(usbUrl);
  }

  Widget _buildPresetCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String url,
    required String badge,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cardBg = isDark
        ? (isSelected ? const Color(0xFF1E293B) : const Color(0xFF111827))
        : (isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC));

    final borderColor = isSelected
        ? AppTheme.primaryColor
        : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0));

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      color: subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final inputBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    final currentUrl = _urlController.text.trim();

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Indicator handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header bar
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.dns_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cấu hình Máy chủ Backend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Chọn phương thức kết nối tới hệ thống',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: subtitleColor,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // URL Input field
              Text(
                'ĐỊA CHỈ MÁY CHỦ (API URL)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: inputBorder),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.link_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: 'http://127.0.0.1:5094',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IconButton(
                        tooltip: 'Kiểm tra kết nối',
                        onPressed: _testing ? null : () => _runPingTest(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFFD97706),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _testing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFD97706),
                                ),
                              )
                            : const Icon(Icons.bolt_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Ping result status badge
              if (_testResult != null) ...[
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _testSuccess
                        ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                        : const Color(0xFFDC2626).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _testSuccess
                          ? const Color(0xFF16A34A).withValues(alpha: 0.4)
                          : const Color(0xFFDC2626).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 18,
                        color: _testSuccess
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _testSuccess
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Presets Title
              Text(
                'PHƯƠNG THỨC KẾT NỐI KHUYÊN DÙNG',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),

              // Option 1: USB Cable (ADB Reverse)
              _buildPresetCard(
                context: context,
                isDark: isDark,
                title: 'Cáp USB',
                url: usbUrl,
                badge: 'Khuyên dùng • 0ms',
                icon: Icons.usb_rounded,
                iconColor: const Color(0xFF10B981),
                isSelected: currentUrl == usbUrl,
                onTap: () {
                  setState(() => _urlController.text = usbUrl);
                  _runPingTest(usbUrl);
                },
              ),

              const SizedBox(height: 8),

              // Option 2: Wi-Fi LAN
              _buildPresetCard(
                context: context,
                isDark: isDark,
                title: 'Wi-Fi Nội bộ (LAN)',
                url: lanUrl,
                badge: 'Chung Wi-Fi',
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xFF2563EB),
                isSelected: currentUrl == lanUrl,
                onTap: () {
                  setState(() => _urlController.text = lanUrl);
                  _runPingTest(lanUrl);
                },
              ),

              const SizedBox(height: 8),

              // Option 3: Cloudflare Tunnel
              _buildPresetCard(
                context: context,
                isDark: isDark,
                title: 'Cloudflare Tunnel',
                url: cloudflareUrl,
                badge: '4G / Internet',
                icon: Icons.cloud_queue_rounded,
                iconColor: const Color(0xFF8B5CF6),
                isSelected: currentUrl == cloudflareUrl,
                onTap: () {
                  setState(() => _urlController.text = cloudflareUrl);
                  _runPingTest(cloudflareUrl);
                },
              ),

              const SizedBox(height: 22),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetDefault,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : const Color(0xFF475569),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Mặc định',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Lưu & Áp dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
