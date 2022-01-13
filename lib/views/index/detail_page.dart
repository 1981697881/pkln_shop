import 'dart:ui';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Image.asset(
                  widget.photoList[currentIndex],fit: BoxFit.cover),
            ),
            Center(
              child: ClipRect(  // 可裁切矩形
                child: BackdropFilter(  // 背景过滤器
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Opacity(
                    opacity: 1,
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade500
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround, //主轴布局
                        crossAxisAlignment: CrossAxisAlignment.center, //次轴布局
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(
                                "￥210",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white, // 文字颜色
                                    fontWeight: FontWeight.bold),
                              ),
                            ), //自定义组件,
                          ),
                          Expanded(
                              flex: 3,
                              child: Container(
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
