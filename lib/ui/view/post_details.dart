import 'package:flutter/material.dart';
import '../../modal/post_info.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../database/db_functions.dart' as dbHelper;
import 'dart:math' as math;

class PostDetail extends StatefulWidget {
  final PostInfo postInfo;

  //constructor
  PostDetail({Key key, @required this.postInfo}) : super(key: key);

  @override
  createState() => new PostDetailState(this.postInfo);
}

class PostDetailState extends State<PostDetail> {
  PostInfo postInfo;
  bool isAppView = true;
  Color webViewColor = Colors.blue;
  Color appViewColor = Colors.blue[700];
  bool isLoading = false;

  PostDetailState(PostInfo postInfo) {
    this.postInfo = postInfo;
  }

  @override
  void initState() {
    super.initState();
    if (postInfo.content == '' || postInfo.content == ' ') {
      isAppView = false;
      webViewColor = Colors.blue[700];
      appViewColor = Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(postInfo.url.toString());
    return Scaffold(
        appBar: _buildAppBar(context, postInfo), body: getBody(isAppView, postInfo));
  }

  Widget getBody(bool isAppView, PostInfo postInfo) {
    if (isAppView) {
      return AppViewWidget(postInfo: postInfo);
    } else {
      return WebViewWidget(postInfo: postInfo);
    }
  }

  AppBar _buildAppBar(BuildContext context, PostInfo postInfo) {
    return AppBar(actions: <Widget>[
      GestureDetector(
        child: Container(
          color: webViewColor,
          margin: EdgeInsets.only(left: 90, right: 0),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.language),
                Text('WebView'),
              ],
            ),
          ),
        ),
        onTap: () {
          setState(() {
            isAppView = false;
            webViewColor = Colors.blue[700];
            appViewColor = Colors.blue;
          });
        },
      ),
      GestureDetector(
        child: Container(
          color: appViewColor,
          margin: EdgeInsets.only(right: 70),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.chrome_reader_mode),
                Text('AppView'),
              ],
            ),
          ),
        ),
        onTap: () {
          setState(() {
            isAppView = true;
            appViewColor = Colors.blue[700];
            webViewColor = Colors.blue;
          });
        },
      ),
      GestureDetector(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.share),
                Text('Share'),
              ],
            ),
          ),
        ),
        onTap: () {
          print('share');
          Share.share(postInfo.url);
        },
      )
    ]);
  }
}

//******************* WebView Widget ******************************/
class WebViewWidget extends StatefulWidget {
  final PostInfo postInfo;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new WebViewState(postInfo);
  }

  //constructor
  WebViewWidget({Key key, @required this.postInfo}) : super(key: key);
}

class WebViewState extends State<WebViewWidget> {
  PostInfo postInfo;
  double progress = 0;

  // Constructor
  WebViewState(PostInfo postInfo) {
    this.postInfo = postInfo;
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        (progress != 1.0)
            ? new SizedBox(
                child: LinearProgressIndicator(
                    value: progress,
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.blue[100]),
                    backgroundColor: Colors.blue[800]),
                height: 2,
              )
            : Container(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: Text(''),
          ),
        )
      ],
    );
  }
}

//******************* AppView Widget ******************************/
class AppViewWidget extends StatefulWidget {
  final PostInfo postInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AppViewState(postInfo);
  }

  //constructor
  AppViewWidget({Key key, @required this.postInfo}) : super(key: key);
}

class _AppViewState extends State<AppViewWidget> {
  PostInfo postInfo;
  bool isAppViewAvailable = true;
  List<PostInfo> listPosts = new List<PostInfo>();

  // constructor
  _AppViewState(PostInfo postInfo) {
    this.postInfo = postInfo;
    print('categories id: ' + postInfo.categoryId);
    isAppViewAvailable = (postInfo.content != '' && postInfo.content != ' ');
    dbHelper.getListCachingPost(postInfo.categoryId).then((listCachingPost) {
      print(listCachingPost.length);
      setState(() {
        this.listPosts = listCachingPost;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (isAppViewAvailable)
        ? _postContent(context, postInfo)
        : Center(
            child: Text('AppView Mode not available for this post...'),
          );
  }

  Widget _postContent(BuildContext context, PostInfo postInfo) {
    return ListView(
      children: <Widget>[
        new Html(
            padding: EdgeInsets.all(15.0),
            data: postInfo.content,
            onLinkTap: (url) {
//              _launchInBrowser(url);
            }),
        Container(
          child: Divider(color: Colors.blueGrey, height: 0.1),
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        ),
        Container(
            child: new Text('Related Post',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.left),
            padding: EdgeInsets.only(left: 10, top: 5, bottom: 10)),
        _getListRelatedPost(listPosts)
      ],
    );
  }

  Widget _getListRelatedPost(List<PostInfo> listPosts) {
    print(listPosts.length);
    int maxRelatedPost = listPosts.length;
    if (listPosts.length > 3) {
      maxRelatedPost = 3;
    }

    return new ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: maxRelatedPost,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
            child: new Card(
                margin: EdgeInsets.only(left: 5, right: 5),
                elevation: 0,
                shape: Border(
                    top: BorderSide(color: Colors.grey, width: 0.1),
                    bottom: BorderSide(color: Colors.grey, width: 0.1)),
                child: new Container(
                  height: 120,
                  child: _buildPosts(context, listPosts[index]),
                )),
            onTap: () => _listOnTap(context, listPosts[index]),
          );
        });
  }

  // build post
  Row _buildPosts(BuildContext context, PostInfo postInfo) {
    return Row(children: <Widget>[
      new Expanded(
          child: new Container(
            margin: EdgeInsets.all(2),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: new Border.all(color: Colors.grey)),
            child: new ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: new CachedNetworkImage(
                  height: 110,
                  width: 76,
                  fadeInDuration: Duration(milliseconds: 500),
                  fit: BoxFit.cover,
                  imageUrl: postInfo.thumbnailInfo,
                  placeholder: (context, holder) {
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
                  errorWidget: (context, error, obj) {
                    return  ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: new Container(
                          width: 76,
                          height: 110,
                          padding: EdgeInsets.all(5),
                          decoration: new BoxDecoration(
                            color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0),
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
          ),
          flex: 40),
      new Expanded(
          child: new Column(
            children: <Widget>[
              new Container(
                child: Html(
                  defaultTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  backgroundColor: Colors.white,
                  data: postInfo.title,
                  padding: EdgeInsets.all(10.0),
                ),
              ),
              new Expanded(
                child: Container(
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
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                ),
                flex: 2,
              )
            ],
          ),
          flex: 60),
    ]);
  }

  _listOnTap(BuildContext context, PostInfo postInfo) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => new PostDetail(postInfo: postInfo)));
  }
}
