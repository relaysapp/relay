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
  String? _passwordError, _gender;

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

  // 이메일/닉네임 중복 검사 (_checkEmailDup/_checkNickDup) 는 이전과 동일하게 유지

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

  Future<void> _register() async {
    // 유효성 검사 + Firestore 저장 로직 (이전과 동일)
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 뒤로가기 화살표 아이콘 자동 생성
      appBar: AppBar(centerTitle: true, title: const Text('회원가입')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 이메일
                _field('이메일', _emailCtrl, suffix: TextButton(onPressed: _checkEmailDup, child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 2) 비밀번호
                _field('비밀번호', _passwordCtrl, obscure: true),
                const SizedBox(height: 16),
                // 3) 비밀번호 확인
                _field('비밀번호 확인', _confirmCtrl, obscure: true, errorText: _passwordError),
                const SizedBox(height: 16),
                // 4) 이름
                _field('이름', _nameCtrl),
                const SizedBox(height: 16),
                // 5) 닉네임
                _field('닉네임', _nickCtrl, suffix: TextButton(onPressed: _checkNickDup, child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 6) 휴대전화
                _field('휴대전화', _phoneCtrl, keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                // 7) 성별
                _buildGenderSelector(),
                const SizedBox(height: 32),
                // 가입하기 버튼
                SizedBox(
                  width: 320,
                  child: ElevatedButton(onPressed: _register, child: const Text('가입하기')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {Widget? suffix, bool obscure = false, TextInputType keyboard = TextInputType.text, String? errorText}) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, errorText: errorText, suffix: suffix, border: const UnderlineInputBorder()),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return SizedBox(
      width: 320,
      child: Row(children: [
        const Text('성별:'),
        Radio<String>(value: 'M', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)),
        const Text('남자'),
        const SizedBox(width: 20),
        Radio<String>(value: 'F', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)),
        const Text('여자'),
      ]),
    );
  }
}
