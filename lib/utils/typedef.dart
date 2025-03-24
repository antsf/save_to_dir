typedef DownloadProgressCallback = void Function(int bytes, int total);
typedef DownloadCompleteCallback = void Function(String downloadPath);
typedef DownloadErrorCallback = void Function(String error);
