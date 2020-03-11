import 'package:flutter/material.dart';
import 'package:hiepsibaotap/ui/view/post_list_view.dart';
import 'package:hiepsibaotap/utils/theme_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class DashBoard extends StatefulWidget {
  @override
  State createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with SingleTickerProviderStateMixin {
  Widget screenView;
  AnimationController sliderAnimationController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
              child: Container(
                  margin: EdgeInsets.only(top: statusBarHeight),
                  child: Scaffold(
                    drawer: Drawer(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          DrawerHeader(
                            child: Text('Drawer Header'),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                            ),
                          ),
                          ListTile(
                            title: Text('Item 1'),
                            onTap: () {
                              // Update the state of the app.
                              // ...
                            },
                          ),
                          ListTile(
                            title: Text('Item 2'),
                            onTap: () {
                              // Update the state of the app.
                              // ...
                            },
                          ),
                        ],
                      ),
                    ),
                    body: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxScroll) {
                        return <Widget>[
                          SliverAppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            expandedHeight: 10.0,
                            floating: true,
                            pinned: false,
                            primary: false,
                            iconTheme: IconThemeData(color: Colors.grey),
                            centerTitle: true,
                            actions: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: Icon(
                                  Icons.search,
                                ),
                              )
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              centerTitle: true,
                              title: Text("Hiệp sĩ bão táp",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                  )),
                            ),
                          ),
                        ];
                      },
                      body: Container(
                        child: TabBarView(
                          controller: _tabController,
                          children: <Widget>[
                            PostListView(
                              categoryId: '',
                              maxPostCount: 9999,
                              queryString: '',
                            ),
                            Text(''),
                            Text(''),
                            Text(''),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: BottomAppBar(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        padding: EdgeInsets.only(right: 5, left: 5),
                        height: 50,
                        child: TabBar(
                          labelColor: Colors.blue,
                          controller: _tabController,
                          tabs: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Icon(Icons.home),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Text("Trang chủ",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ]),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Icon(Icons.assignment),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Text(
                                    "Chủ đề",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Icon(Icons.feedback),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Text("Góp ý",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ]),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Icon(Icons.settings),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  new Text("Cài đặt",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  )));
        }));
  }
}
