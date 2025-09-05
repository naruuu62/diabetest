import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GeminiFoodServices {
  final String apiKey = "AIzaSyDSLvDAgBXeMCHlFWVjOtRF1jZd_b--WJo";

  Future<String> identifyObject(Uint8List imageBytes) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey",
    );

    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": """
Anda adalah sistem ahli pengenalan makanan. Tugas Anda adalah mengidentifikasi setiap jenis makanan yang ada di dalam gambar.

⚡ Aturan:
1. Jawab HANYA dengan nama-nama makanan yang terdeteksi.
2. Jangan sertakan deskripsi, penjelasan, atau kalimat pembuka/penutup.
3. Jika ada lebih dari satu jenis makanan, pisahkan dengan koma dan spasi.
   Contoh: "Nasi putih, Telur mata sapi, Apel".
4. Jika makanan tidak dapat diidentifikasi dengan jelas, jawab "Makanan tidak dikenali".
"""},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data["candidates"] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        return candidates[0]["content"]["parts"][0]["text"] ?? "Tidak ada hasil";
      } else {
        return "Tidak ada kandidat jawaban";
      }
    } else {
      throw Exception("Gagal: ${response.body}");
    }
  }
}
