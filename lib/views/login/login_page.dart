import 'dart:convert';
import 'package:pkln_shop/model/currency_entity.dart';
import 'package:pkln_shop/model/login_entity.dart';
import 'package:pkln_shop/http/api_response.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pkln_shop/utils/toast_util.dart';
import 'package:pkln_shop/server/api.dart';
import 'package:pkln_shop/views/index/index_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _userNameController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _password = ''; //用户名
  var _username = ''; //密码
  var _isShowPwd = false; //是否显示密码
  var _isShowClear = false; //是否显示输入框尾部的清除按钮

  @override
  void initState() {
    // TODO: implement initState
    //设置焦点监听
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _userNameController.addListener(() {
      print(_userNameController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // 移除焦点监听
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeUserName.hasFocus) {
      print("用户名框获取焦点");
      // 取消密码框的焦点状态
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodeUserName.unfocus();
    }
  }

  /**
   * 验证用户名
   */
  String validateUserName(value) {
    // 正则匹配手机号
    /*RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');*/
    if (value.isEmpty) {
      return '用户名不能为空!';
    } else if (value.trim().length < 3 || value.trim().length > 10) {
      return '请输入用户名';
    }
    return null;
  }

  /**
   * 验证密码
   */
  String validatePassWord(value) {
    if (value.isEmpty) {
      return '密码不能为空';
    } else if (value.trim().length < 6 || value.trim().length > 18) {
      return '密码长度不正确';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    print(ScreenUtil().scaleHeight);

    // logo 图片区域
    Widget logoImageArea = new Container(
      alignment: Alignment.topCenter,
      // 设置图片为圆形
      child: ClipOval(
        child: Image.asset(
          "assets/images/icon.png",
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );

    //输入文本框区域
    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(left: 100, right: 100),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          /*color: Colors.white*/
      ),
      child: new Form(
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //设置键盘类型
              /* keyboardType: TextInputType.number,*/
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                helperStyle: TextStyle(
                  color: Colors.white,
                ),
                labelText: "用户名",
                hintText: "请输入用户名",
                prefixIcon: Icon(Icons.person, color: Colors.white),
                //尾部添加清除按钮
                suffixIcon: (_isShowClear)
                    ? IconButton(
                        icon: Icon(Icons.clear),
                  color: Colors.white,
                        onPressed: () {
                          // 清空输入框内容
                          _userNameController.clear();
                        },
                      )
                    : null,
              ),
              //验证用户名
              validator: validateUserName,
              //保存数据
              onSaved: (String value) {
                _username = value;
              },
            ),
            new TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  helperStyle: TextStyle(
                    color: Colors.white,//绿色
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    color: Colors.white,
                    icon: Icon(
                        (_isShowPwd) ? Icons.visibility : Icons.visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: () {
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )),
              obscureText: !_isShowPwd,
              //密码验证
              validator: validatePassWord,
              //保存数据
              onSaved: (String value) {
                _password = value;
              },
            )
          ],
        ),
      ),
    );

    // 登录按钮区域
    Widget loginButtonArea = new Container(
      margin: EdgeInsets.only(left: 300, right: 300),
      height: 60.0,
      child: new RaisedButton(
        color: Colors.blue,
        child: Text(
          "登录",
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        // 设置按钮圆角
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        onPressed: () async {
          //点击登录按钮，解除焦点，回收键盘
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
            Map<String,dynamic> map = Map();
            map['username']='kingdee';
            map['acctID']=API.ACCT_ID;
            map['lcid']=API.lcid;
            map['password']='a123456@';
            ApiResponse<LoginEntity> entity = await LoginEntity.login(map);
            if (entity.data.loginResultType == 1) {
              //  print("登录成功");
              SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
              sharedPreferences.setString('username', 'kingdee');
              sharedPreferences.setString('password', 'a123456@');
              Map<String,dynamic> userMap = Map();
              userMap['FormId']='BD_Empinfo';
              userMap['FilterString']= "FStaffNumber='$_username' and FPwd='$_password'";
              userMap['FieldKeys']='FStaffNumber,FUseOrgId.FName,FForbidStatus';/*FWorkShopID.FNumber,FWorkShopID.FName*/
              Map<String,dynamic> dataMap = Map();
              dataMap['data']=userMap;
              String UserEntity = await CurrencyEntity.polling(dataMap);
              sharedPreferences.setString('FStaffNumber', _username);
              sharedPreferences.setString('FPwd', _password);
              var resUser = jsonDecode(UserEntity);
              if(resUser.length > 0){
                print(resUser);
                if(resUser[0][2] == 'A'){
                  /*sharedPreferences.setString('FWorkShopNumber', resUser[0][2]);
                  sharedPreferences.setString('FWorkShopName', resUser[0][3]);*/
                  ToastUtil.showInfo('登录成功');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return IndexPage();
                      },
                    ),
                  );
                }else{
                  ToastUtil.showInfo('该账号无登录权限');
                }
              }else {
                ToastUtil.showInfo('用户名或密码错误');
              }
            } else {
              ToastUtil.showInfo('登录失败');
            }
            //todo 登录操作
            print("$_username + $_password");
          }
        },
      ),
    );

    return FlutterEasyLoading(
      child: MaterialApp(
        title: 'Flutter EasyLoading',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xFF6b2c25),
                  Color(0xFF896a45),
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          // 外层添加一个手势，用于点击空白部分，回收键盘
          body: GestureDetector(
              onTap: () {
                // 点击空白区域，回收键盘
                print("点击了空白区域");
                _focusNodePassWord.unfocus();
                _focusNodeUserName.unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.amberAccent,
                      Colors.white,
                    ],
                  ),
                ),
                child: Card(
                  // 背景色
                  color: Colors.black.withOpacity(.1),
                  // 阴影颜色
                  /*shadowColor: Colors.white,*/
                  elevation: 20,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  // 阴影高度
                  borderOnForeground: false,
                  // 是否在 child 前绘制 border，默认为 true
                  margin: EdgeInsets.fromLTRB(200, 200, 200, 200),
                  // 外边距
                  child: new ListView(
                    children: <Widget>[
                     /* new SizedBox(
                        height: ScreenUtil().setHeight(0),
                      ),
                      logoImageArea,*/
                      new SizedBox(
                        height: ScreenUtil().setHeight(120),
                      ),
                      inputTextArea,
                      new SizedBox(
                        height: ScreenUtil().setHeight(60),
                      ),
                      loginButtonArea,
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
