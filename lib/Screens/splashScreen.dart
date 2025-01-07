import 'package:agro/Screens/Product/productPage.dart';
import 'package:agro/Screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animation
    _controller = AnimationController(
      duration: Duration(seconds: 2), // Duration for one complete rotation
      vsync: this,
    );

    _rotation = Tween<double>(begin: 0.0, end: 2 * 3.1415927).animate(_controller);

    // Start the animation
    _controller.forward();

    // Check if user is logged in after the animation completes
    Future.delayed(Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;

      // Navigate based on login status
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductPage()), // Navigate to product page
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterScreen()), // Navigate to login page
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the screen is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _rotation,
            child: Image.asset('lib/Images/logo.jpg', height: 100, width: 100), // Replace with your logo image path
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotation.value,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
