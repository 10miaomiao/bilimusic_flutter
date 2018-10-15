import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/model/BannerInfo.dart';
import 'package:flutter/material.dart';
import 'package:bilimusic/model/MenuInfo.dart';
import 'package:bilimusic/comm/MiaoGrid.dart';
import 'package:bilimusic/pages/MusicListPage.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  List<MenuInfo> _hitList = new List();
  List<MenuInfo> _rankList = new List();
  List<BannerInfo> _bannerList = new List();
  LoadAction _hitListAction = LoadAction.loading;
  LoadAction _rankListAction = LoadAction.loading;
  int _hitPn = 1;

  @override
  void initState() {
    super.initState();
    loadHitData();
    loadRankData();
    loadBannerData();
  }

  void loadHitData() async {
    final url =
        "https://www.bilibili.com/audio/music-service-c/web/menu/hit?pn=" +
            _hitPn.toString() +
            "&ps=6";
    setState(() {
      _hitListAction = LoadAction.loading;
    });
    try {
      final res = await Dio().get<Map<String, dynamic>>(url);
      List list = res.data["data"]["data"];
      setState(() {
        _hitList.clear();
        for (var item in list) {
          _hitList.add(new MenuInfo.fromJson(item));
        }
        _hitListAction = LoadAction.complete;
      });
    } catch (e) {
      print(e);
      setState(() {
        _hitListAction = LoadAction.fail;
      });
    }
  }

  void loadRankData() async {
    final url =
        "https://www.bilibili.com/audio/music-service-c/web/home/list-rank?pn=1&ps=20";
    setState(() {
      _rankListAction = LoadAction.loading;
    });
    try {
      final res = await Dio().get<Map<String, dynamic>>(url);
      List list = res.data["data"]["data"];
      setState(() {
        _rankList.clear();
        for (var item in list) {
          _rankList.add(new MenuInfo.fromJson(item));
        }
        _rankListAction = LoadAction.complete;
      });
    } catch (e) {
      setState(() {
        _rankListAction = LoadAction.fail;
      });
    }
  }

  void loadBannerData() async {
    final url =
        "https://www.bilibili.com/audio/music-service-c/web/home/banner";
    try {
      final res = await Dio().get<Map<String, dynamic>>(url);
      List list = res.data["data"];
      setState(() {
        _bannerList.clear();
        for (var item in list) {
          _bannerList.add(new BannerInfo.fromJson(item));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget buildMiddleTip(String title) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          color: Theme.of(context).accentColor,
          width: 10.0,
          height: 24.0,
          margin: EdgeInsets.only(right: 5.0, top: 10.0, bottom: 10.0),
        ),
        new Text(
          title,
          style: new TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget buildBanner(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 1040.0 / 305.0,
      child: new PageView.custom(
        controller: new PageController(),
        childrenDelegate: new SliverChildBuilderDelegate((context, index) {
          final item = _bannerList[index];
          return new Stack(
            children: <Widget>[
              new Image.network(item.bannerImgUrl),
            ],
          );
        }, childCount: _bannerList.length),
      ),
    );
  }

  Widget bunldGridList(BuildContext context, List<MenuInfo> list) {
    return new MiaoGrid(
      itemCount: list.length,
      crossAxisSpacing: 10.0,
      crossAxisCount: 3,
      mainAxisSpacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      itemBuilder: (context, index) {
        final v = list[index];
        return new InkWell(
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new MusicListPage(v.menuId);
            }));
          },
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Image.network(
                v.cover,
              ),
              new Container(
                margin: EdgeInsets.only(top: 5.0),
                child: new Text(
                  v.title,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      child: new SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildBanner(context),
            buildMiddleTip("歌单推荐"),
            new LoadStatus(
              action: _hitListAction,
              completeBuilder: (context) => new Column(
                children: <Widget>[
                  bunldGridList(context, _hitList),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new InkWell(
                        child: new Padding(
                          padding: EdgeInsets.all(5.0),
                          child: new Row(
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: new Icon(
                                  Icons.replay,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              new Text("换一换")
                            ],
                          ),
                        ),
                        onTap: () {
                          _hitPn++;
                          loadHitData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              onRefresh: () {
                loadHitData();
              },
            ),
            buildMiddleTip("全部榜单"),
            new LoadStatus(
              action: _rankListAction,
              completeBuilder: (context) => bunldGridList(context, _rankList),
              onRefresh: () {
                loadRankData();
              },
            ),
          ],
        ),
      ),
      onRefresh: () async {
        _hitPn = 1;
        await loadBannerData();
        loadHitData();
        loadRankData();
        return null;
      },
    );
  }
}
