
//bannerDesc:""
//bannerId:54700
//bannerImgUrl:"http://i0.hdslb.com/bfs/music/a3eb8e112cf7094d53ce4755962ba062ba9a063b.jpg"
//bannerTag:""
//bannerTitle:"协同创作功能上线啦！"
//bannerType:3
//platform:3
//schema:"https://www.bilibili.com/read/cv1108826"

class BannerInfo{
  final String bannerDesc;
  final int bannerId;
  final String bannerImgUrl;
  final String bannerTag;
  final String bannerTitle;
  final int bannerType;
  final int platform;
  final String schema;

  BannerInfo.fromJson(Map<String, dynamic> json)
      : bannerDesc = json['bannerDesc'],
        bannerId = json['bannerId'],
        bannerImgUrl = json['bannerImgUrl'],
        bannerTag = json['bannerTag'],
        bannerTitle = json['bannerTitle'],
        bannerType = json['bannerType'],
        platform = json['platform'],
        schema = json['schema'];
}