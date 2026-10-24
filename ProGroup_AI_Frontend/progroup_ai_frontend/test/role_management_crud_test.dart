import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/data/mock/mock_governance_data.dart';
import 'package:progroup_ai_frontend/data/mock/mock_training_data.dart';
import 'package:progroup_ai_frontend/models/course_model.dart';
import 'package:progroup_ai_frontend/models/governance_student_model.dart';
import 'package:progroup_ai_frontend/models/lecturer_model.dart';
import 'package:progroup_ai_frontend/models/training_import_record_model.dart';
import 'package:progroup_ai_frontend/models/training_subject_model.dart';

void main() {
  group('Governance local CRUD', () {
    test('student add, edit, and delete notify listeners', () {
      final data = MockGovernanceData.instance;
      final id = data.nextStudentId;
      var notifications = 0;
      void listener() => notifications++;

      addTearDown(() => data.removeStudent(id));
      data.addListener(listener);
      addTearDown(() => data.removeListener(listener));

      data.addStudents([
        GovernanceStudentModel(
          id: id,
          studentCode: 'CRUD-STUDENT-$id',
          fullName: 'CRUD Student',
          email: 'crud-student-$id@example.test',
          classCode: 'CRUD-01',
          status: 'Active',
        ),
      ]);
      expect(notifications, 1);
      expect(data.students.any((item) => item.id == id), isTrue);

      data.updateStudent(
        GovernanceStudentModel(
          id: id,
          studentCode: 'CRUD-STUDENT-$id',
          fullName: 'Updated Student',
          email: 'crud-student-$id@example.test',
          classCode: 'CRUD-02',
          status: 'Paused',
        ),
      );
      expect(notifications, 2);
      expect(
        data.students.singleWhere((item) => item.id == id).status,
        'Paused',
      );

      data.removeStudent(id);
      expect(notifications, 3);
      expect(data.students.any((item) => item.id == id), isFalse);
    });

    test('lecturer edits and deletes keep course assignments synchronized', () {
      final data = MockGovernanceData.instance;
      final lecturerId = data.nextLecturerId;
      final courseId = data.nextCourseId;
      final originalName = 'CRUD Lecturer $lecturerId';
      final updatedName = 'Updated Lecturer $lecturerId';
      final originalCode = 'CRUD-GV-$lecturerId';
      final updatedCode = 'CRUD-GV-UPDATED-$lecturerId';
      final course = CourseModel(
        id: courseId,
        code: 'CRUD-SUBJECT',
        name: 'CRUD Subject',
        classCode: 'CRUD-CLASS',
        semester: '2026-1',
        lecturer: originalName,
        status: 'Active',
      );

      addTearDown(() => data.removeLecturer(lecturerId));
      addTearDown(
        () => data.courses.removeWhere((item) => item.id == courseId),
      );

      data.addLecturers([
        LecturerModel(
          id: lecturerId,
          lecturerCode: originalCode,
          fullName: originalName,
          email: 'crud-lecturer-$lecturerId@example.test',
          faculty: 'Test Faculty',
          department: 'Test Department',
          avatar: '',
        ),
      ]);
      data.addCourses([course]);

      data.updateLecturer(
        LecturerModel(
          id: lecturerId,
          lecturerCode: updatedCode,
          fullName: updatedName,
          email: 'crud-lecturer-$lecturerId@example.test',
          faculty: 'Test Faculty',
          department: 'Test Department',
          avatar: '',
        ),
        status: 'On leave',
      );
      expect(
        data.lecturerStatus(
          data.lecturers.singleWhere((item) => item.id == lecturerId),
        ),
        'On leave',
      );
      expect(
        data.courses.singleWhere((item) => item.id == courseId).lecturer,
        updatedName,
      );

      data.removeLecturer(lecturerId);
      expect(
        data.courses.singleWhere((item) => item.id == courseId).lecturer,
        isEmpty,
      );
      expect(data.lecturerStatuses.containsKey(updatedCode), isFalse);
    });

    test('confirmed import history is stored and notifies listeners', () {
      final data = MockGovernanceData.instance;
      final record = TrainingImportRecordModel(
        importedAt: DateTime(2026, 9, 25),
        dataType: 'Sinh viên',
        fileName: 'students.csv',
        totalRecords: 3,
        successfulRecords: 2,
        failedRecords: 1,
        status: 'Hoàn thành một phần',
      );
      var notifications = 0;
      void listener() => notifications++;

      data.addListener(listener);
      addTearDown(() => data.removeListener(listener));
      addTearDown(() => data.importHistory.remove(record));

      data.recordImport(record);

      expect(notifications, 1);
      expect(data.importHistory.first, same(record));
      expect(data.importHistory.first.failedRecords, 1);
    });
  });

  group('Training local CRUD', () {
    test('student add, edit, and delete notify listeners', () {
      final data = MockTrainingData.instance;
      final id = data.nextStudentId;
      var notifications = 0;
      void listener() => notifications++;

      addTearDown(() => data.removeStudent(id));
      data.addListener(listener);
      addTearDown(() => data.removeListener(listener));

      data.addStudents([
        GovernanceStudentModel(
          id: id,
          studentCode: 'CRUD-TRAINING-STUDENT-$id',
          fullName: 'Training Student',
          email: 'training-student-$id@example.test',
          classCode: 'TRAINING-01',
          status: 'Active',
        ),
      ]);
      expect(notifications, 1);

      data.updateStudent(
        GovernanceStudentModel(
          id: id,
          studentCode: 'CRUD-TRAINING-STUDENT-$id',
          fullName: 'Updated Training Student',
          email: 'training-student-$id@example.test',
          classCode: 'TRAINING-02',
          status: 'Graduated',
        ),
      );
      expect(notifications, 2);
      expect(
        data.students.singleWhere((item) => item.id == id).status,
        'Graduated',
      );

      data.removeStudent(id);
      expect(notifications, 3);
      expect(data.students.any((item) => item.id == id), isFalse);
    });

    test('lecturer and class edits preserve assignment and class fields', () {
      final data = MockTrainingData.instance;
      final lecturerId = data.nextLecturerId;
      final classId = data.nextCourseClassId;
      final lecturerName = 'Training Lecturer $lecturerId';
      final updatedLecturerName = 'Updated Training Lecturer $lecturerId';
      final lecturerCode = 'CRUD-TRAINING-GV-$lecturerId';
      final course = CourseModel(
        id: classId,
        code: 'LTDD',
        name: 'Lập trình di động',
        classCode: 'CRUD-TRAINING-CLASS-$classId',
        semester: '2026-1',
        lecturer: lecturerName,
        status: 'Active',
      );

      addTearDown(() => data.removeLecturer(lecturerId));
      addTearDown(() => data.removeCourseClass(classId));

      data.addLecturers([
        LecturerModel(
          id: lecturerId,
          lecturerCode: lecturerCode,
          fullName: lecturerName,
          email: 'training-lecturer-$lecturerId@example.test',
          faculty: 'Test Faculty',
          department: 'Test Department',
          avatar: '',
        ),
      ]);
      data.addCourseClasses([course]);

      data.updateLecturer(
        LecturerModel(
          id: lecturerId,
          lecturerCode: lecturerCode,
          fullName: updatedLecturerName,
          email: 'training-lecturer-$lecturerId@example.test',
          faculty: 'Test Faculty',
          department: 'Test Department',
          avatar: '',
        ),
        status: 'On leave',
      );
      expect(
        data.courseClasses.singleWhere((item) => item.id == classId).lecturer,
        updatedLecturerName,
      );

      data.updateCourseClass(
        CourseModel(
          id: classId,
          code: 'LTDD',
          name: 'Lập trình di động',
          classCode: 'CRUD-TRAINING-CLASS-UPDATED-$classId',
          semester: '2026-2',
          lecturer: updatedLecturerName,
          status: 'Paused',
        ),
      );
      final updatedClass = data.courseClasses.singleWhere(
        (item) => item.id == classId,
      );
      expect(updatedClass.classCode, 'CRUD-TRAINING-CLASS-UPDATED-$classId');
      expect(updatedClass.semester, '2026-2');
      expect(updatedClass.status, 'Paused');

      data.removeLecturer(lecturerId);
      expect(
        data.courseClasses.singleWhere((item) => item.id == classId).lecturer,
        isEmpty,
      );
    });

    test(
      'subject edits update class references and deletes cascade classes',
      () {
        final data = MockTrainingData.instance;
        const oldCode = 'CRUD-SUBJECT';
        const updatedCode = 'CRUD-SUBJECT-UPDATED';
        final classId = data.nextCourseClassId;

        addTearDown(() => data.removeSubject(updatedCode));
        addTearDown(() => data.removeCourseClass(classId));

        data.addSubjects([
          const TrainingSubjectModel(
            code: oldCode,
            name: 'CRUD Subject',
            credits: 3,
            department: 'Test Department',
            status: 'Active',
          ),
        ]);
        data.addCourseClasses([
          CourseModel(
            id: classId,
            code: oldCode,
            name: 'CRUD Subject',
            classCode: 'CRUD-SUBJECT-CLASS-$classId',
            semester: '2026-1',
            lecturer: '',
            status: 'Active',
          ),
        ]);

        data.updateSubject(
          oldCode,
          const TrainingSubjectModel(
            code: updatedCode,
            name: 'Updated CRUD Subject',
            credits: 4,
            department: 'Updated Department',
            status: 'Paused',
          ),
        );
        final updatedClass = data.courseClasses.singleWhere(
          (item) => item.id == classId,
        );
        expect(updatedClass.code, updatedCode);
        expect(updatedClass.name, 'Updated CRUD Subject');

        expect(data.removeSubject(updatedCode), 1);
        expect(data.subjects.any((item) => item.code == updatedCode), isFalse);
        expect(data.courseClasses.any((item) => item.id == classId), isFalse);
      },
    );
  });
}
