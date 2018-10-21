import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/model/MusicInfo.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/netword/ApiHelper.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

typedef void Callback(MusicInfo info);

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  final _list = new List<MusicInfo>();
  final _focusNode = new FocusNode();
  final _scrollController = new ScrollController();
  var _isPop = true;
  var _action = LoadAction.complete;
  var _keyword = "";
  var _page = 1;
  final _pagesize = 20;
  var _noMore = false;
  var _loading = false;
  
  @override
  void initState(){
    super.initState();
    ///增加滑动监听
    _scrollController.addListener(() {
      ///判断当前滑动位置是不是到达底部，触发加载更多回调
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_loading && !_noMore) {
          _page++;
          loadList();
        }
      }
    });
  }

  void search(String keyword) async{
    _noMore = false;
    _page = 1;
    setState(() {
      _list.clear();
      _keyword = keyword;
      _action = LoadAction.loading;
    });
    await loadList();
  }


  void loadList() async{
    _loading = true;
    final params = {
      "appkey": ApiHelper.APP_KEY,
      "build": 5310300,
      "keyword": _keyword,
      "mobi_app": "android",
      "page": _page,
      "pagesize": _pagesize,
      "platform": "android",
      "search_type": "music",
      "ts": ApiHelper.getTime(),
    };
    params["sign"] = ApiHelper.getSign(params);
    final url = "http://api.bilibili.com/audio/music-service-c/s";
    try {
      final res = await Dio().get<Map<String, dynamic>>(url, data: params);
      List list = res.data["data"]["result"];
      if(list.length < _pagesize)
        _noMore = true;
      _loading = false;
      setState(() {
        for (var item in list) {
          _list.add(new MusicInfo.fromJson(item));
        }
        _action = LoadAction.complete;
      });
    } catch (e) {
      print(e);
      setState(() {
        _action = LoadAction.fail;
      });
    }
  }


  void play(int index) async {
    Player.setList([_list[index]]);
    Player.play(0);
  }


  Widget buildItem(BuildContext context,int index){
    final item = _list[index];
    return new StoreConnector<AppState, Callback>(
      builder: (ctx, callback) {
        return new InkWell(
          onTap: () {
            play(index);
            callback(item);
          },
          child: new Container(
            padding: EdgeInsets.all(5.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  item.title,
                  style: new TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                new Text(
                  item.author,
                  style: new TextStyle(
                    fontSize: 15.0,
                    color: new Color(0xFF99A2AA),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      converter: (store) {
        return (info) => store.dispatch(
              new PlayerState(
                title: info.title,
                subTitle: info.author,
                cover: info.cover,
                isPlaying: true,
              ),
            );
      },
    );
  }


  Widget buildBody(BuildContext context){
    return new LoadStatus(
      action: _action,
      completeBuilder: (context) => new RefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _list.length,
          itemBuilder: buildItem,
        ),
        onRefresh: () async {
          await search(_keyword);
        },
      ),
      onRefresh: (){
        search(_keyword);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_isPop){
      FocusScope.of(context).requestFocus(_focusNode);
      _isPop = false;
    }
    
    return new Scaffold(
      appBar: new AppBar(
        title: new TextField(
          focusNode: _focusNode,
          style: new TextStyle(
            color: Colors.white,
          ),
          decoration: new InputDecoration(
            hintText: "请输入关键字",
            hintStyle: new TextStyle(
              color: Colors.white70,
            ),
            border: InputBorder.none,
          ),
          onSubmitted: (value){
            search(value);
          },
          textInputAction: TextInputAction.search,
        )
      ),
      body: buildBody(context),
      bottomNavigationBar: new MyBottomBar(),
    );
  }

}