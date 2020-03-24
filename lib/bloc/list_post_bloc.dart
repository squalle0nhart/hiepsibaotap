import 'dart:async';
import 'package:hiepsibaotap/modal/post_info.dart';
import 'package:hiepsibaotap/database/db_functions.dart' as dbHelper;

class PostBloc {
  StreamController _postStream = new StreamController();
  Stream get postStream => _postStream.stream;

  void dispose() {
    _postStream.close();
  }

  /*
   * Fetch list of category from wordpress API
   */
//  void getListPost(String queryString, String categoryId, List<PostInfo> listPosts, List<int> listPostIds) async {
//    if (queryString != '' && queryString != null) {
//      print('load query' + queryString.toString());
//      Future<List<PostInfo>> fetchList;
//      if (queryString == '_bookmarked') {
//        fetchList = dbHelper.getListBookmarkPost(categoryId);
//      } else {
//        fetchList = dbHelper.getListPostWithoutCaching(
//            listPosts.length, categoryId, queryString);
//      }
//
//      fetchList.then((listFetch) {
//        for (int i = 0; i < listFetch.length; i++) {
//          if (!listPostIds.contains(int.parse(listFetch[i].id))) {
////            setState(() {
////              listPosts.add(listFetch[i]);
////            });
//            listPosts.add(listFetch[i]);
//          }
//        }
//
//        if (listPosts.length > 0) {
//          currentPage++;
//          setState(() {
//            listState =
//                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
//          });
//        } else {
//          setState(() {
//            listState =
//                AppConfig.STATE_ERROR; // set state to error when loading
//            Fluttertoast.showToast(
//                msg: "Error! Server didn't responese data...");
//          });
//        }
//      });
//      return true;
//    }
//
//    if (initLoad) {
//      Future<List<PostInfo>> cachingListFuture =
//      dbHelper.getListCachingPost(categoryId);
//      cachingListFuture.then((listCachingPost) {
//        // load add caching post if available
//        for (int i = 0; i < listCachingPost.length; i++) {
//          setState(() {
//            listPosts.add(listCachingPost[i]);
//            listPostIds.add(int.parse(listCachingPost[i].id));
//          });
//        }
//
//        if (listPosts.length > 0) {
//          setState(() {
//            listState =
//                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
//          });
//        }
//
//        // load list cache from internet
//        Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
//            listPosts.length, categoryId, queryString);
//        fetchList.then((listFetch) {
//          for (int i = 0; i < listFetch.length; i++) {
//            // if fetchPost doesnt cached
//            if (!listPostIds.contains(int.parse(listFetch[i].id))) {
//              dbHelper.addPostToCache(listFetch[i]);
//              setState(() {
//                listPosts.add(listFetch[i]);
//                listPostIds.add(int.parse(listFetch[i].id));
//              });
//            }
//          }
//
//          if (listPosts.length > 0) {
//            setState(() {
//              listState =
//                  AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
//            });
//          } else {
//            setState(() {
//              listState =
//                  AppConfig.STATE_ERROR; // set state to error when loading
//              Fluttertoast.showToast(msg: "No Posts found!!!");
//            });
//          }
//        });
//      });
//      initLoad = false;
//    } else {
//      print('load more');
//      // load list cache from internet
//      Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
//          listPosts.length, categoryId, queryString);
//      fetchList.then((listFetch) {
//        for (int i = 0; i < listFetch.length; i++) {
//          // if fetchPost doesn't cached
//          if (!listPostIds.contains(int.parse(listFetch[i].id))) {
//            dbHelper.addPostToCache(listFetch[i]);
//            setState(() {
//              listPosts.add(listFetch[i]);
//            });
//          }
//        }
//
//        if (listPosts.length > 0) {
//          currentPage++;
//          setState(() {
//            listState =
//                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
//          });
//        } else {
//          setState(() {
//            listState =
//                AppConfig.STATE_ERROR; // set state to error when loading
//            Fluttertoast.showToast(
//                msg: "Error! Server didn't responese data...");
//          });
//        }
//      });
//    }
//    return true;
//  }
}