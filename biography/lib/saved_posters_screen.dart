import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'poster_screen.dart';
import 'main.dart';

class SavedPostersScreen extends StatefulWidget {
  const SavedPostersScreen({super.key});

  @override
  State<SavedPostersScreen> createState() => _SavedPostersScreenState();
}

class _SavedPostersScreenState extends State<SavedPostersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  List<PosterModelFirestore> _posters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosters();
  }

  Future<void> _loadPosters() async {
    setState(() => _isLoading = true);
    try {
      final posters = await _firestoreService.getAllPosters();
      setState(() {
        _posters = posters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading posters: $e')));
      }
    }
  }

  Future<void> _searchPosters(String query) async {
    if (query.isEmpty) {
      _loadPosters();
      return;
    }
    try {
      final posters = await _firestoreService.searchPosters(query);
      setState(() => _posters = posters);
    } catch (e) {
      // Fallback to local filter
      final allPosters = await _firestoreService.getAllPosters();
      setState(() {
        _posters = allPosters
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _deletePoster(String docId) async {
    await _firestoreService.deletePoster(docId);
    _loadPosters();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Poster deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Posters', style: GoogleFonts.anekMalayalam()),
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posters...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPosters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5FCF9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchPosters,
            ),
          ),
          // Posters list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved posters',
                          style: GoogleFonts.anekMalayalam(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _posters.length,
                    itemBuilder: (context, index) {
                      final poster = _posters[index];
                      return _buildPosterCard(poster);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PosterScreen()),
          );
          _loadPosters();
        },
        backgroundColor: const Color(0xFF00BF6D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPosterCard(PosterModelFirestore poster) {
    Uint8List? imageBytes;
    if (poster.imageBase64 != null && poster.imageBase64!.isNotEmpty) {
      imageBytes = base64Decode(poster.imageBase64!);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PosterScreen(existingPosterFirestore: poster),
            ),
          );
          _loadPosters();
        },
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 100,
              color: const Color(0xFF2D3E36),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.white54, size: 40),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poster.title,
                      style: GoogleFonts.anekMalayalam(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      poster.offerPrice.isNotEmpty
                          ? '${poster.price} → ${poster.offerPrice}'
                          : poster.price,
                      style: GoogleFonts.anekMalayalam(
                        fontSize: 14,
                        color: const Color(0xFF00BF6D),
                      ),
                    ),
                    Text(
                      poster.unit,
                      style: GoogleFonts.anekMalayalam(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(poster),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(PosterModelFirestore poster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poster'),
        content: Text('Are you sure you want to delete "${poster.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePoster(poster.docId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
