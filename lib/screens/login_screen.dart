import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _saveId = false;
  bool _autoLogin = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    if (_autoLogin && _auth.currentUser != null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _saveId = p.getBool('saveId') ?? false;
      _autoLogin = p.getBool('autoLogin') ?? false;
      if (_saveId) _emailCtrl.text = p.getString('savedEmail') ?? '';
    });
  }

  Future<void> _onSaveIdChanged(bool? v) async {
    if (v == null) return;
    final p = await SharedPreferences.getInstance();
    setState(() => _saveId = v);
    await p.setBool('saveId', v);
    if (v) await p.setString('savedEmail', _emailCtrl.text.trim());
    else await p.remove('savedEmail');
  }

  Future<void> _onAutoLoginChanged(bool? v) async {
    if (v == null) return;
    final p = await SharedPreferences.getInstance();
    setState(() => _autoLogin = v);
    await p.setBool('autoLogin', v);
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    setState(() => _errorText = null);
    if (email.isEmpty || pwd.isEmpty) {
      setState(() => _errorText = '이메일 또는 비밀번호가 잘못 입력되었습니다.');
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pwd);
      if (_saveId) {
        final p = await SharedPreferences.getInstance();
        await p.setString('savedEmail', email);
      }
      if (_autoLogin) {
        // 이미 저장됨
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException {
      setState(() => _errorText = '이메일 또는 비밀번호가 잘못 입력되었습니다.');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 제목: 맨 위, 가운데 정렬
                const Text('로그인',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                // 2) 이메일 입력
                _buildField('이메일', _emailCtrl, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // 3) 비밀번호 입력
                _buildField('비밀번호', _passwordCtrl, obscure: true),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorText!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),

                // 4) 체크박스
                SizedBox(
                  width: 320,
                  child: Row(children: [
                    Checkbox(value: _saveId, onChanged: _onSaveIdChanged),
                    const Text('아이디 저장'),
                    const SizedBox(width: 16),
                    Checkbox(value: _autoLogin, onChanged: _onAutoLoginChanged),
                    const Text('자동 로그인'),
                  ]),
                ),
                const SizedBox(height: 24),

                // 5) 버튼들: 로그인 → 회원가입 → 비밀번호 찾기
                ...[
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('회원가입'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reset_password'),
                    child: const Text('비밀번호 찾기'),
                  ),
                ].map((w) => SizedBox(width: 320, child: w)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
