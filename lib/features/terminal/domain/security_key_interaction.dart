import 'dart:async';

typedef SecurityKeyPinPrompt =
    Future<String?> Function(SecurityKeyPinRequest request);

class SecurityKeyPinRequest {
  const SecurityKeyPinRequest({this.retriesRemaining});

  final int? retriesRemaining;
}

class SecurityKeyInteraction {
  SecurityKeyInteraction._();

  static final instance = SecurityKeyInteraction._();

  final _messages = StreamController<String>.broadcast();
  final _pinPrompts = <SecurityKeyPinPrompt>[];

  Stream<String> get messages => _messages.stream;

  void announce(String message) {
    if (!_messages.isClosed) {
      _messages.add(message);
    }
  }

  void registerPinPrompt(SecurityKeyPinPrompt prompt) {
    _pinPrompts.add(prompt);
  }

  void unregisterPinPrompt(SecurityKeyPinPrompt prompt) {
    _pinPrompts.remove(prompt);
  }

  Future<String?> requestPin({int? retriesRemaining}) {
    if (_pinPrompts.isEmpty) {
      return Future<String?>.value();
    }
    return _pinPrompts.last(
      SecurityKeyPinRequest(retriesRemaining: retriesRemaining),
    );
  }
}
