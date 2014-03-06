import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:stylus/transformer.dart';
import 'package:barback/barback.dart';

void main() {
  group("Helpers", () {
    test("replaceLast", () {
      expect(replaceLast("/.styl/.styl.styl/.styl.styl.styl.styl", ".styl", ".css"), "/.styl/.styl.styl/.styl.styl.styl.css");
    });
  });
}


class MockDeclaringTransform extends Mock implements DeclaringTransform {
}