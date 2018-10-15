

// attr:0
// cover:"http://i0.hdslb.com/bfs/music/a32c1ed4f6ec3f74f8240f4486a750dda3a509e5.jpg"
// ctime:1501209433
// curtime:1533199796
// intro:"每天11:00更新，为你推送最新音乐"
// menuId:10624
// statistic:
// {sid: 10624, play: 1139166, collect: 10336, comment: 527, share: 177}
// title:"每日新曲推荐（每日11:00更新）"
// type:2
// uid:186574251
// uname:"哔哩哔哩音频"

// 热门信息
class MenuInfo{
  final int attr;
  final String cover;
  final int ctime;
  final int curtime;
  final int menuId;
  final String title;
  final int type;
  final int uid;
  final String uname;
  final String intro;

  MenuInfo(this.attr, this.cover, this.ctime, this.curtime, this.menuId, this.title, this.type, this.uid, this.uname, this.intro);

  MenuInfo.fromJson(Map<String, dynamic> json)
      : attr = json['attr'],
        cover = json['cover'],
        ctime = json['ctime'],
        curtime = json['curtime'],
        menuId = json['menuId'],
        title = json['title'],
        type = json['type'],
        uid = json['uid'],
        uname = json['uname'],
        intro = json['intro'];
}