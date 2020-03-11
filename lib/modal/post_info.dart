class PostInfo {
  String id;
  String type;
  String slug;
  String status;
  String title;
  String content;
  String date;
  String excerpt;
  String thumbnailInfo;
  String author;
  String categoryId;
  String url;
  String intDate;
  String bookmark;

  PostInfo(this.id, this.type, this.slug, this.status, this.title, this.content,
      this.date, this.excerpt,
      this.thumbnailInfo, this.author, this.categoryId, this.url, this.intDate, this.bookmark);

  factory PostInfo.fromJson(Map<String, dynamic> json) {
    String attachment = 'https://flutter.io/images/catalog-widget-placeholder.png';
    // some post have url in attachment some in thumbnail, fuck it!
    dynamic sizes = json['_embedded']['wp:featuredmedia'][0]['media_details']['sizes'];
    if (sizes['medium'] != null) {
      attachment = sizes['medium']['source_url'].toString();
    } else if (sizes['large'] != null) {
      attachment = sizes['large']['source_url'].toString();
    } else if (sizes['full'] != null) {
      attachment = sizes['full']['source_url'].toString();
    }
    print('-------------');
    print(attachment.toString());
    String author = json['_embedded']['author'][0]['name'];

    return new PostInfo(
        json['id'].toString(),
        json['type'].toString(),
        json['slug'].toString(),
        json['status'].toString(),
        json['title']["rendered"].toString(),
        json['content']["rendered"].toString(),
        json['date'].toString().replaceAll("T", " "),
        json['excerpt']["rendered"].toString(),
        attachment,
        author,
        json['categories'][0].toString(),
        json['link'],
        DateTime.parse(json['date'].toString().replaceAll("T", " ")).millisecondsSinceEpoch.toString(),
        'false'
    );
  }


  Map<String, dynamic> toMap() => {
    'date': date,
    'id': id,
    'title': title,
    'content': content,
    'slug': slug,
    'thumbnailInfo': thumbnailInfo,
    'excerpt': excerpt,
    'status': status,
    'type': type,
    'author': author,
    'categories': categoryId,
    'link': url,
    'bookmark': bookmark
  };

  PostInfo.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'].toString();
    this.url = map['link'].toString();
    this.title = map['title'].toString();
    this.content = map['content'].toString();
    this.author = map['author'];
    this.date = map['date'].toString().replaceAll(("T"), " ");
    this.excerpt = map['excerpt'].toString();
    this.status = map['status'].toString();
    this.type = map['type'].toString();
    this.slug = map['slug'].toString();
    this.thumbnailInfo = map['thumbnailInfo'].toString();
    this.categoryId = map['categories'].toString();
    this.intDate =  DateTime.parse(map['date'].toString()).millisecondsSinceEpoch.toString();
    this.bookmark = map['bookmark'];
  }

}