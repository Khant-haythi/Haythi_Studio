import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MaterialPhoto extends StatelessWidget {
  const MaterialPhoto({required this.path, this.size = 120, super.key});
  final String? path;
  final double size;
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
            child: Icon(Icons.diamond_outlined,
                color: Theme.of(context).colorScheme.primary)));
    return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox.square(
            dimension: size,
            child: path == null
                ? placeholder
                : Image.file(File(path!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => placeholder)));
  }
}

class MaterialPhotoPicker extends StatefulWidget {
  const MaterialPhotoPicker(
      {required this.path,
      required this.onChanged,
      required this.enabled,
      super.key});
  final String? path;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  @override
  State<MaterialPhotoPicker> createState() => _MaterialPhotoPickerState();
}

class _MaterialPhotoPickerState extends State<MaterialPhotoPicker> {
  bool _picking = false;
  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final selected = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85);
      if (selected == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final photos = await Directory('${directory.path}/material_photos')
          .create(recursive: true);
      final name =
          '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
      final saved = File('${photos.path}/$name');
      await selected.saveTo(saved.path);
      if (mounted) widget.onChanged(saved.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Could not open or save the photo. Please check photo access and try again.')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        MaterialPhoto(path: widget.path),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, children: [
          TextButton.icon(
              onPressed: widget.enabled && !_picking ? _pick : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_picking
                  ? 'Opening gallery...'
                  : widget.path == null
                      ? 'Add photo'
                      : 'Change photo')),
          if (widget.path != null)
            TextButton(
                onPressed: widget.enabled && !_picking
                    ? () => widget.onChanged(null)
                    : null,
                child: const Text('Remove')),
        ]),
      ]);
}
