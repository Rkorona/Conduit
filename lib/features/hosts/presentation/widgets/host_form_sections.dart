part of '../host_form_page.dart';

class _HostConnectionSection extends StatelessWidget {
  const _HostConnectionSection({
    required this.nameController,
    required this.hostController,
    required this.portController,
    required this.usernameController,
    required this.requiredValidator,
    required this.portValidator,
  });

  final TextEditingController nameController;
  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> portValidator;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.dns_rounded,
      title: 'Connection',
      caption: 'Where to reach this machine.',
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display name',
            hintText: 'production-edge-01',
            prefixIcon: Icon(Icons.label_important_outline_rounded),
          ),
          textInputAction: TextInputAction.next,
          validator: requiredValidator,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host or IP',
                  hintText: 'edge.example.com',
                  prefixIcon: Icon(Icons.public_rounded),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: requiredValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: portValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          textInputAction: TextInputAction.next,
          validator: requiredValidator,
        ),
      ],
    );
  }
}

class _HostAuthenticationSection extends StatelessWidget {
  const _HostAuthenticationSection({
    required this.authMethod,
    required this.passwordController,
    required this.privateKeyController,
    required this.passphraseController,
    required this.showPassword,
    required this.showPassphrase,
    required this.forwardAgent,
    required this.requiredValidator,
    required this.keyMaterialValidator,
    required this.onAuthMethodChanged,
    required this.onTogglePasswordVisibility,
    required this.onTogglePassphraseVisibility,
    required this.onPasteKey,
    required this.onForwardAgentChanged,
  });

  final SshAuthMethod authMethod;
  final TextEditingController passwordController;
  final TextEditingController privateKeyController;
  final TextEditingController passphraseController;
  final bool showPassword;
  final bool showPassphrase;
  final bool forwardAgent;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> keyMaterialValidator;
  final ValueChanged<SshAuthMethod> onAuthMethodChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onTogglePassphraseVisibility;
  final VoidCallback onPasteKey;
  final ValueChanged<bool> onForwardAgentChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.lock_outline_rounded,
      title: 'Authentication',
      caption: 'Credentials are stored in platform secure storage.',
      children: [
        _AuthMethodPicker(value: authMethod, onChanged: onAuthMethodChanged),
        const SizedBox(height: 14),
        if (authMethod == SshAuthMethod.password)
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              helperText: 'Use this for password-only SSH login.',
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                tooltip: showPassword ? 'Hide' : 'Show',
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onTogglePasswordVisibility,
              ),
            ),
            obscureText: !showPassword,
            validator: authMethod == SshAuthMethod.password
                ? requiredValidator
                : null,
          ),
        if (authMethod == SshAuthMethod.privateKey ||
            authMethod == SshAuthMethod.hardwareKey) ...[
          _AuthExplainer(method: authMethod),
          const SizedBox(height: 12),
          TextFormField(
            controller: privateKeyController,
            decoration: InputDecoration(
              labelText: authMethod == SshAuthMethod.hardwareKey
                  ? 'OpenSSH hardware key stub'
                  : 'Private key',
              helperText: authMethod == SshAuthMethod.hardwareKey
                  ? 'Paste the id_ed25519_sk or id_ecdsa_sk file.'
                  : 'Paste a PEM or OpenSSH private key.',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.vpn_key_outlined),
              ),
              suffixIcon: IconButton(
                tooltip: 'Paste key',
                icon: const Icon(Icons.content_paste_rounded),
                onPressed: onPasteKey,
              ),
            ),
            minLines: 5,
            maxLines: 9,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
            validator:
                (authMethod == SshAuthMethod.privateKey ||
                    authMethod == SshAuthMethod.hardwareKey)
                ? keyMaterialValidator
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passphraseController,
            decoration: InputDecoration(
              labelText: authMethod == SshAuthMethod.hardwareKey
                  ? 'Stub passphrase'
                  : 'Key passphrase',
              helperText: authMethod == SshAuthMethod.hardwareKey
                  ? 'Only needed if the *_sk file is encrypted.'
                  : 'Leave empty for an unencrypted key.',
              prefixIcon: const Icon(Icons.shield_outlined),
              suffixIcon: IconButton(
                tooltip: showPassphrase ? 'Hide' : 'Show',
                icon: Icon(
                  showPassphrase
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onTogglePassphraseVisibility,
              ),
            ),
            obscureText: !showPassphrase,
          ),
          const SizedBox(height: 4),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Forward SSH agent'),
              subtitle: const Text(
                'Let hosts you connect to use this key to authenticate '
                'onward. Hardware keys prompt for a touch on each use.',
              ),
              value: forwardAgent,
              onChanged: onForwardAgentChanged,
            ),
          ),
        ],
      ],
    );
  }
}

class _HostAdvancedSection extends StatelessWidget {
  const _HostAdvancedSection({
    required this.tags,
    required this.tagController,
    required this.tagFocusNode,
    required this.timeoutController,
    required this.moshLocaleController,
    required this.useMosh,
    required this.predictiveEchoEnabled,
    required this.timeoutValidator,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onUseMoshChanged,
    required this.onPredictiveEchoChanged,
  });

  final List<String> tags;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final TextEditingController timeoutController;
  final TextEditingController moshLocaleController;
  final bool useMosh;
  final bool predictiveEchoEnabled;
  final FormFieldValidator<String> timeoutValidator;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<bool> onUseMoshChanged;
  final ValueChanged<bool> onPredictiveEchoChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.tune_rounded,
      title: 'Advanced',
      caption: 'Optional tagging and connection timing.',
      children: [
        _TagEditor(
          tags: tags,
          controller: tagController,
          focusNode: tagFocusNode,
          onAdd: onAddTag,
          onRemove: onRemoveTag,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: timeoutController,
          decoration: const InputDecoration(
            labelText: 'Connection timeout',
            suffixText: 'sec',
            prefixIcon: Icon(Icons.timer_outlined),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: timeoutValidator,
        ),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Connect with Mosh'),
            subtitle: const Text(
              'Roaming UDP session over SSH. Requires mosh-server on the '
              'host and open UDP ports.',
            ),
            value: useMosh,
            onChanged: onUseMoshChanged,
          ),
        ),
        if (useMosh) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: moshLocaleController,
            decoration: const InputDecoration(
              labelText: 'Mosh locale',
              helperText: 'Must be a UTF-8 locale installed on the host.',
              prefixIcon: Icon(Icons.language_outlined),
            ),
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Predictive echo (experimental)'),
              subtitle: const Text(
                'Show local input previews on laggy Mosh sessions.',
              ),
              value: predictiveEchoEnabled,
              onChanged: onPredictiveEchoChanged,
            ),
          ),
        ],
      ],
    );
  }
}
