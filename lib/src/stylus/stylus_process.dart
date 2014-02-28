part of stylus;

/**
 * This class wraps the process call to Stylus on your system
 *
 * Use StylusProcess to compile Stylus code into CSS, the easiest
 * way to call is by using the [start] method:
 *
 *     import 'package:stylus/stylus.dart';
 *
 *     StylusProcess.start(new StylusOptions(path: 'file.styl')).pipe(new File('output.css').openWrite());
 *
 * As you can see, the [start] returns a [Stream] that you can use to pipe
 * strait on the result.
 *
 * You can also compile from a [String]:
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
 *     Stylus.fromString(new StylusOptions(input: input)).pipe(new File('output.css').openWrite());
 *
 * And finally, a tip on how to get the compiled content as [String]
 *
 *     import 'dart:convert';
 *     import 'package:stylus/stylus.dart';
 *
 *     StylusProcess.start(new StylusOptions(path: 'app.styl')).transform(ASCII.decoder).single.then((String css) {
 *       print(css); // body .class .internal { color: #00f; }
 *     });
 *
 * There are many other options that you can send to [StylusOptions] to configure
 * the compilation, check the constructor arguments at [StylusOptions]
 */
class StylusProcess {
  final StreamController _streamController;
  Process _process;
  bool _started = false;

  final StylusOptions _options;

  static Stream<List<int>> start(StylusOptions options) {
    return new StylusProcess(options).stream;
  }

  StylusProcess(this._options): _streamController = new StreamController();

  Stream<List<int>> get stream {
    _startSpawn();

    return _streamController.stream;
  }

  void _startSpawn() {
    if (_started) return;

    _started = true;

    _spawn().then(_setupProcess).catchError(_dispatchError);
  }

  Future<Process> _spawn() {
    return Process.start('stylus', _options.args, environment: _env);
  }

  void _setupProcess(Process process) {
    _process = process;
    _writeInput();

    _listenProcessOutput();
    _listenExitCode();
  }

  void _writeInput() {
    if (_options.input != null) {
      _process.stdin.add(ASCII.encode(_options.input));
      _process.stdin.close();
    }
  }

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
    _process.stderr.transform(ASCII.decoder).single.then(_dispatchError);
  }

  void _dispatchError(err) {
    _streamController.addError(err);
    _streamController.close();
  }

  // TODO: this hack made it work for OSX, if you are reading this and use another OS
  // please check if it works for you, otherwise please open an issue
  Map<String, String> get _env => {'PATH': '${Platform.environment['PATH']}:/usr/local/bin'};
}