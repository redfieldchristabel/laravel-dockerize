import 'package:cli/utils/prompts.dart';
import 'package:cli/utils/wizard.dart';
import 'package:test/test.dart';

enum DependencyFeature with EnumValue, HasDisableSelection {
  featureA('A'),
  featureB('B');

  @override
  final String value;
  const DependencyFeature(this.value);

  @override
  SelectionState checkDisabled(Map<String, dynamic> answers) {
    // Note: 'use_octane' matches the id in ScaffoldWizard
    if (this == DependencyFeature.featureB && answers['use_octane'] == true) {
      return (isDisabled: true, reason: 'Incompatible with Octane');
    }
    return (isDisabled: false, reason: null);
  }
}

class FakePromptProvider implements PromptProvider {
  final List<Object?> responses;
  int _responseIndex = 0;
  
  // Capture the state of the last 'feature' question
  SelectionState? lastFeatureStateB;

  FakePromptProvider(this.responses);

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
    SelectionState Function(T option)? getDisabledState,
  }) {
    if (question == 'Select Feature:') {
      lastFeatureStateB = getDisabledState?.call(DependencyFeature.featureB as T);
    }
    
    final response = responses[_responseIndex++];
    if (response is String && T == String) return response as T;
    return (response ?? options.first) as T;
  }

  @override
  bool askConfirm(String question, {bool defaultValue = true, String? description}) {
    return (responses[_responseIndex++] ?? defaultValue) as bool;
  }
}

class TestWizard extends Wizard<String> {
  @override
  List<WizardStep> get steps => [
    EnumSelectionStep<DependencyFeature>(
      id: 'feature',
      label: 'Feature',
      question: 'Select Feature:',
      options: DependencyFeature.values,
    ),
    ConfirmStep(
      id: 'use_octane',
      label: 'Use Octane',
      question: 'Use Octane?',
    ),
  ];

  @override
  String build(Map<String, dynamic> answers) => 'done';
}

void main() {
  test('Wizard should update disabled state during rerun after editing', () {
    // Scenario:
    // 1. First run: 
    //    - Select Feature B (Allowed, octane is null/false)
    //    - Use Octane? YES
    //    - Summary -> Edit answers
    // 2. Second run (Rerun):
    //    - Select Feature: (At this point, Feature B should be DISABLED because use_octane is true from prev run)
    
    final fakePrompts = FakePromptProvider([
      DependencyFeature.featureB, // Loop 1: Select Feature
      true,                       // Loop 1: Use Octane? YES
      'Edit answers',             // Loop 1: Summary
      DependencyFeature.featureA, // Loop 2: Select Feature (will check state here)
      true,                       // Loop 2: Use Octane? YES
      'Confirm and proceed',      // Loop 2: Summary
    ]);
    
    Prompts.instance = fakePrompts;
    final wizard = TestWizard();
    
    wizard.run();
    
    expect(fakePrompts.lastFeatureStateB, isNotNull);
    expect(fakePrompts.lastFeatureStateB!.isDisabled, isTrue, 
      reason: 'Feature B should be disabled in the second loop because use_octane was set to true in the first loop');
  });
}
