
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = '남자';

  String? _errorText;
  String? _successText;
  bool _emailChecked = false;
  bool _nickChecked = false;

  Future<void> _checkDuplicate(String field, TextEditingController controller) async {
    final value = controller.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorText = field == 'email' ? "이메일을 입력해주세요." : "닉네임을 입력해주세요.";
        _successText = null;
      });
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where(field, isEqualTo: value)
        .get();

    final exists = query.docs.isNotEmpty;

    setState(() {
      if (field == 'email') {
        _emailChecked = !exists;
      } else {
        _nickChecked = !exists;
      }
      _errorText = exists ? '이미 사용 중인 ${field == 'email' ? '이메일' : '닉네임'}입니다.' : null;
      _successText = exists ? null : '${field == 'email' ? '이메일' : '닉네임'} 사용 가능';
    });
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final phone = _phoneController.text.trim();

    if ([email, password, confirm, name, nickname, phone].any((e) => e.isEmpty)) {
      setState(() => _errorText = '모든 항목을 입력해주세요.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorText = '비밀번호가 일치하지 않습니다.');
      return;
    }

    if (!_emailChecked || !_nickChecked) {
      setState(() => _errorText = '이메일과 닉네임 중복확인을 해주세요.');
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'name': name,
        'nickname': nickname,
        'phone': phone,
        'gender': _gender,
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _errorText = '회원가입 실패: ${e.toString()}');
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    bool withCheck = false,
    String? fieldKey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: 360,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontSize: 14),
                  contentPadding: const EdgeInsets.only(bottom: 6),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 1.2),
                  ),
                ),
              ),
            ),
            if (withCheck && fieldKey != null)
              TextButton(
                onPressed: () => _checkDuplicate(fieldKey, controller),
                child: const Text("중복확인"),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final mismatch = password.isNotEmpty && confirm.isNotEmpty && password != confirm;
    final match = password.isNotEmpty && confirm.isNotEmpty && password == confirm;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField(label: "이메일", controller: _emailController, withCheck: true, fieldKey: 'email'),
                _buildField(label: "비밀번호", controller: _passwordController, obscure: true),
                _buildField(label: "비밀번호 확인", controller: _confirmController, obscure: true),
                if (mismatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text("비밀번호가 일치하지 않습니다.", style: TextStyle(color: Colors.red)),
                  ),
                if (match)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text("비밀번호가 일치합니다.", style: TextStyle(color: Colors.blue)),
                  ),
                _buildField(label: "이름", controller: _nameController),
                _buildField(label: "닉네임", controller: _nicknameController, withCheck: true, fieldKey: 'nickname'),
                _buildField(label: "휴대전화", controller: _phoneController),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("성별: "),
                    Radio(value: '남자', groupValue: _gender, onChanged: (val) => setState(() => _gender = val!)),
                    const Text("남자"),
                    Radio(value: '여자', groupValue: _gender, onChanged: (val) => setState(() => _gender = val!)),
                    const Text("여자"),
                  ],
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_errorText!, style: const TextStyle(color: Colors.red)),
                  ),
                if (_successText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_successText!, style: const TextStyle(color: Colors.blue)),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text("가입하기"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
