import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer_ia_completo/main.dart';

void main() {
  test('aplicativo principal pode ser instanciado', () {
    const app = PersonalTrainerIaApp();

    expect(app, isA<Widget>());
  });
}
