class MusicInfo {
  final int id;
  final String title;
  final String author;
  final String cover;
  final String lyric;

  MusicInfo(this.id, this.title, this.author, this.cover, this.lyric);

  MusicInfo.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        author = json["author"],
        cover = json["cover"] ?? json["cover_url"],
        lyric = json["lyric"] ?? json["lyric_url"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "cover": cover,
      "lyric": lyric,
    };
  }
}