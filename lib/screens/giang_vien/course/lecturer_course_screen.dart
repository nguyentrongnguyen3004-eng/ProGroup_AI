import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../widgets/lecturer/lecturer_course_card.dart';
import 'lecturer_course_detail_screen.dart';
import '../../../models/lecturer_course_model.dart';

class LecturerCourseScreen extends StatefulWidget {
  const LecturerCourseScreen({super.key});

  @override
  State<LecturerCourseScreen> createState() => _LecturerCourseScreenState();
}

class _LecturerCourseScreenState extends State<LecturerCourseScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await CourseService().getMyClasses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
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
