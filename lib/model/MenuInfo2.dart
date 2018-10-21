import 'package:json_annotation/json_annotation.dart'; 
  
part 'MenuInfo2.g.dart';


@JsonSerializable()
class MenuInfo2 extends Object {

  int menuId;

  String title;

  String coverUrl;

  String intro;

  int type;

  int ctime;

  String ctimeStr;

  int playNum;

  int collectNum;

  int commentNum;

  int collected;

  int isOff;

  int songNum;

  String toptitle;

  String chnTitle;

  String chnTieup;

  String mbnames;

  int snum;

  int patime;

  int pbtime;

  int uid;

  String uname;

  int menuAttr;

  String schema;

  String face;

  int isDefault;

  int collectionId;

  MenuInfo2(this.menuId,this.title,this.coverUrl,this.intro,this.type,this.ctime,this.ctimeStr,this.playNum,this.collectNum,this.commentNum,this.collected,this.isOff,this.songNum,this.toptitle,this.chnTitle,this.chnTieup,this.mbnames,this.snum,this.patime,this.pbtime,this.uid,this.uname,this.menuAttr,this.schema,this.face,this.isDefault,this.collectionId,);

  factory MenuInfo2.fromJson(Map<String, dynamic> srcJson) => _$MenuInfo2FromJson(srcJson);

  Map<String, dynamic> toJson() => _$MenuInfo2ToJson(this);

}

  
