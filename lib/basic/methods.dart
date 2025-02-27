import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'entities.dart';

export 'entities.dart';

const methods = Methods._();

class Methods {
  const Methods._();

  static const _channel = MethodChannel("methods");
  static HttpClient httpClient = HttpClient();

  Future<String> _invoke(String method, dynamic params) async {
    late String resp;
    if (Platform.isWindows) {
      var req = await httpClient.post("127.0.0.1", 52764, "invoke");
      req.add(utf8.encode(jsonEncode({
        "method": method,
        "params": params is String ? params : jsonEncode(params),
      })));
      var rsp = await req.close();
      resp = await rsp.transform(utf8.decoder).join();
    } else {
      resp = await _channel.invokeMethod(
          "invoke",
          jsonEncode({
            "method": method,
            "params": params is String ? params : jsonEncode(params),
          }));
    }
    var response = _Response.fromJson(jsonDecode(resp));
    if (response.errorMessage.isNotEmpty) {
      throw StateError(response.errorMessage);
    }
    return response.responseData;
  }

  Future init() {
    return _invoke("init", "");
  }

  Future<String> loadProperty(String propertyKey) {
    return _invoke("load_property", propertyKey);
  }

  Future<ComicsResponse> comics(String slug, SortBy sortBy, int page) async {
    final rsp = await _invoke("comics", {
      "categories_slug": slug,
      "sort_by": sortBy.value,
      "page": page,
    });
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<ComicsResponse> comicSearch(
    String searchQuery,
    SortBy sortBy,
    int page,
  ) async {
    final rsp = await _invoke("comic_search", {
      "search_query": searchQuery,
      "sort_by": sortBy.value,
      "page": page,
    });
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<ComicsResponse> pageViewLog(int page) async {
    final rsp = await _invoke("page_view_log", page);
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<CategoriesResponse> categories() async {
    return CategoriesResponse.fromJson(
        jsonDecode(await _invoke("categories", "")));
  }

  Future saveImageFileToGallery(String path) {
    return _channel.invokeMethod("saveImageFileToGallery", path);
  }

  Future saveProperty(String key, String v) {
    return _invoke("save_property", {"k": key, "v": v});
  }

  Future<AlbumResponse> album(int id) async {
    return AlbumResponse.fromJson(jsonDecode(await _invoke("album", id)));
  }

  Future<ChapterResponse> chapter(int id) async {
    return ChapterResponse.fromJson(jsonDecode(await _invoke("chapter", id)));
  }

  Future<CommentPage> forum(String mode, int aid, int page) async {
    return CommentPage.fromJson(jsonDecode(await _invoke("forum", {
      "mode": mode,
      "aid": aid,
      "page": page,
    })));
  }

  Future<FavoritesResponse> favorites(int page) async {
    return FavoritesResponse.fromJson(
      jsonDecode(await _invoke("favorites", page)),
    );
  }

  Future<ActionResponse> setFavorite(int aid) async {
    return ActionResponse.fromJson(
      jsonDecode(await _invoke("set_favorite", aid)),
    );
  }

  Future<GamePage> games(int page) async {
    return GamePage.fromJson(
      jsonDecode(await _invoke("games", page)),
    );
  }

  Future updateViewLog(int id, int lastViewChapterId, int lastViewPage) {
    return _invoke("update_view_log", {
      "id": id,
      "last_view_chapter_id": lastViewChapterId,
      "last_view_page": lastViewPage,
    });
  }

  Future<ViewLog?> findViewLog(int id) async {
    final map = jsonDecode(await _invoke("find_view_log", id));
    if (map == null) {
      return null;
    }
    return ViewLog.fromJson(map);
  }

  Future cleanAllCache() async {
    return _invoke("clean_all_cache", "params");
  }

  Future<String> jm3x4Cover(int comicId) {
    return _invoke("jm_3x4_cover", comicId);
  }

  Future<String> jmSquareCover(int comicId) {
    return _invoke("jm_square_cover", comicId);
  }

  Future<String> jmPageImage(int id, String imageName) {
    return _invoke("jm_page_image", {"id": id, "image_name": imageName});
  }

  Future<String> jmPhotoImage(String imageName) {
    return _invoke("jm_photo_image", imageName);
  }

  Future<ImageSize> imageSize(String path) async {
    return ImageSize.fromJson(jsonDecode(await _invoke("image_size", path)));
  }

  Future httpGet(String versionUrl) {
    return _invoke("http_get", versionUrl);
  }

  Future<String> loadApiHost() {
    return _invoke("load_api_host", "");
  }

  Future<String> loadCdnHost() {
    return _invoke("load_cdn_host", "");
  }

  Future saveApiHost(String choose) {
    return _invoke("save_api_host", choose);
  }

  Future saveCdnHost(String choose) {
    return _invoke("save_cdn_host", choose);
  }

  Future<PreLoginResponse> preLogin() async {
    return PreLoginResponse.fromJson(
      jsonDecode(await _invoke("pre_login", "")),
    );
  }

  Future<SelfInfo> login(String username, String password) async {
    return SelfInfo.fromJson(
      jsonDecode(await _invoke("login", {
        "username": username,
        "password": password,
      })),
    );
  }

  Future<CommentResponse> commentResponse(int aid, String comment) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("comment", {
      "aid": aid,
      "comment": comment,
    })));
  }

  Future<CommentResponse> comment(int aid, String comment) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("comment", {
      "aid": aid,
      "comment": comment,
    })));
  }

  Future<CommentResponse> childComment(
    int aid,
    String comment,
    int? commentId,
  ) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("child_comment", {
      "aid": aid,
      "comment": comment,
      "comment_id": commentId,
    })));
  }

  Future<String> loadUsername() {
    return _invoke("load_username", "");
  }

  Future<String> loadPassword() {
    return _invoke("load_password", "");
  }

  Future clearViewLog() {
    return _invoke("clear_view_log", "");
  }

  Future<List<SearchHistory>> lastSearchHistories(int count) async {
    return List.of(jsonDecode(await _invoke("last_search_histories", "$count")))
        .map((e) => SearchHistory.fromJson(e))
        .toList()
        .cast<SearchHistory>();
  }

  /// 下载列表
  Future<List<DownloadAlbum>> allDownloads() async {
    return List.of(jsonDecode(await _invoke("all_downloads", "")))
        .map((e) => DownloadAlbum.fromJson(e))
        .toList()
        .cast<DownloadAlbum>();
  }

  /// 寻找下载
  Future<DownloadCreate?> downloadById(int id) async {
    var map = jsonDecode(await _invoke("download_by_id", "$id"));
    if (map == null) {
      return map;
    }
    return DownloadCreate.fromJson(map);
  }

  /// 创建下载
  Future<dynamic> createDownload(DownloadCreate create) async {
    return _invoke("create_download", create);
  }

  /// 下载图片列表
  Future<List<DlImage>> dlImageByChapterId(int id) async {
    return List.of(jsonDecode(await _invoke("dl_image_by_chapter_id", "$id")))
        .map((e) => DlImage.fromJson(e))
        .toList()
        .cast<DlImage>();
  }

  /// 创建下载
  Future<dynamic> deleteDownload(int id) async {
    return _invoke("delete_download", id);
  }
}

class _Response {
  late String errorMessage;
  late String responseData;

  _Response.fromJson(Map json) {
    errorMessage = json["error_message"];
    responseData = json["response_data"];
  }
}
