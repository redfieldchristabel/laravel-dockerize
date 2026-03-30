import 'package:cli/utils/prompts.dart';
import 'package:cli/utils/wizard.dart';
import 'package:test/test.dart';

enum MockFeature with EnumValue, HasDisableSelection {
  featureA('Feature A'),
  featureB('Feature B');

  @override
  final String value;

  const MockFeature(this.value);

  @override
  SelectionState checkDisabled(Map<String, dynamic> answers) {
    if (this == MockFeature.featureB && answers['dependency'] == 'off') {
      return (isDisabled: true, reason: 'dependency is off');
    }
    return (isDisabled: false, reason: null);
  }
}

class FakePromptProvider implements PromptProvider {
  Object? lastAnswer;
  SelectionState? Function(dynamic)? lastGetDisabledState;

  @override
  bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
  }) {
    return true;
  }

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
    SelectionState? Function(T option)? getDisabledState,
  }) {
    if (getDisabledState != null) {
      lastGetDisabledState = (dynamic val) => getDisabledState(val as T);
    } else {
      lastGetDisabledState = null;
    }
    return (lastAnswer ?? options.first) as T;
  }
}

void main() {
  late FakePromptProvider fakePrompts;

  setUp(() {
    fakePrompts = FakePromptProvider();
    Prompts.instance = fakePrompts;
  });

  group('Disabled Selection with Reasons', () {
    test('EnumSelectionStep should pass isDisabled and reason to Prompts', () {
      final step = EnumSelectionStep<MockFeature>(
        id: 'feature',
        label: 'Feature',
        question: 'Select Feature:',
        options: MockFeature.values,
      );

      final answers = {'dependency': 'off'};
      step.ask(answers: answers);

      expect(fakePrompts.lastGetDisabledState, isNotNull);

      final stateA = fakePrompts.lastGetDisabledState!(MockFeature.featureA);
      expect(stateA?.isDisabled, isFalse);

      final stateB = fakePrompts.lastGetDisabledState!(MockFeature.featureB);
      expect(stateB?.isDisabled, isTrue);
      expect(stateB?.reason, 'dependency is off');
    });

    test(
      'SelectionStep should also support manual SelectionState predicate',
      () {
        final step = SelectionStep(
          id: 'manual',
          label: 'Manual',
          question: 'Choose:',
          options: ['one', 'two'],
          getDisabledState: (option, answers) =>
              option == 'two' && answers['allow_two'] == false
              ? (isDisabled: true, reason: 'not allowed')
              : (isDisabled: false, reason: null),
        );

        step.ask(answers: {'allow_two': false});

        final stateOne = fakePrompts.lastGetDisabledState!('one');
        expect(stateOne?.isDisabled, isFalse);

        final stateTwo = fakePrompts.lastGetDisabledState!('two');
        expect(stateTwo?.isDisabled, isTrue);
        expect(stateTwo?.reason, 'not allowed');
      },
    );
  });
}
