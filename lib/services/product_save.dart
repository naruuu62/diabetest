import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductSave {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<void> saveProduct(Map<String, dynamic> productData) async {
    user = auth.currentUser;
    if (user == null) {
      print("⚠️ User belum login, data tidak bisa disimpan");
      return;
    }

    try {
      final nutriments = productData['nutriments'] ?? {};

      final dataToSave = {
        'product_name': productData['product_name'] ?? 'Nama Tidak Ada',
        'generic_name': productData['generic_name'] ?? 'Deskripsi tidak tersedia',
        'image_url': productData['image_url'] ?? '',
        'categories_tags': (productData['categories_tags'] as List<dynamic>?)
            ?.cast<String>()
            .take(3)
            .map((tag) => tag.split(':').last.replaceAll('-', ' '))
            .toList() ??
            [],
        'total_gula': _toDouble(nutriments['sugars_100g']),
        'total_karbohidrat': _toDouble(nutriments['carbohydrates_100g']),
        'glycemic_index': _toDouble(nutriments['fiber_100g']),
        'glycemic_load': _toDouble(nutriments['fat_100g']),
        'other_nutriments': nutriments,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('riwayat_asupan')
          .doc(user!.uid)
          .collection('product')
          .add(dataToSave);

      print('✅ Data berhasil disimpan ke Firestore!');
    } catch (e) {
      print('❌ Gagal menyimpan data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    user = auth.currentUser;
    if (user == null) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('riwayat_asupan')
          .doc(user!.uid)
          .collection('product')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) => {
        'id': doc.id, // id dokumen
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();

      return products;
    } catch (e) {
      print('❌ Gagal mengambil data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLatestProducts({int limit = 3}) async {
    user = auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('riwayat_asupan')
          .doc(user!.uid)
          .collection('product')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();
    } catch (e) {
      print('❌ Error fetching latest products: $e');
      return [];
    }
  }
}
