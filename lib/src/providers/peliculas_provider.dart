import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actores_model.dart';

import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = '7b91daf5421b0907175e2762ce854d18';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing/', {
      'api_key': _apikey,
      'language': _language,
    });

    return await _tratarDatos(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular/', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularesPage.toString()
    });

    final resp = await _tratarDatos(url);

    _populares.addAll(resp);

    //punto clave, esto es lo que tenemos que escuchar.
    popularesSink(_populares);

    _cargando = false;
    return resp;
  }

  Future<List<Pelicula>> _tratarDatos(Uri url) async {
    final respuesta = await http.get(url);
    final decodedData = json.decode(respuesta.body);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key': _apikey,
      'language': _language,
    });

    final respuesta = await http.get(url);
    final decodedData = json.decode(respuesta.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);
    return cast.actores;
  }

  Future<List<Pelicula>> buscarPeliculas(String query) async {
    final url = Uri.https(_url, '3/search/movie', {
      'api_key': _apikey,
      'query': query,
      'language': _language,
    });

    return await _tratarDatos(url);
  }
}
