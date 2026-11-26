import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../services/governance_api_service.dart';

class GovernanceRegistrationOverviewScreen extends StatefulWidget {
  const GovernanceRegistrationOverviewScreen({super.key});

  @override
  State<GovernanceRegistrationOverviewScreen> createState() =>
      _GovernanceRegistrationOverviewScreenState();
}

class _GovernanceRegistrationOverviewScreenState
    extends State<GovernanceRegistrationOverviewScreen> {
  bool _isLoading = true;
  bool _isSendingReminder = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _periods = [];
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _groupsNotSubmitted = [];

  @override
  void initState() {
    super.initState();
    GovernanceApiService.instance.dataVersion.addListener(_onDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    GovernanceApiService.instance.dataVersion.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _loadData(forceRefresh: true);
  }

  Future<void> _loadData({bool forceRefresh = true}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        GovernanceApiService.instance.fetchCourses(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchGroups(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchRegistrationPeriods(),
        GovernanceApiService.instance.fetchGovernanceOverview(forceRefresh: forceRefresh),
        GovernanceApiService.instance.fetchGroupsNotSubmitted(),
      ]);

      if (!mounted) return;
      setState(() {
        _courses = results[0] as List<Map<String, dynamic>>;
        _groups = results[1] as List<Map<String, dynamic>>;
        _periods = results[2] as List<Map<String, dynamic>>;
        _overview = results[3] as Map<String, dynamic>;
        _groupsNotSubmitted = results[4] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu đăng ký đồ án: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePeriodStatus(int periodId, String currentStatus) async {
    final nextStatus = currentStatus == 'Đang mở' ? 'Đã đóng' : 'Đang mở';
    final actionText = nextStatus == 'Đang mở' ? 'Mở đợt đăng ký' : 'Đóng đợt đăng ký';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$actionText?'),
        content: Text(
          nextStatus == 'Đang mở'
              ? 'Sinh viên sẽ có thể tiếp tục đăng ký đề tài vào đợt này.'
              : 'Sinh viên sẽ không thể đăng ký thêm đề tài vào đợt này nữa.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: nextStatus == 'Đang mở'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await GovernanceApiService.instance.updatePeriodStatus(periodId, nextStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đợt đăng ký thành "$nextStatus".'),
            backgroundColor: nextStatus == 'Đang mở'
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  Future<void> _openStudentsWithoutGroupSheet({
    int? lopHocPhanId,
    String label = 'Toàn khoa',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentsWithoutGroupSheet(
        lopHocPhanId: lopHocPhanId,
        courseLabel: label,
      ),
    );
  }

  Future<void> _sendReminders({List<int>? nhomIds, String? targetName}) async {
    final count = nhomIds?.length ?? _groupsNotSubmitted.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Expanded(child: Text('Xác nhận gửi thông báo đôn đốc', style: TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(
          targetName != null
              ? 'Gửi thông báo đôn đốc nộp báo cáo tiến độ tới nhóm "$targetName"?'
              : 'Gửi thông báo đôn đốc nộp báo cáo tiến độ tới tất cả $count nhóm chưa nộp bài?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Xác nhận gửi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSendingReminder = true);
    try {
      final res = await GovernanceApiService.instance.sendGroupReminders(nhomIds: nhomIds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((res['message'] ?? 'Đã gửi thông báo đôn đốc thành công.').toString()),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi thông báo: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    } finally {
      if (mounted) setState(() => _isSendingReminder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text('Theo dõi đăng ký đồ án', en: 'Topic Registrations'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalGroups = _overview['totalGroups'] as int? ?? _groups.length;
    final approvedGroups = _overview['approvedGroups'] as int? ?? 0;
    final pendingGroups = _overview['pendingGroups'] as int? ?? 0;
    final groupsWithoutTopic = _overview['groupsWithoutTopic'] as int? ?? 0;
    final svNotInGroup = _overview['svNotInGroup'] as int? ?? 0;
    final svWithoutTopic = _overview['svWithoutTopic'] as int? ?? svNotInGroup;
    final gvTopics = _overview['gvTopics'] as int? ?? 0;
    final svTopics = _overview['svTopics'] as int? ?? 0;
    final gvPercent = ((_overview['gvPercent'] ?? 0) as num).toDouble();
    final svPercent = ((_overview['svPercent'] ?? 0) as num).toDouble();
    final approveRate = ((_overview['approveRate'] ?? 0) as num).toDouble();
    final approvedRegs = _overview['approvedRegs'] as int? ?? 0;
    final totalRegs = _overview['totalRegs'] as int? ?? 0;

    final courseStatsRaw = _overview['courseStats'] as List? ?? [];
    final courseStats = courseStatsRaw.isNotEmpty
        ? courseStatsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : _courses;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // ── 1. THỐNG KÊ TỔNG QUAN ─────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                title: 'Tổng nhóm đã đăng ký',
                value: '$totalGroups',
                icon: Icons.groups_outlined,
                color: const Color(0xFF2563EB),
              ),
              _buildStatCard(
                title: 'Nhóm đã được duyệt',
                value: '$approvedGroups',
                icon: Icons.task_alt,
                color: const Color(0xFF10B981),
              ),
              _buildStatCard(
                title: 'Nhóm chưa có đề tài',
                value: '$groupsWithoutTopic',
                icon: Icons.topic_outlined,
                color: const Color(0xFFD97706),
              ),
              _buildStatCard(
                title: 'SV chưa nhóm / đề tài',
                value: '$svWithoutTopic',
                icon: Icons.person_off_outlined,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openStudentsWithoutGroupSheet(label: 'Toàn khoa'),
              icon: const Icon(Icons.person_search_outlined, size: 18),
              label: Text(
                'Xem danh sách SV chưa đăng ký nhóm & chưa có đề tài ($svWithoutTopic SV)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── 2. TỶ LỆ ĐỀ TÀI GV vs SV & TỶ LỆ DUYỆT THỰC TẾ ──────────
          _sectionTitle('Thống kê Nguồn đề tài & Tỷ lệ duyệt'),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ratioBar(
                          label: 'GV đề xuất ($gvTopics)',
                          percent: gvPercent,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ratioBar(
                          label: 'SV tự đề xuất ($svTopics)',
                          percent: svPercent,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                totalRegs > 0
                                    ? 'Tỷ lệ duyệt: $approveRate% ($approvedRegs/$totalRegs lượt ĐK)'
                                    : 'Tỷ lệ duyệt thành công: $approveRate%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pendingGroups > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$pendingGroups chờ duyệt',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── 4. NHÓM CHƯA NỘP BÁO CÁO (đôn đốc) ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Nhóm chưa nộp bài (${_groupsNotSubmitted.length})'),
              if (_groupsNotSubmitted.isNotEmpty)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                  onPressed: _isSendingReminder ? null : () => _sendReminders(),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: const Text('Đôn đốc tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_groupsNotSubmitted.isEmpty)
            Card(
              elevation: 0,
              color: const Color(0xFFECFDF5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFA7F3D0)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tất cả nhóm đang hoạt động đều đã nộp báo cáo tiến độ.',
                        style: TextStyle(color: Color(0xFF065F46), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._groupsNotSubmitted.map((g) => _buildGroupNotSubmittedCard(g)),
          const SizedBox(height: 20),

          // ── 5. GIÁM SÁT THEO TỪNG MÔN HỌC ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Giám sát đăng ký theo Môn học'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${courseStats.length} Môn học',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (courseStats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppLocalizations.text('Chưa có dữ liệu môn học', en: 'No courses available'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...courseStats.map((c) {
              final lopHocPhanId = c['lopHocPhanId'] as int?;
              final name = c['tenHocPhan'] ?? c['tenLopHocPhan'] ?? 'Môn học';
              final code = c['maLopHocPhan'] ?? '';
              final gvTen = (c['giangVienTen'] ?? 'Chưa phân công').toString();
              final soSV = c['soSinhVien'] as int? ?? 0;
              final soNhom = c['soNhom'] as int? ?? 0;
              final approvedInClass = c['soNhomDaDuyet'] as int? ?? 0;
              final pendingInClass = c['soNhomChoDuyet'] as int? ?? 0;
              final noTopicInClass = c['soNhomChuaCoDeTai'] as int? ?? 0;
              final svNoGroupInClass = c['soSinhVienChuaCoNhom'] as int? ?? 0;
              final isAssigned = gvTen != 'Chưa phân công';

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.class_outlined, color: Color(0xFF2563EB), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$name ($code)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    color: Color(0xFF1E3A5F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$soSV SV · Tổng $soNhom nhóm · $svNoGroupInClass SV chưa có nhóm',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'GV: $gvTen',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isAssigned ? FontWeight.w500 : FontWeight.bold,
                                    color: isAssigned ? Colors.grey.shade700 : const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _metricBox(
                              'Đã duyệt',
                              '$approvedInClass nhóm',
                              const Color(0xFF059669),
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _metricBox(
                              'Chờ duyệt',
                              '$pendingInClass nhóm',
                              const Color(0xFF2563EB),
                              const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _metricBox(
                              'Chưa đề tài',
                              '$noTopicInClass nhóm',
                              const Color(0xFFD97706),
                              Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      if (lopHocPhanId != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            foregroundColor: const Color(0xFF2563EB),
                          ),
                          onPressed: () => _openStudentsWithoutGroupSheet(
                            lopHocPhanId: lopHocPhanId,
                            label: '$code',
                          ),
                          icon: const Icon(Icons.person_search_outlined, size: 16),
                          label: const Text(
                            'Xem SV chưa có nhóm / chưa có đề tài',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),

          // ── 6. ĐỢT ĐĂNG KÝ ───────────────────────────────────────────
          if (_periods.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(
                  AppLocalizations.text('Các đợt đăng ký đồ án', en: 'Registration Periods'),
                ),
                Text(
                  '${_periods.length} đợt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._periods.map((p) {
              final periodId = p['dotDangKyId'] as int? ?? p['id'] as int? ?? 0;
              final tenDot = p['tenDot'] as String? ?? 'Đợt đăng ký';
              final lop = p['tenLopHocPhan'] ?? p['maLopHocPhan'] ?? '';
              final trangThai = p['trangThai'] as String? ?? 'Chưa mở';
              final isOpen = trangThai == 'Đang mở';

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isOpen
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: isOpen ? const Color(0xFF10B981) : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tenDot, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (lop.toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text('$lop', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trangThai,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isOpen ? const Color(0xFF059669) : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          backgroundColor: isOpen
                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                              : const Color(0xFF10B981).withValues(alpha: 0.12),
                          foregroundColor: isOpen ? const Color(0xFFEF4444) : const Color(0xFF059669),
                        ),
                        onPressed: () => _togglePeriodStatus(periodId, trangThai),
                        child: Text(
                          isOpen ? 'Đóng đợt' : 'Mở đợt',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
    );
  }

  Widget _metricBox(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _ratioBar({required String label, required double percent, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('$percent%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupNotSubmittedCard(Map<String, dynamic> g) {
    final nhomId = g['nhomId'] as int?;
    final tenNhom = (g['tenNhom'] ?? g['TenNhom'] ?? 'Nhóm').toString();
    final maLop = (g['maLop'] ?? g['tenLop'] ?? '—').toString();
    final truong = (g['truongNhom'] ?? '—').toString();
    final email = (g['email'] ?? '').toString();
    final tenDeTai = (g['tenDeTai'] ?? 'Chưa có đề tài').toString();
    final soTV = g['thanhVienCount'] ?? 0;

    return Card(
      elevation: 0,
      color: const Color(0xFFFFF1F2),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFFECACA)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group_outlined, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenNhom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lớp: $maLop  ·  $soTV thành viên',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Text(
                    'Trưởng nhóm: $truong',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                  ),
                  Text(
                    'Đề tài: $tenDeTai',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                  ),
                  if (email.isNotEmpty)
                    Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5)),
                ],
              ),
            ),
            if (nhomId != null)
              IconButton(
                tooltip: 'Gửi đôn đốc nhóm này',
                onPressed: _isSendingReminder
                    ? null
                    : () => _sendReminders(nhomIds: [nhomId], targetName: tenNhom),
                icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2563EB)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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

class _StudentsWithoutGroupSheet extends StatefulWidget {
  final int? lopHocPhanId;
  final String courseLabel;

  const _StudentsWithoutGroupSheet({
    required this.lopHocPhanId,
    required this.courseLabel,
  });

  @override
  State<_StudentsWithoutGroupSheet> createState() =>
      _StudentsWithoutGroupSheetState();
}

class _StudentsWithoutGroupSheetState
    extends State<_StudentsWithoutGroupSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final list = await GovernanceApiService.instance.fetchStudentsWithoutGroup(
      lopHocPhanId: widget.lopHocPhanId,
      includeWithoutTopic: true,
    );
    if (!mounted) return;
    setState(() {
      _students = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SV chưa có nhóm / đề tài (${widget.courseLabel})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tìm thấy ${_students.length} sinh viên',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(
                        child: Text(
                          'Tất cả sinh viên đều đã đăng ký nhóm và đề tài!',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _students.length,
                        itemBuilder: (_, idx) {
                          final s = _students[idx];
                          final mssv = (s['mssv'] ?? s['MSSV'] ?? '—').toString();
                          final hoTen = (s['hoTen'] ?? s['HoTen'] ?? '—').toString();
                          final email = (s['email'] ?? s['Email'] ?? '—').toString();
                          final phone = (s['soDienThoai'] ?? '').toString().trim();
                          final lopNC = (s['lopNienChe'] ?? s['LopNienChe'] ?? '—').toString();
                          final statusLabel =
                              (s['trangThaiDangKy'] ?? 'Chưa đăng ký nhóm').toString();
                          final hasGroup = s['daCoNhom'] == true;

                          return Card(
                            elevation: 0,
                            color: const Color(0xFFFFF7ED),
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFFFED7AA)),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  hasGroup
                                      ? Icons.topic_outlined
                                      : Icons.person_off_outlined,
                                  color: const Color(0xFFD97706),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                hoTen,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$mssv · $lopNC',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  if (phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasGroup
                                          ? Colors.amber.withValues(alpha: 0.2)
                                          : const Color(0xFFEF4444)
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: hasGroup
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
