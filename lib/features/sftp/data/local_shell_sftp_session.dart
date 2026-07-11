import 'dart:io';
import 'dart:typed_data';

import 'package:conduit/features/sftp/domain/sftp_entry.dart';
import 'package:conduit/features/sftp/domain/sftp_session.dart';
import 'package:path/path.dart' as p;

/// An [SftpSession] that browses the local Arch Linux rootfs using dart:io.
///
/// Virtual paths (e.g. `/home/user`) are translated to host-filesystem paths
/// (e.g. `<rootfsDir>/home/user`) transparently so the rest of the SFTP UI
/// needs no changes.
class LocalShellSftpSession implements SftpSession {
  LocalShellSftpSession({required this.rootfsDir});

  final String rootfsDir;

  /// Translate a virtual rootfs path to the real host path.
  String _hostPath(String virtualPath) {
    if (virtualPath == '/') return rootfsDir;
    final relative = virtualPath.replaceFirst(RegExp(r'^/+'), '');
    return relative.isEmpty ? rootfsDir : p.join(rootfsDir, relative);
  }

  /// Translate a real host path back to a virtual rootfs path.
  String _virtualPath(String hostPath) {
    final rel = p.relative(hostPath, from: rootfsDir);
    if (rel == '.') return '/';
    // p.relative uses the OS separator; always use forward slash for virtual paths.
    return '/${rel.replaceAll(r'\', '/')}';
  }

  String _joinVirtual(String parent, String name) {
    if (parent == '/') return '/$name';
    return '$parent/$name';
  }

  SftpEntryKind _entryKind(FileSystemEntityType type) => switch (type) {
    FileSystemEntityType.directory => SftpEntryKind.directory,
    FileSystemEntityType.file => SftpEntryKind.file,
    FileSystemEntityType.link => SftpEntryKind.symlink,
    _ => SftpEntryKind.other,
  };

  @override
  Future<List<SftpEntry>> list(String path) async {
    final dir = Directory(_hostPath(path));
    final entries = <SftpEntry>[];

    await for (final entity in dir.list(followLinks: false)) {
      final name = p.basename(entity.path);
      // Skip hidden . and .. (list() never returns these, but be safe)
      if (name == '.' || name == '..') continue;

      final type = await FileSystemEntity.type(
        entity.path,
        followLinks: false,
      );
      final stat = await FileStat.stat(entity.path); // follows links for stat

      entries.add(
        SftpEntry(
          name: name,
          path: _joinVirtual(path, name),
          kind: _entryKind(type),
          size: stat.size >= 0 ? stat.size : null,
          modifiedAt: stat.modified,
          permissions: stat.mode & 0xFFF,
        ),
      );
    }

    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  @override
  Future<String> resolve(String path) async {
    // Resolve symlinks relative to the rootfs.
    final hostResolved = await File(_hostPath(path)).resolveSymbolicLinks().catchError((_) => _hostPath(path));
    // If the resolved path escapes the rootfsDir (e.g. absolute symlinks
    // pointing outside), clamp it back to rootfsDir.
    if (!hostResolved.startsWith(rootfsDir)) {
      return path; // return as-is
    }
    return _virtualPath(hostResolved);
  }

  @override
  Future<Uint8List> read(
    String path, {
    void Function(int bytesRead, int? total)? onProgress,
  }) async {
    final file = File(_hostPath(path));
    final stat = await file.stat();
    final total = stat.size > 0 ? stat.size : null;
    final builder = BytesBuilder(copy: false);
    var bytesRead = 0;
    await for (final chunk in file.openRead()) {
      builder.add(chunk);
      bytesRead += chunk.length;
      onProgress?.call(bytesRead, total);
    }
    return builder.takeBytes();
  }

  @override
  Future<void> write(
    String path,
    Stream<Uint8List> data,
    int length, {
    void Function(int bytesSent)? onProgress,
  }) async {
    final file = File(_hostPath(path));
    final sink = file.openWrite();
    var bytesSent = 0;
    try {
      await for (final chunk in data) {
        sink.add(chunk);
        bytesSent += chunk.length;
        onProgress?.call(bytesSent);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  @override
  Future<void> makeDirectory(String path) async {
    await Directory(_hostPath(path)).create();
  }

  @override
  Future<void> rename(String from, String to) async {
    final fromHost = _hostPath(from);
    final toHost = _hostPath(to);
    final type = await FileSystemEntity.type(fromHost, followLinks: false);
    if (type == FileSystemEntityType.directory) {
      await Directory(fromHost).rename(toHost);
    } else {
      await File(fromHost).rename(toHost);
    }
  }

  @override
  Future<void> delete(SftpEntry entry) async {
    if (entry.isDirectory) {
      await Directory(_hostPath(entry.path)).delete(recursive: true);
    } else {
      // Files and symlinks
      await File(_hostPath(entry.path)).delete();
    }
  }

  @override
  Future<void> close() async {
    // dart:io needs no explicit connection teardown.
  }
}
