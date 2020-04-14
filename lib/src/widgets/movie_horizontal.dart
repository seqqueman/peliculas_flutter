import 'package:flutter/material.dart';
import 'package:peliculas/src/models/pelicula_model.dart';

class MovieHorizontal extends StatelessWidget {
  //const MovieHorizontal({Key key}) : super(key: key);

  final List<Pelicula> peliculas;
  final Function siguientePagina;

  MovieHorizontal({@required this.peliculas, @required this.siguientePagina});

  final _pageController = new PageController(
    initialPage: 1,
    viewportFraction: 0.22,
  );

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    final altura = _screenSize.height * 0.2;

    _pageController.addListener(() {
      if (_pageController.position.pixels >=
          _pageController.position.maxScrollExtent - 200) {
        siguientePagina();
      }
    });

    return Container(
      height: altura,
      child: PageView.builder(
          pageSnapping: false,
          controller: _pageController,
          //children: _tarjetas(altura, context),
          itemCount: peliculas.length,
          itemBuilder: (context, i) => _tarjeta(context, peliculas[i], altura)),
    );
  }

/*  List<Widget> _tarjetas(double altura, BuildContext context) {
    return peliculas.map((pelicula) {
      return Container(
        margin: EdgeInsets.only(right: 3.0),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FadeInImage(
                placeholder: AssetImage('assets/img/no-image.jpg'),
                image: NetworkImage(pelicula.getPosterimg()),
                fit: BoxFit.cover,
                height: altura*0.8,
              ),
            ),
            // SizedBox(height:  5.0),
            Text(
              pelicula.title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      );
    }).toList();
  }
*/
  Widget _tarjeta(BuildContext context, Pelicula pelicula, double altura) {
    pelicula.uniqueId = '${pelicula.id}-cardHor';
    final tarjeta = Container(
      margin: EdgeInsets.only(right: 3.0),
      child: Column(
        children: <Widget>[
          
          Hero(
            tag: pelicula.uniqueId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FadeInImage(
                placeholder: AssetImage('assets/img/no-image.jpg'),
                image: NetworkImage(pelicula.getPosterimg()),
                fit: BoxFit.cover,
                height: altura * 0.8,
              ),
            ),
          ),
          // SizedBox(height:  5.0),
          Text(
            pelicula.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );

    return GestureDetector(
      child: tarjeta,
      onTap: () {
        Navigator.pushNamed(context, 'detalle', arguments: pelicula);
      },
    );
  }
}
