part of stylus;

/**
 * Stylus compiler
 *
 * This class providers a simple port to convert [Stylus](http://learnboost.github.io/stylus/)
 * files to CSS using Dart.
 *
 * For this class to work you gonna need to have the `stylus` command on your path.
 */
class Stylus {
  /**
   * Converts a Stylus file from a path
   *
   *     import 'package:stylus/stylus.dart';
   *
   *     Stylus.fromPath('file.styl').pipe(new File('output.css').openWrite());
   */
  static Stream<List<int>> fromPath(String path) {
    return new _StylusProcess(path: path).stream;
  }

  /**
   * Converts Stylus [String] content into CSS
   *
   *     import 'dart:convert';
   *     import 'package:stylus/stylus.dart';
   *
   *     var input = '''
   *       body
   *         .class
   *           .internal
   *             color: blue
   *     ''';
   *
   *     Stylus.fromString('file.styl').transform(ASCII.decoder).single.then((String css) {
   *       print(css); // body .class .internal { color: #00f; }
   *     });
   */
  static Stream<List<int>> fromString(String input) {
    return new _StylusProcess(input: input).stream;
  }
}

class _StylusProcess {
  final StreamController _streamController;
  Process _process;

  String path;
  String input;

  _StylusProcess({this.path, this.input}): _streamController = new StreamController() {
    _spawn().then(_setupProcess).catchError((err) {
      _dispatchError(err);
    });
  }

  Future<Process> _spawn() {
    return Process.start('stylus', _buildArgs(), environment: _env);
  }

  List<String> _buildArgs() {
    var args = [];

    if (path != null) args.addAll(['-p', path]);

    return args;
  }

  void _setupProcess(Process process) {
    _process = process;
    _writeInput();

    _listenProcessOutput();
    _listenExitCode();
  }

  void _writeInput() {
    if (input != null) {
      _process.stdin.add(ASCII.encode(input));
      _process.stdin.close();
    }
  }

  Stream<List<int>> get stream => _streamController.stream;

  void _listenProcessOutput() {
    _process.stdout.listen((List<int> data) {
      _streamController.add(data);
    });
  }

  void _listenExitCode() {
    _process.exitCode.then(_processExitCode);
  }

  void _processExitCode(int code) {
    if (code == 0) {
      _streamController.close();
    } else {
      _processError();
    }
  }

  void _processError() {
    _process.stderr.transform(ASCII.decoder).single.then((String errorString) {
      _dispatchError(errorString.split('\n').skip(4).join('\n').trim());
    });
  }

  void _dispatchError(err) {
    _streamController.addError(err);
    _streamController.close();
  }

  // TODO: this hack made it work for OSX, if you are reading this and use another OS
  // please check if it works for you, otherwise please open an issue
  Map<String, String> get _env => {'PATH': '${Platform.environment['PATH']}:/usr/local/bin'};
}