import 'package:cli/commands/scaffold.dart';
import 'package:cli/models/scaffold_options.dart';
import 'package:cli/utils/prompts.dart';
import 'package:cli/utils/wizard.dart';
import 'package:test/test.dart';

/// A fake prompt provider to capture calls and return mocked values
class FakePromptProvider implements PromptProvider {
  Object? lastAnswer;
  String? lastQuestion;
  List<dynamic>? lastOptions;

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
    SelectionState? Function(T option)? getDisabledState,
  }) {
    lastQuestion = question;
    lastOptions = options;
    return (lastAnswer ?? options.first) as T;
  }

  @override
  bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
    SelectionState? Function(bool value)? getDisabledState,
  }) {
    lastQuestion = question;
    return (lastAnswer ?? defaultValue) as bool;
  }
}

void main() {
  late FakePromptProvider fakePrompts;

  setUp(() {
    fakePrompts = FakePromptProvider();
    Prompts.instance = fakePrompts;
  });

  group('Enum and Model Logic', () {
    test(
      'PhpVersion should return correct display value via EnumValue mixin',
      () {
        expect(PhpVersion.v8_1.value, '8.1');
        expect(PhpVersion.v8_3.value, '8.3');
        expect(PhpVersion.v8_4.value, '8.4');
      },
    );

    test('Database should return correct connection names', () {
      expect(Database.sqlite.connectionName, 'sqlite');
      expect(Database.mysql.connectionName, 'mysql');
      expect(Database.postgres.connectionName, 'pgsql');
      expect(Database.mariadb.connectionName, 'mariadb');
    });
  });

  group('Wizard Steps', () {
    test('SelectionStep should pass correct data to Prompts', () {
      final step = SelectionStep(
        id: 'test',
        label: 'Test',
        question: 'What is your name?',
        options: ['A', 'B'],
      );

      fakePrompts.lastAnswer = 'B';
      final result = step.ask();

      expect(result, 'B');
      expect(fakePrompts.lastQuestion, 'What is your name?');
      expect(fakePrompts.lastOptions, ['A', 'B']);
    });

    test('EnumSelectionStep should pass full Enum objects to Prompts', () {
      final step = EnumSelectionStep<Database>(
        id: 'db',
        label: 'DB',
        question: 'Select DB:',
        options: Database.values,
      );

      fakePrompts.lastAnswer = Database.postgres;
      final result = step.ask();

      expect(result, Database.postgres);
      expect(fakePrompts.lastOptions, Database.values);
    });

    test('ConfirmStep should pass correct data to Prompts', () {
      final step = ConfirmStep(id: 'ok', label: 'Ok', question: 'Proceed?');

      fakePrompts.lastAnswer = false;
      final result = step.ask();

      expect(result, isFalse);
      expect(fakePrompts.lastQuestion, 'Proceed?');
    });
  });

  group('ScaffoldWizard', () {
    test('build should correctly transform answer map to ScaffoldOption', () {
      final wizard = ScaffoldWizard();
      final answers = {
        'php_version': PhpVersion.v8_3,
        'use_octane': true,
        'is_filament': false,
        'database': Database.postgres,
        'web_socket': WebSocketTech.reverb,
        'base_image': BaseImage.alpine,
        'use_vite': true,
        'production_ready': true,
      };

      final options = wizard.build(answers);

      expect(options.phpVersion, PhpVersion.v8_3);
      expect(options.useOctane, isTrue);
      expect(options.database, Database.postgres);
      expect(options.baseImage, BaseImage.alpine);
      expect(options.productionReady, isTrue);
    });
  });
}
