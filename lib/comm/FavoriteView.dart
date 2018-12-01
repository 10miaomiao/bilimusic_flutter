

import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/model/CollectionInfo.dart';
import 'package:bilimusic/netword/BiliMusicApi.dart';
import 'package:bilimusic/plugin/Toast.dart';
import 'package:flutter/material.dart';

class FavoriteView extends StatefulWidget {
  int id;

  FavoriteView(this.id);

  @override
  State<FavoriteView> createState() => new _FavoriteView(id);
}



class _FavoriteView extends State<FavoriteView> {
  final _collectionsList = new List<CollectionInfo>();
  var loadAction = LoadAction.loading;
  int id;

  _FavoriteView(this.id);

  @override
  void initState(){
    super.initState();
    print("id：" + id.toString());
    loadData();
  }

  void loadData() async{
    setState(() {
      loadAction = LoadAction.loading;      
    });
    // 我的收藏
    final r = await BiliMusicApi.getCollections();
    if(r.data["code"] == 0){
      List list = r.data["data"]["list"];
      setState(() {
        loadAction = LoadAction.complete;
        _collectionsList.clear();
        list.forEach((i){
          var info = CollectionInfo.fromJson(i);
          info.favorite = info.songsid_list.indexOf(id) != -1;
          _collectionsList.add(info);
        });
      });
    }else{
      setState(() {
        loadAction = LoadAction.fail;      
      });
    }
  }

  void _favorite(BuildContext context) async{
    var list = new List<int>();
    _collectionsList.forEach((item){ 
      if(item.favorite) 
        list.add(item.id); 
    });
    try{
      var r = await BiliMusicApi.favorite(id, list);
      Toast.showLongToast(r.data["code"] == 0 ? "操作成功" : r.data["msg"]);
    }catch(e){
      Toast.showLongToast("发生错误");
    }
    Navigator.of(context).pop();
  }

  Widget buildCollectionItem(BuildContext context,int index){
    final item = _collectionsList[index];
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
      trailing: new Checkbox(
        value: item.favorite,
        onChanged: (v){
          setState(() {
            item.favorite = v;        
          });
        }
      ),
      onTap: (){
        setState(() {
          item.favorite = !item.favorite;        
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new SizedBox(
          height: 36.0,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: new Text("收藏到歌单"),
              )
            ],
          ),
        ),
        new Expanded(
          child: new LoadStatus(
            action: loadAction,
            completeBuilder: (context){
              return new ListView.builder(
                itemCount: _collectionsList.length,
                itemBuilder: buildCollectionItem,
              );
            },
            onRefresh: (){
              loadData();
            },
          ),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              child: new InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new Text(
                    "确定",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                onTap: (){ _favorite(context); },
              ),
            ),
            new Expanded(
              child: new InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new Text(
                    "取消",
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: (){
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
        
        
      ],
    );
  }
}