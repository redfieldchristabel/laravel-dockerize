import 'dart:io';
import 'prompts.dart';

abstract class WizardStep<T> {
  final String id;
  final String label;
  final String question;

  WizardStep({
    required this.id,
    required this.label,
    required this.question,
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
  });

  @override
  String ask({String? initialValue}) =>
      Prompts.askSelection(question, options, initialValue: initialValue);
}

class ConfirmStep extends WizardStep<bool> {
  final bool defaultValue;

  ConfirmStep({
    required super.id,
    required super.label,
    required super.question,
    this.defaultValue = true,
  });

  @override
  bool ask({bool? initialValue}) =>
      Prompts.askConfirm(question, defaultValue: initialValue ?? defaultValue);
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
      final displayValue = value is bool ? (value ? 'Yes' : 'No') : value;
      print('${step.label}: \x1b[36m$displayValue\x1b[0m');
    }
    print('------------------');

    final choice = Prompts.askSelection(
      'Everything looks correct?',
      ['Confirm and proceed', 'Edit answers', 'Cancel'],
    );

    if (choice == 'Cancel') {
      print('❌ Operation cancelled.');
      exit(0);
    }

    return choice == 'Confirm and proceed';
  }
}
