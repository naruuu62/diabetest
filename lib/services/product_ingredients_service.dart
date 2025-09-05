import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductIngredients{
  final String baseUrl = "https://world.openfoodfacts.org/api/v2";

  Future<Map<String, dynamic>?> searchProduct(String query)async{
    final url = Uri.parse('$baseUrl/search?query=$query');

    try{
      final response = await http.get(url);

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);

        if(data["products"]!= null && data["products"].length > 0){
          return data["products"][0];
        }
      }
      return null;
    } catch(e){
      print("Error fetching product: $e");
      return null;
    }
  }
}