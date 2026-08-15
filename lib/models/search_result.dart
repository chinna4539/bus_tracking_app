enum SearchResultType { bus, route, stop }

class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final Object item;

  const SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.item,
  });
}
