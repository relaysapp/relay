import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  Timer? _emailDebounce;
  Timer? _nickDebounce;

  bool _isEmailChecked = false;
  bool _emailExists = false;
  bool _isNickChecked = false;
  bool _nickExists = false;
  bool _passwordsMatch = true;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _nickDebounce?.cancel();
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmController.text;
      _passwordError = _passwordsMatch ? null : 'Passwords do not match';
    });
  }

  void _checkEmailDuplicate() {
    if (_emailDebounce?.isActive ?? false) _emailDebounce!.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      final email = _emailController.text.trim();
      if (email.isEmpty) return;
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      setState(() {
        _isEmailChecked = true;
        _emailExists = query.docs.isNotEmpty;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _emailExists ? 'Email already in use' : 'Email available',
          ),
        ),
      );
    });
  }

  void _checkNickDuplicate() {
    if (_nickDebounce?.isActive ?? false) _nickDebounce!.cancel();
    _nickDebounce = Timer(const Duration(milliseconds: 500), () async {
      final nick = _nicknameController.text.trim();
      if (nick.isEmpty) return;
      final query = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nick)
          .limit(1)
          .get();
      setState(() {
        _isNickChecked = true;
        _nickExists = query.docs.isNotEmpty;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _nickExists ? 'Nickname already in use' : 'Nickname available',
          ),
        ),
      );
    });
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty ||
        nickname.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (!_isEmailChecked || _emailExists) {
      _showError('Please check your email');
      return;
    }
    if (!_isNickChecked || _nickExists) {
      _showError('Please check your nickname');
      return;
    }
    if (!_passwordsMatch) {
      _showError('Passwords do not match');
      return;
    }
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      String message = 'Registration failed';
      if (e is FirebaseAuthException) {
        message = e.message ?? message;
      } else if (kIsWeb && e.toString().contains('JavaScriptObject')) {
        message = 'Web: unexpected error occurred';
      }
      _showError(message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                suffix: TextButton(
                  onPressed: _checkEmailDuplicate,
                  child: Text('Check'),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                suffix: TextButton(
                  onPressed: _checkNickDuplicate,
                  child: Text('Check'),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _passwordError,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _register,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
