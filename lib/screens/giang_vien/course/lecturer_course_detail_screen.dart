import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../../../core/localization/app_localizations.dart';
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/lecturer_api_service.dart';
=======
import '../../../models/group_model.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../models/topic_model.dart';
import '../../../services/group_service.dart';
import '../../../services/topic_service.dart';
>>>>>>> origin/Frontend
import '../../../widgets/lecturer/lecturer_group_card.dart';
import '../group/lecturer_group_detail_screen.dart';
import '../group/lecturer_group_screen.dart';
import '../topic/lecturer_topic_screen.dart';
import 'lecturer_course_settings_screen.dart';

class LecturerCourseDetailScreen extends StatefulWidget {
  final LecturerCourseModel course;

  const LecturerCourseDetailScreen({super.key, required this.course});

  @override
  State<LecturerCourseDetailScreen> createState() =>
      _LecturerCourseDetailScreenState();
}

class _LecturerCourseDetailScreenState
    extends State<LecturerCourseDetailScreen> {
<<<<<<< HEAD
  late LecturerCourseModel _course;
  bool _isLoading = true;
  String? _errorMessage;
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  List<Map<String, dynamic>> _registrations = [];
=======
  late LecturerCourseModel course;
  List<GroupModel> _groups = [];
  List<TopicModel> _topics = [];
  bool _isLoading = true;
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _course = widget.course;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        LecturerApiService.instance.fetchGroups(_course.courseId),
        LecturerApiService.instance.fetchTopics(_course.courseId),
        LecturerApiService.instance.fetchTopicRegistrations(_course.courseId),
      ]);

      if (mounted) {
        setState(() {
          _groups = results[0] as List<GroupModel>;
          _topics = results[1] as List<TopicModel>;
          _registrations = results[2] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
=======
    course = widget.course;
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);
    try {
      final groups = await GroupService().getGroupsByCourse(course.courseId);
      final topics = await TopicService().getLecturerTopics(dotDangKyId: course.courseId);
      if (mounted) {
        setState(() {
          _groups = groups;
          _topics = topics;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
>>>>>>> origin/Frontend
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lớp học phần')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(
          AppLocalizations.text(
            'Chi tiết lớp học phần',
            en: 'Course Details',
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 40),
                          const SizedBox(height: 12),
                          Text(_errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
=======
        title: const Text('Chi tiết lớp học phần'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourseData,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.school_outlined,
                      size: 30,
                      color: colors.onPrimaryContainer,
>>>>>>> origin/Frontend
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                      children: [
                        // Hero Course Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.courseName(_course.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${_course.code} • ${_course.classCode}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _course.semester,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4-Card Mini Stat Grid
                        Row(
                          children: [
                            Expanded(
                              child: _StatGridCard(
                                icon: Icons.people_alt_rounded,
                                iconColor: const Color(0xFF2563EB),
                                title: '${_course.studentCount}',
                                label: AppLocalizations.text('Sinh viên', en: 'Students'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatGridCard(
                                icon: Icons.groups_rounded,
                                iconColor: const Color(0xFF10B981),
                                title: '${_groups.length}',
                                label: AppLocalizations.text('Nhóm', en: 'Groups'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatGridCard(
                                icon: Icons.lightbulb_rounded,
                                iconColor: const Color(0xFFF59E0B),
                                title: '${_topics.length}',
                                label: AppLocalizations.text('Đề tài', en: 'Topics'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatGridCard(
                                icon: Icons.assignment_turned_in_rounded,
                                iconColor: const Color(0xFF8B5CF6),
                                title: '${_registrations.length}',
                                label: AppLocalizations.text('Đăng ký', en: 'Registrations'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Deadlines & Settings Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(alpha: 0.35),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 18,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.text('Lịch trình & Giới hạn', en: 'Deadlines & Limits'),
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _DetailRow(
                                icon: Icons.group_add_rounded,
                                iconColor: const Color(0xFF2563EB),
                                label: AppLocalizations.text('Hạn lập nhóm', en: 'Group creation'),
                                value: '${_course.groupRegistrationStart} – ${_course.groupRegistrationEnd}',
                              ),
                              const SizedBox(height: 10),
                              _DetailRow(
                                icon: Icons.assignment_rounded,
                                iconColor: const Color(0xFFF59E0B),
                                label: AppLocalizations.text('Hạn đăng ký đề tài', en: 'Topic registration'),
                                value: '${_course.topicRegistrationStart} – ${_course.topicRegistrationEnd}',
                              ),
                              const SizedBox(height: 10),
                              _DetailRow(
                                icon: Icons.people_outline_rounded,
                                iconColor: const Color(0xFF10B981),
                                label: AppLocalizations.text('Quy mô mỗi nhóm', en: 'Group size'),
                                value: '${_course.minMembers} – ${_course.maxMembers} ${AppLocalizations.text('thành viên', en: 'members')}',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final updated = await Navigator.push<LecturerCourseModel>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                LecturerCourseSettingsScreen(course: _course),
                                          ),
                                        );
                                        if (updated != null && mounted) {
                                          setState(() => _course = updated);
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.tune_rounded, size: 17),
                                      label: Text(
                                        AppLocalizations.text('Cấu hình', en: 'Settings'),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LecturerStatisticsScreen(
                                            initialCourseId: _course.courseId,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.analytics_rounded, size: 17),
                                      label: Text(
                                        AppLocalizations.text('Thống kê', en: 'Analytics'),
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionHeading(
                          title: AppLocalizations.text(
                            'Nhóm của học phần',
                            en: 'Course Groups',
                          ),
                          trailing: Text('${_groups.length}'),
                        ),
                        const SizedBox(height: 8),
                        if (_groups.isEmpty)
                          _EmptyCard(
                            message: AppLocalizations.text(
                              'Học phần chưa có nhóm.',
                              en: 'No groups in this course yet.',
                            ),
                          )
                        else
                          ..._groups
                              .take(3)
                              .map(
                                (group) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: LecturerGroupCard(
                                    group: group,
                                    minMembers: _course.minMembers,
                                    maxMembers: _course.maxMembers,
                                    onTap: () => _openGroup(context, group),
                                  ),
                                ),
                              ),
                        if (_groups.isNotEmpty)
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LecturerGroupScreen(course: _course),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.groups_outlined),
                              label: Text(
                                AppLocalizations.text(
                                  'Xem tất cả nhóm',
                                  en: 'View all groups',
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        _SectionHeading(
                          title: AppLocalizations.text(
                            'Đề tài của học phần',
                            en: 'Course Topics',
                          ),
                          trailing: Text('${_topics.length}'),
                        ),
                        const SizedBox(height: 8),
                        if (_topics.isEmpty)
                          _EmptyCard(
                            message: AppLocalizations.text(
                              'Học phần chưa có đề tài.',
                              en: 'No topics in this course yet.',
                            ),
                          )
                        else
                          ..._topics.take(4).map(
                            (topic) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TopicPreview(topic: topic),
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LecturerTopicScreen(lecturerCourseId: _course.courseId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.lightbulb_outline),
                            label: Text(
                              AppLocalizations.text(
                                'Quản lý đề tài của học phần',
                                en: 'Manage course topics',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
<<<<<<< HEAD
=======
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _Info(label: 'Học kỳ', value: course.semester),
                  _Info(label: 'Sinh viên tối đa', value: '${course.studentCount}'),
                  _Info(label: 'Nhóm', value: '${_groups.length}'),
                  _Info(label: 'Đề tài', value: '${_topics.length}'),
                  _Info(
                    label: 'Số thành viên mỗi nhóm',
                    value: '${course.minMembers} - ${course.maxMembers}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian đăng ký',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _Info(
                    label: 'Lập nhóm',
                    value:
                        '${course.groupRegistrationStart} – ${course.groupRegistrationEnd}',
                  ),
                  _Info(
                    label: 'Đăng ký đề tài',
                    value:
                        '${course.topicRegistrationStart} – ${course.topicRegistrationEnd}',
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<LecturerCourseModel>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LecturerCourseSettingsScreen(course: course),
                        ),
                      );
                      if (updated != null && mounted) {
                        setState(() => course = updated);
                      }
                    },
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Cấu hình thời gian và quy mô nhóm'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: 'Nhóm của học phần',
            trailing: Text('${_groups.length}'),
          ),
          const SizedBox(height: 8),
          if (_groups.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có nhóm.')
          else
            ..._groups
                .take(3)
                .map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LecturerGroupCard(
                      group: group,
                      onTap: () => _openGroup(context, group),
                    ),
                  ),
                ),
          if (_groups.isNotEmpty)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LecturerGroupScreen(course: course),
                    ),
                  );
                },
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Xem tất cả nhóm'),
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeading(
            title: 'Đề tài của học phần',
            trailing: Text('${_topics.length}'),
          ),
          const SizedBox(height: 8),
          if (_topics.isEmpty)
            const _EmptyCard(message: 'Học phần chưa có đề tài.')
          else
            ..._topics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TopicPreview(topic: topic),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LecturerTopicScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Quản lý đề tài của học phần'),
            ),
          ),
        ],
>>>>>>> origin/Frontend
      ),
    );
  }

  void _openGroup(BuildContext context, GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(
<<<<<<< HEAD
        builder: (_) => LecturerGroupDetailScreen(course: _course, group: group),
=======
        builder: (_) => LecturerGroupDetailScreen(group: group),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
>>>>>>> origin/Frontend
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeading({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _TopicPreview extends StatelessWidget {
  final TopicModel topic;

  const _TopicPreview({required this.topic});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
        ),
        title: Text(
          AppLocalizations.topicText(topic.title),
          maxLines: 1,
=======
    return Card(
      child: ListTile(
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          topic.description.isNotEmpty ? topic.description : 'Chưa có mô tả',
          maxLines: 2,
>>>>>>> origin/Frontend
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '${topic.technology} • ${AppLocalizations.status(topic.status)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            topic.status,
            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _StatGridCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String label;

  const _StatGridCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
