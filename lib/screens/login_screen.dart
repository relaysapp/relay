import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;
  bool _rememberId = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final autoLogin = prefs.getBool('auto_login') ?? false;
    setState(() {
      _emailController.text = savedEmail ?? '';
      _rememberId = savedEmail != null;
      _autoLogin = autoLogin;
    });
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email != 'test@test.com' || password != '12345678') {
      setState(() {
        _errorText = '이메일 또는 비밀번호가 잘못 입력되었습니다.';
      });
      return;
    }
    SharedPreferences.getInstance().then((prefs) {
      if (_rememberId) prefs.setString('saved_email', email);
      else prefs.remove('saved_email');
      prefs.setBool('auto_login', _autoLogin);
    });
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("로그인", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '이메일'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorText!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _rememberId,
                    onChanged: (val) => setState(() => _rememberId = val ?? false),
                  ),
                  const Text('아이디 저장'),
                  const SizedBox(width: 16),
                  Checkbox(
                    value: _autoLogin,
                    onChanged: (val) => setState(() => _autoLogin = val ?? false),
                  ),
                  const Text('자동 로그인'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: _login, child: const Text('로그인')),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('회원가입'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/reset_password'),
                    child: const Text('비밀번호 찾기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}