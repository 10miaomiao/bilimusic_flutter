import 'package:flutter/material.dart';

class LyricBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LyricBox();
}

class _LyricBox extends State<LyricBox> {
  final _scrollController = new ScrollController();
  var _index = -1;
  List<LyricModel> _list;

  @override
  void initState(){
    super.initState();
    new Lyric((){
      loadLyric();
    },(index){
      setState(() {
        _lyricIndex = index;
      });
    });
    loadLyric();
  }

  void loadLyric(){
    Player.getLyric().then((list){
      setState(() {
        _lyricList = list;
      });
    });
  }

  List<Widget> buildLyricList(BuildContext context){
    return _list.map((item){
      return new Center(
        child: new Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: new Text(
            item.text,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = new ListView(
      controller: _scrollController,
      children: <Widget>[
        new SizedBox( 
          height: MediaQuery.of(context).size.width / 2,
        )]
        ..addAll(buildLyricList(context))
        ..add(new SizedBox( 
          height: MediaQuery.of(context).size.width / 2,
        )
      ),
    );
    // _scrollController.animateTo(50.0, duration: new Duration(seconds: 2), curve: Curves.ease);
    return list;
  }

}

class LyricModel{
  String text;
  int time;
  LyricModel(this.text, this.time);
}