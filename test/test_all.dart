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
        expect(processPath('fixtures/not_here.styl'), throwsA(matches('Error: ENOENT')));
      });

      test('compiling file with syntax error', () {
        expect(processPath('fixtures/simple_error.styl'), throwsA(matches('ParseError: ')));
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
        expect(processString('body:bad:string'), throwsA(matches('ParseError: ')));
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
    group('copyWith', () {
      const stylus = """
h1
 color red
""";

      test('set attributes', () {
        var options = new StylusOptions(path: 'path', use: ['nib'], inlineImages: true, compress: true, compare: true, firebug: true, lineNumbers: true, includeCss: true, resolveUrls: true);
        var copy = options.copyWith(path: null, input: stylus, use: null, inlineImages: false, compress: false, compare: false, firebug: false, lineNumbers: false, includeCss: false, resolveUrls: false);
        expect(copy.path, null);
        expect(copy.input, stylus);
        expect(copy.use, null);
        expect(copy.inlineImages, false);
        expect(copy.compress, false);
        expect(copy.firebug, false);
        expect(copy.lineNumbers, false);
        expect(copy.includeCss, false);
        expect(copy.resolveUrls, false);
      });
      test('no attributes', () {
        var options = new StylusOptions(path: 'path', use: ['nib'], inlineImages: true, compress: true, compare: true, firebug: true, lineNumbers: true, includeCss: true, resolveUrls: true);
        var copy = options.copyWith();
        expect(copy.path, options.path);
        expect(copy.input, options.input);
        expect(copy.use, options.use);
        expect(copy.inlineImages, options.inlineImages);
        expect(copy.compress, options.compress);
        expect(copy.firebug, options.firebug);
        expect(copy.lineNumbers, options.lineNumbers);
        expect(copy.includeCss, options.includeCss);
        expect(copy.resolveUrls, options.resolveUrls);
      });
    });
    group('fromMap', () {
      test('empty map', () {
        var options = new StylusOptions.fromMap({});
        expect(options.path, null);
        expect(options.input, null);
        expect(options.use, null);
        expect(options.inlineImages, null);
        expect(options.compress, null);
        expect(options.firebug, null);
        expect(options.lineNumbers, null);
        expect(options.includeCss, null);
        expect(options.resolveUrls, null);
      });
      test('map', () {
        final map = {
                     "path": "path",
                     "input": "input",
                     "use": ["a","b"],
                     "inlineImages": true,
                     "compress": true,
                     "firebug": true,
                     "lineNumbers": true,
                     "includeCss": true,
                     "resolveUrls": true
                   };
        var options = new StylusOptions.fromMap(map);
        expect(options.path, "path");
        expect(options.input, "input");
        expect(options.use, ["a","b"]);
        expect(options.inlineImages, true);
        expect(options.compress, true);
        expect(options.firebug, true);
        expect(options.lineNumbers, true);
        expect(options.includeCss, true);
        expect(options.resolveUrls, true);

        map["use"].add("c");
        expect(options.use, ["a","b"]);
      });
    });
  });
}