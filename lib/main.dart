import 'dart:async';
import 'dart:convert';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:bilimusic/pages/SearchPage.dart';
import 'package:bilimusic/pages/ThemePage.dart';
import 'package:bilimusic/test/ListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:bilimusic/pages/HomePage.dart';
import 'package:bilimusic/pages/HistoryPage.dart';
import 'package:bilimusic/pages/MusicListPage.dart';
import 'package:bilimusic/comm/MyDrawer.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final store = new Store<AppState>(mainReducer,
      initialState: new AppState(
        player: new PlayerState(title: "", subTitle: ""),
        theme: new ThemeState(
          color: new Color(0xff2196f3),
        ),
        user: new UserState()
      ),
    );
  Timer.periodic(new Duration(milliseconds: 500), (timer) async {
    store.dispatch(await Player.getInfo());
  });
  SharedPreferences.getInstance().then((prefs){
    store.dispatch(new ThemeState(
      color: new Color(prefs.getInt("theme_color") ?? 0xff2196f3),
    ));
    var user_str = prefs.getString("user_info") ?? "";
    if(user_str != ""){
      Map<String, dynamic> user_info = json.decode(user_str);
      store.dispatch(new UserState.fromJson(user_info));
      loadUserData(store, prefs);
    }
  });
  runApp(new MyApp(store));
}

void loadUserData(Store<AppState> store,SharedPreferences prefs) async{
  final access_token = prefs.getString("access_token");
  final user = await LoginHelper.authInfo(access_token);
  if(user['code'] == 0){
    final user_data = user['data'];
    LoginHelper.saveUserInfo(user_data);
    final action = new UserState.fromJson(user_data);
    store.dispatch(action);
  }
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp(this.store);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: new StoreConnector<AppState, ThemeState>(
          builder: (ctx, theme){
            return new MaterialApp(
              title: '哔哩喵音乐',
              theme: new ThemeData(
                primaryColor: theme.color,
                accentColor: theme.color,
                primaryColorBrightness: Brightness.dark,
              ),
              home: new MyHomePage(title: '首页'),
              // home: new ListPage(),
              routes: {"musicList": (_) => MusicListPage(0)},
            );
          },
          converter: (store) => store.state.theme,
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selected = 0;
  var _title = "首页";

  Widget body(BuildContext contex) {
    switch(_selected){
      case 0:
        return new HomePage();
      case 1:
        return new HistoryPage();
      case 2:
        return new ThemePage();
      case 3:
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                height: 72.0,
                width: 72.0,
                margin: EdgeInsets.only(bottom: 10.0),
                child: new CircleAvatar(
                  backgroundImage: AssetImage("images/bilimusic.jpg"),
                ),
              ),
              new Text("哔哩喵音乐"),
              new Text("v0.1 alpha3"),
              new Text("Flutter版本：0.8.2"),
              new Text("by 10miaomiao.cn"),
            ],
          ),
        );
    }
    return new HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(_title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new SearchPage();
              }));
            }
          ),
        ],
      ),
      body: body(context),
      drawer: new MyDrawer(
        selected: _selected,
        onTap: (item) {
          setState(() {
            _selected = item.key;
            _title = item.title;
          });
        },
      ),
      bottomNavigationBar: new MyBottomBar(),
    );
  }
}
