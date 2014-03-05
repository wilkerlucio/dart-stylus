Dart Stylus Compiler
==============

[![Build Status](https://drone.io/github.com/wilkerlucio/dart-stylus/status.png)](https://drone.io/github.com/wilkerlucio/dart-stylus/latest)

[Stylus](http://learnboost.github.io/stylus/) compiler wrapper for Dart.

Install
-------

Just add to your `pubspec.yaml`:

```yaml
dependencies:
  stylus: any
```

You also gonna need to have `stylus` command into your path. To install stylus, run (you must have [Node](http://nodejs.org/) and [NPM](https://npmjs.org/) installed before):
```
npm install -g stylus
```

Usage
-----

Use StylusProcess to compile Stylus code into CSS, the easiest
way to call is by using the [start] method:

```dart
import 'package:stylus/stylus.dart';

StylusProcess.start(new StylusOptions(path: 'file.styl')).pipe(new File('output.css').openWrite());
```

As you can see, the [start] returns a [Stream] that you can use to pipe
strait on the result.

You can also compile from a [String]:

```dart
import 'dart:convert';
import 'package:stylus/stylus.dart';

var input = '''
  body
    .class
      .internal
        color: blue
''';

StylusProcess.start(new StylusOptions(input: input)).pipe(new File('output.css').openWrite());
```

And finally, a tip on how to get the compiled content as [String]

```dart
import 'dart:convert';
import 'package:stylus/stylus.dart';

StylusProcess.start(new StylusOptions(path: 'app.styl')).transform(ASCII.decoder).single.then((String css) {
  print(css); // body .class .internal { color: #00f; }
});
```

There are many other options that you can send to [StylusOptions] to configure
the compilation, check the constructor arguments at [StylusOptions](https://github.com/wilkerlucio/dart-stylus/blob/master/lib/src/stylus/stylus_options.dart#L7-L59)

Compiler on Editor Build
------------------------

We also provide a build helper if you wanna your `.styl` files to automatic compile to `.css` on save using Dart Editor, to setup that you gonna need to create a file called `build.dart` on your project root (if you don't have it already), having it, just base the setup on the following example:

```dart
import 'package:stylus/stylus.dart';

void main(List<String> args) {
  buildStylus(args);
}
```

You can provide custom options if you want:

```dart
import 'package:stylus/stylus.dart';

void main(List<String> args) {
  buildStylus(args, new StylusOptions(use: ['nib'], lineNumbers: true, includeCss: true, compress: true));
}
```

Transformer in a Pub build
--------------------------

If you're using pub build or pub serve for your application, you can use the [StylusTransformer]
to generate .css from .styl or .stylus files.  It will also replace <style> tags with a type of
"text/stylus" with compiled CSS.

To add the transformer to your build:

```
dependencies:
    ...
    stylus: any
    ...
transformers:
- stylus
```

You can also pass through any valid option in [StylusOptions], eg:

```
dependencies:
    ...
    stylus: any
    ...
transformers:
- stylus:
    compress: true
```