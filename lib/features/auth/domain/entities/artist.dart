class Artist {
  final String id;
  final String name;
  final List<String> labels;

  const Artist({
    required this.id,
    required this.name,
    this.labels = const <String>[],
  });

  bool get isAdmin {
    for (final label in labels) {
      if (label.toLowerCase() == 'admin') {
        return true;
      }
    }
    return false;
  }
}
