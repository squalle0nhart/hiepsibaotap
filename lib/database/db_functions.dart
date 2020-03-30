import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'database_helper.dart';
import 'dart:io';
import '../modal/post_info.dart';
import '../config/app_config.dart';
import 'dart:convert';

var dbHelper = DatabaseHelper();
int perPageInt = 4;
List<PostInfo> cachedPosts;
List<PostInfo> posts;
int dbCount;
bool netConnection = false;

List<int> postsIDs = List();
List<int> cachedPostsIDs = List();

getCachedPostsIDs() {
  for (int i = 0; i < cachedPosts.length; i++) {
    cachedPostsIDs.add(int.parse(cachedPosts[i].id));
  }
}

Future<List<PostInfo>> getListCachingPost(String categoryId) async {
  return await dbHelper.getPostList(categoryId, false);
}

getPostsIDs() {
  for (int i = 0; i < posts.length; i++) {
    postsIDs.add(int.parse(cachedPosts[i].id));
  }
}

clearDB() async {
  int count = await dbHelper.getCount();

  debugPrint("count is :  " + count.toString());
  for (int i = 0; i < count; i++) {
    dbHelper.deletePost(int.parse(cachedPosts[i].id));
    debugPrint("this post has been deleted" + (posts[i].id).toString());
    debugPrint("${cachedPosts[i].id} has been Deleted from  DB");
  }
}

fillDB(List<PostInfo> posts) {
  for (int i = 0; i < posts.length; i++) {
    dbHelper.insertPost(posts[i]);
    debugPrint("${posts[i].id} has been inserted to DB");
  }
}

addPostToCache(PostInfo postInfo) {
  try {
    dbHelper.insertPost(postInfo);
    debugPrint("${postInfo.id} has been inserted to DB");
  } catch (error) {
    print('error when insert post to cache');
  }
}

doWeHaveNet() async {
  int count = await dbHelper.getCount();
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      netConnection = true;
    }
  } on SocketException catch (_) {
    print('not connected');
    if (count < 1) {
      debugPrint('we need intenet');
      netConnection = false;
    }
  }
}

Future<List<PostInfo>> getListBookmarkPost(String categoryId) async {
  return await dbHelper.getPostList(categoryId, true);
}

Future<List<PostInfo>> getListPostWithoutCaching(
    int currentPage, String categoryId, String queryString) async {
  return await getListPost(currentPage, categoryId, queryString);
}

/*
   * Fetch list of category from wordpress API
   */
getListPost(int offset, String categoryId, String queryString) async {
  List<PostInfo> listPosts = new List<PostInfo>();
  String requestURL = AppConfig.API_GET_POST +
      '&offset=' +
      offset.toString() +
      '&per_page=' +
      AppConfig.PER_PAGE.toString();

  // if it's list category post
  if (categoryId != '') {
    requestURL = requestURL + '&categories=' + categoryId;
  }

  // if it's search posts
  if (queryString != null && queryString != '') {
    requestURL = requestURL + '&search=' + queryString;
  }
  print(requestURL);
  final response = await http.get(requestURL);
  if (response.statusCode == 200) {
    offset++;
    List<dynamic> result = jsonDecode(response.body);
    for (int i = 0; i < result.length; i++) {
      listPosts.add(PostInfo.fromJson(result[i]));
    }
  }
  //listPosts.sort((a, b) => b.id.compareTo(a.id));
  return listPosts;
}

updatePost(PostInfo postInfo) {
  dbHelper.updatePost(postInfo);
}
