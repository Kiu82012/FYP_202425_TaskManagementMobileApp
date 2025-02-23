import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // Camera controller to manage camera functionality
  CameraController? _controller;

  // Future to track camera initialization progress
  Future<void>? _initializeControllerFuture;

  // State flags
  bool _isCameraActive = false;  // Whether camera preview is showing
  bool _isLoading = false;       // Loading state during camera setup
  bool _showCaptureFeedback = false; // Visual feedback after capture

  /// Initializes camera hardware and prepares preview
  Future<void> _initializeCamera() async {
    setState(() => _isLoading = true);

    try {
      // 1. Get available cameras
      final cameras = await availableCameras();

      // 2. Create controller with first camera (usually rear)
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,  // Balanced quality/performance
      );

      // 3. Initialize controller
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      // 4. Update state to show camera preview
      setState(() {
        _isCameraActive = true;
        _isLoading = false;
      });
    } catch (e) {
      // Handle initialization errors
      setState(() => _isLoading = false);
      _showError('Camera initialization failed');
    }
  }

  void _returnToInitialView() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
    setState(() {
      _isCameraActive = false;
      _initializeControllerFuture = null;
    });
  }

  /// Captures photo and provides user feedback
  Future<void> _takePhoto() async {
    // Guard clause if camera isn't ready
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Show visual feedback immediately
      setState(() => _showCaptureFeedback = true);

      // 1. Capture image
      final image = await _controller!.takePicture();

      // 2. Show success feedback
      _showSuccess('Photo captured!');

      // 3. Keep feedback visible for 1 second
      await Future.delayed(const Duration(seconds: 1));

      // 4. Hide feedback (if still mounted)
      if (mounted) {
        setState(() => _showCaptureFeedback = false);
      }

      // Print path for development purposes
      print("Captured image path: ${image.path}");

    } catch (e) {
      _showError('Failed to capture photo');
    }
  }

  /// Displays success message using SnackBar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Displays error message using SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up camera resources
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _selectFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        print('Selected image path: ${pickedFile.path}');
        _showSuccess('Image selected from gallery');
        // You can add your image handling logic here
      }
    } catch (e) {
      _showError('Failed to select image: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Function'),
        leading: _isCameraActive
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToInitialView,
        )
            : null,
      ),
      body: Stack(
        children: [
          // Main content (camera preview or button)
          _buildMainContent(),

          // Capture feedback overlay
          if (_showCaptureFeedback)
            const Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 80,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
        ],
      ),
      // Floating action button only visible when camera is active
      floatingActionButton: _isCameraActive ? _buildCameraButton() : null,
    );
  }

  /// Builds the appropriate main content based on current state
  Widget _buildMainContent() {
    // Show loading indicator during initialization
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Initial state - show camera activation button
    if (!_isCameraActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera'),
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Select from Gallery'),
              onPressed: _selectFromGallery,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      );
    }

    // Camera preview with initialization handling
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Builds the camera capture button
  Widget _buildCameraButton() {
    return FloatingActionButton(
      onPressed: _takePhoto,
      child: const Icon(Icons.camera),
    );
  }
}