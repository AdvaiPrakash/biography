import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'models/poster_model.dart';
import 'services/firestore_service.dart';
import 'main.dart';

class PosterScreen extends StatefulWidget {
  final PosterModelFirestore? existingPosterFirestore;

  const PosterScreen({super.key, this.existingPosterFirestore});

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _posterKey = GlobalKey();
  final FirestoreService _firestoreService = FirestoreService();
  String? _posterDocId;

  // Editable text fields
  String _title = 'Product Name';
  String _price = '₹100';
  String _unit = 'per 1Kg';
  String _offerPrice = '';
  String _description = 'Enter product description here.';
  
  // Aspect Ratio (Default: Instagram Portrait 4:5)
  double _aspectRatio = 4 / 5;

  @override
  void initState() {
    super.initState();
    if (widget.existingPosterFirestore != null) {
      _loadExistingPoster();
    }
  }

  void _loadExistingPoster() {
    final poster = widget.existingPosterFirestore!;
    _posterDocId = poster.docId;
    _title = poster.title;
    _price = poster.price;
    _unit = poster.unit;
    _offerPrice = poster.offerPrice;
    _description = poster.description;
    if (poster.imageBase64 != null && poster.imageBase64!.isNotEmpty) {
      _imageBytes = base64Decode(poster.imageBase64!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<Uint8List?> _capturePoster() async {
    try {
      RenderRepaintBoundary boundary =
          _posterKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveImage() async {
    try {
      final pngBytes = await _capturePoster();
      if (pngBytes == null) {
        throw Exception('Failed to capture poster');
      }

      if (kIsWeb) {
        // For web, trigger download
        await Share.shareXFiles([
          XFile.fromData(pngBytes, name: 'poster.png', mimeType: 'image/png'),
        ]);
      } else {
        // For mobile, save to gallery
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
          name: 'poster_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (mounted) {
          if (result['isSuccess'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image saved to gallery!')),
            );
          } else {
            throw Exception('Failed to save image');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  Future<void> _saveToDatabase() async {
    try {
      // Save only the source image data (compressed)
      String? imageBase64;
      if (_imageBytes != null) {
        imageBase64 = base64Encode(_imageBytes!);
      }

      final poster = PosterModel(
        title: _title,
        price: _price,
        unit: _unit,
        offerPrice: _offerPrice,
        description: _description,
        imageBase64: imageBase64,
      );

      if (_posterDocId != null) {
        await _firestoreService.updatePoster(_posterDocId!, poster);
      } else {
        final docId = await _firestoreService.insertPoster(poster);
        setState(() => _posterDocId = docId);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Poster saved to cloud!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving to cloud: $e')));
      }
    }
  }

  Future<void> _shareToWhatsApp() async {
    try {
      final pngBytes = await _capturePoster();
      if (pngBytes == null) {
        throw Exception('Failed to capture poster');
      }

      if (kIsWeb) {
        await Share.shareXFiles([
          XFile.fromData(pngBytes, name: 'poster.png', mimeType: 'image/png'),
        ], text: '$_title - $_price $_unit');
      } else {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles([
          XFile(imagePath),
        ], text: '$_title - $_price $_unit');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for contrast
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Back and Aspect Ratio controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  // Aspect Ratio Toggle
                  PopupMenuButton<double>(
                    icon: const Icon(Icons.aspect_ratio, color: Colors.white),
                    tooltip: 'Change Aspect Ratio',
                    onSelected: (ratio) {
                      setState(() {
                        _aspectRatio = ratio;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 4 / 5,
                        child: Text('Instagram Portrait (4:5)'),
                      ),
                      const PopupMenuItem(
                        value: 1.0,
                        child: Text('Square (1:1)'),
                      ),
                      const PopupMenuItem(
                        value: 9 / 16,
                        child: Text('Story (9:16)'),
                      ),
                    ],
                  ),
                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Poster Area
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _aspectRatio,
                  child: RepaintBoundary(
                    key: _posterKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image or placeholder
                        if (_imageBytes != null)
                          Image.memory(_imageBytes!, fit: BoxFit.cover)
                        else
                          Container(
                            color: const Color(0xFF2D3E36),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 80,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to add image',
                                    style: GoogleFonts.anekMalayalam(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  const Color(0xFF1A3A2F).withValues(alpha: 0.7),
                                  const Color(0xFF1A3A2F).withValues(alpha: 0.95),
                                ],
                                stops: const [0.0, 0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Logo in top right corner
                        Positioned(
                          top: 16,
                          right: 16,
                          child:
                              Image.asset('assets/Untitled-1.png', height: 48),
                        ),

                        // Text content at bottom
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _title,
                                style: GoogleFonts.anekMalayalam(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Price section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  if (_offerPrice.isNotEmpty) ...[
                                    // Original price with strikethrough
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          _price,
                                          style: GoogleFonts.anekMalayalam(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 18,
                                          ),
                                        ),
                                        Positioned(
                                          child: Container(
                                            width: _price.length * 10.0,
                                            height: 2,
                                            color: Colors.red.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    // Offer price with ₹ sign
                                    Text(
                                      _offerPrice.startsWith('₹')
                                          ? _offerPrice
                                          : '₹$_offerPrice',
                                      style: GoogleFonts.anekMalayalam(
                                        color: Colors.greenAccent.shade200,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else ...[
                                    // Regular price (no offer) - big and green
                                    Text(
                                      _price,
                                      style: GoogleFonts.anekMalayalam(
                                        color: Colors.greenAccent.shade200,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  // Unit
                                  Text(
                                    _unit,
                                    style: GoogleFonts.anekMalayalam(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _description,
                                style: GoogleFonts.anekMalayalam(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tap to pick image (invisible overlay on image area)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            behavior: HitTestBehavior.translucent,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Controls below poster (Edit, Save, Share)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       TextButton.icon(
                        onPressed: _showEditDialog,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit Details', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Save to Cloud button
                      FloatingActionButton.extended(
                        heroTag: 'saveDb',
                        onPressed: _saveToDatabase,
                        backgroundColor: Colors.orange,
                        icon: const Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                        ),
                        label: Text(
                          _posterDocId != null ? 'Update' : 'Save',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Row(
                        children: [
                          // Save to Gallery button
                          FloatingActionButton(
                            heroTag: 'saveGallery',
                            onPressed: _saveImage,
                            backgroundColor: Colors.blue,
                            child: const Icon(
                              Icons.save_alt,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Share button
                          FloatingActionButton(
                            heroTag: 'share',
                            onPressed: _shareToWhatsApp,
                            backgroundColor: const Color(0xFF25D366),
                            child: const Icon(Icons.share, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    // Strip '₹' for editing
    final titleController = TextEditingController(text: _title);
    final priceController = TextEditingController(
      text: _price.replaceAll('₹', '').trim(),
    );
    final unitController = TextEditingController(text: _unit);
    final offerPriceController = TextEditingController(
      text: _offerPrice.replaceAll('₹', '').trim(),
    );
    final descController = TextEditingController(text: _description);

    const inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Poster Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(
                  labelText: 'Price',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Unit',
                  hintText: 'e.g. per kg',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: offerPriceController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(
                  labelText: 'Offer Price (Optional)',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                ),
                maxLines: 4,
                 minLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _title = titleController.text;
                // Add '₹' back if not empty
                _price = priceController.text.isNotEmpty 
                    ? '₹${priceController.text}' 
                    : '';
                _unit = unitController.text;
                _offerPrice = offerPriceController.text.isNotEmpty
                    ? '₹${offerPriceController.text}'
                    : '';
                _description = descController.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF6D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
