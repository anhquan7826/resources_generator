class Logger {
  Logger._();

  static bool verbose = false;

  static void log(dynamic message) {
    print(message);
  }

  static void verboseLog(dynamic message) {
    if (verbose) {
      print(message);
    }
  }
}