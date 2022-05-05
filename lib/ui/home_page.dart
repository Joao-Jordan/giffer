import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;
  final _searchController = TextEditingController();

  Future<Map?> _getSearch() async {
    http.Response response; //Declarando a resposta

    if (_search == null) {
      //Se a variável _Search for null, a resposta do request será os trendings gifs
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=caIqzglStv4GdCt2KVejx1errswe4iDf&limit=21&rating=g"));
    } else {
      //Se a variável _Search não for null, a resposta do request será a pesquisa no site
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=caIqzglStv4GdCt2KVejx1errswe4iDf&q=$_search&limit=20&offset=$_offset&rating=g&lang=en"));
    }
    return json.decode(response.body);
  }

  Widget _loadingGifs(context, snapshot) {
    switch (snapshot.connectionState) {
      case (ConnectionState.waiting):
      case (ConnectionState.none):
        return Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 5,
          ),
        );
      default:
        if (snapshot.hasError) {
          return Container();
        } else {
          return _createGifGrid(context, snapshot);
        }
    }
  }

  int _getCount(List data) {
    if (_search == null) {
      //Se não estiver pesquisando retorna a quantidade padrão de gifs (20)
      return data.length;
    } else {
      return data.length +
          1; //Se durante uma pesquisa, faz a quantidade de gifs + 1, para criar um "espaço em branco" no grid
    }
  }

  Widget _createGifGrid(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
              ["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GifPage(snapshot.data["data"][index])),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
              ["url"]);
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 50,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(
                    () {
                  _offset += 20;
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _getSearch().then((map) {});
  }

//INÍCIO DO CÓDIGO
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 1),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_searchController.text.isEmpty) {
                        _search = null;
                        _offset = 0;
                      } else {
                        _search = _searchController.text;
                      }
                    });
                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: const OutlineInputBorder(),
                labelText: 'O que você está procurando?',
                labelStyle: const TextStyle(color: Colors.white),
              ),
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              onSubmitted: (text) {
                setState(
                      () {
                    if (_searchController.text.isEmpty) {
                      _search = null;
                      _offset = 0;
                    } else {
                      _search = _searchController.text;
                    }
                  },
                );
              },
              onTap: () {
                _searchController.text = '';
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getSearch(),
              builder: _loadingGifs,
            ),
          ),
        ],
      ),
    );
  }
}
