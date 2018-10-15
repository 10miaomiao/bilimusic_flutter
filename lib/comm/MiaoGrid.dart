import 'package:flutter/material.dart';

class MiaoGrid extends StatelessWidget {

  int itemCount;
  IndexedWidgetBuilder itemBuilder;
  double mainAxisSpacing; //竖向间距
  int crossAxisCount; //横向Item的个数
  double crossAxisSpacing; //横向间距
  CrossAxisAlignment crossAxisAlignment;

  MiaoGrid({
    this.crossAxisCount : 3,
    this.crossAxisSpacing : 0.0,
    this.mainAxisSpacing : 0.0,
    @required this.itemBuilder,
    @required this.itemCount,
    this.crossAxisAlignment: CrossAxisAlignment.center,
  });

  /**
   * 创建行
   */
  Widget buildRow(BuildContext context, int count, int index) {
    if (crossAxisSpacing > 0) {
      return new Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(count * 2 - 1, (i) {
          if (i % 2 == 1) {
            return new SizedBox(width: crossAxisSpacing);
          }
          return new Expanded(child: itemBuilder(context, index + i ~/ 2));
        }),
      );
    }
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(count, (i) {
        return new Expanded(child: itemBuilder(context, index + i));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var columns = new List<Widget>();
    var index = 0;
    for (index = 0; index < itemCount; index += crossAxisCount) {
      if (index != 0 && mainAxisSpacing > 0)
        columns.add(new SizedBox(height: mainAxisSpacing));
      var count = itemCount - index < crossAxisCount
          ? itemCount - index
          : crossAxisCount;
      var rows = buildRow(context, count, index);
      columns.add(rows);
    }

    if (columns.length == 0) {
      return new Column();
    } else if (columns.length == 1) {
      return columns[0];
    } else {
      return new Column(children: columns);
    }
  }
}
