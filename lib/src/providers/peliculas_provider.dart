import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider{

  String _apikey ='7b91daf5421b0907175e2762ce854d18';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;

  List<Pelicula> _populares = new List( );

  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  void disposeStreams( ){
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines( ) async{

    final url = Uri.https(_url, '3/movie/now_playing/',{
      'api_key': _apikey,
      'language' : _language
    });

    return await _tratarDatos(url);

  }

  Future<List<Pelicula>> getPopulares( ) async{

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular/',{
      'api_key': _apikey,
      'language' : _language,
      'page': _popularesPage.toString()
    });

    final resp = await _tratarDatos(url);

    _populares.addAll(resp);

    //punto clave, esto es lo que tenemos que escuchar.
    popularesSink(_populares);

    return resp;

  }

  Future<List<Pelicula>> _tratarDatos(Uri url) async {
    final respuesta  = await http.get(url);
    final decodedData = json.decode(respuesta.body);
    
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

}