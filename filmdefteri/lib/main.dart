
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/screen1.dart';
import 'screens/screen2.dart';
import 'screens/screen3.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // OMDb API anahtarı .env'den alınır.
  final String? apiKey = dotenv.env["KEY"];
  bool _isConnected = false;
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
     _connectivity = Connectivity();
      _connectivityStream =
          _connectivity.onConnectivityChanged.asyncMap((e) async {
        return e.first;
      });

      _checkConnection();

      _connectivityStream.listen((ConnectivityResult result) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      });
    }
  
  

  void _checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Times New Roman"),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
         resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text("Film Defteri",
                style: TextStyle(fontFamily: "GreatVibes", fontSize: 50)),
            bottom: const TabBar(
              tabs: [
                Tab(
                    child: Text("Ara",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Tab(
                    child: Text("Sonra İzle",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Tab(
                    child: Text("İzlediklerim",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Screen1(apiKey: apiKey ?? "Hatali"),
              Screen2(isConnected: _isConnected
              ),
              Screen3(isConnected: _isConnected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
