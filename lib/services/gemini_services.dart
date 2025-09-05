import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class GeminiServices {
  final String apiKey = "AIzaSyDSLvDAgBXeMCHlFWVjOtRF1jZd_b--WJo";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;


  Map<String, dynamic>? _parseGeminiJson(String textResponse) {
    try {
      String rawJson = textResponse;
    if (rawJson.contains("```json")) {
        rawJson = rawJson.split("```json")[1].split("```")[0].trim();
      }


      if (rawJson.contains("```")) {
        rawJson = rawJson.split("```")[1].trim();
      }

      rawJson = rawJson.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim();

      return jsonDecode(rawJson);
    } catch (e) {
      print("LOG: Gagal parse JSON: $e");
      return null;
    }
  }


  Future<String> identifyObject(Uint8List imageBytes) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey",
    );

    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": """
Anda adalah sistem inventaris toko. Tugas Anda adalah mengidentifikasi nama produk pada gambar.

⚡ Aturan:
1. Jawab hanya dengan nama produk lengkap (brand + varian utama).
2. Jangan sertakan deskripsi tambahan, penjelasan, atau kalimat lain.
3. Format jawaban: "<Merek> <Varian>".
   Contoh: "Indomie Goreng Original", "Aqua Botol 600ml", "Oreo Vanilla".
4. Jika produk tidak jelas, jawab "Tidak dikenali".
"""
            },
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

  Future<Map<String, dynamic>> getAnalysisFromGemini() async {
    try {
      _user = _auth.currentUser;

      if (_user == null) {
        print("LOG: Pengguna tidak login.");
        return {'risiko': 'Error', 'alasan': 'Pengguna tidak login.'};
      }

      print("LOG: Mengambil data pengguna dari Firestore...");
      DocumentSnapshot userDoc =
      await _firestore.collection('identity').doc(_user!.uid).get();

      if (!userDoc.exists) {
        print("LOG: Data pengguna tidak ditemukan di Firestore.");
        return {
          'risiko': 'Tidak Ada Data',
          'alasan': 'Data pengguna tidak ditemukan.'
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print("LOG: Data pengguna berhasil diambil: $userData");

      String prompt = """
Berdasarkan data profil kesehatan berikut, berikan analisis risiko diabetes dalam format JSON. 
Format JSON harus memiliki dua kunci: 'risiko' ('tinggi', 'sedang', 'rendah') dan 'alasan'.

Data Pengguna:
- Konsumsi alkohol: "${userData['alkohol']}"
- Tekanan darah tinggi: "${userData['darah_tinggi']}"
- Diabetes: "${userData['diabetes']}"
- Jenis kelamin: "${userData['gender']}"
- Tinggi: "${userData['height']}" cm
- Kolesterol: "${userData['kolesterol']}"
- Olahraga: "${userData['olahraga']}"
- Pola makan: "${userData['pola_makan']}"
- Tipe diabetes: "${userData['tipe']}"
- Berat: "${userData['weight']}" kg

JSON Respons:
""";
      print("LOG: Prompt Gemini siap.");

      print("LOG: Memanggil Gemini API...");
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      print("LOG: Permintaan selesai. Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data["candidates"] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final textResponse =
              candidates[0]["content"]["parts"][0]["text"] ?? "";
          print("LOG: Respons Gemini (mentah): $textResponse");

          final analysisData = _parseGeminiJson(textResponse);

          if (analysisData != null) {
            String risiko = analysisData['risiko'] ?? 'tidak';
            await _firestore.collection('identity').doc(_user!.uid).update({
              'status_diabetes': risiko.toLowerCase(),
            });
            print("LOG: Status diabetes berhasil disimpan: $risiko");
            return analysisData;
          } else {
            return {
              'risiko': 'Error',
              'alasan': 'Gagal memproses JSON dari Gemini.'
            };
          }
        } else {
          return {
            'risiko': 'Error',
            'alasan': 'Tidak ada kandidat respons dari Gemini.'
          };
        }
      } else {
        return {
          'risiko': 'Error',
          'alasan': 'Gagal mendapatkan analisis dari Gemini API.'
        };
      }
    } catch (e) {
      print("LOG: Terjadi exception: $e");
      return {'risiko': 'Error', 'alasan': 'Terjadi error: $e'};
    }
  }

  Future<Map<String, dynamic>> getProductAnalysis(Map<String, dynamic> productData) async {
    final String prompt = """
Analisis produk makanan/minuman berikut untuk kesehatan dalam format JSON.
Format JSON WAJIB seperti ini:
{
  "skor_kesehatan": <angka 0-100>,
  "status": "<Sehat / Kurang Sehat / Tidak Sehat>",
  "rekomendasi": ["..."],
  "alternatif": ["..."],
  "penjelasan": "..."
}

Data Produk:
${jsonEncode(productData)}
""";

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        final String rawText =
            responseBody['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
                '';

        print("LOG: Respons Gemini Produk (mentah): $rawText");


        final parsedJson = _parseGeminiJson(rawText);

        if (parsedJson != null) {
          return parsedJson;
        } else {
          return {
            "skor_kesehatan": 50,
            "status": "Analisis Gagal",
            "rekomendasi": ["Gagal mendapatkan rekomendasi."],
            "alternatif": ["Coba lagi nanti."],
            "penjelasan": "Terjadi kesalahan saat memproses data produk."
          };
        }
      } else {
        throw Exception("API call failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in Gemini API call: $e");
      return {
        "skor_kesehatan": 50,
        "status": "Analisis Error",
        "rekomendasi": ["Terjadi error saat analisis."],
        "alternatif": ["Silakan coba ulang nanti."],
        "penjelasan": e.toString()
      };
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    final prompt = """
    Terjemahkan teks berikut ke dalam $targetLanguage: "$text"
    Hanya berikan hasil terjemahan, tanpa kalimat tambahan atau penjelasan.
    """;

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ]
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return translatedText.trim();
      } else {
        print("Gemini Translate Error: ${response.body}");
        return text; // Fallback ke teks asli jika gagal
      }
    } catch (e) {
      print("Gemini Translate Exception: $e");
      return text; // Fallback ke teks asli jika terjadi error
    }
  }


}




