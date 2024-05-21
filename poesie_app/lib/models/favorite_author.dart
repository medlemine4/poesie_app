// models/favorite_author.dart
class FavoriteAuthor {
  final String authorId;

  FavoriteAuthor({
    required this.authorId,
  });
}

class FavoritePoem {
  final String poemId;

  FavoritePoem({
    required this.poemId,
  });
}

class historical {
  final String historic;

  historical({
    required this.historic,
  });

  get timestamp => null;

  static fromMap(String item) {}
}