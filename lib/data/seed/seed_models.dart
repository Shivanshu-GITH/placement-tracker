/// Plain data holders for built-in seed content. Kept separate from Drift
/// rows so content authoring stays simple and readable.
class SeedSheet {
  const SeedSheet({
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    this.source = '',
    required this.topics,
  });

  final String slug;
  final String title;
  final String category; // PrepCategory.name
  final String description;
  final String source;
  final List<SeedTopic> topics;
}

class SeedTopic {
  const SeedTopic({required this.slug, required this.title, required this.items});
  final String slug;
  final String title;
  final List<SeedItem> items;
}

class SeedItem {
  const SeedItem({
    required this.slug,
    required this.title,
    this.difficulty = 'medium',
    this.url = '',
    this.platform = '',
    this.tags = '',
  });

  final String slug;
  final String title;
  final String difficulty;
  final String url;
  final String platform;
  final String tags;
}
