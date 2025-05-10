import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Timer? _emailDebounce, _nickDebounce;
  bool _emailChecked = false, _emailExists = false;
  bool _nickChecked = false, _nickExists = false;
  bool _passwordsMatch = true;
  String? _passwordError, _gender, _errorText;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(_checkMatch);
  }

  void _checkMatch() {
    setState(() {
      _passwordsMatch = _passwordCtrl.text == _confirmCtrl.text;
      _passwordError =
          _passwordsMatch ? null : '비밀번호가 일치하지 않습니다.';
    });
  }

  void _checkEmailDup() {
    _emailDebounce?.cancel();
    _emailDebounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        final e = _emailCtrl.text.trim();
        if (e.isEmpty) return;
        final q = await _firestore
            .collection('users')
            .where('email', isEqualTo: e)
            .limit(1)
            .get();
        setState(() {
          _emailChecked = true;
          _emailExists = q.docs.isNotEmpty;
        });
      },
    );
  }

  void _checkNickDup() {
    _nickDebounce?.cancel();
    _nickDebounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        final n = _nickCtrl.text.trim();
        if (n.isEmpty) return;
        final q = await _firestore
            .collection('users')
            .where('nickname', isEqualTo: n)
            .limit(1)
            .get();
        setState(() {
          _nickChecked = true;
          _nickExists = q.docs.isNotEmpty;
        });
      },
    );
  }

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;
    final conf = _confirmCtrl.text;
    final name = _nameCtrl.text.trim();
    final nick = _nickCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    String? error;
    if ([email, pass, conf, name, nick, phone, _gender]
        .contains(null) ||
        [email, pass, conf, name, nick, phone].any((s) => s.isEmpty)) {
      error = '모든 항목을 입력해 주세요.';
    } else if (!_emailChecked || _emailExists) {
      error = '이메일 중복 확인을 해주세요.';
    } else if (!_nickChecked || _nickExists) {
      error = '닉네임 중복 확인을 해주세요.';
    } else if (!_passwordsMatch) {
      error = '비밀번호가 일치하지 않습니다.';
    }

    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    try {
      final uc = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      await _firestore.collection('users').doc(uc.user!.uid).set({
        'email': email,
        'name': name,
        'nickname': nick,
        'phone': phone,
        'gender': _gender,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = e.message ?? '회원가입에 실패했습니다.');
    }
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _nickDebounce?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _nickCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // leading으로 화살표
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 이메일
                _field('이메일', _emailCtrl,
                    suffix: TextButton(
                        onPressed: _checkEmailDup,
                        child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 2) 비밀번호
                _field('비밀번호', _passwordCtrl, obscure: true),
                const SizedBox(height: 16),
                // 3) 비밀번호 확인
                _field('비밀번호 확인', _confirmCtrl,
                    obscure: true, errorText: _passwordError),
                const SizedBox(height: 16),
                // 4) 이름
                _field('이름', _nameCtrl),
                const SizedBox(height: 16),
                // 5) 닉네임
                _field('닉네임', _nickCtrl,
                    suffix: TextButton(
                        onPressed: _checkNickDup,
                        child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 6) 휴대전화
                _field('휴대전화', _phoneCtrl,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                // 7) 성별
                _genderSelector(),
                const SizedBox(height: 24),
                // 가입하기 버튼
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                      onPressed: _register,
                      child: const Text('가입하기')),
                ),
                // 2) 경고 문구 (가운데 정렬)
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 320,
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {Widget? suffix,
      bool obscure = false,
      TextInputType keyboard = TextInputType.text,
      String? errorText}) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffix: suffix,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return SizedBox(
      width: 320,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('성별:'),
          Radio<String>(
              value: 'M',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v)),
          const Text('남자'),
          const SizedBox(width: 20),
          Radio<String>(
              value: 'F',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v)),
          const Text('여자'),
        ],
      ),
    );
  }
}
