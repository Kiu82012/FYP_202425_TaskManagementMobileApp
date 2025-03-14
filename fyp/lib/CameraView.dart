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

  static late String Photopath;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraActive = false;
  bool _isLoading = false;
  bool _showCaptureFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize the camera when the view is opened
  }

  Future<void> _initializeCamera() async {
    setState(() => _isLoading = true);
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      setState(() {
        _isCameraActive = true;
        _isLoading = false;
      });
    } catch (e) {
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
    Navigator.pop(context); // Return to the previous screen
  }

  void OnConfirm() {
    widget.PassPhotoToAI();
    Navigator.pop(context, true);
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() => _showCaptureFeedback = true);
      final image = await _controller!.takePicture();
      CameraView.Photopath = image.path;
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
      if (confirmed ?? false) _showSuccess('Photo saved successfully!');
    } catch (e) {
      _showError('Failed to capture photo: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _showCaptureFeedback = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Function'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToInitialView,
        ),
      ),
      body: Stack(
        children: [
          _buildMainContent(),
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
      floatingActionButton: _isCameraActive ? _buildCameraButton() : null,
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isCameraActive) {
      return Container();
    }
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

  Widget _buildCameraButton() {
    return FloatingActionButton(
      onPressed: _takePhoto,
      child: const Icon(Icons.camera),
    );
  }
}

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