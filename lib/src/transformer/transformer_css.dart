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
 * Create a new [AssetId] for the given [assetId] with it's extension changed to .css
 */
AssetId _calculateCssAssetId(AssetId assetId) => new AssetId(assetId.package,
    assetId.path.replaceAll(assetId.extension, ".css")); // TODO Only replace extension