import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class DetailPage extends StatefulWidget {
  final int initialIndex;
  final List<String> photoList;
  final PageController pageController;

  DetailPage({this.initialIndex, this.photoList})
      : pageController = PageController(initialPage: initialIndex);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
  //创建table
  Widget _buildTableView() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Table(
        columnWidths: {
          //列宽
          0: FixedColumnWidth(10),
          1: FixedColumnWidth(20),
          2: FixedColumnWidth(20),
          3: FixedColumnWidth(20),
          4: FixedColumnWidth(20),
        },
        //表格边框样式
        border: TableBorder.all(
          color: Colors.orange,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        children: _buildTableItem(1),
      ),
    );
  }

//动态创建table的item
  List<TableRow> _buildTableItem(bean) {
    List<TableRow> tabList = List();

    bean.dataList?.forEach((bean) {
      tabList.add(TableRow(children: [
        //增加行高
        SizedBox(
          height: 30,
          child: Center(
            child: photoText('颜色',
                Colors.black, 15, 1),
          ),
        ),
        SizedBox(
          height: 30,
          child: Center(
            child: photoText('S',
                Colors.black, 15, 2),
          ),
        ),
        SizedBox(
          height: 30,
          child: Center(
            child: photoText('M',
                Colors.black, 15, 2),
          ),
        ),
        SizedBox(
          height: 30,
          child: Center(
            child: photoText('L',
                Colors.black, 15, 2),
          ),
        ),
      ]));
    });
    return tabList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Image.asset(widget.photoList[currentIndex],
                  fit: BoxFit.cover),
            ),
            Center(
              child: ClipRect(
                // 可裁切矩形
                child: BackdropFilter(
                  // 背景过滤器
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Opacity(
                    opacity: 1,
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                          color: Colors.grey.shade500
                      ),*/
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround, //主轴布局
                        crossAxisAlignment: CrossAxisAlignment.center, //次轴布局
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(top: 50,left: 10,right:10,bottom:10),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    gradient: LinearGradient(      //渐变位置
                                        begin: Alignment.topRight, //右上
                                        end: Alignment.bottomLeft, //左下
                                        stops: [0.0, 1.0],         //[渐变起始点, 渐变结束点]
                                        //渐变颜色[始点颜色, 结束颜色]
                                        colors: [Color.fromRGBO(63, 68, 72, 1), Color.fromRGBO(36, 41, 46, 1)]
                                    ),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0.0, 10.0),
                                          //阴影xy轴偏移量
                                          blurRadius: 10.0,
                                          //阴影模糊程度
                                          spreadRadius: 2.0 //阴影扩散程度
                                      )
                                    ]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      padding:
                                      EdgeInsets.only(left: 10, top: 10),
                                      child: Text('上衣',
                                          style: TextStyle(
                                            color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.orange,
                                                offset: Offset(0.0, 5.0),
                                                //阴影xy轴偏移量
                                                blurRadius: 5.0,
                                                //阴影模糊程度
                                                spreadRadius: 1.0 //阴影扩散程度
                                            )
                                          ]),
                                      child: Table(
                                        //所有列宽
                                        columnWidths: const {
                                          //列宽
                                          0: FixedColumnWidth(10.0),
                                          1: FixedColumnWidth(50.0),
                                          2: FixedColumnWidth(50.0),
                                          3: FixedColumnWidth(50.0),
                                        },
                                        //表格边框样式
                                        border: TableBorder.all(
                                          color: Colors.orange,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        children: [
                                          TableRow(
                                              children: [
                                                //增加行高
                                                SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: photoText('颜色',
                                                        Colors.black, 15, 1),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: photoText('S',
                                                        Colors.black, 15, 2),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: photoText('M',
                                                        Colors.black, 15, 2),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: Center(
                                                    child: photoText('L',
                                                        Colors.black, 15, 2),
                                                  ),
                                                ),
                                              ]),
                                          TableRow(children: [
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '红色', Colors.black, 15, 1),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '1', Colors.black54, 15, 2),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '2', Colors.black54, 15, 2),
                                              ),
                                            ), SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '2', Colors.black54, 15, 2),
                                              ),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '黑色', Colors.black, 15, 1),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '4', Colors.black54, 15, 2),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '1', Colors.black54, 15, 2),
                                              ),
                                            ),SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '1', Colors.black54, 15, 2),
                                              ),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '白色', Colors.black, 15, 1),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '2', Colors.black54, 15, 2),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '5', Colors.black54, 15, 2),
                                              ),
                                            ),SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: photoText(
                                                    '5', Colors.black54, 15, 2),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(children: [
                                        Expanded(
                                          child: Text('￥250',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              )),
                                        ),
                                        Expanded(
                                          child: Text('存：100',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              )), //自定义组件,
                          Expanded(
                              flex: 2,
                              child: Container(
                                child: PhotoViewGallery.builder(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  onPageChanged: onPageChanged,
                                  itemCount: widget.photoList.length,
                                  pageController: widget.pageController,
                                  builder: (BuildContext context, int index) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider:
                                      AssetImage(widget.photoList[index]),
                                      minScale:
                                      PhotoViewComputedScale.contained *
                                          0.6,
                                      maxScale:
                                      PhotoViewComputedScale.covered * 1.1,
                                      initialScale:
                                      PhotoViewComputedScale.contained,
                                    );
                                  },
                                ),
                              ) //自定义组件,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class photoText extends StatelessWidget {
  String str;
  Color color;
  double fontSize;
  double fontWeight;

  photoText(this.str, this.color, this.fontSize, this.fontWeight);

  @override
  Widget build(BuildContext context) {
    return Text(str,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight == 1 ? FontWeight.w100 : FontWeight.w600));
  }
}
