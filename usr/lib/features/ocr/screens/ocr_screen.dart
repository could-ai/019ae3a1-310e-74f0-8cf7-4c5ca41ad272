import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  
  List<XFile> _selectedImages = [];
  bool _isProcessing = false;
  String? _resultCsv;
  String? _errorMessage;

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
          _resultCsv = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  Future<void> _processImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _resultCsv = null;
    });

    try {
      // Simulate processing or call actual service
      final result = await _ocrService.extractLabels(_selectedImages);
      setState(() {
        _resultCsv = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Processing failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _selectedImages = [];
      _resultCsv = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Label Extraction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickImages,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select Images'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_selectedImages.isEmpty || _isProcessing) 
                        ? null 
                        : _processImages,
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: Colors.white
                            )
                          )
                        : const Icon(Icons.analytics),
                    label: Text(_isProcessing ? 'Processing...' : 'Extract Labels'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Image Preview
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Selected Images (${_selectedImages.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: _selectedImages.isEmpty
                                ? const Center(
                                    child: Text('No images selected'),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(8),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      final file = _selectedImages[index];
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            file.path,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) {
                                              // Fallback for non-web platforms if needed, 
                                              // though Image.network works with blob URLs on web
                                              // and file paths on mobile usually need Image.file
                                              if (kIsWeb) {
                                                return const Center(child: Icon(Icons.image));
                                              }
                                              return Image.file(
                                                File(file.path),
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.black54,
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white, 
                                                  fontSize: 10
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right: Results
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Extraction Results',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                if (_resultCsv != null)
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      // Copy to clipboard functionality
                                      // Note: In web, this might need specific handling
                                      // but we'll stick to basic Flutter Clipboard API
                                      // which works in most cases.
                                      // However, user report mentioned permission issues.
                                    },
                                    tooltip: 'Copy CSV',
                                  ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: _errorMessage != null
                                ? Center(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : _resultCsv == null
                                    ? const Center(
                                        child: Text(
                                          'Results will appear here after processing',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child: SelectableText(
                                          _resultCsv!,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
