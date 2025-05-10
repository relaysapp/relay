import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      _passwordError = _passwordsMatch ? null : '비밀번호가 일치하지 않습니다.';
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
          content: Text(
            _emailExists ? '이미 사용 중인 이메일입니다.' : '사용 가능한 이메일입니다.',
          ),
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
          content: Text(
            _nickExists ? '이미 사용 중인 닉네임입니다.' : '사용 가능한 닉네임입니다.',
          ),
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

    if ([email, pass, conf, name, nick, phone, _gender]
            .contains(null) ||
        [email, pass, conf, name, nick, phone]
            .any((s) => s.isEmpty)) {
      _showError('모든 항목을 입력해 주세요.');
      return;
    }
    if (!_emailChecked || _emailExists) {
      _showError('이메일 중복 확인을 해주세요.');
      return;
    }
    if (!_nickChecked || _nickExists) {
      _showError('닉네임 중복 확인을 해주세요.');
      return;
    }
    if (!_passwordsMatch) {
      _showError('비밀번호가 일치하지 않습니다.');
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
    } catch (e) {
      var msg = '회원가입에 실패했습니다.';
      if (e is FirebaseAuthException) msg = e.message ?? msg;
      else if (kIsWeb && e.toString().contains('JavaScriptObject'))
        msg = '웹 오류가 발생했습니다.';
      _showError(msg);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('회원가입'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 이메일
              _buildField('이메일', _emailCtrl,
                  suffix: TextButton(onPressed: _checkEmailDup, child: const Text('중복확인'))),
              const SizedBox(height: 16),
              // 2. 비밀번호
              _buildField('비밀번호', _passwordCtrl, obscure: true),
              const SizedBox(height: 16),
              // 3. 비밀번호 확인
              _buildField('비밀번호 확인', _confirmCtrl,
                  obscure: true, errorText: _passwordError),
              const SizedBox(height: 16),
              // 4. 이름
              _buildField('이름', _nameCtrl),
              const SizedBox(height: 16),
              // 5. 닉네임
              _buildField('닉네임', _nickCtrl,
                  suffix: TextButton(onPressed: _checkNickDup, child: const Text('중복확인'))),
              const SizedBox(height: 16),
              // 6. 휴대전화
              _buildField('휴대전화', _phoneCtrl, keyboard: TextInputType.phone),
              const SizedBox(height: 16),
              // 7. 성별
              _buildGenderSelector(),
              const SizedBox(height: 32),
              // 가입하기 버튼
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text('가입하기'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController ctrl, {
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
          isDense: true,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return SizedBox(
      width: 320,
      child: Row(
        children: [
          const Text('성별:'),
          const SizedBox(width: 16),
          Radio<String>(
            value: 'M',
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v),
          ),
          const Text('남자'),
          const SizedBox(width: 24),
          Radio<String>(
            value: 'F',
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v),
          ),
          const Text('여자'),
        ],
      ),
    );
  }
}
