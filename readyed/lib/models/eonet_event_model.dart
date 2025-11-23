class EonetEvent {
  final String id;
  final String title;
  final String? description;
  final String link;
  final List<String> categories;
  final DateTime? date;
  final double? latitude;
  final double? longitude;

  EonetEvent({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    required this.categories,
    this.date,
    this.latitude,
    this.longitude,
  });

  factory EonetEvent.fromJson(Map<String, dynamic> json) {
    // Extract categories
    List<String> categoryTitles = (json['categories'] as List<dynamic>?)
            ?.map((cat) => cat['title'] as String)
            .toList() ??
        [];

    // Extract date and coordinates from the geometry list
    DateTime? eventDate;
    double? lat, lon;
    if (json['geometry'] != null && (json['geometry'] as List).isNotEmpty) {
      final geom = (json['geometry'] as List).first;
      if (geom['date'] != null) {
        eventDate = DateTime.parse(geom['date']);
      }
      if (geom['type'] == 'Point' && geom['coordinates'] != null) {
        final coords = geom['coordinates'] as List;
        if (coords.length >= 2) {
          // EONET format is typically [longitude, latitude]
          lon = (coords[0] as num).toDouble();
          lat = (coords[1] as num).toDouble();
        }
      }
    }

    return EonetEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      link: json['link'],
      categories: categoryTitles,
      date: eventDate,
      latitude: lat,
      longitude: lon,
    );
  }
}
