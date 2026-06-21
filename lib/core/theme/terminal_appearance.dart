enum TerminalFontOption { systemMonospace, atkynsonNerdFont }

const terminalFontSizeDefault = 13.5;
const terminalFontSizeMin = 4.0;
const terminalFontSizeMax = 30.0;
const terminalFontSizeStep = 0.5;
const terminalFontSizeDivisions = 52;

double clampTerminalFontSize(num size) {
  return size.clamp(terminalFontSizeMin, terminalFontSizeMax).toDouble();
}

double normalizeTerminalFontSize(double size) {
  final normalized =
      (size / terminalFontSizeStep).round() * terminalFontSizeStep;
  return clampTerminalFontSize(normalized);
}

extension TerminalFontOptionDetails on TerminalFontOption {
  String get label => switch (this) {
    TerminalFontOption.systemMonospace => 'System mono',
    TerminalFontOption.atkynsonNerdFont => 'Nerd Font',
  };

  String get fontFamily => switch (this) {
    TerminalFontOption.systemMonospace => 'monospace',
    TerminalFontOption.atkynsonNerdFont => 'AtkynsonMonoNerdFontMono',
  };
}

enum TerminalKeyboardAction {
  escape,
  control,
  alt,
  tab,
  fullscreen,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  home,
  end,
  pageUp,
  pageDown,
  controlC,
  controlD,
  controlZ,
  controlL,
  colon,
  slash,
  pipe,
  dash,
  paste,
  functionKeys,
}

const defaultTerminalKeyboardActions = [
  TerminalKeyboardAction.escape,
  TerminalKeyboardAction.control,
  TerminalKeyboardAction.alt,
  TerminalKeyboardAction.tab,
  TerminalKeyboardAction.arrowUp,
  TerminalKeyboardAction.arrowDown,
  TerminalKeyboardAction.arrowLeft,
  TerminalKeyboardAction.arrowRight,
  TerminalKeyboardAction.slash,
  TerminalKeyboardAction.dash,
  TerminalKeyboardAction.pipe,
  TerminalKeyboardAction.paste,
  TerminalKeyboardAction.controlC,
  TerminalKeyboardAction.controlD,
  TerminalKeyboardAction.controlZ,
  TerminalKeyboardAction.controlL,
  TerminalKeyboardAction.colon,
  TerminalKeyboardAction.home,
  TerminalKeyboardAction.end,
  TerminalKeyboardAction.pageUp,
  TerminalKeyboardAction.pageDown,
  TerminalKeyboardAction.functionKeys,
  TerminalKeyboardAction.fullscreen,
];

const legacyDefaultTerminalKeyboardActions = [
  TerminalKeyboardAction.escape,
  TerminalKeyboardAction.control,
  TerminalKeyboardAction.alt,
  TerminalKeyboardAction.tab,
  TerminalKeyboardAction.fullscreen,
  TerminalKeyboardAction.arrowUp,
  TerminalKeyboardAction.arrowDown,
  TerminalKeyboardAction.arrowLeft,
  TerminalKeyboardAction.arrowRight,
  TerminalKeyboardAction.home,
  TerminalKeyboardAction.end,
  TerminalKeyboardAction.pageUp,
  TerminalKeyboardAction.pageDown,
  TerminalKeyboardAction.controlC,
  TerminalKeyboardAction.controlD,
  TerminalKeyboardAction.controlZ,
  TerminalKeyboardAction.controlL,
  TerminalKeyboardAction.colon,
  TerminalKeyboardAction.slash,
  TerminalKeyboardAction.pipe,
  TerminalKeyboardAction.dash,
  TerminalKeyboardAction.paste,
  TerminalKeyboardAction.functionKeys,
];

extension TerminalKeyboardActionDetails on TerminalKeyboardAction {
  String get label => switch (this) {
    TerminalKeyboardAction.escape => 'Esc',
    TerminalKeyboardAction.control => 'Ctrl',
    TerminalKeyboardAction.alt => 'Alt',
    TerminalKeyboardAction.tab => 'Tab',
    TerminalKeyboardAction.fullscreen => 'Full',
    TerminalKeyboardAction.arrowUp => 'Up',
    TerminalKeyboardAction.arrowDown => 'Down',
    TerminalKeyboardAction.arrowLeft => 'Left',
    TerminalKeyboardAction.arrowRight => 'Right',
    TerminalKeyboardAction.home => 'Home',
    TerminalKeyboardAction.end => 'End',
    TerminalKeyboardAction.pageUp => 'PgUp',
    TerminalKeyboardAction.pageDown => 'PgDn',
    TerminalKeyboardAction.controlC => '^C',
    TerminalKeyboardAction.controlD => '^D',
    TerminalKeyboardAction.controlZ => '^Z',
    TerminalKeyboardAction.controlL => '^L',
    TerminalKeyboardAction.colon => ':',
    TerminalKeyboardAction.slash => '/',
    TerminalKeyboardAction.pipe => '|',
    TerminalKeyboardAction.dash => '-',
    TerminalKeyboardAction.paste => 'Paste',
    TerminalKeyboardAction.functionKeys => 'Fn',
  };
}
