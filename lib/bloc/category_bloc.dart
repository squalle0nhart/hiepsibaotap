import 'dart:async';
import 'package:hiepsibaotap/modal/categories_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiepsibaotap/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum Status { START_FETCH, FINISH_FETCH, FETCH_ERROR }

class CategoryBloc {
  StreamController _categoryStream = new StreamController();
  Stream get categoryStream => _categoryStream.stream;

  void getListCategory() async {
    List<CategoryInfo> listCategory = new List<CategoryInfo>();
    CategoryInfo top = new CategoryInfo('', '', 'Trang chủ', 9999);
    listCategory.add(top);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(AppConfig.PREF_CATEGORY_CACHE) == null ||
        prefs.getString(AppConfig.PREF_CATEGORY_CACHE) == '') {
      final response = await http.get(AppConfig.API_GET_CATEGORY_INDEX);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        prefs.setString(AppConfig.PREF_CATEGORY_CACHE, response.body);
      } else {
        prefs.setString(AppConfig.PREF_CATEGORY_CACHE, '');
        _categoryStream.sink.add(Status.FETCH_ERROR);
      }
    }

    List<dynamic> result =
    jsonDecode(prefs.getString(AppConfig.PREF_CATEGORY_CACHE));
    for (int i = 0; i < result.length; i++) {
      if (CategoryInfo.fromJson(result[i]).postCount > 0) {
        listCategory.add(CategoryInfo.fromJson(result[i]));
      }
    }
    _categoryStream.sink.add(listCategory);
  }

  void dispose() {
    _categoryStream.close();
  }
}