
class DisasterAlert {
  final String title;
  final String description;
  final String pubDate;
  final String link;
  final String category;

  DisasterAlert({
    required this.title,
    required this.description,
    required this.pubDate,
    required this.link,
    required this.category,
  });

  factory DisasterAlert.fromRss(dynamic item) {
    return DisasterAlert(
      title: item.title ?? 'No Title',
      description: item.description ?? '',
      pubDate: item.pubDate?.toString() ?? '',
      link: item.link ?? '',
      category: item.categories?.first.value ?? 'General',
    );
  }
}
