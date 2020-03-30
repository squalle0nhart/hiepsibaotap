class AppConfig {
  static const String appName = "Hiệp Sĩ Bão Táp";
  // config domain here!!!
  static const String domainURL = "hiepsibaotap.com";


  // API request URL
  static const String API_GET_CATEGORY_INDEX = "https://$domainURL/wp-json/wp/v2/categories";
  static const String API_GET_POST = "https://$domainURL/wp-json/wp/v2/posts/?_embed&orderby=date&order=desc"; //?page=51

  static const int STATE_LOADING = 0;
  static const int STATE_LOADING_MORE = 3;
  static const int STATE_LOAD_FINISH_POST = 1;
  static const int STATE_LOAD_FINISH_SEARCH = 1;
  static const int STATE_ERROR = -1;
  static const int STATE_LOAD_FINISH_CATEGORY = 2;

  static const int PER_PAGE = 7;

  //Pref key-value
  static const String PREF_CATEGORY_CACHE = "PREF_CATEGORY_CACHE";

}