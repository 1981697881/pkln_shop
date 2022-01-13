import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pkln_shop/http/api_response.dart';
import 'package:pkln_shop/model/version_entity.dart';
import 'package:pkln_shop/views/login/login_page.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'detail_page.dart';

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
  //自动更新字段
  String serviceVersionCode = '';
  String downloadUrl = '';
  String buildVersion = '';
  String buildUpdateDescription = '';
  ProgressDialog pr;
  String apkName = 'pkln_shop.apk';
  String appPath = '';
  ReceivePort _port = ReceivePort();

  List<String> assetNames = [
    'assets/images/splash.png',
    'assets/images/my_head.jpg',
    'assets/images/icon.png',
  ];

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen(_updateDownLoadInfo);
    FlutterDownloader.registerCallback(_downLoadCallback);
    afterFirstLayout(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // 如果是android，则执行热更新
    if (Platform.isAndroid) {
      _getNewVersionAPP(context);
    }
  }

  /// 执行版本更新的网络请求
  _getNewVersionAPP(context) async {
    ApiResponse<VersionEntity> entity = await VersionEntity.getVersion();
    serviceVersionCode = entity.data.data.buildVersionNo;
    buildVersion = entity.data.data.buildVersion;
    buildUpdateDescription = entity.data.data.buildUpdateDescription;
    downloadUrl = entity.data.data.downloadUrl;
    _checkVersionCode();
  }

  /// 检查当前版本是否为最新，若不是，则更新
  void _checkVersionCode() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      var currentVersionCode = packageInfo.buildNumber;
      if (int.parse(serviceVersionCode) > int.parse(currentVersionCode)) {
        _showNewVersionAppDialog();
      }
    });
  }

  /// 版本更新提示对话框
  Future<void> _showNewVersionAppDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Row(
              children: <Widget>[
                new Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0.0, 10.0, 0.0),
                    child: new Text("发现新版本"))
              ],
            ),
            content: new Text(
                buildUpdateDescription + "（" + buildVersion + ")"
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('下次再说'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('立即更新'),
                onPressed: () {
                  _doUpdate(context);
                },
              )
            ],
          );
        });
  }


  /// 执行更新操作
  _doUpdate(BuildContext context) async {
    Navigator.pop(context);
    _executeDownload(context);
  }

  /// 下载最新apk包
  Future<void> _executeDownload(BuildContext context) async {
    pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      isDismissible: true,
      showLogs: true,
    );
    pr.style(message: '准备下载...');
    if (!pr.isShowing()) {
      pr.show();
    }

    final path = await _apkLocalPath;
    await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: path,
        fileName: apkName,
        showNotification: true,
        openFileFromNotification: true
    );
  }

  /// 下载进度回调函数
  static void _downLoadCallback(String id, DownloadTaskStatus status,
      int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName(
        'downloader_send_port');
    send.send([id, status, progress]);
  }

  /// 更新下载进度框
  _updateDownLoadInfo(dynamic data) {
    DownloadTaskStatus status = data[1];
    int progress = data[2];
    if (status == DownloadTaskStatus.running) {
      pr.update(
          progress: double.parse(progress.toString()), message: "下载中，请稍后…");
    }
    if (status == DownloadTaskStatus.failed) {
      if (pr.isShowing()) {
        pr.hide();
      }
    }

    if (status == DownloadTaskStatus.complete) {
      if (pr.isShowing()) {
        pr.hide();
      }
      _installApk();
    }
  }

  /// 安装apk
  Future<Null> _installApk() async {
    await OpenFile.open(appPath + '/' + apkName);
  }

  /// 获取apk存储位置
  Future<String> get _apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    String path = directory.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
    this.setState(() {
      appPath = path;
    });
    return path;
  }

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
            height: 40,
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
                          contentPadding: EdgeInsets.only(bottom: 10.0),
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

  void _pushSaved() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version; //版本号
    String buildNumber = packageInfo.buildNumber; //版本构建号
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
                title: Text('版本信息（$version）'),
                onTap: () async {
                  afterFirstLayout(context);
                },
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
                            return DetailPage(
                              initialIndex: index,
                              photoList: assetNames,
                            );
                          }));
                        },
                        onLongPress: () {
                          //debug:
                          print('长按');
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
              /*margin: EdgeInsets.only(bottom: 1.0),
              padding: EdgeInsets.symmetric(
                // 同appBar的titleSpacing一致
                horizontal: NavigationToolbar.kMiddleSpacing,
                vertical: 20.0,
              ),*/
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
        child: Icon(Icons.person),
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
    return Container(
      margin: EdgeInsets.only(left:6,top: 6),
      child: new Material(
        child: new Ink(
          //设置背景
          decoration: new BoxDecoration(
            //背景
            color: this.color,
            //设置四周圆角 角度
           /* borderRadius: BorderRadius.all(Radius.circular(5.0)),*/
            //设置四周边框
          ),
          child: new InkResponse(
            borderRadius: new BorderRadius.all(new Radius.circular(25.0)),
            //点击或者toch控件高亮时显示的控件在控件上层,水波纹下层
//                highlightColor: Colors.deepPurple,
            //点击或者toch控件高亮的shape形状
            highlightShape: BoxShape.rectangle,
            //.InkResponse内部的radius这个需要注意的是，我们需要半径大于控件的宽，如果radius过小，显示的水波纹就是一个很小的圆，
            //水波纹的半径
            radius: 300.0,
            //水波纹的颜色
            splashColor: Colors.yellow,
            //true表示要剪裁水波纹响应的界面   false不剪裁  如果控件是圆角不剪裁的话水波纹是矩形
            containedInkWell: true,
            //点击事件
            onTap: () {
              print("click");
            },
            child: Container(
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: 40,
              width: 100,
              child: Text(this.text,
                style: TextStyle(
                  color: Colors.white, // 文字颜色
                )),
            ),
          ),
        ),
      ),
    );
  }
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

