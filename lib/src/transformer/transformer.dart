part of stylus.transformer;

/**
 * A Transformer that will scan all .styl files and transform them into CSS.  It
 * will also scan HTML files and find any <style> blocks with type="text/stylus" and transform those
 * as well.  Note that at the moment the block can not have any indentation.
 *
 * For example, this will work:
 *     <head>
 *         <style type="text/stylus">
 *     h1
 *       color red
 *         </style>
 *     </head>
 * 
 *
 * However, the following will not:
 *  
 *     <head>
 *         <style type="text/stylus">
 *         h1
 *          color red
 *         </style>
 *     </head>
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