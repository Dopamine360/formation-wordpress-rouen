class LoginPayload {
  LoginPayload({required this.email, required this.referendumId, required this.clientNonce, required this.signature});

  final String email;
  final String referendumId;
  final String clientNonce;
  final String signature;

  Map<String, dynamic> toJson() => {
        'email': email,
        'referendum_id': referendumId,
        'client_nonce': clientNonce,
        'signature': signature,
      };
}

class LoginChallenge {
  LoginChallenge({required this.challengeId, required this.otpChannel, required this.expiresIn});

  factory LoginChallenge.fromJson(Map<String, dynamic> json) => LoginChallenge(
        challengeId: json['challenge_id'] as String,
        otpChannel: json['otp_channel'] as String,
        expiresIn: json['expires_in'] as int,
      );

  final String challengeId;
  final String otpChannel;
  final int expiresIn;
}

class VerifyOtpPayload {
  VerifyOtpPayload({required this.challengeId, required this.otpCode, this.deviceInfo});

  final String challengeId;
  final String otpCode;
  final Map<String, dynamic>? deviceInfo;

  Map<String, dynamic> toJson() => {
        'challenge_id': challengeId,
        'otp_code': otpCode,
        'device_info': deviceInfo,
      };
}

class TokenPairModel {
  TokenPairModel({required this.accessToken, required this.refreshToken});

  factory TokenPairModel.fromJson(Map<String, dynamic> json) => TokenPairModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  final String accessToken;
  final String refreshToken;
}

class ReferendumSummaryModel {
  ReferendumSummaryModel({required this.id, required this.title, required this.status, required this.publicKey});

  factory ReferendumSummaryModel.fromJson(Map<String, dynamic> json) => ReferendumSummaryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        publicKey: json['public_key'] as String,
      );

  final String id;
  final String title;
  final String status;
  final String publicKey;
}

class VoteSubmitPayload {
  VoteSubmitPayload({
    required this.referendumId,
    required this.c1,
    required this.c2,
    required this.proofCommitment,
    required this.merkleLeaf,
    required this.clientTimestamp,
    required this.nonce,
    required this.signature,
  });

  final String referendumId;
  final String c1;
  final String c2;
  final String proofCommitment;
  final String merkleLeaf;
  final String clientTimestamp;
  final String nonce;
  final String signature;

  Map<String, dynamic> toJson() => {
        'referendum_id': referendumId,
        'ballot_ciphertext': {
          'c1': c1,
          'c2': c2,
        },
        'proof_commitment': proofCommitment,
        'merkle_leaf': merkleLeaf,
        'client_timestamp': clientTimestamp,
        'nonce': nonce,
        'signature': signature,
      };
}

class VoteReceiptModel {
  VoteReceiptModel({required this.voteId, required this.merkleRoot, required this.merklePath});

  factory VoteReceiptModel.fromJson(Map<String, dynamic> json) => VoteReceiptModel(
        voteId: json['vote_id'] as String,
        merkleRoot: json['merkle_root'] as String,
        merklePath: List<String>.from(json['merkle_path'] as List<dynamic>),
      );

  final String voteId;
  final String merkleRoot;
  final List<String> merklePath;
}

class VoteVerificationModel {
  VoteVerificationModel({required this.status, required this.auditLogReference});

  factory VoteVerificationModel.fromJson(Map<String, dynamic> json) => VoteVerificationModel(
        status: json['status'] as String,
        auditLogReference: json['audit_log_reference'] as String,
      );

  final String status;
  final String auditLogReference;
}
