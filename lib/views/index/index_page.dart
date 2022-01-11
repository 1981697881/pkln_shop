import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:english_words/english_words.dart';
import 'package:pkln_shop/views/login/login_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class IndexPage extends StatefulWidget {
  IndexPage({
    Key key,
  }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final controller = TextEditingController();
  final _saved = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  List<String> assetNames = [
    'assets/images/splash.png',
    'assets/images/my_head.jpg',
    'assets/images/icon.png',
  ];

  // 承载listView的滚动视图
  ScrollController _scrollController = ScrollController();

  // tabs 容器
  Widget buildAppBarTabs() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AppBarTabsItem(
          icon: Icons.favorite,
          text: "全部",
          color: Theme.of(context).primaryColor.withOpacity(0.8),
        ),
        AppBarTabsItem(
          icon: Icons.person,
          text: "爆款",
          color: Colors.blue.withOpacity(0.9),
        ),
        AppBarTabsItem(
          icon: Icons.face,
          text: "新品上市",
          color: Colors.green.withOpacity(0.7),
        ),
        Expanded(
            child: Card(
          child: new Container(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 6.0,
                ),
                Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: TextField(
                      controller: this.controller,
                      decoration: new InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 2.0),
                          hintText: '输入关键字',
                          border: InputBorder.none),
                      onSubmitted: (value) {
                        setState(() {});
                      },
                      // onChanged: onSearchTextChanged,
                    ),
                  ),
                ),
                new IconButton(
                  icon: new Icon(Icons.cancel),
                  color: Colors.grey,
                  iconSize: 18.0,
                  onPressed: () {
                    this.controller.clear();
                    // onSearchTextChanged('');
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _pushSaved() {
    /* Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LoginPage(
          );
        },
      ),
    );*/
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('系统设置'),
              centerTitle: true,
            ),
            body: new ListView(padding: EdgeInsets.all(10), children: <Widget>[
              ListTile(
                leading: Icon(Icons.search),
                title: Text('版本信息'),
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('退出登录'),
                onTap: () async {
                  print("点击退出登录");
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ),
                  );
                },
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _scrollView(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          /*SliverPersistentHeader(
            pinned: false,
            delegate: HeroHeader(
              minExtent: 100.0,
              maxExtent: 200.0,
            ),
          ),*/
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                    alignment: Alignment.center,
                    padding: _edgeInsetsForIndex(index),
                    child: InkWell(
                        onTap: () {
                          //debug:
                          print(assetNames[index]);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return PhotoPreview(
                              initialIndex: index,
                              photoList: assetNames,
                            );
                          }));
                        },
                        child: Column(children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  //渐变位置
                                  begin: Alignment.topRight, //右上
                                  end: Alignment.bottomLeft, //左下
                                  stops: [
                                    0.0,
                                    1.0
                                  ], //[渐变起始点, 渐变结束点]
                                  //渐变颜色[始点颜色, 结束颜色]
                                  colors: [
                                    Color.fromRGBO(63, 28, 72, 0.5),
                                    Color.fromRGBO(36, 41, 46, 1)
                                  ]),
                            ),
                            child: Center(
                              child: Text(
                                "衣服",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, // 文字颜色
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            height: 30.0,
                            width: 250.0,
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              //指定未定位或部分定位widget的对齐方式
                              children: <Widget>[
                                Container(
                                  height: 250.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          image: ExactAssetImage(
                                              assetNames[index]),
                                          fit: BoxFit.cover),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(0.0, 15.0),
                                            //阴影xy轴偏移量
                                            blurRadius: 15.0,
                                            //阴影模糊程度
                                            spreadRadius: 1.0 //阴影扩散程度
                                            )
                                      ]),
                                ),
                                /* Positioned(
                                  right: 2.0,
                                  top: 2.0,
                                  child: Text(
                                    "新品",
                                    style: TextStyle(
                                        color: Colors.pinkAccent, // 文字颜色
                                        fontWeight: FontWeight.bold),
                                  ),
                                )*/
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    //渐变位置
                                    begin: Alignment.topRight, //右上
                                    end: Alignment.bottomLeft, //左下
                                    stops: [
                                  0.0,
                                  1.0
                                ], //[渐变起始点, 渐变结束点]
                                    //渐变颜色[始点颜色, 结束颜色]
                                    colors: [
                                  Color.fromRGBO(63, 68, 72, 0.5),
                                  Color.fromRGBO(36, 21, 46, 1)
                                ])),
                            height: 35.0,
                            width: 250.0,
                            child: Row(children: <Widget>[
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.only(left: 5),
                                child: Text(
                                  "库存：999",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.white, // 文字颜色
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.only(right: 5),
                                child: Text(
                                  "￥210",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.white, // 文字颜色
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                            ]),
                          ),
                        ])));
              },
              childCount: assetNames.length,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _edgeInsetsForIndex(int index) {
    if (index % 2 == 0) {
      return EdgeInsets.only(top: 4.0, left: 8.0, right: 4.0, bottom: 4.0);
    } else {
      return EdgeInsets.only(top: 4.0, left: 4.0, right: 8.0, bottom: 4.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('主页'),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.settings), onPressed: _pushSaved),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue,
              margin: EdgeInsets.only(bottom: 1.0),
              padding: EdgeInsets.symmetric(
                // 同appBar的titleSpacing一致
                horizontal: NavigationToolbar.kMiddleSpacing,
                vertical: 20.0,
              ),
              child: buildAppBarTabs(),
            ),
            Expanded(
              //加上
              child: _scrollView(context),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomAppBar(
        //跟FloatingActionButton的margin值
        notchMargin: 4.0,
        color: Colors.blue,
        elevation: 2.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.directions),
                onPressed: () {}),
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.directions_railway),
                onPressed: () {})
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }
}

class AppBarTabsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const AppBarTabsItem({Key key, this.icon, this.text, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
              color: this.color, borderRadius: BorderRadius.circular(6.0)),
          child: Icon(
            this.icon,
            size: IconTheme.of(context).size - 6,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          this.text,
          style: TextStyle(
            color: Colors.white, // 文字颜色
          ),
        ),
      ],
    );
  }
}

//PhotoPreview 点击小图后的效果
class PhotoPreview extends StatefulWidget {
  final int initialIndex;
  final List<String> photoList;
  final PageController pageController;

  PhotoPreview({this.initialIndex, this.photoList})
      : pageController = PageController(initialPage: initialIndex);

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class HeroHeader extends SliverPersistentHeaderDelegate {
  HeroHeader({
    this.onLayoutToggle,
    this.minExtent,
    this.maxExtent,
  });

  final VoidCallback onLayoutToggle;
  double maxExtent;
  double minExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/my_head.jpg',
          /* fit: BoxFit.cover,*/
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black54,
              ],
              stops: [0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated,
            ),
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          child: Text(
            '新品上市',
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;
}

class _PhotoPreviewState extends State<PhotoPreview> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  //图片切换
  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
        itemCount: widget.photoList.length,
        pageController: widget.pageController,
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(widget.photoList[index]),
            minScale: PhotoViewComputedScale.contained * 0.6,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
      ),
    );
  }
}
