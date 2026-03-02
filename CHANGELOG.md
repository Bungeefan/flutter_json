## 0.1.0

* Fixed possible concurrent modifications to the root node and indices during processing.
  Fixes [#5](https://github.com/Bungeefan/flutter_json/issues/5).
* Added getter for `processingFuture`.
* Updated/corrected sdk constraints.

### Breaking changes:

* `JsonWidgetState.rootNode` getter is now nullable.
* `JsonWidgetState.maxDepth` getter is now nullable.
* `JsonWidgetState.getNodePath(int index)` method is now nullable.

## 0.0.6

* Fixed alignment regression after min height fix in `0.0.5`.

## 0.0.5

* Added `nodeBuilder` parameter to allow wrapping individual nodes with custom widgets.
* Fixed `minNodeHeight` (it is now applied more correctly).
* Added `hiddenTextColor` parameter.
* Improved JSON equals check to reduce possibly unnecessary JSON processing passes.
* Fixed incorrect controller handling.
* Added pub.dev `topics`.

## 0.0.4

* Added optional `loadingBuilder` and `errorBuilder` to allow custom loading and error widgets.
* Switched default progress indicator to `adaptive` style.

## 0.0.3

* Added `primary` and `physics` parameter.

## 0.0.2

* Added `onDoubleTap` callback.
* Increased upper sdk constraint to `4.0.0`.

## 0.0.1+1

* Changed sdk constraint to `2.18.0`.

## 0.0.1

* Initial release.
