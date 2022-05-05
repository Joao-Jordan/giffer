import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final Map? gifData;

  GifPage(this.gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          gifData!['title'],
          style: const TextStyle(
            color: Colors.white,
            backgroundColor: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(gifData!['images']['fixed_height']['url']);
              }),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(alignment: Alignment.center,
              child: Expanded(child: Image.network(gifData!['images']['fixed_height']['url']),
              )
          ),
        ],
      ),
    );
  }
}
