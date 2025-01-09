import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:filmdefteri/screens/rate_popup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/movie.dart';

class Screen1 extends StatefulWidget {
  final String apiKey;
  const Screen1({super.key, required this.apiKey});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  bool _isConnected = false;
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  final TextEditingController _searchController = TextEditingController();
  
  //İnternet bağlantısı kontrolü
  @override
  void initState() {
    super.initState();
      _connectivity = Connectivity();
      _connectivityStream =
          _connectivity.onConnectivityChanged.asyncMap((event) async {
        return event.first;
      });
      _checkConnection();
      _connectivityStream.listen((ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
});
    _loadMovies();
  }

 void _checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _loadMovies() {
    setState(() {});
  }

  //Film bilgilerinin gösterileceği popUp
  void showMoviePopup(BuildContext context, Movie movie) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                  child: movie.poster == "N/A"
                      ? Image.asset("assets/images/default.png",
                          width: 180,
                          height: 180,
                          fit: BoxFit.fill) // Varsayılan resim
                      : Image.network(movie.poster,
                          width: 180, height: 180, fit: BoxFit.fill),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                movie.watched = false;
                final db = DatabaseHelper.instance;
                await db.insertMovie(movie);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Daha Sonra İzlenecekler listesine eklendi!")),
                );
              },
              child: const Text("Daha Sonra İzle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                RateMoviePopup.rate(context, movie, _loadMovies);
              },
              child: const Text("İzlediklerime Kaydet"),
            ),
          ],
        );
      },
    );
  }

  void errorPopUp() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red[300],
            title: const Text(
              "FİLM BULUNAMADI",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Aradığınız film maalesef bulunamadı, filmin İngilizce ismini yazmaya özen gösterin.",
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Kapat")),
            ],
          );
        });
  }

  //İnternet kapalıyken film aratılmak istenirse verilecek hata popUpu.
  void errorPopUp2() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              "İNTERNETİNİZ KAPALI",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "İnternetiniz kapalı olduğu için film aratılamıyor.",
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Kapat")),
            ],
          );
        });
  }

  //Film bilgisinin çekilip movie modeline dönüştürüldüğü fonksiyon.
  Future<Movie?> fetchMovie(String title) async {
    final url = 'https://www.omdbapi.com/?t=$title&apikey=${widget.apiKey}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        return Movie(
          title: data['Title'],
          year: data['Year'],
          genre: data['Genre'],
          description: data['Plot'],
          poster: data['Poster'],
          director: data['Director'],
          ownRating: 0,
          comment: "",
          rating: data['imdbRating'] == "N/A"
              ? 0.0
              : double.parse(data['imdbRating']),
          watched: false,
        );
      } else {
        errorPopUp();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Image.asset(
          "assets/images/wp.jpg",
          fit: BoxFit.cover,
        ),
      ),
      SingleChildScrollView(
        child: Center(
          child: Column(children: [
            const SizedBox(height: 150),
            const Text(
              "İstediğiniz Film ve Diziler\n      bir arama uzakta!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 130),
            SizedBox(
              width: 300,
              child: TextField(
                style: const TextStyle(fontSize: 18.0),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Film/Dizi Adı',
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (!_isConnected) {
                  errorPopUp2();
                  _searchController.text = "";
                  return;
                }
                else if (_searchController.text.isEmpty) {
                  _searchController.text = "";
                  return;
                } 
                final movie = await fetchMovie(_searchController.text);
                if (movie != null) {
                  showMoviePopup(context, movie);
                  setState(() {
                    _searchController.text = "";
                  });
                }
              },
              child: const Text("Ara ve Ekle"),
            ),
          ]),
        ),
      ),
    ]);
  }
}
