import 'package:conduit/features/local_shell/domain/local_shell_instance.dart';
import 'package:conduit/features/local_shell/domain/local_shell_state.dart';
import 'package:conduit/features/local_shell/presentation/local_shell_controller.dart';
import 'package:conduit/features/local_shell/presentation/local_shell_setup_page.dart';
import 'package:flutter/material.dart';

class LocalShellSection extends StatelessWidget {
  const LocalShellSection({
    required this.controller,
    required this.activeInstanceIds,
    required this.onAdd,
    required this.onOpenInstance,
    required this.onManageInstance,
    required this.onOpenFiles,
    super.key,
  });

  final LocalShellController controller;
  final Set<String> activeInstanceIds;
  final VoidCallback onAdd;
  final Future<void> Function(LocalShellInstance instance) onOpenInstance;
  final void Function(LocalShellInstance instance) onManageInstance;
  final void Function(LocalShellInstance instance) onOpenFiles;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isUnsupported) return const SizedBox.shrink();
        final instances = controller.instances;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                showAdd: !controller.isChecking && instances.isNotEmpty,
                onAdd: onAdd,
              ),
              const SizedBox(height: 10),
              if (controller.isChecking)
                const _CheckingCard()
              else if (instances.isEmpty)
                _SetupPromptCard(onTap: onAdd)
              else
                for (final instance in instances) ...[
                  _InstanceCard(
                    instance: instance,
                    distroName:
                        controller.distroById(instance.distroId)?.name ??
                        instance.distroId,
                    state: controller.stateFor(instance.id),
                    active: activeInstanceIds.contains(instance.id),
                    onOpen: () => onOpenInstance(instance),
                    onManage: () => onManageInstance(instance),
                    onOpenFiles: () => onOpenFiles(instance),
                  ),
                  if (instance != instances.last) const SizedBox(height: 8),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.showAdd, required this.onAdd});

  final bool showAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Run commands locally, no server required.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (showAdd)
          IconButton(
            tooltip: 'New local shell',
            visualDensity: VisualDensity.compact,
            onPressed: onAdd,
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _CheckingCard extends StatelessWidget {
  const _CheckingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _CardShell(
      highlighted: false,
      child: Row(
        children: [
          const _Avatar(ready: false),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Checking local shells…',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 9),
        ],
      ),
    );
  }
}

class _SetupPromptCard extends StatelessWidget {
  const _SetupPromptCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: _CardShell(
          highlighted: false,
          child: Row(
            children: [
              const _Avatar(ready: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set up a local shell',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arch, Debian, Ubuntu, Alpine and more',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _InstanceAction { files, manage }

class _InstanceCard extends StatelessWidget {
  const _InstanceCard({
    required this.instance,
    required this.distroName,
    required this.state,
    required this.active,
    required this.onOpen,
    required this.onManage,
    required this.onOpenFiles,
  });

  final LocalShellInstance instance;
  final String distroName;
  final LocalShellState state;
  final bool active;
  final Future<void> Function() onOpen;
  final VoidCallback onManage;
  final VoidCallback onOpenFiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ready = state.isReady;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (ready) {
            onOpen();
          } else if (!state.isBusy) {
            onManage();
          }
        },
        child: _CardShell(
          highlighted: ready && active,
          child: Row(
            children: [
              _Avatar(ready: ready),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instance.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLine(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: state.stage == LocalShellStage.failed
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _trailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (state.isBusy) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: state.progress,
            ),
          ),
        ),
      );
    }
    if (state.isReady) {
      return PopupMenuButton<_InstanceAction>(
        tooltip: 'Local shell options',
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
        onSelected: (action) => switch (action) {
          _InstanceAction.files => onOpenFiles(),
          _InstanceAction.manage => onManage(),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _InstanceAction.files,
            child: ListTile(
              leading: Icon(Icons.folder_open_outlined),
              title: Text('Files'),
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 24,
            ),
          ),
          PopupMenuItem(
            value: _InstanceAction.manage,
            child: ListTile(
              leading: Icon(Icons.tune_rounded),
              title: Text('Manage'),
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 24,
            ),
          ),
        ],
      );
    }
    return IconButton(
      tooltip: 'Manage',
      iconSize: 18,
      onPressed: onManage,
      icon: Icon(Icons.tune_rounded, color: colorScheme.onSurfaceVariant),
    );
  }

  String _statusLine() {
    return switch (state.stage) {
      LocalShellStage.ready =>
        '$distroName · ${formatLocalShellBytes(state.diskUsageBytes)}',
      LocalShellStage.checking => '$distroName · checking…',
      LocalShellStage.notInstalled =>
        '$distroName · setup incomplete, tap to resume',
      LocalShellStage.downloading =>
        'Downloading… ${((state.progress ?? 0) * 100).toStringAsFixed(0)}%',
      LocalShellStage.extracting => 'Unpacking…',
      LocalShellStage.configuring => 'Configuring…',
      LocalShellStage.failed =>
        state.error?.message ?? 'Setup failed - tap to retry',
      LocalShellStage.unsupported => 'Not available on this device',
    };
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.highlighted, required this.child});

  final bool highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? colorScheme.primary.withValues(alpha: 0.55)
              : colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ready
              ? [accent, colorScheme.secondary]
              : [
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainerHigh,
                ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ready
              ? accent.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Icon(
        Icons.terminal_rounded,
        size: 18,
        color: ready ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
