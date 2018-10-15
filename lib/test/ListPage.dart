import 'package:flutter/material.dart';

const double _ITEM_HEIGHT = 70.0;

class ListPage extends StatefulWidget {
  ListPage({Key key}) : super(key: key);

  @override
  _ListPageState createState() => new _ListPageState();

}

class _ListPageState extends State<ListPage> {
  ScrollController _scrollController;
  List<Item> _items;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    // TODO - this is shortcut to specify items.
    // In a real app, you would get them
    // from your data repository or similar.
    _items = new List<Item>();
    _items.add(new Item("Apples", false));
    _items.add(new Item("Oranges", false));
    _items.add(new Item("Rosemary", false));
    _items.add(new Item("Carrots", false));
    _items.add(new Item("Potatoes", false));
    _items.add(new Item("Mushrooms", false));
    _items.add(new Item("Thyme", false));
    _items.add(new Item("Tomatoes", false));
    _items.add(new Item("Peppers", false));
    _items.add(new Item("Salt", false));
    _items.add(new Item("Ground ginger", false));
    _items.add(new Item("Cucumber", false));
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonsWidget = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new FlatButton(
            textColor: Colors.blueGrey,
            color: Colors.white,
            child: new Text('SELECT ORANGES'),
            onPressed: _scrollToOranges,
          ),
          new FlatButton(
            textColor: Colors.blueGrey,
            color: Colors.white,
            child: new Text('SELECT TOMATOES'),
            onPressed: _scrollToTomatoes,
          ),
        ],
      ),
    );

    Widget itemsWidget =
      new ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          controller: _scrollController,
          children: _items.map((Item item) {
            return _singleItemDisplay(item);
          }).toList());


    return new Scaffold(
      appBar: new AppBar(
        title: new Text("List of items"),
      ),
      body: new Padding(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
        child: new Column(children: <Widget>[
          buttonsWidget,
          new Expanded(
            child:
            itemsWidget,),
        ],
        ),
      ),
    );
  }

  Widget _singleItemDisplay(Item item) {
    return new Container(
      height: _ITEM_HEIGHT,
      child: new Container (
        padding: const EdgeInsets.all(2.0),
        color: new Color(0x33000000),
        child: new Text(item.displayName),
      ),
    );
  }

  void _scrollToOranges() {
    setState(() {
    for (var item in _items) {
        if (item.displayName == "Oranges") {
          item.selected = true;
        } else {
          item.selected = false;
        }
      }
    });
  }

  void _scrollToTomatoes() {
    setState(() {
      for (var item in _items) {
        if (item.displayName == "Tomatoes") {
          item.selected = true;
        } else {
          item.selected = false;
        }
      }
    });
  }
}


class Item {
  final String displayName;
  bool selected;
 
  Item(this.displayName, this.selected);
}