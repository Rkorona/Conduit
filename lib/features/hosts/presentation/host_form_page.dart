import 'package:conduit/core/presentation/conduit_brand.dart';
import 'package:conduit/core/presentation/system_navigation_insets.dart';
import 'package:conduit/core/theme/theme_controller.dart';
import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/hosts/presentation/widgets/host_form_chrome.dart';
import 'package:conduit/features/hosts/presentation/widgets/host_form_sections.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class HostFormPage extends StatefulWidget {
  const HostFormPage({this.host, this.themeController, super.key});

  final SavedHost? host;
  final ThemeController? themeController;

  @override
  State<HostFormPage> createState() => _HostFormPageState();
}

class _HostFormPageState extends State<HostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _tagController = TextEditingController();
  final _timeoutController = TextEditingController(text: '12');
  final _moshLocaleController = TextEditingController(text: 'C.UTF-8');
  final _tmuxStartDirectoryController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  SshAuthMethod _authMethod = SshAuthMethod.password;
  bool _showPassword = false;
  bool _showPassphrase = false;
  bool _useMosh = false;
  bool _predictiveEchoEnabled = false;
  bool _forwardAgent = false;
  bool _startTmuxOnConnect = false;
  TmuxPrefixKey _tmuxPrefixKey = defaultTmuxPrefixKey;
  List<String> _tags = const [];

  bool get _isEditing => widget.host != null;

  @override
  void initState() {
    super.initState();
    final host = widget.host;
    if (host != null) {
      _nameController.text = host.name;
      _hostController.text = host.host;
      _portController.text = host.port.toString();
      _usernameController.text = host.username;
      _passwordController.text = host.password;
      _privateKeyController.text = host.privateKey;
      _passphraseController.text = host.passphrase;
      _tags = List<String>.from(host.tags);
      _timeoutController.text = host.connectionTimeoutSeconds.toString();
      _authMethod = host.authMethod;
      _useMosh = host.useMosh;
      _moshLocaleController.text = host.moshLocale;
      _predictiveEchoEnabled = host.predictiveEchoEnabled;
      _forwardAgent = host.forwardAgent;
      _startTmuxOnConnect = host.startTmuxOnConnect;
      _tmuxPrefixKey = host.tmuxPrefixKey;
      _tmuxStartDirectoryController.text = host.tmuxStartDirectory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _privateKeyController.dispose();
    _passphraseController.dispose();
    _tagController.dispose();
    _tagFocusNode.dispose();
    _timeoutController.dispose();
    _moshLocaleController.dispose();
    _tmuxStartDirectoryController.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    if (_tags.any((t) => t.toLowerCase() == trimmed.toLowerCase())) {
      _tagController.clear();
      return;
    }
    setState(() {
      _tags = [..._tags, trimmed];
      _tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((t) => t != tag).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final palette = widget.themeController?.palette;
    final body = SafeArea(
      bottom: shouldApplyBottomSafeArea(context),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            HostFormHeader(
              title: _isEditing ? 'Edit machine' : 'New machine',
              subtitle: _isEditing
                  ? 'Update connection details and credentials.'
                  : 'Connection profile and credentials.',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            HostConnectionSection(
              nameController: _nameController,
              hostController: _hostController,
              portController: _portController,
              usernameController: _usernameController,
              requiredValidator: _required,
              portValidator: _validatePort,
            ),
            const SizedBox(height: 14),
            HostAuthenticationSection(
              authMethod: _authMethod,
              passwordController: _passwordController,
              privateKeyController: _privateKeyController,
              passphraseController: _passphraseController,
              showPassword: _showPassword,
              showPassphrase: _showPassphrase,
              forwardAgent: _forwardAgent,
              requiredValidator: _required,
              keyMaterialValidator: _validateKeyMaterial,
              onAuthMethodChanged: (method) =>
                  setState(() => _authMethod = method),
              onTogglePasswordVisibility: () =>
                  setState(() => _showPassword = !_showPassword),
              onTogglePassphraseVisibility: () =>
                  setState(() => _showPassphrase = !_showPassphrase),
              onPasteKey: _pasteKey,
              onForwardAgentChanged: (value) =>
                  setState(() => _forwardAgent = value),
            ),
            const SizedBox(height: 14),
            HostAdvancedSection(
              tags: _tags,
              tagController: _tagController,
              tagFocusNode: _tagFocusNode,
              timeoutController: _timeoutController,
              moshLocaleController: _moshLocaleController,
              tmuxStartDirectoryController: _tmuxStartDirectoryController,
              useMosh: _useMosh,
              predictiveEchoEnabled: _predictiveEchoEnabled,
              startTmuxOnConnect: _startTmuxOnConnect,
              tmuxPrefixKey: _tmuxPrefixKey,
              timeoutValidator: _validateTimeout,
              onAddTag: _addTag,
              onRemoveTag: _removeTag,
              onUseMoshChanged: (value) => setState(() {
                _useMosh = value;
                if (value) {
                  _predictiveEchoEnabled = false;
                }
              }),
              onPredictiveEchoChanged: (value) =>
                  setState(() => _predictiveEchoEnabled = value),
              onStartTmuxOnConnectChanged: (value) =>
                  setState(() => _startTmuxOnConnect = value),
              onTmuxPrefixKeyChanged: (value) =>
                  setState(() => _tmuxPrefixKey = value),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(_isEditing ? 'Save changes' : 'Add machine'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Stored on-device only • never synced to the cloud',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: palette == null
          ? body
          : ConduitBackdrop(palette: palette, child: body),
    );
  }

  Future<void> _pasteKey() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    if (_privateKeyController.text.isNotEmpty) {
      if (!mounted) return;
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace key?'),
          content: const Text(
            'The private key field already has content. Replace it with the '
            'clipboard contents?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (replace != true) return;
    }
    _privateKeyController.text = text;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_tagController.text.trim().isNotEmpty) {
      _addTag(_tagController.text);
    }

    final currentHost = widget.host;
    final savedHost = SavedHost(
      id: currentHost?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.parse(_portController.text),
      username: _usernameController.text.trim(),
      authMethod: _authMethod,
      password: _passwordController.text,
      privateKey: _privateKeyController.text,
      passphrase:
          (_authMethod == SshAuthMethod.privateKey ||
              _authMethod == SshAuthMethod.hardwareKey)
          ? _passphraseController.text
          : '',
      forwardAgent:
          (_authMethod == SshAuthMethod.privateKey ||
              _authMethod == SshAuthMethod.hardwareKey) &&
          _forwardAgent,
      tags: _tags,
      connectionTimeoutSeconds: int.parse(_timeoutController.text),
      useMosh: _useMosh,
      moshLocale: _moshLocaleController.text.trim().isEmpty
          ? 'C.UTF-8'
          : _moshLocaleController.text.trim(),
      predictiveEchoEnabled: _predictiveEchoEnabled,
      startTmuxOnConnect: _startTmuxOnConnect,
      tmuxPrefixKey: _tmuxPrefixKey,
      tmuxStartDirectory: _tmuxStartDirectoryController.text.trim(),
      lastConnectedAt: currentHost?.lastConnectedAt,
    );

    Navigator.of(context).pop(savedHost);
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validateKeyMaterial(String? value) {
    final required = _required(value);
    if (required != null) {
      return required;
    }
    try {
      final keyPairs = SSHKeyPair.fromPem(
        value!,
        _passphraseController.text.isEmpty ? null : _passphraseController.text,
      );
      final hasSecurityKey = keyPairs.any(
        (keyPair) => keyPair is OpenSSHSecurityKeyPair,
      );
      if (_authMethod == SshAuthMethod.privateKey && hasSecurityKey) {
        return 'This is a hardware-key stub. Choose Hardware key instead.';
      }
      if (_authMethod == SshAuthMethod.hardwareKey && !hasSecurityKey) {
        return 'Use id_ed25519_sk or id_ecdsa_sk, not a normal private key.';
      }
    } catch (_) {
      return _authMethod == SshAuthMethod.hardwareKey
          ? 'Paste a valid OpenSSH *_sk key stub.'
          : 'Paste a valid PEM or OpenSSH private key.';
    }
    return null;
  }

  String? _validatePort(String? value) {
    final port = int.tryParse(value ?? '');
    if (port == null || port < 1 || port > 65535) return '1-65535';
    return null;
  }

  String? _validateTimeout(String? value) {
    final timeout = int.tryParse(value ?? '');
    if (timeout == null || timeout < 3 || timeout > 120) return '3-120';
    return null;
  }
}
