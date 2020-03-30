import 'package:flutter/material.dart';
import '../view/post_list_view.dart';
import '../../config/app_config.dart';

// Widget
class PostBookMark extends StatefulWidget {
  @override
  PostBookMarkState createState() => PostBookMarkState();
}
// State
class PostBookMarkState extends State<PostBookMark>
    with AutomaticKeepAliveClientMixin<PostBookMark> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return _getMainChild(context);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  _getMainChild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarked Post')),
      backgroundColor: Colors.white, //Color.fromARGB(255, 240, 240, 240),
      body: new PostListView(categoryId: '', queryString: '_bookmarked')
    );
  }
}
