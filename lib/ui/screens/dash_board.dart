import 'package:flutter/material.dart';
import 'package:hiepsibaotap/ui/view/post_list_view.dart';
import 'package:hiepsibaotap/utils/theme_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hiepsibaotap/bloc/category_bloc.dart';
import 'package:hiepsibaotap/modal/categories_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:hiepsibaotap/ui/anim/fade_route.dart';

class DashBoard extends StatefulWidget {
  @override
  State createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  Widget screenView;
  AnimationController sliderAnimationController;
  CategoryBloc _categoryBloc = new CategoryBloc();
  List<CategoryInfo> listCategory = new List<CategoryInfo>();
  int _lastTabIndex = 0;
  Icon actionIcon = new Icon(Icons.search);
  final TextEditingController _searchQuery = new TextEditingController();
  Widget appBarTitle = new Text("Hiệp sĩ bão táp");
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _categoryBloc.getListCategory();
  }

  @override
  void dispose() {
    super.dispose();
    _categoryBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeChangeNotifier(),
        child: Consumer<ThemeChangeNotifier>(builder: (context, theme, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                // status bar icons' color
                systemNavigationBarIconBrightness:
                    Brightness.dark, //navigation bar icons' color
              ),
              child: Scaffold(
                body: StreamBuilder(
                  stream: _categoryBloc.categoryStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active &&
                        snapshot.data.runtimeType == listCategory.runtimeType &&
                        snapshot.data.length > 0) {
                      TabController _tabController = new TabController(
                          length: snapshot.data.length,
                          vsync: this,
                          initialIndex: _lastTabIndex);
                      // save state of tab index
                      _tabController.addListener(() {
                        _lastTabIndex = _tabController.index;
                      });
                      listCategory = snapshot.data;
                      return Stack(
                        children: <Widget>[
                          NestedScrollView(
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                  floating: true,
                                  snap: true,
                                  pinned: true,
                                  bottom: PreferredSize(
                                    preferredSize: Size(0, kToolbarHeight),
                                    child: TabBar(
                                      isScrollable: true,
                                      controller: _tabController,
                                      tabs: _generateTab(),
                                    ),
                                  ),
                                ),
                              ];
                            },
                            body: TabBarView(
                              controller: _tabController,
                              children: _generatePage(),
                              physics: NeverScrollableScrollPhysics(),
                            ),
                          ),
                          Positioned(
                            top: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeBottom: true,
                              child: buildBar(context),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                        child: new CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                    ));
                  },
                ),
              ));
        }));
  }

  List<Widget> _generateTab() {
    List<Widget> listTab = new List<Widget>();
    for (int i = 0; i < listCategory.length; i++) {
      listTab.add(Tab(child: Text(listCategory[i].title)));
    }
    return listTab;
  }

  List<Widget> _generatePage() {
    List<Widget> listTab = new List<Widget>();
    for (int i = 0; i < listCategory.length; i++) {
      listTab.add(PostListView(
        categoryId: listCategory[i].id,
        queryString: '',
      ));
    }
    return listTab;
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
      );
      this.appBarTitle = new Text(
        "Hiệp sĩ bão táp",
      );
      _isSearching = false;
      _searchQuery.clear();
    });
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(
        elevation: 0,
        centerTitle: false,
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextField(
                    controller: _searchQuery,
                    onSubmitted: (queryString) {
                      print('subbmit');
                      if (queryString == '' || queryString == null) return;
                      _handleSearchEnd();
                      Navigator.of(context).push(FadeRouteBuilder(
                          page: Scaffold(
                        appBar: AppBar(
                          title: Text('Tìm: "' + queryString + '"'),
                        ),
                        body: PostListView(
                          categoryId: '',
                          queryString: queryString,
                        ),
                      )));
                    },
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      prefixIcon: new Icon(Icons.search, color: Colors.white,),
                      hintText: "Tìm kiếm",
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white)
                    ),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // do search
            },
          ),
          IconButton(
            icon: Icon(Icons.star_half),
            onPressed: () {
              Navigator.of(context).push(FadeRouteBuilder(
                  page: Scaffold(
                appBar: AppBar(
                  title: Text('Đánh dấu'),
                ),
                body: new PostListView(
                  categoryId: '',
                  queryString: '_bookmarked',
                ),
              )));
            },
          ),
          IconButton(
            icon: Icon(Icons.lightbulb_outline),
            onPressed: () {
              // do change theme
              DynamicTheme.of(context).setBrightness(
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark);
            },
          ),
        ]);
  }
}
