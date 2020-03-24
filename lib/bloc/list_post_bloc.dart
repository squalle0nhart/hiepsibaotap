import 'dart:async';

class PostBloc {
  StreamController _postStream = new StreamController();
  Stream get postStream => _postStream.stream;


  void dispose() {
    _postStream.close();
  }
}