import 'dart:io';
import 'package:bilimusic/model/state.dart' show AppState, UserState;
import 'package:bilimusic/netword/ApiHelper.dart';
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _cookieJar = new CookieJar();
  bool _isHide = false;
  final _focusNodePassword = new FocusNode();
  var isCaptcha = false;
  var _username = "";
  var _password = "";
  var _captcha = "";
  var _captchaUrl = "https://passport.bilibili.com/captcha?ts=" + ApiHelper.getTime().toString();
  var _captchaHeaders = new Map<String, String>();

  @override
  void initState(){
    super.initState();
    _focusNodePassword.addListener((){
      setState(() {
        _isHide = _focusNodePassword.hasFocus;
      });
    });
  }

  void login(BuildContext context) async{
    try{
      final login_r = await LoginHelper.login(
        _username, _password,
        captcha: isCaptcha ? _captcha : null,
        cookieJar: _cookieJar,
      );
      if(login_r['code'] == 0){
        final data = login_r["data"];
        // 保存token
        final access_token = data['access_token'];
        final refresh_token = data['refresh_token'];
        await LoginHelper.saveToken(access_token, refresh_token);

        // 获取用户信息并保存
        final user = await LoginHelper.authInfo(access_token);
        if(user['code'] == 0){
          final user_data = user['data'];
          await LoginHelper.saveUserInfo(user_data);
          final action = new UserState.fromJson(user_data);
          StoreProvider.of<AppState>(context).dispatch(action);
          Navigator.of(context).pop();
        }else{
          setState(() {isCaptcha = false;});
          alert(user["message"]);
        }

      }else if(login_r['code'] == -105){
        List<Cookie> cookies = _cookieJar.loadForRequest(Uri.parse("https://passport.bilibili.com/"));
        var cookieValue = "";
        cookies.forEach((cookie){
          //Cookie: sid=cgdxe73p;
          cookieValue += cookie.name + "=" + cookie.value + ";";
        });    
        alert(isCaptcha ? "验证码不正确" : "请输入验证码");
        setState(() {
          _captchaUrl = "https://passport.bilibili.com/captcha?ts=" + ApiHelper.getTime().toString();
          _captchaHeaders = { "Cookie": cookieValue };
          isCaptcha = true;
        });
      }else{
        setState(() {isCaptcha = false;});
        alert(login_r["message"]);
      }
    }catch(e){
      alert("发生了一点点小错误");
      new Dio().post(
        "https://10miaomiao.cn/miao/bilimusic/logerr",
        data: { "err": e.toString()}
      );
    }
    
  }

  void alert(String text){
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
          title: new Text(text),
          actions:<Widget>[
            new FlatButton(child:new Text("确定"), onPressed: (){
              Navigator.of(context).pop();
            },)
          ]
      )
    );
  }

  Widget buildHeader(){
    final height = 72.0;
    return SizedBox(
      height: height,
      child: new Row(
        children: <Widget>[
          new Image.asset(_isHide ? "images/ic_22_hide.png" : "images/ic_22.png"),
          new Expanded(
            flex: 1,
            child: new Center(
              child: new Text(
                "登陆bilibili",
                style: new TextStyle(
                  fontSize: 24.0,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          new Image.asset(_isHide ? "images/ic_33_hide.png" : "images/ic_33.png"),
        ],
      ),
    );
  }

  Widget buildForm(BuildContext context){
    return new Column(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: new TextField(
            decoration: InputDecoration(
              hintText: '请输入用户名/邮箱/手机号'
            ),
            onChanged: (text){
              _username = text;
            },
          ),
        ),
        new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: new TextField(
            focusNode: _focusNodePassword,
            obscureText: true,
            decoration: new InputDecoration(
              hintText: "请输入密码",
            ),
            onChanged: (text){
              _password = text;
            },
          )
        ),
        isCaptcha 
          ? new Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    decoration: new InputDecoration(
                      hintText: "请输入验证码",
                    ),
                    onChanged: (text){
                      _captcha = text;
                    },
                  ),
                ),
                new GestureDetector(
                  child: new Container(
                    margin: EdgeInsets.only(left: 5.0),
                    height: 40.0,
                    child: new Image.network(
                      _captchaUrl,
                      headers: _captchaHeaders,
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      _captchaUrl = "https://passport.bilibili.com/captcha?ts=" + ApiHelper.getTime().toString();
                    });
                  },
                )
              ],
            ),
          )
          : new Container()
        ,
        new Material(
          borderRadius: BorderRadius.circular(20.0),
          child: new Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            child: new FlatButton(
              onPressed: (){
                if(_username.length == 0){
                  alert("请输入用户名/邮箱/手机号");
                  return;
                }
                if(_password.length == 0){
                  alert("请输入密码");
                  return;
                }
                login(context);
              },
              color: Theme.of(context).accentColor,
              child: new Text('登陆', style: new TextStyle(color: Colors.white),),
            ),
          ),
        )
      ],
    );
  }

  Widget buildBody(BuildContext context){
    return new Column(
      children: <Widget>[
        buildHeader(),
        new Expanded(
          child: new Material(
            elevation: 5.0,
            child: buildForm(context),
          ),
        ),
      ],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text("登陆"),
      ),
      body: buildBody(context),
    );
  }

}