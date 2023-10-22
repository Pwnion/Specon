class CanvasData {
  final List<Map<String, dynamic>> subjects;

  CanvasData._(this.subjects);

  static CanvasData fromDB(final List<dynamic> subjects) {
    return CanvasData._(
        subjects.map((subject) => subject as Map<String, dynamic>).toList()
    );
  }
}