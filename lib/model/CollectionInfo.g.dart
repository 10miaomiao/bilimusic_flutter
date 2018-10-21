// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CollectionInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionInfo _$CollectionInfoFromJson(Map<String, dynamic> json) {
  return CollectionInfo(
      json['id'] as int,
      json['mid'] as int,
      json['title'] as String,
      json['ctime'] as int,
      json['mtime'] as int,
      json['is_default'] as int,
      json['is_open'] as int,
      json['img_url'] as String,
      json['collection_id'] as int,
      json['desc'] as String,
      json['uname'] as String,
      json['avatar'] as String,
      json['menu_id'] as int,
      json['records_num'] as int,
      (json['songsid_list'] as List)?.map((e) => e as int)?.toList());
}

Map<String, dynamic> _$CollectionInfoToJson(CollectionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mid': instance.mid,
      'title': instance.title,
      'ctime': instance.ctime,
      'mtime': instance.mtime,
      'is_default': instance.is_default,
      'is_open': instance.is_open,
      'img_url': instance.img_url,
      'collection_id': instance.collection_id,
      'desc': instance.desc,
      'uname': instance.uname,
      'avatar': instance.avatar,
      'menu_id': instance.menu_id,
      'records_num': instance.records_num,
      'songsid_list': instance.songsid_list
    };
