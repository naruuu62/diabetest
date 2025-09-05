import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IngredientsPreview extends StatefulWidget{
  const IngredientsPreview({key});
  @override
  State<IngredientsPreview> createState() => _IngredientsPreviewState();
}

class _IngredientsPreviewState extends State<IngredientsPreview> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        centerTitle: true,
      ),
      body: Center(

      ),
    );
  }
}