import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    // Firebase Auth에 이메일/비밀번호로 계정 생성
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        // 자동생성된 uid,
        email: email,
        password: password,
      );

      try {
        // Firebase에 닉네임 저장
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nickname': nickname,
          'createdAt': DateTime.now(),
        });
      } catch (e) {
        // Firestore 실패하면 Auth 계정도 삭제
        print('Firestore 저장 실패($e)');
        await userCredential.user!.delete();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
    print('Firestore 저장 완료');
  }

  // 로그인
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 닉네임 불러오기
  Future<String> getNickname() async {
    final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    return doc.data()!['nickname'];
  }

  // 닉네임 수정
  Future<void> updateNickname(String nickname) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'nickname': nickname,
    });
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
