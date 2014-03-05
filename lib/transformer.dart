library stylus.transformer;

import 'dart:async';
import 'dart:convert';

import 'package:barback/barback.dart';
import 'package:html5lib/dom.dart' show Document, Element;
import 'package:html5lib/parser.dart' show HtmlParser;

import 'stylus.dart';

const String STYLUS_MEDIA_TYPE = "text/stylus";

/**
 * A Transformer that will scan all .styl and .stylus files and transform them into CSS.  It
 * will also scan HTML files and find any <style> blocks with type="text/stylus" and transform those
 * as well.  Note that at the moment the block can not have any indentation.
 *
 * eg
 *     <head>
 *         <style type="text/stylus">
 *     h1
 *       color red
 *         </style>
 *     </head>
 *
 *  will work, however, the following will not:
 *
 *      <head>
 *          <style type="text/stylus">
 *          h1
 *            color red
 *          </style>
 *      </head>
 */
class StylusTransformer extends TransformerGroup {

  StylusTransformer(StylusOptions options) : super(_createDeployPhases(options));

  StylusTransformer.asPlugin(BarbackSettings settings) : this(new StylusOptions.fromMap(settings.configuration));

}

List<List<Transformer>> _createDeployPhases(StylusOptions options) {
  return [
          [new StylusCssTransformer(options)],
          [new StylusHtmlTransformer(options)]
         ];
}

/**
 * The Stylus transformer.  This transformer will look for assets with extension
 * .styl or .stylus and compile them with Stylus into the corresponding .css file.
 */
class StylusCssTransformer extends Transformer with DeclaringTransformer {

  final StylusOptions protoOptions;

  StylusCssTransformer(StylusOptions this.protoOptions);

  String get allowedExtensions => ".styl .stylus";

  @override
  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((input) {

      transform.addOutput(new Asset.fromStream(_calculateCssAssetId(
          transform.primaryInput.id), StylusProcess.start(protoOptions.copyWith(input:
          input)).handleError((e) => transform.logger.error(e.toString()))));

    });
  }

  @override
  Future declareOutputs(DeclaringTransform transform) {
    return new Future.sync(() {
      transform.declareOutput(_calculateCssAssetId(transform.primaryInput.id));
    });
  }

}

/**
 * This transformer will parse HTML assets and compile any <style> tags within them that
 * have a type="text/stylus".  It replaces the body of the style tag with the compiled
 * CSS and change the type to "text/css"
 */
class StylusHtmlTransformer extends Transformer with DeclaringTransformer {

  final StylusOptions protoOptions;

  StylusHtmlTransformer(StylusOptions this.protoOptions);

  String get allowedExtensions => ".htm .html";

  @override
  Future apply(Transform transform) {
    return _readPrimaryAsHtml(transform).then((var doc) {
      var elements = doc.querySelectorAll("style"); // only type selectors are implemented, so can't use [type="text/stylus"]
      var cssTransforms = new List<Future>();
      for (final Element elem in elements) {
        if ("text/stylus" == elem.attributes["type"]) {
          cssTransforms.add(UTF8.decodeStream(StylusProcess.start(
              protoOptions.copyWith(input: elem.text))).then((css) {
            elem.attributes["type"] = "text/css";
            elem.text = css;
          }).catchError((e) => transform.logger.error(e.toString(), span: elem.sourceSpan)));
        }
      }
      return Future.wait(cssTransforms).then((_) {
        transform.addOutput(new Asset.fromString(transform.primaryInput.id, doc.outerHtml));
      });
    });
  }

  @override
  Future declareOutputs(DeclaringTransform transform) {
    return new Future.sync(() {
      transform.declareOutput(transform.primaryInput.id);
    });
  }

}

AssetId _calculateCssAssetId(AssetId assetId) => new AssetId(assetId.package,
    assetId.path.replaceAll(assetId.extension, ".css")); // TODO Only replace extension

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
