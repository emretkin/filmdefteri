class Movie {
  final int? id;
  final String title;
  final String year;
  final String genre;
  final String description;
  final String poster;
  final String director;
  final double rating;
  double ownRating;
  String comment;
  bool watched;

  Movie({
    this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.description,
    required this.poster,
    required this.director,
    required this.rating,
    required this.ownRating,
    required this.comment,
    required this.watched,
  });

  //Veritabanına film bilgileri kaydedilirken kullanılıyor.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'description': description,
      'poster': poster,
      'director': director,
      'rating': rating,
      'ownRating': ownRating,
      'comment': comment,
      'watched': watched ? 1 : 0,
    };
  }

  //Veritabanından film bilgileri alınırken kullanılıyor.
  static Movie fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      year: map['year'],
      genre: map['genre'],
      description: map['description'],
      poster: map['poster'],
      director: map['director'],
      rating: map['rating'],
      ownRating: map['ownRating'],
      comment: map['comment'],
      watched: map['watched'] == 1,
    );
  }
}
