import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/hosts/presentation/host_form_page.dart';
import 'package:conduit/features/hosts/presentation/hosts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_doubles.dart';

void main() {
  group('SavedHost.isValid', () {
    const base = SavedHost(
      id: 'id',
      name: 'name',
      host: '192.168.1.1',
      port: 22,
      username: 'user',
      authMethod: SshAuthMethod.password,
      password: 'p',
    );

    test('rejects empty id, name, host, username', () {
      expect(base.copyWith(id: '').isValid, isFalse);
      expect(base.copyWith(name: ' ').isValid, isFalse);
      expect(base.copyWith(host: '').isValid, isFalse);
      expect(base.copyWith(username: '').isValid, isFalse);
    });

    test('rejects out-of-range ports', () {
      expect(base.copyWith(port: 0).isValid, isFalse);
      expect(base.copyWith(port: 65536).isValid, isFalse);
      expect(base.copyWith(port: 1).isValid, isTrue);
      expect(base.copyWith(port: 65535).isValid, isTrue);
    });

    test('rejects out-of-range timeouts', () {
      expect(base.copyWith(connectionTimeoutSeconds: 2).isValid, isFalse);
      expect(base.copyWith(connectionTimeoutSeconds: 121).isValid, isFalse);
      expect(base.copyWith(connectionTimeoutSeconds: 3).isValid, isTrue);
      expect(base.copyWith(connectionTimeoutSeconds: 120).isValid, isTrue);
    });

    test('requires credential for the chosen auth method', () {
      expect(base.copyWith(password: '').isValid, isFalse);
      expect(
        base
            .copyWith(authMethod: SshAuthMethod.privateKey, privateKey: '')
            .isValid,
        isFalse,
      );
      expect(
        base
            .copyWith(authMethod: SshAuthMethod.privateKey, privateKey: 'pem')
            .isValid,
        isTrue,
      );
      expect(
        base
            .copyWith(authMethod: SshAuthMethod.hardwareKey, privateKey: '')
            .isValid,
        isFalse,
      );
      expect(
        base
            .copyWith(
              authMethod: SshAuthMethod.hardwareKey,
              privateKey: 'openssh-sk-stub',
            )
            .isValid,
        isTrue,
      );
    });
  });

  group('SavedHost round-trip', () {
    test('toJson then fromJson preserves all fields', () {
      final original = SavedHost(
        id: 'id',
        name: 'My Host',
        host: 'example.com',
        port: 2222,
        username: 'root',
        authMethod: SshAuthMethod.privateKey,
        privateKey: '-----BEGIN-----',
        passphrase: 'pp',
        tags: const ['prod', 'edge'],
        connectionTimeoutSeconds: 30,
        useMosh: true,
        moshLocale: 'en_US.UTF-8',
        startTmuxOnConnect: true,
        tmuxPrefixKey: TmuxPrefixKey.controlA,
        tmuxStartDirectory: '~/projects',
        lastConnectedAt: DateTime.parse('2025-01-02T03:04:05Z'),
      );

      final decoded = SavedHost.fromJson(original.toJson());

      expect(decoded.id, original.id);
      expect(decoded.name, original.name);
      expect(decoded.host, original.host);
      expect(decoded.port, original.port);
      expect(decoded.username, original.username);
      expect(decoded.authMethod, original.authMethod);
      expect(decoded.privateKey, original.privateKey);
      expect(decoded.passphrase, original.passphrase);
      expect(decoded.tags, original.tags);
      expect(
        decoded.connectionTimeoutSeconds,
        original.connectionTimeoutSeconds,
      );
      expect(decoded.useMosh, original.useMosh);
      expect(decoded.moshLocale, original.moshLocale);
      expect(decoded.predictiveEchoEnabled, original.predictiveEchoEnabled);
      expect(decoded.startTmuxOnConnect, original.startTmuxOnConnect);
      expect(decoded.tmuxPrefixKey, original.tmuxPrefixKey);
      expect(decoded.tmuxStartDirectory, original.tmuxStartDirectory);
      expect(decoded.lastConnectedAt, original.lastConnectedAt);
    });

    test('older saved hosts default to no tmux start with Ctrl-B', () {
      final decoded = SavedHost.fromJson(const {
        'id': 'id',
        'name': 'Legacy Host',
        'host': 'example.com',
        'port': 22,
        'username': 'root',
        'authMethod': 'password',
        'password': 'secret',
      });

      expect(decoded.startTmuxOnConnect, isFalse);
      expect(decoded.tmuxPrefixKey, TmuxPrefixKey.controlB);
      expect(decoded.tmuxStartDirectory, isEmpty);
    });

    test('preserves hardware key auth method', () {
      const original = SavedHost(
        id: 'id',
        name: 'Hardware Host',
        host: 'example.com',
        port: 22,
        username: 'root',
        authMethod: SshAuthMethod.hardwareKey,
        privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----',
      );

      final decoded = SavedHost.fromJson(original.toJson());

      expect(decoded.authMethod, SshAuthMethod.hardwareKey);
      expect(decoded.privateKey, original.privateKey);
      expect(decoded.passphrase, isEmpty);
    });
  });

  group('HostFormPage auth validation', () {
    testWidgets('private key rejects OpenSSH hardware key stubs', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HostFormPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Display name'),
        'Host',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Host or IP'),
        'example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'root',
      );
      await tester.tap(find.text('Private key').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Private key'),
        fakeSecurityKeyPem(),
      );
      final listPosition =
          ((find.byType(Scrollable).evaluate().first as StatefulElement).state
                  as ScrollableState)
              .position;
      final addButton = find.text('Add machine');
      for (var i = 0; i < 40 && addButton.evaluate().isEmpty; i++) {
        listPosition.jumpTo(
          (listPosition.pixels + 200).clamp(0.0, listPosition.maxScrollExtent),
        );
        await tester.pump();
      }
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      listPosition.jumpTo(0);
      await tester.pumpAndSettle();

      expect(
        find.text('This is a hardware-key stub. Choose Hardware key instead.'),
        findsOneWidget,
      );
    });
  });

  group('HostsController', () {
    test('upsert + load surfaces persisted hosts', () async {
      final repository = FakeHostsRepository();
      final controller = HostsController(repository);
      await controller.load();

      await controller.upsert(buildHost('a'));
      expect(controller.hosts, hasLength(1));
      expect(repository.persisted, hasLength(1));
    });

    test('markConnected uses the latest version of the host', () async {
      final repository = FakeHostsRepository();
      final controller = HostsController(repository);
      await controller.load();
      await controller.upsert(buildHost('a', username: 'old'));
      final stale = buildHost('a', username: 'old');
      await controller.upsert(buildHost('a', username: 'new'));

      await controller.markConnected(stale);

      final saved = repository.persisted.single;
      expect(saved.username, 'new');
      expect(saved.lastConnectedAt, isNotNull);
    });
  });
}
