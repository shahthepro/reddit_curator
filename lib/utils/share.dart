
import 'package:image_downloader/image_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:esys_flutter_share/esys_flutter_share.dart';

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


Future<bool> shareImage(String imageLink) async {
  return http.get(imageLink).then((response) async {
    final contentType = response.headers['content-type'];
    final extension = contentType.split("/")[1];
    final byteData = response.bodyBytes.buffer.asByteData();;
    // final base64Data = base64Encode(byteData);
    // final dataURI = "data:$contentType;base64,$base64Data";
    final fileName = "${new DateTime.now().millisecondsSinceEpoch}.$extension";
    // print(contentType);
    // print(byteData.lengthInBytes);
    // print(dataURI.length);
    
    await EsysFlutterShare.shareImage(fileName, byteData, fileName);
    // Share.share(dataURI);
    return true;
  }).catchError((_) {
    return false;
  });
}