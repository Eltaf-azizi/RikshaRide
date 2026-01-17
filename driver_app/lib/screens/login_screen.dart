import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../../../../firestore_service.dart';
import '../../../../models/user.dart';
import '../../../../models/wallet.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  void _sendCode() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.verifyPhoneNumber(
      _phoneController.text.trim(),
      (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code sent')));
      },
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  void _verifyCode() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    try {
      final user = await authService.signInWithSmsCode(_verificationId!, _codeController.text.trim());
      if (user != null) {
        // Check if user exists in Firestore
        final existingUser = await firestoreService.getUser(user.uid);
        if (existingUser == null) {
          // Create new user
          final newUser = User(
            uid: user.uid,
            name: _nameController.text.trim(),
            phone: user.phoneNumber ?? _phoneController.text.trim(),
            role: 'driver',
            status: 'offline',
            currentLat: 0.0,
            currentLng: 0.0,
            rating: 5.0,
          );
          await firestoreService.createUser(newUser);
          // Create wallet
          await firestoreService.createWallet(Wallet(userId: user.uid, balance: 0.0, transactionHistory: []));
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Send Code'),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Verification Code'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Verify Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}