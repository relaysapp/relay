import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _gender;
  String _emailMsg = '';
  String _nickMsg = '';
  String _pwMatchMsg = '';
  String _generalError = '';
  bool _isLoading = false;

  bool _emailOk = false;
  bool _nickOk = false;
  bool _pwMatch = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _nickCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    setState(() {
      if (methods.isEmpty) {
        _emailMsg = '사용 가능한 이메일입니다.';
        _emailOk = true;
      } else {
        _emailMsg = '중복된 이메일입니다.';
        _emailOk = false;
      }
    });
  }

  Future<void> _checkNick() async {
    final nick = _nickCtrl.text.trim();
    if (nick.isEmpty) return;
    final qr = await _firestore.collection('users')
        .where('nickname', isEqualTo: nick).get();
    setState(() {
      if (qr.docs.isEmpty) {
        _nickMsg = '사용 가능한 닉네임입니다.';
        _nickOk = true;
      } else {
        _nickMsg = '중복된 닉네임입니다.';
        _nickOk = false;
      }
    });
  }

  void _checkPwMatch() {
    setState(() {
      _pwMatch = _pwCtrl.text == _pwConfirmCtrl.text;
      _pwMatchMsg = _pwMatch ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.';
    });
  }

  Future<void> _register() async {
    setState(() {
      _generalError = '';
      _isLoading = true;
    });
    if (_emailCtrl.text.isEmpty ||
        _pwCtrl.text.isEmpty ||
        _pwConfirmCtrl.text.isEmpty ||
        _nickCtrl.text.isEmpty ||
        _nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _gender == null) {
      setState(() {
        _generalError = '모든 항목을 입력해주세요.';
        _isLoading = false;
      });
      return;
    }
    if (_pwCtrl.text.length < 10) {
      setState(() {
        _generalError = '비밀번호는 최소 10자 이상이어야 합니다.';
        _isLoading = false;
      });
      return;
    }
    if (!_pwMatch) {
      setState(() {
        _generalError = '비밀번호가 일치하지 않습니다.';
        _isLoading = false;
      });
      return;
    }
    if (!_emailOk || !_nickOk) {
      setState(() {
        _generalError = '이메일과 닉네임 중복확인을 해주세요.';
        _isLoading = false;
      });
      return;
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
      );
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': _emailCtrl.text.trim(),
        'nickname': _nickCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gender': _gender,
        'created_at': FieldValue.serverTimestamp(),
      });
      await cred.user!.sendEmailVerification();
      Navigator.pushReplacementNamed(context, '/emailVerify');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _generalError = e.message ?? '회원가입 오류';
        _isLoading = false;
      });
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    bool obscure = false,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    final w = MediaQuery.of(context).size.width * 0.6;
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center),
        SizedBox(
          width: w,
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              suffixIcon: suffix,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField(
                label: '이메일(아이디)',
                ctrl: _emailCtrl,
                onChanged: (_) {
                  setState(() {
                    _emailOk = false;
                    _emailMsg = '';
                  });
                },
                suffix: TextButton(onPressed: _checkEmail, child: const Text('중복확인')),
              ),
              Text(_emailMsg, style: TextStyle(color: _emailOk ? Colors.blue : Colors.red)),
              const SizedBox(height: 12),

              _buildField(
                label: '비밀번호 (10자 이상)',
                ctrl: _pwCtrl,
                obscure: true,
                onChanged: (_) => _checkPwMatch(),
              ),
              const SizedBox(height: 12),

              _buildField(
                label: '비밀번호 확인',
                ctrl: _pwConfirmCtrl,
                obscure: true,
                onChanged: (_) => _checkPwMatch(),
              ),
              Text(_pwMatchMsg, style: TextStyle(color: _pwMatch ? Colors.blue : Colors.red)),
              const SizedBox(height: 12),

              _buildField(
                label: '닉네임',
                ctrl: _nickCtrl,
                onChanged: (_) {
                  setState(() {
                    _nickOk = false;
                    _nickMsg = '';
                  });
                },
                suffix: TextButton(onPressed: _checkNick, child: const Text('중복확인')),
              ),
              Text(_nickMsg, style: TextStyle(color: _nickOk ? Colors.blue : Colors.red)),
              const SizedBox(height: 12),

              _buildField(label: '이름', ctrl: _nameCtrl),
              const SizedBox(height: 12),

              _buildField(label: '휴대전화번호', ctrl: _phoneCtrl),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Radio<String>(value: '남성', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)),
                const Text('남성'),
                const SizedBox(width: 20),
                Radio<String>(value: '여성', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)),
                const Text('여성'),
              ]),
              const SizedBox(height: 20),

              if (_generalError.isNotEmpty)
                Text(_generalError, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}