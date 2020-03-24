import 'package:flutter/material.dart';
import 'package:hiepsibaotap/ui/view/post_list_view.dart';
import 'package:hiepsibaotap/utils/theme_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hiepsibaotap/bloc/category_bloc.dart';
import 'package:hiepsibaotap/modal/categories_info.dart';

class DashBoard extends StatefulWidget {
  @override
  State createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with SingleTickerProviderStateMixin {
  Widget screenView;
  AnimationController sliderAnimationController;
  TabController _tabController;
  CategoryBloc _categoryBloc = new CategoryBloc();
  List<CategoryInfo> listCategory;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _categoryBloc.getListCategory().then((result) {
      listCategory = result;
      setState(() {
        isLoaded = true;
        _tabController =
            new TabController(length: listCategory.length, vsync: this);
      });
    });
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
        maxPostCount: 9999,
        queryString: '',
      ));
    }
    return listTab;
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
                body: isLoaded
                    ? Stack(
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
                              child: AppBar(
                                automaticallyImplyLeading: true,
                                elevation: 0,
                                title: Text("Hiệp sĩ bão táp"),
                                actions: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.help_outline),
                                    onPressed: () {
                                      // do search
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.star_half),
                                    onPressed: () {
                                      // do search
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.lightbulb_outline),
                                    onPressed: () {
                                      // do search
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      // do search
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text('Loading'),
                      ),
              ));
        }));
  }
}
