class Pic {
  final int id;
  final String url;
  final String fullUrl;
  final String user;
  final String tags;
  final int likes;
  final int downloads;
  final int views;

  Pic({
    required this.id,
    required this.url,
    required this.fullUrl,
    required this.user,
    required this.tags,
    required this.likes,
    required this.downloads,
    required this.views,
  });

  factory Pic.fromJson(Map<String, dynamic> json) {
    return Pic(
      id: json['id'] as int? ?? 0,
      url: json['webformatURL'] as String? ?? '',
      fullUrl: json['largeImageURL'] as String? ?? '',
      user: json['user'] as String? ?? 'Anonymous',
      tags: json['tags'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webformatURL': url,
      'largeImageURL': fullUrl,
      'user': user,
      'tags': tags,
      'likes': likes,
      'downloads': downloads,
      'views': views,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
