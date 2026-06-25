import 'package:fish_counter/utils/type_utils.dart';

/// User information for a game session.
class SessionUserInfo {
  final String userId;
  final String userEmail;
  final String userDisplayName;

  const SessionUserInfo({
    this.userId = '',
    this.userEmail = '',
    this.userDisplayName = '',
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userEmail': userEmail,
    'userDisplayName': userDisplayName,
  };

  factory SessionUserInfo.fromJson(Map<String, dynamic> json) {
    return SessionUserInfo(
      userId: TypeUtils.safeString(json['userId']),
      userEmail: TypeUtils.safeString(json['userEmail']),
      userDisplayName: TypeUtils.safeString(json['userDisplayName']),
    );
  }
}