import '../entities/course.dart';

abstract class CourseRepository {
  Stream<List<Course>> watchCourses();

  Future<List<Course>> fetchCourses();

  Future<void> upsertCourse(Course course);

  Future<void> deleteCourse(String id);

  Future<void> sync();
}
