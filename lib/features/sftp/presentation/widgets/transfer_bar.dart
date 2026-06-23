import 'package:conduit/features/sftp/presentation/sftp_browser_controller.dart';
import 'package:flutter/material.dart';

class TransferBar extends StatelessWidget {
  const TransferBar({required this.transfer, super.key});

  final SftpTransfer transfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                transfer.isUpload
                    ? Icons.upload_rounded
                    : Icons.download_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${transfer.isUpload ? 'Uploading' : 'Downloading'} '
                  '${transfer.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: transfer.fraction,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
