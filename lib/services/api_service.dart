import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/business.dart';
import '../models/financial_report.dart';
import '../models/order.dart';
import '../models/order_detail.dart';
import '../models/product.dart';
import 'auth_service.dart';

// ============================================================
// ApiException
// ============================================================
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

// ============================================================
// ApiService (singleton)
// ============================================================
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  // ============================================================
  // HEADERS
  // ============================================================
  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await AuthService().getToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (isJson) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ============================================================
  // GENERIC GET
  // ============================================================
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}$path',
    ).replace(queryParameters: query);

    try {
      final headers = await _getHeaders(isJson: false);
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw ApiException('Format response tidak valid');
        }
        return decoded;
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException('Gagal parsing response: $e');
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server: $e');
    }
  }

  /// Extract error message from HTTP body (support `error` object/string & `message`)
  String _extractErrorMessage(String body, int statusCode) {
    try {
      final errJson = jsonDecode(body);
      if (errJson is Map) {
        final err = errJson['error'];
        if (err is String && err.isNotEmpty) return err;
        if (err is Map && err['message'] != null) {
          return err['message'].toString();
        }
        if (errJson['message'] != null) {
          return errJson['message'].toString();
        }
      }
    } catch (_) {}
    return 'API mengembalikan HTTP $statusCode';
  }

  // ============================================================
  // PRODUCTS
  // ============================================================
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    String? business,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (category != null && category.trim().isNotEmpty) {
      params['category'] = category.trim();
    }
    if (business != null && business.trim().isNotEmpty) {
      params['business'] = business.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      params['status'] = status.trim();
    }

    final json = await _get(ApiConfig.kProducts, query: params);
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<Product> getProduct(String slug) async {
    final json = await _get(
      '${ApiConfig.kProducts}/${Uri.encodeComponent(slug)}',
    );
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format detail produk tidak valid');
    }
    return Product.fromJson(data);
  }

  Future<List<Category>> getCategories() async {
    final json = await _get(ApiConfig.kCategories);
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  // ============================================================
  // BUSINESS — FIX: pakai /businesses/me (auth), bukan /businesses (public)
  // ============================================================
  Future<Business> getMyBusiness() async {
    final json = await _get(ApiConfig.kBusinessMe);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format data business tidak valid');
    }
    if (kDebugMode) {
      debugPrint('🔧 Business.fromJson keys: ${data.keys.toList()}');
    }
    return Business.fromJson(data);
  }

  // ============================================================
  // ORDERS
  // ============================================================
  Future<List<Order>> getOrders({String? status}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      params['status'] = status;
    }
    final json = await _get(ApiConfig.kOrders, query: params);
    final data = json['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Order.fromJson).toList();
  }

  Future<OrderDetail> getOrderDetail(String publicId) async {
    final json = await _get('${ApiConfig.kOrders}/$publicId');
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format detail order tidak valid');
    }
    return OrderDetail.fromJson(data);
  }

  // ============================================================
  // SHIPMENTS
  // ============================================================
  Future<List<Shipment>> getShipments() async {
    final json = await _get(ApiConfig.kShipments);
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Shipment.fromJson)
        .toList();
  }

  // ============================================================
  // FINANCIAL REPORT
  // ============================================================
  Future<FinancialReport> getFinancialReport({
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final json = await _get(ApiConfig.kReportFinancial, query: params);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Format laporan tidak valid');
    }
    return FinancialReport.fromJson(data);
  }

  // ============================================================
  // COURIERS
  // ============================================================
  Future<List<dynamic>> getAvailableCouriers({
    required double lat,
    required double lng,
    double radius = 5,
  }) async {
    // FIX: query param harus via Uri.replace, bukan concat di path
    final json = await _get(
      '/courier/available',
      query: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
      },
    );
    return (json['data'] as List<dynamic>?) ?? const [];
  }

  Future<void> assignCourier(
    String orderPublicId,
    dynamic courierId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}/orders/$orderPublicId/assign-courier',
    );
    try {
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(),
            body: jsonEncode({'courier_id': courierId}),
          )
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal assign kurir: $e');
    }
  }

  Future<void> claimPickup(String orderPublicId) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}/orders/$orderPublicId/claim-pickup',
    );
    try {
      final response = await http
          .post(uri, headers: await _getHeaders())
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal klaim pickup: $e');
    }
  }

  // ============================================================
  // PRODUCT CRUD
  // ============================================================
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    String? categorySlug,
    String? sku,
  }) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}');
    try {
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(),
            body: jsonEncode({
              'name': name.trim(),
              'price': price,
              'stock': stock,
              'description': description?.trim(),
              'category_slug': categorySlug,
              'sku': sku,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal membuat produk',
          statusCode: response.statusCode,
        );
      }
      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal membuat produk',
        );
      }
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required String publicId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? categorySlug,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}/$publicId',
    );
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (price != null) body['price'] = price;
    if (stock != null) body['stock'] = stock;
    if (description != null) body['description'] = description.trim();
    if (categorySlug != null) body['category_slug'] = categorySlug;

    try {
      final response = await http
          .put(uri, headers: await _getHeaders(), body: jsonEncode(body))
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal update produk',
          statusCode: response.statusCode,
        );
      }
      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal update produk',
        );
      }
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  Future<void> deleteProduct(String publicId) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}${ApiConfig.kProducts}/$publicId',
    );
    try {
      final response = await http
          .delete(uri, headers: await _getHeaders())
          .timeout(const Duration(milliseconds: ApiConfig.kTimeoutMs));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal hapus produk',
          statusCode: response.statusCode,
        );
      }
      if (json['success'] != true) {
        throw ApiException(json['message']?.toString() ?? 'Gagal hapus produk');
      }
    } on TimeoutException {
      throw ApiException('Permintaan timeout. Periksa koneksi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  // ============================================================
  // MULTIPART UPLOAD — LOGO
  // ============================================================
  Future<void> uploadLogo(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}/businesses/me/logo');
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _getHeaders(isJson: false));
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('logo', bytes, filename: 'logo.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('logo', imageFile.path),
        );
      }
      final streamed = await request
          .send()
          .timeout(const Duration(milliseconds: 30000));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Upload timeout.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal upload logo: $e');
    }
  }

  // ============================================================
  // MULTIPART UPLOAD — BANNER
  // ============================================================
  Future<void> uploadBanner(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}/businesses/me/banner');
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _getHeaders(isJson: false));
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('banner', bytes, filename: 'banner.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('banner', imageFile.path),
        );
      }
      final streamed = await request
          .send()
          .timeout(const Duration(milliseconds: 30000));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Upload timeout.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal upload banner: $e');
    }
  }

  // ============================================================
  // MULTIPART UPLOAD — PRODUCT IMAGE
  // ============================================================
  Future<Map<String, dynamic>> uploadProductImage({
    required String productPublicId,
    required File imageFile,
    bool isPrimary = true,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}/products/$productPublicId/images',
    );
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _getHeaders(isJson: false));

      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: 'upload.$ext',
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
      request.fields['is_primary'] = isPrimary ? '1' : '0';

      final streamed = await request
          .send()
          .timeout(const Duration(milliseconds: 30000));
      final response = await http.Response.fromStream(streamed);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal upload gambar',
          statusCode: response.statusCode,
        );
      }
      if (json['success'] != true) {
        throw ApiException(
          json['message']?.toString() ?? 'Gagal upload gambar',
        );
      }
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on TimeoutException {
      throw ApiException('Upload timeout. Coba lagi.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal upload: $e');
    }
  }
}