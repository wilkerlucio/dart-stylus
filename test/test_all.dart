import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:stylus/stylus.dart';

void main() {
  group('Stylus', () {
    group('fromPath', () {
      test('compiling a valid source file', () {
        var output = '''
body div {
  background: #000;
}
''';

        var stream = Stylus.fromPath('fixtures/simple.styl').transform(ASCII.decoder).single;

        expect(stream, completion(output));
      });

      test('compiling file bad path', () {
        var stream = Stylus.fromPath('fixtures/not_here.styl').transform(ASCII.decoder).single;

        expect(stream, throwsA('Error: ENOENT, lstat \'fixtures/not_here.styl\''));
      });

      test('compiling file with syntax error', () {
        var stream = Stylus.fromPath('fixtures/simple_error.styl').transform(ASCII.decoder).single;

        expect(stream, throwsA(startsWith('ParseError: ')));
      });
    });

    group('fromString', () {
      test('compiling from string', () {
        var input = """
body
  div
    background: black
""";

        var output = '''
body div {
  background: #000;
}

''';

        var stream = Stylus.fromString(input).transform(ASCII.decoder).single;

        expect(stream, completion(output));
      });

      test('syntax error', () {
        var stream = Stylus.fromString('body:bad:string').transform(ASCII.decoder).single;

        expect(stream, throwsA(startsWith('ParseError: ')));
      });
    });
  });
}

