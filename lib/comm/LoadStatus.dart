import 'package:flutter/material.dart';

class LoadStatus extends StatelessWidget {
  LoadAction action;
  WidgetBuilder loadingBuilder;
  WidgetBuilder failBuilder;
  WidgetBuilder completeBuilder;
  VoidCallback onRefresh;

  LoadStatus({
    this.action: LoadAction.loading,
    this.loadingBuilder,
    this.failBuilder,
    this.completeBuilder,
    this.onRefresh,
  });

  Widget buildLoading(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.all(10.0),
            child: new CircularProgressIndicator(),
          ),
          new Text("加载中")
        ],
      ),
    );
  }

  Widget buildFail(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.all(10.0),
            child: new Text(
              "加载出不来了 ≧ ﹏ ≦",
              style: new TextStyle(fontSize: 20.0),
            ),
          ),
          new FlatButton(
            onPressed: onRefresh ?? () {},
            child: new Text(
              "重新加载",
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          )
        ],
      ),
    );
  }

  Widget buildComplete(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Text("加载完成")],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (action) {
      case LoadAction.loading:
        if (loadingBuilder == null)
          return buildLoading(context);
        else
          return loadingBuilder(context);
        break;
      case LoadAction.fail:
        if (failBuilder == null)
          return buildFail(context);
        else
          return failBuilder(context);
        break;
      case LoadAction.complete:
        if (completeBuilder == null)
          return completeBuilder(context);
        else
          return completeBuilder(context);
        break;
    }
    return new Container();
  }
}

enum LoadAction { loading, fail, complete }
