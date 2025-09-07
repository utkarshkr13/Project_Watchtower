enum Genre {
  action,
  adventure,
  animation,
  comedy,
  crime,
  documentary,
  drama,
  family,
  fantasy,
  history,
  horror,
  music,
  mystery,
  romance,
  sciFi,
  thriller,
  war,
  western;

  String get displayName {
    switch (this) {
      case Genre.sciFi:
        return 'Sci‑Fi';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  String get id => name;
}
