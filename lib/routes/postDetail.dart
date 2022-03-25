import 'package:flutter/material.dart';

class PostDetail extends StatelessWidget {
  String title, articleContext, imageURL;

  PostDetail({required this.title, required this.articleContext, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(padding: EdgeInsets.all(16),child: Column(
        children: [Image.network(imageURL),SizedBox(height: 20,),Text(articleContext)],
      ),),
    );
  }
}
