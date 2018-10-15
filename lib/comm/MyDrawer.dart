import 'package:bilimusic/player/Toast.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('哔哩喵音乐', style: TextStyle(color: Colors.white, fontSize: 16.0)),
            accountEmail: Text("哔哩哔哩音乐姬", style: TextStyle(fontSize: 12.0)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("images/bilimusic.jpg"),
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
          ),
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
