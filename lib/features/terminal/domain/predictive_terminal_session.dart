abstract interface class PredictiveTerminalSession {
  Stream<int> get echoAcks;

  Duration? get smoothedRtt;

  int sendWithInputState(List<int> data);
}
