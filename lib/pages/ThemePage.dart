import 'package:bilimusic/comm/CustomTheme.dart';
import 'package:bilimusic/model/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ThemePage();
}

class _ThemePage extends State<ThemePage> {

  final _list = [
    new ThemeInfo("胖次蓝", new Color(0xff2196f3)),
    new ThemeInfo("少女粉", new Color(0xfffb7299)),
    new ThemeInfo("姨妈红", new Color(0xfff44336)),
    new ThemeInfo("咸蛋黄", new Color(0xffff9800)),
    new ThemeInfo("早苗绿", new Color(0xff4caf50)),
    new ThemeInfo("基佬紫", new Color(0xff673ab7)),
    new ThemeInfo("自定义", new Color(0xff000000)),
  ];
  var _value = -1;

  @override
  void initState() {
    super.initState();
    readTheme();
  }

  void readTheme() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = prefs.getInt("theme_index") ?? 0;
      if(_value == _list.length - 1){
        _list[_value].color = new Color(prefs.getInt("theme_color") ?? 0xff000000);
      }
    });
  }

  void setTheme(BuildContext context, int value, VoidCallback callback) {
    setState(() {
      _value = value;
    });
    if(_value == _list.length - 1){
      showDialog(
        context: context,
        builder: (context){
          return new AlertDialog(
            title: const Text('自定义主题'),
            content: SingleChildScrollView(
              child: new ColorPicker(
                pickerColor: _list[_value].color,
                onColorChanged: (color){
                  _list[_value].color = color;
                },
                enableLabel: true,
                enableAlpha: false,
                pickerAreaHeightPercent: 0.5,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('确定'),
                onPressed: () {
                  callback();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }else{
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, VoidCallback>(
      builder: (context, callback) {
        return ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index){
            final item = _list[index];
            return new ListTile(
              leading: new Container(
                height: 15.0,
                width: 15.0,
                color: item.color,
              ),
              title: new Text(item.name),
              trailing: new Radio(
                activeColor: item.color,
                onChanged: (bool){
                  setTheme(context, index, callback);
                },
                value: _value,
                groupValue: index,
              ),
              onTap: () {
                setTheme(context, index, callback);
              },
            );
          },
        );
      }, 
      converter: (store) => (){
        store.dispatch(new ThemeState(
          color: _list[_value].color
        ));
        SharedPreferences.getInstance().then((prefs){
          prefs.setInt("theme_index", _value);
          prefs.setInt("theme_color", _list[_value].color.value);
        });
      },
    );
  }
}

class ThemeInfo{
  String name;
  Color color;

  ThemeInfo(this.name, this.color);
}