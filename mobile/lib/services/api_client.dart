import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.vote.local/v1');

  Future<LoginChallenge> login(LoginPayload payload) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode != 200) {
      throw ApiException('Login failed', response.statusCode, response.body);
    }
    return LoginChallenge.fromJson(jsonDecode(response.body));
  }

  Future<TokenPairModel> verifyOtp(VerifyOtpPayload payload) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode != 200) {
      throw ApiException('OTP invalid', response.statusCode, response.body);
    }
    return TokenPairModel.fromJson(jsonDecode(response.body));
  }

  Future<List<ReferendumSummaryModel>> listReferendums(String accessToken) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/referendum/list'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw ApiException('Unable to fetch referendums', response.statusCode, response.body);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;
    return items.map((item) => ReferendumSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<VoteReceiptModel> submitVote(String accessToken, VoteSubmitPayload payload) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/vote/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'X-Timestamp': DateTime.now().toUtc().toIso8601String(),
        'X-Signature': payload.signature,
      },
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode != 202) {
      throw ApiException('Vote rejected', response.statusCode, response.body);
    }
    return VoteReceiptModel.fromJson(jsonDecode(response.body));
  }

  Future<VoteVerificationModel> verifyVote(String voteId, String merkleRoot) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/vote/verify?vote_id=$voteId&merkle_root=$merkleRoot'),
    );
    if (response.statusCode != 200) {
      throw ApiException('Verification failed', response.statusCode, response.body);
    }
    return VoteVerificationModel.fromJson(jsonDecode(response.body));
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode, this.body);

  final String message;
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
