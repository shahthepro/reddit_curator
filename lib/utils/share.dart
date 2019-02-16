import 'package:image_downloader/image_downloader.dart';

Future<bool> downloadImage(String imageLink) async {
  try {
    String imageId = await ImageDownloader.downloadImage(imageLink);
    if (imageId == null) {
      return false;
    }
  } on Exception catch (_) {
    return false;
  }
  return true;  
}