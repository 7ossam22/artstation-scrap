import 'json_converter.dart';

class ModelItem implements IJsonSerializable {
  final int? id;

  final String? hashId;
  final String? url;
  final bool? hideAsAdult;
  final String? coverUrl;

  ModelItem({
    required this.id,
    required this.hashId,
    required this.url,
    required this.hideAsAdult,
    required this.coverUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "hash_id": hashId,
        "url": url,
        "hide_as_adult": hideAsAdult,
        "smaller_square_cover_url": coverUrl,
      };
}

class ModelItemFactory implements IModelFactory<ModelItem> {
  @override
  ModelItem fromJson(Map<String, dynamic> jsonMap) {
    return ModelItem(
      id: jsonMap["id"],
      hashId: jsonMap["username"],
      url: jsonMap["medium_avatar_url"],
      hideAsAdult: jsonMap["is_staff"],
      coverUrl: jsonMap["full_name"],
    );
  }
}
