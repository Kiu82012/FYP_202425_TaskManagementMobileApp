import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fyp/ConfirmView.dart';
import 'package:fyp/Event.dart';
import 'package:fyp/EventJsonUtils.dart';
import 'package:fyp/EventNavigator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraView extends StatefulWidget {
  final Future<void> Function() PassPhotoToAI;
  const CameraView({super.key, required this.PassPhotoToAI});

  // global var for photo path
  static late String Photopath;
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // Camera controller to manage camera functionality
  CameraController? _controller;

  // Future to track camera initialization progress
  Future<void>? _initializeControllerFuture;

  late Function() _PassPhotoToAI; //not same as the one in line 16

  // State flags
  bool _isCameraActive = false;  // Whether camera preview is showing
  bool _isLoading = false;       // Loading state during camera setup
  bool _showCaptureFeedback = false; // Visual feedback after capture
  @override
    void initState(){
    _PassPhotoToAI = widget.PassPhotoToAI;
  }

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

  void OnConfirm(){
    print("Passing photo to AI");
    _PassPhotoToAI();
    Navigator.pop(context, true);
  }

  /// Captures photo and provides user feedback
  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _showCaptureFeedback = true);

      // 1. Capture image
      final image = await _controller!.takePicture();
      CameraView.Photopath = image.path;
      //testing
      print("Testtt"+CameraView.Photopath);
      // 2. Show preview screen
      if (!mounted) return;

      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(
            imagePath: image.path,
            onConfirm: OnConfirm,
            onRetake: () => Navigator.pop(context, false),
          ),
        ),
      );

      // 3. Handle confirmation or retake
      if (confirmed ?? false) {
        _showSuccess('Photo saved successfully!');
        // Add your photo saving logic here
      } else {
        _showSuccess('Photo discarded');
      }

    } catch (e) {
      _showError('Failed to capture photo: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _showCaptureFeedback = false);
      }
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

// Add new widget class for the confirmation
class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

  const PhotoPreviewScreen({
    super.key,
    required this.imagePath,
    required this.onConfirm,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Photo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onRetake,
        ),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: onConfirm,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
          ),
          FloatingActionButton(
            onPressed: onRetake,
            backgroundColor: Colors.red,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }


}
