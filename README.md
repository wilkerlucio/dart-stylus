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

To compile Stylus code to CSS is actually pretty easy, an example is better than words for this one:

```dart
import 'package:stylus/stylus.dart';

Stylus.fromPath('file.styl').pipe(new File('output.css').openWrite());
```

You can also compiling from a `String`

```dart
import 'dart:convert';
import 'package:stylus/stylus.dart';

var input = '''
  body
    .class
      .internal
        color: blue
''';

Stylus.fromString('file.styl').transform(ASCII.decoder).single.then((String css) {
  print(css); // body .class .internal { color: #00f; }
});
```

Compiler on Editor Build
------------------------

We also provide a build helper if you wanna your `.styl` files to automatic compile to `.css` on save using Dart Editor, to setup that you gonna need to create a file called `build.dart` on your project root (if you don't have it already), having it, just base the setup on the following example:

```dart
import 'package:stylus/stylus.dart'

void main(List<String> args) {
  buildStylus(args);
}
```
