import 'package:bilimusic/model/state.dart' show AppState, UserState;
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  bool _isHide = false;
  final _focusNodePassword = new FocusNode();
  var _username = "";
  var _password = "";

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
    final login_r = await LoginHelper.login(_username, _password);
    if(login_r['code'] == 0){
      final data = login_r["data"];
      // 保存token
      final access_token = data['access_token'];
      final refresh_token = data['refresh_token'];
      await LoginHelper.saveToken(access_token, refresh_token);

      // 获取用户信息并保存
      final user = await LoginHelper.authInfo(access_token);
      print(user);
      if(user['code'] == 0){
        final user_data = user['data'];
        print(user_data);
        await LoginHelper.saveUserInfo(user_data);
        final action = new UserState.fromJson(user_data);
        StoreProvider.of<AppState>(context).dispatch(action);
        Navigator.of(context).pop();
      }else{
        alert(user["message"]);
      }

    }else{
      alert(login_r["message"]);
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