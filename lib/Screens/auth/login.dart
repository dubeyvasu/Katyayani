import 'package:agro/Screens/Product/productPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true;
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>ProductPage()),(Route route)=>false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>ProductPage()),(Route route)=>false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink], // Customize the gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            // Form container with white background
            padding: EdgeInsets.all(16.0),
            width: 300, // You can adjust the width of the form
            decoration: BoxDecoration(
              color: Colors.white, // White background for the form
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true, // Prevent scrolling issues when content fits
                children: [
                  Text(
                    isLogin ? 'Login to your account' : 'Create a new account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  if (errorMessage != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isLogin) {
                          _login();
                        } else {
                          _register();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isLogin ? 'Login' : 'Register',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        errorMessage = null; // Clear error message when toggling
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
