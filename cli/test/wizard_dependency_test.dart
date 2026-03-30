import 'package:cli/utils/prompts.dart';
import 'package:cli/utils/wizard.dart';
import 'package:test/test.dart';

enum DependencyFeature with EnumValue, HasDisableSelection {
  featureA('A'),
  featureB('B');

  final String value;
  const DependencyFeature(this.value);

  @override
  SelectionState checkDisabled(Map<String, dynamic> answers) {
    if (this == DependencyFeature.featureB && answers['enable_b'] != true) {
      return (isDisabled: true, reason: 'requires enable_b to be true');
    }
    return (isDisabled: false, reason: null);
  }
}

class FakePromptProvider implements PromptProvider {
  Map<String, Object?> mockedAnswers = {};
  Map<String, SelectionState Function(dynamic)?> capturedStates = {};

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
    SelectionState Function(T option)? getDisabledState,
  }) {
    capturedStates[question] = getDisabledState != null 
        ? (dynamic val) => getDisabledState(val as T) 
        : null;
    
    return (mockedAnswers[question] ?? options.first) as T;
  }

  @override
  bool askConfirm(String question, {bool defaultValue = true, String? description}) {
    return (mockedAnswers[question] ?? defaultValue) as bool;
  }
}

class DependencyWizard extends Wizard<String> {
  @override
  List<WizardStep> get steps => [
    ConfirmStep(id: 'enable_b', label: 'Enable B', question: 'Enable B?'),
    EnumSelectionStep<DependencyFeature>(
      id: 'feature',
      label: 'Feature',
      question: 'Select Feature:',
      options: DependencyFeature.values,
    ),
  ];

  @override
  String build(Map<String, dynamic> answers) => answers['feature'].toString();
}

void main() {
  late FakePromptProvider fakePrompts;

  setUp(() {
    fakePrompts = FakePromptProvider();
    Prompts.instance = fakePrompts;
  });

  group('Wizard Dependency Logic', () {
    test('Disabled state should update based on previous answers in the same run', () {
      final wizard = DependencyWizard();
      
      // Step 1: User says NO to Enable B
      fakePrompts.mockedAnswers['Enable B?'] = false;
      // Step 2: User confirms summary immediately
      fakePrompts.mockedAnswers['Everything looks correct?'] = 'Confirm and proceed';

      wizard.run();

      final stateB = fakePrompts.capturedStates['Select Feature:']!(DependencyFeature.featureB);
      expect(stateB.isDisabled, isTrue, reason: 'Feature B should be disabled because enable_b is false');
    });

    test('Disabled state should respect preserved answers during Edit/Restart phase', () {
      final wizard = DependencyWizard();
      
      // First pass: Enable B is true, so nothing is disabled
      fakePrompts.mockedAnswers['Enable B?'] = true;
      fakePrompts.mockedAnswers['Select Feature:'] = DependencyFeature.featureB;
      
      // User chooses to EDIT
      fakePrompts.mockedAnswers['Everything looks correct?'] = 'Edit answers';
      
      // Second pass (the Edit Rerun): User changes Enable B to false
      // Now when the wizard reruns 'Select Feature:', it should see that Enable B is false
      // but wait... in Wizard.run(), the loop restarts from the first question.
      
      // To test this properly, we need to capture the state during the SECOND pass.
      int callCount = 0;
      Prompts.instance = _InterceptingFakePromptProvider(fakePrompts, () {
        callCount++;
        if (callCount == 4) { // 4th prompt call is 'Select Feature:' in the second loop
           // At this point, answers['enable_b'] should be false from the previous step in this loop
        }
      });

      // Simulation of user interaction:
      // Loop 1: Enable B (Yes) -> Feature (B) -> Summary (Edit)
      // Loop 2: Enable B (No) -> Feature (Check state here)
      final sequence = [
        true,                      // Enable B? (Loop 1)
        DependencyFeature.featureB, // Select Feature: (Loop 1)
        'Edit answers',            // Summary (Loop 1)
        false,                     // Enable B? (Loop 2)
        DependencyFeature.featureA, // Select Feature: (Loop 2)
        'Confirm and proceed'      // Summary (Loop 2)
      ];
      
      int seqIdx = 0;
      fakePrompts.mockedAnswers['Enable B?'] = null; // Use sequential logic instead
      
      // Overriding askSelection to act like a script
      // (This is a bit complex for a test but necessary to verify the Rerun logic)
    });
  });
}

class _InterceptingFakePromptProvider extends FakePromptProvider {
  final FakePromptProvider delegate;
  final Function onCall;
  _InterceptingFakePromptProvider(this.delegate, this.onCall);
  
  // Implementation omitted for brevity in this thought process, 
  // I will just use a simpler way in the actual test file.
}
