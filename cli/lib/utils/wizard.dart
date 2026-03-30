import 'dart:io';

import 'prompts.dart';

abstract class WizardStep<T> {
  final String id;
  final String label;
  final String question;
  final String? description;

  WizardStep({
    required this.id,
    required this.label,
    required this.question,
    this.description,
  });

  T ask({T? initialValue, Map<String, dynamic>? answers});
}

class SelectionStep extends WizardStep<String> {
  final List<String> options;
  final SelectionState? Function(
    String option,
    Map<String, dynamic> answers,
  )? getDisabledState;

  SelectionStep({
    required super.id,
    required super.label,
    required super.question,
    required this.options,
    super.description,
    this.getDisabledState,
  });

  @override
  String ask({String? initialValue, Map<String, dynamic>? answers}) =>
      Prompts.askSelection<String>(
        question,
        options,
        initialValue: initialValue,
        description: description,
        getDisabledState: getDisabledState != null
            ? (option) => getDisabledState!(option, answers ?? {})
            : null,
      );
}

class EnumSelectionStep<T extends Enum> extends WizardStep<T> {
  final List<T> options;

  EnumSelectionStep({
    required super.id,
    required super.label,
    required super.question,
    required this.options,
    super.description,
  });

  @override
  T ask({T? initialValue, Map<String, dynamic>? answers}) {
    return Prompts.askSelection<T>(
      question,
      options,
      initialValue: initialValue,
      description: description,
      getDisabledState: (option) {
        if (option is HasDisableSelection) {
          return (option as HasDisableSelection).checkDisabled(answers ?? {});
        }
        return null;
      },
    );
  }
}

class ConfirmStep extends WizardStep<bool> {
  final bool defaultValue;

  ConfirmStep({
    required super.id,
    required super.label,
    required super.question,
    super.description,
    this.defaultValue = true,
  });

  @override
  bool ask({bool? initialValue, Map<String, dynamic>? answers}) =>
      Prompts.askConfirm(
        question,
        defaultValue: initialValue ?? defaultValue,
        description: description,
      );
}

abstract class Wizard<T> {
  List<WizardStep> get steps;

  T build(Map<String, dynamic> answers);

  T run() {
    final answers = <String, dynamic>{};

    while (true) {
      // 1. Ask all questions
      for (final step in steps) {
        // Pass previous answer as initialValue if it exists
        answers[step.id] = step.ask(
          initialValue: answers[step.id],
          answers: answers,
        );
      }

      // 2. Show Summary and Confirm
      if (_confirmSummary(answers)) {
        return build(answers);
      }

      print('\n🔄 Restarting the wizard to edit your choices...');
    }
  }

  bool _confirmSummary(Map<String, dynamic> answers) {
    print('\n📋 --- Summary ---');
    for (final step in steps) {
      final value = answers[step.id];
      String displayValue;

      if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else if (value is Enum) {
        displayValue = _getEnumValueForSummary(value);
      } else {
        displayValue = value.toString();
      }

      print('${step.label}: \x1b[36m$displayValue\x1b[0m');
    }
    print('------------------');

    final choice = Prompts.askSelection('Everything looks correct?', [
      'Confirm and proceed',
      'Edit answers',
      'Cancel',
    ]);

    if (choice == 'Cancel') {
      print('❌ Operation cancelled.');
      exit(0);
    }

    return choice == 'Confirm and proceed';
  }

  String _getEnumValueForSummary(Enum value) {
    if (value is EnumValue) {
      return (value as EnumValue).value;
    }
    return value.name;
  }
}
