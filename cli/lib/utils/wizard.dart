import 'dart:io';

import 'package:cli/models/scaffold_options.dart';

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

  T ask({T? initialValue});
}

class SelectionStep extends WizardStep<String> {
  final List<String> options;

  SelectionStep({
    required super.id,
    required super.label,
    required super.question,
    required this.options,
    super.description,
  });

  @override
  String ask({String? initialValue}) => Prompts.askSelection(
    question,
    options,
    initialValue: initialValue,
    description: description,
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

  String _getEnumName(T value) {
    if (value is EnumValue) {
      return (value as EnumValue).value;
    }

    return value.name;
  }

  @override
  T ask({T? initialValue}) {
    final selection = Prompts.askSelection(
      question,
      options.map(_getEnumName).toList(),
      initialValue: initialValue?.name,
      description: description,
    );
    return options.firstWhere((e) => e.name == selection);
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
  bool ask({bool? initialValue}) => Prompts.askConfirm(
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
        answers[step.id] = step.ask(initialValue: answers[step.id]);
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
        displayValue = value.name;
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
}
