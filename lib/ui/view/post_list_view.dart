import '../../modal/post_info.dart';
import 'package:flutter/material.dart';
import 'package:hiepsibaotap/config/app_config.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'post_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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
        enablePullDown: true,
        enablePullUp: enableLoadMore,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: new ListView.builder(
            itemCount: listPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                child: new Container(
                  height: 410,
                  child: _buildPosts(context, listPosts[index]),
                ),
                onTap: () => _listOnTap(context, listPosts[index]),
              );
            }),
      );
    }
  }

  // build post
  Column _buildPosts(BuildContext context, PostInfo postInfo) {
    return Column(
      children: <Widget>[
        _buildAuthor(postInfo),
        _buildPreviewImg(postInfo),
        Align(
          alignment: Alignment.centerLeft,
          child: HtmlWidget(
            postInfo.title,
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 5),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.open_in_new, color: Colors.grey[500], size: 20),
              Text(
                '  ' + 'Mở',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
              Text('     '),
              (queryString != '_bookmarked')
                  ? ((postInfo.bookmark == 'true')
                      ? new InkWell(
                          child: new Icon(
                            Icons.star,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          onTap: () {
                            setState(() {
                              postInfo.bookmark = 'false';
                            });
                            dbHelper.updatePost(postInfo);
                          })
                      : new InkWell(
                          child: new Icon(Icons.star_border,
                              color: Colors.grey[500], size: 22),
                          onTap: () {
                            setState(() {
                              postInfo.bookmark = 'true';
                            });
                            dbHelper.updatePost(postInfo);
                          }))
                  : Text(''),
              Text(
                'Đánh dấu',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
        ),
        Container(
          width: 10000,
          height: 0.15,
          color: Colors.blueGrey,
        )
      ],
    );
  }

  Widget _buildAuthor(PostInfo postInfo) {
    return Container(
      padding: EdgeInsets.only(top: 7, bottom: 2, left: 7),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: CachedNetworkImage(
              imageUrl: postInfo.authorAvatar,
              width: 42,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '   ' + postInfo.author,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  '   ' +
                      postInfo.date.substring(0, postInfo.date.indexOf(' ')),
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPreviewImg(PostInfo postInfo) {
    return new Container(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
      child: new ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: new CachedNetworkImage(
            fadeInDuration: Duration(milliseconds: 500),
            fit: BoxFit.cover,
            imageUrl: postInfo.thumbnailInfo,
            width: MediaQuery.of(context).size.width,
            height: 245,
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: HtmlWidget(
                        postInfo.title,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ));
            }),
      ),
    );
  }

  void _onRefresh() {
    currentPage = 1;
    isRefresh = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        initLoad = true;
        listPosts.clear();
      });
    });
  }

  void _onLoading() {
    isRefresh = false;
  }

  // handle tap click
  _listOnTap(BuildContext context, PostInfo postInfo) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => new PostDetail(postInfo: postInfo)));
  }

  @override
  bool get wantKeepAlive => true;
}
