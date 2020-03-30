import 'dart:async';
import 'package:hiepsibaotap/modal/post_info.dart';
import 'package:hiepsibaotap/database/db_functions.dart' as dbHelper;

enum Status { FINISH_LOAD_POST, LOAD_ERROR }

class PostBloc {
  StreamController _postStream = new StreamController();
  Stream get postStream => _postStream.stream;
  int currentPage = 0;
  Status listState;
  List<PostInfo> listPosts = new List<PostInfo>();
  List<int> listPostIds = new List<int>();

  void dispose() {
    _postStream.close();
  }

  void updatePost(PostInfo postInfo) {
    dbHelper.updatePost(postInfo);
    _postStream.sink.add(listPosts);
  }

  /*
   * Fetch list of category from wordpress API
   */
  void getListPost(String queryString, String categoryId, bool initLoad) async {
    if (queryString != '' && queryString != null) {
      print('load query' + queryString.toString());
      Future<List<PostInfo>> fetchList;
      if (queryString == '_bookmarked') {
        fetchList = dbHelper.getListBookmarkPost(categoryId);
      } else {
        fetchList = dbHelper.getListPostWithoutCaching(
            listPosts.length, categoryId, queryString);
      }

      fetchList.then((listFetch) {
        for (int i = 0; i < listFetch.length; i++) {
          if (!listPostIds.contains(int.parse(listFetch[i].id))) {
            listPosts.add(listFetch[i]);
          }
        }

        if (listPosts.length > 0) {
          currentPage++;
          listState = Status.FINISH_LOAD_POST; // set st
        } else {
          listState = Status.LOAD_ERROR;
        }
      });
      _postStream.sink.add(listPosts);
      return;
    }

    if (initLoad) {
      Future<List<PostInfo>> cachingListFuture =
          dbHelper.getListCachingPost(categoryId);
      cachingListFuture.then((listCachingPost) {
        // load add caching post if available
        for (int i = 0; i < listCachingPost.length; i++) {
          listPosts.add(listCachingPost[i]);
          listPostIds.add(int.parse(listCachingPost[i].id));
        }

        if (listPosts.length > 0) {
          listState = Status.FINISH_LOAD_POST;
          _postStream.sink.add(listPosts);
        }

        // load list cache from internet
        Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
            listPosts.length, categoryId, queryString);
        fetchList.then((listFetch) {
          for (int i = 0; i < listFetch.length; i++) {
            // if fetchPost doesnt cached
            if (!listPostIds.contains(int.parse(listFetch[i].id))) {
              dbHelper.addPostToCache(listFetch[i]);
              listPosts.add(listFetch[i]);
              listPostIds.add(int.parse(listFetch[i].id));
            }
          }

          if (listPosts.length > 0) {
            listState = Status.FINISH_LOAD_POST; // set state
            _postStream.sink.add(listPosts);
          } else {
            listState = Status.LOAD_ERROR; // set state to error when loading
          }
        });
      });
      initLoad = false;
    } else {
      // load list cache from internet
      Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
          listPosts.length, categoryId, queryString);
      fetchList.then((listFetch) {
        for (int i = 0; i < listFetch.length; i++) {
          // if fetchPost doesn't cached
          if (!listPostIds.contains(int.parse(listFetch[i].id))) {
            dbHelper.addPostToCache(listFetch[i]);
            listPosts.add(listFetch[i]);
          }
        }

        if (listPosts.length > 0) {
          currentPage++;
          listState = Status.FINISH_LOAD_POST;
        } else {
          listState = Status.LOAD_ERROR; // set
        }
      });
    }

    _postStream.sink.add(listPosts);
    return;
  }
}
