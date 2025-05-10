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
                // 1) 상단 제목
                const Text(
                  '로그인',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // 2) 이메일
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3) 비밀번호
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),

                // 4) 오류 텍스트 (가운데 정렬)
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 320,
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // 5) 체크박스 (가운데 정렬)
                SizedBox(
                  width: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(value: _saveId, onChanged: _onSaveIdChanged),
                      const Text('아이디 저장'),
                      const SizedBox(width: 16),
                      Checkbox(value: _autoLogin, onChanged: _onAutoLoginChanged),
                      const Text('자동 로그인'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6) 버튼들 순서대로 (가운데 정렬)
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                      onPressed: _signIn, child: const Text('로그인')),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 320,
                  child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('회원가입')),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 320,
                  child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/reset_password'),
                      child: const Text('비밀번호 찾기')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
