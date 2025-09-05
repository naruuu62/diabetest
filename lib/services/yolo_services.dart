import 'package:tflite_flutter/tflite_flutter.dart';

class YoloServices{
  late Interpreter interpreter;
  
  Future<void> loadModel() async{
    interpreter = await Interpreter.fromAsset('models/yolov8n_float16_tflite');

  }
}