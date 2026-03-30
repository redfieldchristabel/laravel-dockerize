import 'package:cli/utils/prompts.dart';
import 'package:cli/utils/wizard.dart';
import 'package:test/test.dart';

class FakePromptProvider implements PromptProvider {
  SelectionState? Function(bool value)? lastGetDisabledState;

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
    SelectionState? Function(T option)? getDisabledState,
  }) {
    return options.first;
  }

  @override
  bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
    SelectionState? Function(bool value)? getDisabledState,
  }) {
    lastGetDisabledState = getDisabledState;
    return defaultValue;
  }
}

void main() {
  test('ConfirmStep should pass getDisabledState to Prompts', () {
    final fakePrompts = FakePromptProvider();
    Prompts.instance = fakePrompts;

    final step = ConfirmStep(
      id: 'octane',
      label: 'Octane',
      question: 'Use Octane?',
      getDisabledState: (value, answers) {
        if (value == true && answers['php'] == '8.1') {
          return (isDisabled: true, reason: 'unsupported');
        }
        return null;
      },
    );

    // Test case 1: PHP 8.1 - Yes should be disabled
    step.ask(answers: {'php': '8.1'});
    expect(fakePrompts.lastGetDisabledState, isNotNull);
    expect(fakePrompts.lastGetDisabledState!(true)?.isDisabled, isTrue);
    expect(fakePrompts.lastGetDisabledState!(true)?.reason, 'unsupported');
    expect(fakePrompts.lastGetDisabledState!(false), isNull);

    // Test case 2: PHP 8.2 - Nothing should be disabled
    step.ask(answers: {'php': '8.2'});
    expect(fakePrompts.lastGetDisabledState!(true), isNull);
    expect(fakePrompts.lastGetDisabledState!(false), isNull);
  });
}
