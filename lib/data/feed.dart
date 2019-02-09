class FeedItem {
  final String id;
  final String title;
  final String link;
  final String timestamp;
  final int type; // 0 - Image, 1 - Video

  FeedItem(this.id, this.title, this.link, this.timestamp, this.type);
}