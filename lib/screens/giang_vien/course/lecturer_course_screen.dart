<<<<<<< HEAD
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../models/lecturer_course_model.dart';
import '../../../services/lecturer_api_service.dart';
=======
﻿import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
>>>>>>> origin/Frontend
import '../../../widgets/lecturer/lecturer_course_card.dart';
import 'lecturer_course_detail_screen.dart';
import '../../../models/lecturer_course_model.dart';

class LecturerCourseScreen extends StatefulWidget {
  const LecturerCourseScreen({super.key});

  @override
  State<LecturerCourseScreen> createState() => _LecturerCourseScreenState();
}

class _LecturerCourseScreenState extends State<LecturerCourseScreen> {
<<<<<<< HEAD
  bool _isLoading = true;
  String? _errorMessage;
  List<LecturerCourseModel> _courses = [];
=======
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;
>>>>>>> origin/Frontend

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final courses = await LecturerApiService.instance.fetchCourses();
=======
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await CourseService().getMyClasses();
>>>>>>> origin/Frontend
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
<<<<<<< HEAD
          _errorMessage = e.toString().replaceAll('Exception: ', '');
=======
          _error = e.toString();
>>>>>>> origin/Frontend
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.text('Lớp Học Phần', en: 'Courses'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.text('Lớp Học Phần', en: 'Courses'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: colors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() { _isLoading = true; _error = null; });
                  _fetchCourses();
                },
                child: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
<<<<<<< HEAD
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Gradient Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.text('Lớp học phần', en: 'Course Classes'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.text(
                            'Danh sách các lớp học phần được phân công',
                            en: 'List of assigned course classes',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: _loadCourses,
                    tooltip: 'Tải lại',
                  ),
                ],
              ),
            ),

            Expanded(
              child: _buildBody(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCourses,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.text('Thử lại', en: 'Retry')),
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

    if (_courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadCourses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded, size: 56, color: colors.outlineVariant),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.text(
                          'Chưa có lớp học phần được phân công.',
                          en: 'No assigned course classes yet.',
=======
      appBar: AppBar(
        title: Text(AppLocalizations.text('Lớp Học Phần', en: 'Courses')),
      ),
      body: _courses.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.text('Chưa có lớp học phần nào.', en: 'No courses available.'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LecturerCourseCard(
                    course: course,
                    onTap: () {
                      LecturerCourseModel fakeModel = LecturerCourseModel(
                        id: course.id,
                        courseId: course.id,
                        code: course.code,
                        name: course.name,
                        classCode: course.code,
                        semester: course.semester,
                        studentCount: 40,
                        groupCount: 0,
                        topicCount: 0,
                        groupRegistrationStart: '2024-01-01',
                        groupRegistrationEnd: '2024-01-01',
                        topicRegistrationStart: '2024-01-01',
                        topicRegistrationEnd: '2024-01-01',
                        minMembers: 3,
                        maxMembers: 5,
                        status: 'Đang mở'
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LecturerCourseDetailScreen(course: fakeModel),
>>>>>>> origin/Frontend
                        ),
                        style: TextStyle(color: colors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LecturerCourseCard(
              course: course,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LecturerCourseDetailScreen(course: course),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
