class CategoryInfo {
  String id;
  String slug;
  String title;
  int postCount;

  CategoryInfo(
      this.id, this.slug, this.title, this.postCount);

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      json['id'].toString(),
      json['slug'].toString(),
      json['name'].toString(),
      json['count'],
    );
  }
}