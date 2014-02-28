import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:stylus/stylus.dart';
import 'dart:async';

Future<String> processPath(String path) {
  return StylusProcess.start(new StylusOptions(path: path)).transform(ASCII.decoder).single;
}

Future<String> processString(String content) {
  return StylusProcess.start(new StylusOptions(input: content)).transform(ASCII.decoder).single;
}

void main() {
  group('StylusProcess', () {
    group('from path', () {
      test('compiling a valid source file', () {
        var output = '''
body div {
  background: #000;
}
''';

        expect(processPath('fixtures/simple.styl'), completion(output));
      });

      test('compiling file bad path', () {
        expect(processPath('fixtures/not_here.styl'), throwsA('Error: ENOENT, lstat \'fixtures/not_here.styl\''));
      });

      test('compiling file with syntax error', () {
        expect(processPath('fixtures/simple_error.styl'), throwsA(startsWith('ParseError: ')));
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

        expect(processString(input), completion(output));
      });

      test('syntax error', () {
        expect(processString('body:bad:string'), throwsA(startsWith('ParseError: ')));
      });
    });
  });

  group('StylusOptions', () {
    test('argument error if no input OR path is provided', () {
      expect(() { new StylusOptions().args; }, throwsArgumentError);
    });

    test('argument error if input AND path are provided', () {
      expect(() { new StylusOptions(path: 'file.styl', input: 'text input').args; }, throwsArgumentError);
    });

    test('path option', () {
      var options = new StylusOptions(path: 'file.styl');

      expect(options.args, ['--print', 'file.styl']);
    });

    test('input option', () {
      var options = new StylusOptions(input: 'input string');

      expect(options.args, []);
    });

    test('use option', () {
      var options = new StylusOptions(input: '', use: ['nib']);

      expect(options.args, ['--use', 'nib']);
    });

    test('inlineImages option', () {
      var options = new StylusOptions(input: '', inlineImages: true);

      expect(options.args, ['--inline']);
    });

    test('compress option', () {
      var options = new StylusOptions(input: '', compress: true);

      expect(options.args, ['--compress']);
    });

    test('compare option', () {
      var options = new StylusOptions(input: '', compare: true);

      expect(options.args, ['--compare']);
    });

    test('firebug option', () {
      var options = new StylusOptions(input: '', firebug: true);

      expect(options.args, ['--firebug']);
    });

    test('lineNumbers option', () {
      var options = new StylusOptions(input: '', lineNumbers: true);

      expect(options.args, ['--line-numbers']);
    });

    test('resolveUrls option', () {
      var options = new StylusOptions(input: '', resolveUrls: true);

      expect(options.args, ['--resolve-url']);
    });

    test('copy', () {
      var options = new StylusOptions(path: 'path', use: ['nib'], inlineImages: true, compress: true, compare: true, firebug: true, lineNumbers: true, includeCss: true, resolveUrls: true);
      var copy = options.copy;

      copy.use.add('other');

      expect(copy.use, ['nib', 'other']);
      expect(options.use, ['nib']);
    });
  });
}