import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/capsule_entry.dart';
import '../providers/capsule_provider.dart';
import '../utils/image_source.dart';

class EditorScreen extends StatefulWidget {
  final CapsuleEntry? existingEntry;

  const EditorScreen({Key? key, this.existingEntry}) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _contentController;
  late TextEditingController _songController;
  late TextEditingController _reflectionController;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.existingEntry?.content ?? '');
    _songController = TextEditingController(text: widget.existingEntry?.songInfo ?? '');
    _reflectionController = TextEditingController();
    _imagePath = widget.existingEntry?.imagePath;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _songController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1440,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final mimeType = _guessMimeType(image.name);
        setState(() {
          _imagePath = 'data:$mimeType;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  void _saveEntry() {
    final provider = context.read<CapsuleProvider>();
    final content = _contentController.text.trim();
    final songInfo = _songController.text.trim();

    if (content.isEmpty && (_imagePath == null || _imagePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.t('need_text_or_image'))),
      );
      return;
    }

    if (widget.existingEntry == null) {
      final newEntry = CapsuleEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        imagePath: _imagePath,
        songInfo: songInfo,
        timestamp: DateTime.now(),
      );
      provider.addEntry(newEntry);
    } else {
      provider.updateEntry(widget.existingEntry!.id, content, _imagePath, songInfo);
    }

    Navigator.pop(context);
  }

  Future<void> _addReflection() async {
    final text = _reflectionController.text.trim();
    if (text.isEmpty || widget.existingEntry == null) return;

    final provider = context.read<CapsuleProvider>();
    await provider.addCommentToEntry(widget.existingEntry!.id, text);
    _reflectionController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final latestComments = (widget.existingEntry != null)
        ? provider.entries
            .firstWhere((e) => e.id == widget.existingEntry!.id, orElse: () => widget.existingEntry!)
            .comments
        : <Comment>[];

    final imageProvider = imageProviderFromStoredSource(_imagePath);
    final accent = Theme.of(context).colorScheme.primary;
    final borderColor = accent.withOpacity(0.35);
    final chipBackground = _imagePath == null ? const Color(0xFF1E1E1E) : accent.withOpacity(0.14);
    final destructiveColor = provider.isMonochrome ? Colors.white70 : Colors.redAccent;

    final title = widget.existingEntry == null ? provider.t('capture_moment') : provider.t('edit_moment');
    final dateFormat = provider.language == AppLanguage.zh ? 'yyyy-MM-dd HH:mm' : 'MMM dd, yyyy - hh:mm a';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.existingEntry != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: destructiveColor),
              tooltip: provider.t('erase_memory'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: Text(provider.t('erase_memory'), style: const TextStyle(color: Colors.white)),
                      content: Text(provider.t('erase_confirm'), style: const TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(provider.t('cancel'), style: const TextStyle(color: Colors.white70)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: destructiveColor),
                          onPressed: () {
                            context.read<CapsuleProvider>().deleteEntry(widget.existingEntry!.id);
                            Navigator.pop(dialogContext);
                            Navigator.pop(context);
                          },
                          child: Text(provider.t('erase'), style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.check, color: accent),
            onPressed: _saveEntry,
            tooltip: provider.t('save_entry'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: chipBackground,
                    borderRadius: BorderRadius.circular(30),
                    border: _imagePath != null ? Border.all(color: borderColor) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _imagePath == null ? Icons.image_outlined : Icons.image,
                        color: _imagePath == null ? Colors.white70 : accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _imagePath == null ? provider.t('attach_photo') : provider.t('photo_attached'),
                        style: TextStyle(
                          color: _imagePath == null ? Colors.white70 : accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (imageProvider != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: imageProvider,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePath = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.queue_music, color: accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _songController,
                      decoration: InputDecoration(
                        hintText: provider.t('track_hint'),
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: widget.existingEntry != null ? 180 : 300,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accent.withOpacity(0.75), width: 3)),
                color: const Color(0xFF181818),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.white),
                decoration: InputDecoration(
                  hintText: provider.t('content_hint'),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.existingEntry != null) ...[
              const Divider(color: Colors.white24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    provider.t('reflections'),
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              if (latestComments.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: latestComments.length,
                  itemBuilder: (context, i) {
                    final c = latestComments[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(dateFormat).format(c.timestamp),
                            style: const TextStyle(color: Colors.white30, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.text,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reflectionController,
                        decoration: InputDecoration(
                          hintText: provider.t('talk_past'),
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onSubmitted: (_) => _addReflection(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: accent, size: 20),
                      onPressed: _addReflection,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

