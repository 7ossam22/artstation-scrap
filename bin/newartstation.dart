import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'header.dart';
import 'model.dart';

void main() async {
  // /home/hossam/newartstation/Images
  int pageNumber = 1;
  var keepLooping = true;
  print("What are you searching for?");
  String? input = stdin.readLineSync();
  print("Where do you want to save your data?");
  String? path = stdin.readLineSync();
  var directoryInitialized = await initDirectory("$path/${input ?? ""}");
  if (directoryInitialized != null) {
    while (keepLooping && pageNumber < 20) {
      List<ModelItem> list = await getImages(input!, pageNumber);
      if (list.isEmpty) {
        keepLooping = false;
      } else {
        list
            .map((e) => downloadData(e, pageNumber, directoryInitialized))
            .toList();
      }
      print(pageNumber);
      pageNumber++;
    }
  }
}

Future<Directory?> initDirectory(String folderName) async {
  var folderPath = Directory("$folderName/");
  var isThere = await folderPath.exists();

  if (!isThere) {
    try {
      Directory.fromUri(folderPath.uri).createSync(recursive: true);
      return folderPath;
    } catch (e) {
      return null;
    }
  }
  return folderPath;
}

Future<void> downloadData(
  ModelItem modelItem,
  int pageNumber,
  Directory directoryInitialized,
) async {
  try {
    final coverUrl = modelItem.coverUrl!.replaceFirst(RegExp(r"/\d{14}/"), "/");
    print(coverUrl);
    final request = await HttpClient()
        .getUrl(Uri.parse(coverUrl.replaceFirst("smaller_square", "large")));
    final response = await request.close();
    var file =
        await File("${directoryInitialized.path}$pageNumber${modelItem.hashId}")
            .create();
    await response.pipe(file.openWrite());
    print("${modelItem.hashId}\nDownloaded successfully");
  } catch (e) {
    print("Failed to download : $e");
  }
}

Future<List<ModelItem>> getImages(String query, int pageNumber) async {
  List<ModelItem> modelItem = [];
  var request = http.Request('POST',
      Uri.parse('https://www.artstation.com/api/v2/search/projects.json'));
  request.body = json.encode({
    "query": query,
    "page": pageNumber,
    "per_page": 50,
    "sorting": "relevance",
    "pro_first": "1",
    "filters": [],
    "additional_fields": []
  });
  request.headers.addAll(initHeader(query));

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final finalResponse =
        json.decode(await response.stream.bytesToString())["data"];

    finalResponse
        .map((e) => modelItem.add(ModelItem(
                id: e["id"],
                hashId: e["hash_id"],
                url: e["url"],
                hideAsAdult: e["hide_as_adult"],
                coverUrl:
                    e["smaller_square_cover_url"])) // fullName: fullName,)
            )
        .toList();

    return modelItem;
  }
  return [];
}
