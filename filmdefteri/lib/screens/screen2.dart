import 'package:flutter/material.dart';
import 'package:filmdefteri/screens/rate_popup.dart';
import '../database/database_helper.dart';
import '../models/movie.dart';

class Screen2 extends StatefulWidget {
  final bool isConnected;
  Screen2({super.key,required this.isConnected});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  bool _isConnected = false;

  String _selectedGenre = "Tümü";
  Future<List<Movie>>? _moviesFuture;
  final List<String> _genres = [
    "Tümü",
    "Sci-Fi",
    "Horror",
    "Thriller",
    "Drama",
    "Crime",
    "Romance",
    "Action",
    "Comedy",
    "Mystery"
  ];
  @override
  void initState() {
    super.initState();
    _isConnected = widget.isConnected;
    _loadMovies();
  }

  void _loadMovies({String genre = "Tümü"}) {
    if (genre == "Tümü") {
      _moviesFuture = DatabaseHelper.instance.getMovies(watched: false);
    } else {
      _moviesFuture =
          DatabaseHelper.instance.getCategory(watched: false, genre: genre);
    }
    setState(() {});
  }

  void showMoviePopup(BuildContext context, Movie movie) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Kapat")),
            ElevatedButton(
                onPressed: () async {
                  final db = DatabaseHelper.instance;
                  await db.deleteMovie(movie);
                  _loadMovies();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Sil",
                  style: TextStyle(color: Colors.white),
                ))
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Align(alignment: Alignment.center, child: Text(movie.title)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: (!_isConnected || movie.poster == "N/A")
                      ? Image.asset("assets/images/logo.png",
                          width: 240,
                          height: 240,
                          fit: BoxFit.fill) // Varsayılan resim
                      : Image.network(movie.poster,
                          width: 240, height: 240, fit: BoxFit.fill),
                ),
                const SizedBox(height: 10),
                Text("Konusu:${movie.description}"),
                const SizedBox(height: 10),
                Text(
                  "Yıl: ${movie.year}",
                ),
                const SizedBox(height: 10),
                Text("Tür: ${movie.genre}"),
                const SizedBox(height: 10),
                Text("Yönetmen: ${movie.director}"),
                const SizedBox(height: 10),
                Text("IMDB Puanı: ${movie.rating}"),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Movie>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final movies = snapshot.data!;
            return ListView.separated(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  minTileHeight: 90.0,
                  tileColor: Colors.indigo,
                  textColor: Colors.white,
                  leading: (!_isConnected || movie.poster == "N/A")
                      ? Image.asset("assets/images/logo.png",
                          width: 60,
                          height: 60,
                          fit: BoxFit.fill) // Varsayılan resim
                      : Image.network(movie.poster,
                          width: 60, height: 60, fit: BoxFit.fill),
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Yılı: ${movie.year}"),
                      Text(
                        "IMDB: ${movie.rating}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        RateMoviePopup.rate(context, movie, _loadMovies);
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                      )),
                  onTap: () {
                    showMoviePopup(context, movie);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 2);
              },
            );
          }),
      floatingActionButton: SizedBox(
        width: 100,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {},
          child: DropdownButton<String>(
            alignment: Alignment.center,
            value: _selectedGenre,
            underline: const SizedBox(), // Alt çizgiyi kaldırır
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            dropdownColor: Colors.white, // Menü arka plan rengi
            items: _genres.map((String genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(
                  genre,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedGenre = newValue;
                  _loadMovies(genre: _selectedGenre); // Filmleri filtrele
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
