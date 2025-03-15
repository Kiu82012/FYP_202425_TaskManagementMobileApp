import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingPage extends StatelessWidget {

  const LoadingPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Container(
        color: Colors.cyan.withOpacity(0.5), // Semi-transparent background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Processing...',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100, // Adjust size as needed
                height: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.pacman,
                  colors: const [Colors.yellow],
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent, // Transparent background
                  pathBackgroundColor: Colors.transparent, // Transparent path
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}