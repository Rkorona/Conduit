import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/local_shell/presentation/local_shell_controller.dart';
import 'package:conduit/features/sftp/data/local_shell_sftp_session.dart';
import 'package:conduit/features/sftp/domain/sftp_repository.dart';
import 'package:conduit/features/sftp/domain/sftp_session.dart';

/// An [SftpRepository] that opens a local shell instance's rootfs as a file
/// session, using dart:io instead of an SSH/SFTP connection.
class LocalShellSftpRepository implements SftpRepository {
  const LocalShellSftpRepository(this._controller, this._instanceId);

  final LocalShellController _controller;
  final String _instanceId;

  @override
  Future<SftpSession> connect(SavedHost host) async {
    final launch = await _controller.requireLaunch(_instanceId);
    return LocalShellSftpSession(rootfsDir: launch.paths.rootfsDir);
  }
}
