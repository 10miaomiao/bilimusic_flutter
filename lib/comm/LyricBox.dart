import 'package:bilimusic/comm/MarqueeWidget.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/plugin/Lyric.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LyricBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LyricBox();
}

class _LyricBox extends State<LyricBox> {
  final _scrollController = new ScrollController();
  var _itemHeight = 30.0;
  var _index = 0;
  List<LyricModel> _list = new List();

  @override
  void initState(){
    super.initState();
    new Lyric((){
      loadLyric();
    },(index){
      setState(() {
        _index = index;
      });
    });
    loadLyric();
  }

  void loadLyric(){
    Player.getLyric().then((list){
      setState(() {
        _list = list;
      });
    });
  }

  List<Widget> buildLyricList(BuildContext context,int index){
    return List.generate(_list.length, (i){
      final item = _list[i];
      final isHighlight = i == index;
      final text = new Text(
        item.text,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: isHighlight ? Theme.of(context).accentColor : Colors.black,
        ),
        maxLines: 1,
      );
      return new SizedBox(
        height: _itemHeight,
        child: new Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: text,
        ),
      );
    })
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, int>(
      converter: (store){
        int index= 0;
        final position = store.state.player.position;
        if(_list == null || _list.length == 0){
          return 0;
        }
        if(index == -1 || _list[index].time == null){
          return -1;
        }
        for(index = 0;index<_list.length;index++){
          if(position < _list[index].time){
            break;
          }
        }
        if(index > 0)
          index--;
        if(index != _index){
          final offset = _itemHeight * index;
          _scrollController.animateTo(offset, duration: new Duration(milliseconds: 500), curve: Curves.ease);
        }
        return index;
      },
      builder: (context, index){
        _index = index;
        final half = MediaQuery.of(context).size.width / 2 - _itemHeight / 2;
        final list = new ListView(
          controller: _scrollController,
          children: <Widget>[
            new SizedBox( 
              height: half,
            )]
            ..addAll(buildLyricList(context, index))
            ..add(new SizedBox( 
              height: half,
            )
          ),
        );
        return list;
      },
    );
  }

}

class LyricModel{
  String text;
  int time;
  LyricModel(this.text, this.time);
}