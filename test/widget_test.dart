import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer_ia_completo/main.dart';
void main(){testWidgets('app builds',(tester) async {await tester.pumpWidget(const PersonalTrainerIaApp());expect(find.text('Personal Trainer IA'),findsNothing);});}
