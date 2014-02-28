part of stylus;

/**
 * Dart Editor Stylus Build
 *
 * Use this method if you want Dart Editor to automatic compile .styl files
 * into css files on save. It will save the .css on the same folder of the
 * .styl file. File names that start with an `_` are ignored.
 *
 * Example setup:
 *
 *     import 'package:stylus/stylus.dart'
 *
 *     void main(List<String> args) {
 *       buildStylus(args);
 *     }
 */
void buildStylus(List<String> args, [StylusOptions options]) {
  new _StylusBuilder(options).build(args);
}

class _StylusBuilder {
  StylusOptions _options;

  _StylusBuilder(this._options) {
    if (_options == null) _options = new StylusOptions();
  }

  void build(List<String> args) {
    final opts = BuildOptions.parse(args);

    opts.changed
      .where((String path) => Path.extension(path) == '.styl')
      .where((String path) => !Path.basename(path).startsWith('_'))
      .forEach(_buildStylusFile);
  }

  void _buildStylusFile(String path) {
    String dir = Path.dirname(path);
    String out = Path.join(dir, Path.basenameWithoutExtension(path) + '.css');

    new StylusProcess(_options.copy..path = path).stream.pipe(new File(out).openWrite()).catchError((err) {
      print(err);
      exit(1);
    });
  }
}