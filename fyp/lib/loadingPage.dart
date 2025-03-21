import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class LoadingPage extends StatelessWidget {
  final String lottieAsset;  // Add a parameter for the Lottie asset path

  const LoadingPage({Key? key, required this.lottieAsset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Container(
        color: Colors.blueGrey.withOpacity(0.5), // Semi-transparent background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generating event...',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200, // Adjust size as needed
                height: 200,
                child: Lottie.asset(
                  lottieAsset, // Use the Lottie asset path
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain, // Adjust fit as needed
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}