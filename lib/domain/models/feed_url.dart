class FeedUrl {
  final String id;
  final String url;
  final String name;

  FeedUrl({required this.id, required this.url, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'name': name};
  }

  factory FeedUrl.fromJson(Map<String, dynamic> json) {
    return FeedUrl(
      id: json['id'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
    );
  }
}
