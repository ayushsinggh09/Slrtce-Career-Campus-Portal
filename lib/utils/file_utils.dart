class FileUtils {
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static String getFileName(String path) {
    try {
      // Handles both web URLs and local paths
      return Uri.decodeFull(path.split('/').last.split('?').first);
    } catch (e) {
      return 'file';
    }
  }
}