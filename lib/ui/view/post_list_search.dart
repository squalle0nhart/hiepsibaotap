import 'package:flutter/material.dart';
import '../view/post_list_view.dart';
import '../../config/app_config.dart';

// Widget
class PostSearch extends StatefulWidget {
  String searchString;
  //constructor
  PostSearch(
      {Key key, @required this.searchString})
      : super(key: key);
  @override
  PostSearchState createState() => PostSearchState(searchString);
}
// State
class PostSearchState extends State<PostSearch>
    with AutomaticKeepAliveClientMixin<PostSearch> {
  String searchString;
  PostSearchState(String searchString) {
    this.searchString = searchString;
  }

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
      appBar: AppBar(title: Text('Search result for: "' + searchString + '"')),
      backgroundColor: Colors.white, //Color.fromARGB(255, 240, 240, 240),
      body: new PostListView(categoryId: '', queryString: searchString)
    );
  }
}
