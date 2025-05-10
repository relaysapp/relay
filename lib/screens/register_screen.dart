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
    _confirmCtrl.addListener(_checkPasswordMatch);
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

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordCtrl.text == _confirmCtrl.text;
      _passwordError =
          _passwordsMatch ? null : '비밀번호가 일치하지 않습니다.';
    });
  }

  void _checkEmailDup() {
    _emailDebounce?.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_emailExists
              ? '이미 사용 중인 이메일입니다.'
              : '사용 가능한 이메일입니다.'),
        ),
      );
    });
  }

  void _checkNickDup() {
    _nickDebounce?.cancel();
    _nickDebounce = Timer(const Duration(milliseconds: 500), () async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_nickExists
              ? '이미 사용 중인 닉네임입니다.'
              : '사용 가능한 닉네임입니다.'),
        ),
      );
    });
  }

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;
    final conf = _confirmCtrl.text;
    final name = _nameCtrl.text.trim();
    final nick = _nickCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    String? err;
    if ([email, pass, conf, name, nick, phone, _gender].contains(null) ||
        [email, pass, conf, name, nick, phone].any((s) => s.isEmpty)) {
      err = '모든 항목을 입력해 주세요.';
    } else if (!_emailChecked || _emailExists) {
      err = '이메일 중복 확인을 해주세요.';
    } else if (!_nickChecked || _nickExists) {
      err = '닉네임 중복 확인을 해주세요.';
    } else if (!_passwordsMatch) {
      err = '비밀번호가 일치하지 않습니다.';
    }
    if (err != null) {
      setState(() => _errorText = err);
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
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 사용 → 기본 화살표 아이콘 보장
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          '회원가입',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(builder: (ctx, cons) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: cons.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이메일
                _buildField(
                  '이메일',
                  _emailCtrl,
                  suffix: TextButton(
                    onPressed: _checkEmailDup,
                    child: const Text('중복확인'),
                  ),
                ),
                const SizedBox(height: 16),
                // 비밀번호
                _buildField('비밀번호', _passwordCtrl, obscure: true),
                const SizedBox(height: 16),
                // 비밀번호 확인
                _buildField(
                    '비밀번호 확인', _confirmCtrl,
                    obscure: true, errorText: _passwordError),
                const SizedBox(height: 16),
                // 이름
                _buildField('이름', _nameCtrl),
                const SizedBox(height: 16),
                // 닉네임
                _buildField(
                  '닉네임',
                  _nickCtrl,
                  suffix: TextButton(
                    onPressed: _checkNickDup,
                    child: const Text('중복확인'),
                  ),
                ),
                const SizedBox(height: 16),
                // 휴대전화
                _buildField('휴대전화', _phoneCtrl,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                // 성별
                _buildGenderSelector(),
                const SizedBox(height: 24),
                // 가입하기
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('가입하기'),
                  ),
                ),
                // 에러 문구
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    Widget? suffix,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? errorText,
  }) {
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

  Widget _buildGenderSelector() {
    return SizedBox(
      width: 320,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('성별:'),
          const SizedBox(width: 16),
          Radio<String>(
              value: 'M',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v)),
          const Text('남자'),
          const SizedBox(width: 24),
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
