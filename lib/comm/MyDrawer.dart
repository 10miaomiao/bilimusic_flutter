import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/pages/LoginPage.dart';
import 'package:bilimusic/pages/MinePage.dart';
import 'package:bilimusic/plugin/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

typedef void TapCallback(DrawerMenuItem item);

class MyDrawer extends StatefulWidget {
  int selected;
  TapCallback onTap;

  MyDrawer({
    this.onTap,
    this.selected,
  });

  @override
  State<StatefulWidget> createState() => _MyDrawer(onTap, selected);
}

class _MyDrawer extends State<MyDrawer> {
  bool _isLogin = false;
  int selected;
  TapCallback onTap;

  _MyDrawer(this.onTap, this.selected);

  final drawerList = <DrawerMenuItem>[
    const DrawerMenuItem(Icons.home, '首页', 0),
    const DrawerMenuItem(Icons.history, '最近', 1),
    const DrawerMenuItem(Icons.color_lens, '主题', 2),
    const DrawerMenuItem(Icons.hotel, '关于', 3),
  ];

  List<Widget> buildList(BuildContext context) {
    return drawerList.map((item) {
      return ListTile(
        selected: selected == item.key,
        leading: Icon(item.icon),
        title: Text(item.title),
        onTap: () {
          if (onTap != null) onTap(item);
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }

  void _onHeaderTap(){
    if(_isLogin){
      Navigator.of(context).pop();
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return new MinePage();
      }));
    }else{
      Navigator.of(context).pop();
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return new LoginPage();
      }));
    }
  }

  Widget buildHeader(BuildContext context){
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.user,
      builder: (context, user){
        String title, subTitle;
        ImageProvider avatar;
        _isLogin = user.isLogin;
        if(user.isLogin){
          title = user.name;
          subTitle = "硬币：${user.coin}";
          avatar = new NetworkImage(user.face);
        }else{
          title = "请登陆";
          subTitle = "ε=ε=ε=(~￣▽￣)~";
          avatar = new AssetImage("images/bilimusic.jpg");
        }
        return new UserAccountsDrawerHeader(
          accountName: new Text(
            title, 
            style: new TextStyle(
              color: Colors.white,
              fontSize: 16.0
            ),
          ),
          accountEmail: new Text(
            subTitle, 
            style: TextStyle(
              color: Colors.white70, 
              fontSize: 12.0
            ),
          ),
          currentAccountPicture: new GestureDetector(
            onTap: _onHeaderTap,
            child: new CircleAvatar(
              backgroundImage: avatar,
            ),
          ),
          otherAccountsPictures: <Widget>[
            GestureDetector(
              child: Icon(Icons.settings, color: Colors.white),
              onTap: (){
                Toast.showLongToast("施工中");
              },
            )
            ],
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            // image: DecorationImage(
            //   fit: BoxFit.cover,
            //   image: ExactAssetImage('images/lake.jpg'),
            // ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          buildHeader(context),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView(children: buildList(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int key;

  const DrawerMenuItem(this.icon, this.title, this.key);
}
