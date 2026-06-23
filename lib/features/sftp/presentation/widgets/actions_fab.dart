import 'package:flutter/material.dart';

class ActionsFab extends StatelessWidget {
  const ActionsFab({
    required this.onNewFolder,
    required this.onUpload,
    super.key,
  });

  final VoidCallback onNewFolder;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'sftp-new-folder',
          tooltip: 'New folder',
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          onPressed: onNewFolder,
          child: const Icon(Icons.create_new_folder_outlined),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: 'sftp-upload',
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            onPressed: onUpload,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Upload'),
          ),
        ),
      ],
    );
  }
}
