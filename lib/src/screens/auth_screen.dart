import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  void _showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await AuthService.signUp(email, pass);
      } else {
        await AuthService.signIn(email, pass);
      }
      _showMessage('Signed in successfully');
    } catch (e) {
      _showMessage('Auth error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _anon() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInAnonymously();
      _showMessage('Signed in anonymously');
    } catch (e) {
      _showMessage('Anonymous auth error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pawst! — Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: _isSignUp, onChanged: (v) => setState(() => _isSignUp = v ?? false)),
                Text('Create account (sign up)'),
              ],
            ),
            SizedBox(height: 12),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text(_isSignUp ? 'Sign up' : 'Sign in')),
            SizedBox(height: 8),
            Text('Or continue anonymously for prototyping'),
            TextButton(onPressed: _anon, child: Text('Continue anonymously')),
          ],
        ),
      ),
    );
  }
}
