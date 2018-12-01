import 'package:json_annotation/json_annotation.dart'; 
  
part 'CollectionInfo.g.dart';


@JsonSerializable()
class CollectionInfo extends Object {

  int id;

  int mid;

  String title;

  int ctime;

  int mtime;

  int is_default;

  int is_open;

  String img_url;

  int collection_id;

  String desc;

  String uname;

  String avatar;

  int menu_id;

  int records_num;

  List<int> songsid_list;

  bool favorite = false;

  CollectionInfo(this.id,this.mid,this.title,this.ctime,this.mtime,this.is_default,this.is_open,this.img_url,this.collection_id,this.desc,this.uname,this.avatar,this.menu_id,this.records_num,this.songsid_list,);

  factory CollectionInfo.fromJson(Map<String, dynamic> srcJson) => _$CollectionInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CollectionInfoToJson(this);

}
