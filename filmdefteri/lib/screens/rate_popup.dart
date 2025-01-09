import 'package:flutter/material.dart';
import 'package:filmdefteri/database/database_helper.dart';
import 'package:filmdefteri/models/movie.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateMoviePopup {
  static void rate(BuildContext context, Movie movie, Function reloadMovies) {
    final TextEditingController commentController = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(20),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                "${movie.title} için Yorum ve Puan",
                style: const TextStyle(fontSize: 20.0),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Yorumunuzu girin",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Seçilen Puan: ${rating.toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 2), 
                        Expanded(
                          child: RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: 5.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 10,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (newRating) {
                              setState(() {
                                rating = newRating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    movie.comment = commentController.text;
                    movie.ownRating = rating;
                    movie.watched = true;
                    final db = DatabaseHelper.instance;
                    await db.deleteMovie(movie);
                    final newMovie = Movie(
                      title: movie.title,
                      description: movie.description,
                      year: movie.year,
                      genre: movie.genre,
                      director: movie.director,
                      poster: movie.poster,
                      rating: movie.rating,
                      comment: movie.comment,
                      ownRating: movie.ownRating,
                      watched: movie.watched,
                    );
                    await db.insertMovie(newMovie);
                    reloadMovies();  
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("İzlenilenlere Kaydedildi"),
                      ),
                    );
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}