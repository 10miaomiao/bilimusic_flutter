import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/model/CollectionInfo.dart';
import 'package:bilimusic/model/MenuInfo2.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/netword/BiliMusicApi.dart';
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:bilimusic/pages/CollectionDetailsPage.dart';
import 'package:bilimusic/pages/MusicListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MinePage();
}

class _MinePage extends State<MinePage> {
  final _collectionsList = new List<CollectionInfo>();
  final _menuList = new List<MenuInfo2>();
  var loadAction = LoadAction.loading;

  @override
  void initState(){
    super.initState();
    loadData();
    
  }

  void loadData() async{
    // 我的收藏
    final r = await BiliMusicApi.getCollections();
    if(r.data["code"] == 0){
      List list = r.data["data"]["list"];
      setState(() {
        _collectionsList.clear();
        list.forEach((i){
          _collectionsList.add(CollectionInfo.fromJson(i));
        });
      });
    }else{
      
    }

    final user = await LoginHelper.readUserInfo();
    final r2 = await BiliMusicApi.getMenus(user["mid"], 1, 100);
    if(r2.data["code"] == 0){
      List list = r2.data["data"]["list"];
      setState(() {
        _menuList.clear();
        list.forEach((i){
          _menuList.add(MenuInfo2.fromJson(i));
        });
      });
    }else{
      
    }
  }

  Widget buildCollectionItem(BuildContext context,CollectionInfo item){
    return new ListTile(
      leading: new Container(
        height: 64.0,
        width: 64.0,
        color: new Color(0xFFE7E7E7),
        child: item.img_url == "" 
          ? new Image.asset("images/bili.png")
          : new Image.network(item.img_url),
      ),
      title: new Text(item.title),
      subtitle: new Text(
        item.records_num.toString() 
          + "首"
          + " · "
          + (item.is_open == 1 ? "公开" : "绝对领域")
      ),
      onTap: (){
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          return new CollectionDetailsPage(item);
        }));
      },
    );
  }

  Widget buildMenuItem(BuildContext context,MenuInfo2 item){
    return new ListTile(
      leading: new Container(
        height: 64.0,
        width: 64.0,
        color: new Color(0xFFE7E7E7),
        child: new Image.network(item.coverUrl),
      ),
      title: new Text(item.title),
      subtitle: new Text(
        item.songNum.toString() + "首歌曲"
      ),
      onTap: (){
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          return new MusicListPage(item.menuId);
        }));
      },
    );
  }

  Widget buildList(BuildContext context){
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Text("创建的歌单"),
        ),
      ]..addAll(
        List.generate(
          _collectionsList.length, (index){
            return buildCollectionItem(context, _collectionsList[index]);
          },
        )
      )..add(
        new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Text("收藏的歌单"),
        ),
      )..addAll(
        List.generate(
          _menuList.length, (index){
            return buildMenuItem(context, _menuList[index]);
          },
        )
      )..add(
        new SizedBox(
          height: 10.0,
        )
      ),
    );
  }

  Widget buildHeader(BuildContext context){
    
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.user,
      builder: (context, user){
        return new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              new SizedBox(
                height: 64.0,
                width: 64.0,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(user.face),
                ),
              ),
              new Expanded(
                child: new Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: new Text(
                    user.name,
                    style: new TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                ),
              ),
              // new Column(
              //   children: <Widget>[
              //     new Text("最近")
              //   ],
              // )
            ],
          ),
        );
      },
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text("我的"),
      ),
      body: new RefreshIndicator(
        child: new ListView(
          physics: new AlwaysScrollableScrollPhysics(),
          children: [
            buildHeader(context),
            new Material(
              elevation: 5.0,
              child: buildList(context),
            ),
          ],
        ),
        onRefresh: () async{
          await loadData();
        }
      ),
      bottomNavigationBar: new MyBottomBar(),
    );
  }

}