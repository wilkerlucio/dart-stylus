part of stylus;

/**
 * Use this class to build the argument options for the [StylusProcess]
 */
class StylusOptions {
  /**
   * The Stylus source file path
   */
  String path;

  /**
   * You can use the input to send a input string to be compiled instead of
   * a file path, note that you must only use [path] OR [input] you will get
   * an error if you try to use both.
   */
  String input;

  /**
   * Utilize the Stylus plugins
   */
  List<String> use;

  /**
   * Utilize image inlining via data URI support
   */
  bool inlineImages;

  /**
   * Compress output css
   */
  bool compress;

  /**
   * Display input along with output
   */
  bool compare;

  /**
   * Emits debug infos in the generated CSS that can be used by the FireStylus
   * Firebug plugin
   */
  bool firebug;

  /**
   * Emits comments in the generated CSS indicating the corresponding Stylus
   * line
   */
  bool lineNumbers;

  /**
   * Include regular CSS on @import
   */
  bool includeCss;

  /**
   * Resolve relative urls inside imports
   */
  bool resolveUrls;

  StylusOptions({
    this.path,
    this.input,
    this.use,
    this.inlineImages: false,
    this.compress:     false,
    this.compare:      false,
    this.firebug:      false,
    this.lineNumbers:  false,
    this.includeCss:   false,
    this.resolveUrls:  false});

  List<String> get args {
    _validate();

    var builder = new List<String>();

    if (use != null) {
      builder.add('--use');
      builder.addAll(use);
    }

    if (inlineImages) builder.add('--inline');
    if (compress)     builder.add('--compress');
    if (compare)      builder.add('--compare');
    if (firebug)      builder.add('--firebug');
    if (lineNumbers)  builder.add('--line-numbers');
    if (resolveUrls)  builder.add('--resolve-url');

    if (path != null) builder.addAll(['--print', path]);

    return builder;
  }

  StylusOptions get copy => new StylusOptions(
      path: path,
      input: input,
      use: use == null ? null : new List.from(use),
      inlineImages: inlineImages,
      compress: compress,
      compare: compare,
      firebug: firebug,
      lineNumbers: lineNumbers);

  void _validate() {
    if (path == null && input == null)
      throw new ArgumentError("You need to send at least a 'path' or 'input'");

    if (path != null && input != null)
      throw new ArgumentError("You can to send 'path' OR 'input' but not both");
  }
}