part of stylus.transformer;

/**
 * The Stylus transformer.  This transformer will look for assets with extension
 * .styl or .stylus and compile them with Stylus into the corresponding .css file.
 */
class StylusCssTransformer extends Transformer with DeclaringTransformer {

  final StylusOptions protoOptions;

  StylusCssTransformer(StylusOptions this.protoOptions);

  String get allowedExtensions => ".styl";

  @override
  Future apply(Transform transform) =>
      transform.primaryInput.readAsString().then((input) {
        UTF8.decodeStream(StylusProcess.start(protoOptions.copyWith(input: input)))
        .then((css) { transform.addOutput(new Asset.fromString(_calculateCssAssetId(transform.primaryInput.id), css)); } )
        .catchError((e) { transform.logger.error(e.toString()); });
      });

  @override
  Future declareOutputs(DeclaringTransform transform) =>
      new Future.sync(() {
        transform.declareOutput(_calculateCssAssetId(transform.primaryInput.id));
      });

}

/**
 * Create a new [AssetId] for the given [assetId] with it's extension changed to .css
 */
AssetId _calculateCssAssetId(AssetId assetId) =>
    new AssetId(assetId.package, replaceLast(assetId.path, assetId.extension, ".css"));

/**
 * Replace the last occurence of [from] in [string] with [replace]
 */
String replaceLast(String string, Pattern from, String replace) =>
    string.substring(0, string.lastIndexOf(from)) + replace;
