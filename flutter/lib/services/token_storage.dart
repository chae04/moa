// [역할] 로그인 토큰(JWT) 보관함
// - 로그인하면 서버가 준 토큰을 기기 보안 저장소에 저장하고, 필요할 때 꺼내거나 지운다.
// - 토큰이 있으면 "로그인된 상태", 없으면 "로그아웃 상태"로 판단하는 기준이 된다.
// - 사용처: api_client.dart(요청마다 토큰 꺼냄), auth_service.dart(로그인 시 저장, 로그아웃 시 삭제)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(); // 기기 보안 저장소 (Keychain / 암호화 저장소)
  static const _tokenKey = 'accessToken'; // 저장할 때 쓰는 키 이름

  // 로그인 성공 시 서버가 준 JWT 저장
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  // 저장된 토큰 꺼내기 (없으면 null → 로그인 안 된 상태)
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  // 로그아웃 / 탈퇴 / 토큰 만료 시 토큰 삭제
  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
