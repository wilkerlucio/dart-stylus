part of stylus.transformer;

const String STYLUS_MEDIA_TYPE = "text/stylus";
const String CSS_MEDIA_TYPE = "text/css";

/**
 * This transformer will parse HTML assets and compile any <style> tags within them that
 * have a type="text/stylus".  It replaces the body of the style tag with the compiled
 * CSS and change the type to "text/css".
 */
class StylusHtmlTransformer extends Transformer with DeclaringTransformer {

  final StylusOptions protoOptions;

  StylusHtmlTransformer(StylusOptions this.protoOptions);

  String get allowedExtensions => ".html";

  @override
  Future apply(Transform transform) =>
      _readPrimaryAsHtml(transform).then((doc) =>
            Future.wait(
              extractStylusTags(doc).map((elem) => 
                compileStylusBlock(protoOptions.copyWith(input: elem.text))
                .then((css) { updateElement(elem, css); })
                .catchError((e) => transform.logger.error(e.toString(), span: elem.sourceSpan))
              )
            )
            .then((_) { transform.addOutput(new Asset.fromString(transform.primaryInput.id, doc.outerHtml)); })
        );

  @override
  Future declareOutputs(DeclaringTransform transform) {
    return new Future.sync(() {
      transform.declareOutput(transform.primaryInput.id);
    });
  }

}

List<Element> extractStylusTags(Document doc) => 
    doc.querySelectorAll("style").where((e) => STYLUS_MEDIA_TYPE == e.attributes["type"]);

Future<String> compileStylusBlock(StylusOptions options) => 
    UTF8.decodeStream(StylusProcess.start(options));

void updateElement(Element elem, String css) {
  elem.attributes["type"] = CSS_MEDIA_TYPE;
  elem.text = css;
}

// Shamelessly stolen from polymer.dart

/**
 * Parses an HTML file [contents] and returns a DOM-like tree. Adds emitted
 * error/warning to [logger].
 */
Document _parseHtml(String contents, String sourcePath, TransformLogger
    logger, {bool checkDocType: true, String encoding: 'utf8'}) {

  var parser = new HtmlParser(contents, encoding: encoding, generateSpans: true,
      sourceUrl: sourcePath);
  var document = parser.parse();

  // Note: errors aren't fatal in HTML (unless strict mode is on).
  // So just print them as warnings.
  for (var e in parser.errors) {
    if (checkDocType || e.errorCode != 'expected-doctype-but-got-start-tag') {
      logger.warning(e.message, span: e.span);
    }
  }
  return document;
}

Future<Document> _readPrimaryAsHtml(Transform transform) {
  var asset = transform.primaryInput;
  var id = asset.id;
  return asset.readAsString().then((content) {
    return _parseHtml(content, id.path, transform.logger);
  });
}
