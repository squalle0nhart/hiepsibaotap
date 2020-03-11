import '../../modal/post_info.dart';
import 'package:flutter/material.dart';
import 'package:hiepsibaotap/config/app_config.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'post_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../database/db_functions.dart' as dbHelper;

class PostListView extends StatefulWidget {
  final String categoryId;
  final int maxPostCount;
  final String queryString;
  //constructor
  PostListView(
      {Key key,
      @required this.categoryId,
      @required this.maxPostCount,
      @required this.queryString})
      : super(key: key);

  @override
  createState() => new PostListState(categoryId, maxPostCount, queryString);
}

class PostListState extends State<PostListView>
    with AutomaticKeepAliveClientMixin<PostListView>, WidgetsBindingObserver {
  bool enableLoadMore = true;
  bool isRefresh = false;
  bool initLoad = true;
  int listState = AppConfig.STATE_LOADING;
  int currentPage = 1;
  String categoryId;
  List<PostInfo> listPosts = new List<PostInfo>();
  List<int> listPostIds = new List<int>();

  RefreshController _refreshController;
  int maxPostCount;
  String queryString;
  PostListState(String categoryId, int postCount, String queryString) {
    this.categoryId = categoryId;
    this.queryString = queryString;
    this.maxPostCount = postCount;
  }

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController();
    getListPost(null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (listPosts.length <= 2 ||
        listPosts.length >= 99999 ||
        queryString == '_bookmarked') {
      enableLoadMore = false;
    } else {
      enableLoadMore = true;
    }

    if (listState == AppConfig.STATE_LOADING) {
      return Center(
          child: CircularProgressIndicator(backgroundColor: Colors.blue));
    } else {
      return new SmartRefresher(
        enablePullDown: false,
        enablePullUp: enableLoadMore,
        controller: _refreshController,
        child: new ListView.builder(
            itemCount: listPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                child: new Card(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    elevation: 0,
                    shape: Border(
                        top: BorderSide(color: Colors.grey, width: 0.1),
                        bottom: BorderSide(color: Colors.grey, width: 0.1)),
                    child: new Container(
                      height: 350,
                      child: _buildPosts(context, listPosts[index]),
                    )),
                onTap: () => _listOnTap(context, listPosts[index]),
              );
            }),
      );
    }
  }

  /*
   * Fetch list of category from wordpress API
   */
  Future<bool> getListPost(bool up) async {
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
            setState(() {
              listPosts.add(listFetch[i]);
            });
          }
        }

        if (listPosts.length > 0) {
          currentPage++;
          setState(() {
            listState =
                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
          });
        } else {
          setState(() {
            listState =
                AppConfig.STATE_ERROR; // set state to error when loading
            Fluttertoast.showToast(
                msg: "Error! Server didn't responese data...");
          });
        }
      });
      return true;
    }

    if (initLoad) {
      print('init load');
      Future<List<PostInfo>> cachingListFuture =
          dbHelper.getListCachingPost(categoryId);
      cachingListFuture.then((listCachingPost) {
        // load add caching post if available
        for (int i = 0; i < listCachingPost.length; i++) {
          setState(() {
            listPosts.add(listCachingPost[i]);
            listPostIds.add(int.parse(listCachingPost[i].id));
          });
        }

        if (listPosts.length > 0) {
          setState(() {
            listState =
                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
          });
        }

        // load list cache from internet
        Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
            listPosts.length, categoryId, queryString);
        fetchList.then((listFetch) {
          for (int i = 0; i < listFetch.length; i++) {
            // if fetchPost doesnt cached
            if (!listPostIds.contains(int.parse(listFetch[i].id))) {
              dbHelper.addPostToCache(listFetch[i]);
              setState(() {
                listPosts.add(listFetch[i]);
                listPostIds.add(int.parse(listFetch[i].id));
              });
            }
          }

          if (listPosts.length > 0) {
            setState(() {
              listState =
                  AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
            });
          } else {
            setState(() {
              listState =
                  AppConfig.STATE_ERROR; // set state to error when loading
              Fluttertoast.showToast(msg: "No Posts found!!!");
            });
          }
        });
      });
      initLoad = false;
    } else {
      print('load more');
      // load list cache from internet
      Future<List<PostInfo>> fetchList = dbHelper.getListPostWithoutCaching(
          listPosts.length, categoryId, queryString);
      fetchList.then((listFetch) {
        for (int i = 0; i < listFetch.length; i++) {
          // if fetchPost doesnt cached
          if (!listPostIds.contains(int.parse(listFetch[i].id))) {
            dbHelper.addPostToCache(listFetch[i]);
            setState(() {
              listPosts.add(listFetch[i]);
            });
          }
        }

        if (listPosts.length > 0) {
          currentPage++;
          setState(() {
            listState =
                AppConfig.STATE_LOAD_FINISH_POST; // set state to load finish
          });
        } else {
          setState(() {
            listState =
                AppConfig.STATE_ERROR; // set state to error when loading
            Fluttertoast.showToast(
                msg: "Error! Server didn't responese data...");
          });
        }
      });
    }
    return true;
  }

  // build post
  Column _buildPosts(BuildContext context, PostInfo postInfo) {
    return Column(
      children: <Widget>[
        _buildPreviewImg(postInfo),
        Html(
          defaultTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16),
          backgroundColor: Colors.white,
          data: postInfo.title,
          padding: EdgeInsets.all(10.0),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.only(bottom: 5),
                onPressed: () {},
                icon: Icon(Icons.date_range,
                    color: Colors.grey[600], size: 20),
              ),
              Text(
                postInfo.date,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
              (queryString != '_bookmarked')
                  ? ((postInfo.bookmark == 'true')
                  ? new IconButton(
                  icon: new Icon(Icons.bookmark,
                      color: Colors.blueGrey),
                  onPressed: () {
                    setState(() {
                      postInfo.bookmark = 'false';
                    });
                    dbHelper.updatePost(postInfo);
                  })
                  : new IconButton(
                  icon: new Icon(Icons.bookmark_border,
                      color: Colors.blueGrey),
                  onPressed: () {
                    setState(() {
                      postInfo.bookmark = 'true';
                    });
                    dbHelper.updatePost(postInfo);
                  }))
                  : Text('')
            ],
          ),
          alignment: Alignment.centerLeft,
        )
      ],
    );
  }

  Widget _buildPreviewImg(PostInfo postInfo) {
    return new Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: new Border.all(color: Colors.grey)),
      child: new ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: new CachedNetworkImage(
            fadeInDuration: Duration(milliseconds: 500),
            fit: BoxFit.cover,
            imageUrl: postInfo.thumbnailInfo,
            width: MediaQuery.of(context).size.width,
            placeholder: (context, str) {
              return new Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Image.asset(
                    'placeholder-image.jpg',
                    fit: BoxFit.cover,
                  ),
                  new Center(
                      child: new CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ))
                ],
              );
            },
            errorWidget: (context, string, obj) {
              return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: new Container(
                    width: 76,
                    height: 110,
                    padding: EdgeInsets.all(5),
                    decoration: new BoxDecoration(
                      color: Color(
                              (int.parse(postInfo.id).toDouble() * 0xFFFFFF)
                                      .toInt() <<
                                  0)
                          .withOpacity(1.0),
                    ),
                    child: Center(
                      child: Html(
                        defaultTextStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 14),
                        data: postInfo.title,
                        padding: EdgeInsets.all(5),
                      ),
                    ),
                  ));
            }),
      ),
    );
  }

  // handle tap click
  _listOnTap(BuildContext context, PostInfo postInfo) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => new PostDetail(postInfo: postInfo)));
  }

  @override
  bool get wantKeepAlive => true;
}
