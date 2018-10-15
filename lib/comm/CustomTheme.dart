import 'package:flutter/material.dart';

typedef CustomThemeCallback = void Function(Color color);

class CustomTheme extends StatelessWidget {
  CustomThemeCallback callback;

  CustomTheme({
    @required this.callback,

  })
    : assert(callback != null);
  
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Text("自定义颜色"),
        new Row(
          children: <Widget>[
            new Text("红"),
            new Slider(
              value: 0.5,
              onChanged: (value){
              },
            )
          ],
        ),
        new Row(
          children: <Widget>[
            new Text("绿"),
            new Slider(
              value: 0.5,
              onChanged: (value){
              },
            )
          ],
        ),
        new Row(
          children: <Widget>[
            new Text("蓝"),
            new Slider(
              value: 0.5,
              onChanged: (value){
              },
            )
          ],
        ),
      ],
    );
  }

}