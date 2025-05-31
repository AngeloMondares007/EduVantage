class Logger {
  static void logTask(String userName, String taskName) {
    String timestamp = _getTimestamp();
    print("$timestamp - $userName created task: $taskName");
  }

  static void logClass(String userName, String className) {
    String timestamp = _getTimestamp();
    print("$timestamp - $userName created class: $className");
  }

  static void logNote(String userName, String noteTitle) {
    String timestamp = _getTimestamp();
    print("$timestamp - $userName created note: $noteTitle");
  }

  static void logFlashcard(String userName, String flashcardTitle) {
    String timestamp = _getTimestamp();
    print("$timestamp - $userName created flashcard: $flashcardTitle");
  }

  static String _getTimestamp() {
    DateTime now = DateTime.now();
    return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} "
        "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}
