import '../../modal/post_info.dart';
import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'post_details.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hiepsibaotap/bloc/list_post_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hiepsibaotap/ui/anim/fade_route.dart';

class PostListView extends StatefulWidget {
  final String categoryId;
  final String queryString;
  //constructor
  PostListView(
      {Key key,
      @required this.categoryId,
      @required this.queryString})
      : super(key: key);

  @override
  createState() => new PostListState(categoryId, queryString);
}

class PostListState extends State<PostListView>
    with AutomaticKeepAliveClientMixin<PostListView>, WidgetsBindingObserver {
  bool enableLoadMore = true;
  String categoryId;
  PostBloc _postBloc = new PostBloc();
  List<PostInfo> listPosts = new List<PostInfo>();

  RefreshController _refreshController;
  String queryString;
  PostListState(String categoryId, String queryString) {
    this.categoryId = categoryId;
    this.queryString = queryString;
  }

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController();
    _postBloc.getListPost(queryString, categoryId, true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
      stream: _postBloc.postStream,
      builder: (context, snapshot) {
        print(snapshot.data.runtimeType.toString());
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data.runtimeType == listPosts.runtimeType) {
          listPosts = snapshot.data;
          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: !(queryString == '_bookmarked'),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: new ListView.builder(
                itemCount: _postBloc.listPosts.length,
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
        } else {
          return Center(
              child: CircularProgressIndicator(backgroundColor: Colors.blue));
        }
      },
    );
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
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 5),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  launch(postInfo.url);
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.open_in_new, color: Colors.grey[500], size: 20),
                    Text(
                      '  ' + 'Mở',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    )
                  ],
                ),
              ),
              Text('     '),
              InkWell(
                onTap: () {
                  if (queryString == '_bookmarked') {
                    return;
                  }
                  if (postInfo.bookmark == 'true') {
                    postInfo.bookmark = 'false';
                  } else {
                    postInfo.bookmark = 'true';
                  }
                  _postBloc.updatePost(postInfo);
                },
                child:  (queryString != '_bookmarked') ? Row(
                  children: <Widget>[
                    ((postInfo.bookmark == 'true')
                        ? Icon(Icons.star, color: Colors.grey[500], size: 22)
                        : new Icon(Icons.star_border,
                            color: Colors.grey[500], size: 22)),
                    Text(
                      ' Đánh dấu',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ],
                ) : Text(''),
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
              imageUrl: postInfo.authorAvatar != null
                  ? postInfo.authorAvatar
                  : 'https://www.hiepsibaotap.com/wp-content/uploads/2020/03/hsbt-dragon-avatar-169x169.png',
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
                    'assets/image/placeholder-image.jpg',
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
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ));
            }),
      ),
    );
  }

  void _onRefresh() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _postBloc.currentPage = 0;
      _postBloc.listPosts.clear();
      _postBloc.getListPost(queryString, categoryId, true);
      _refreshController.refreshCompleted(resetFooterState: true);
    });
  }

  void _onLoading() {
    _postBloc.getListPost(queryString, categoryId, false);
    _refreshController.loadComplete();
  }

  // handle tap click
  _listOnTap(BuildContext context, PostInfo postInfo) {
    Navigator.of(context).push(FadeRouteBuilder(page:  new PostDetail(postInfo: postInfo)));
  }

  @override
  bool get wantKeepAlive => true;
}
