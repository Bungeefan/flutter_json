# Flutter JSON

Flutter JSON allows you to beautifully render any valid JSON as an interactive hierarchical tree
structure in your app. It supports lazy rendering of children for improved
performance, and offers extensive customization options for styling and appearance.

## Features

* Supports rendering any valid JSON.
* Lazily renders the tree structure for improved performance.
* Offers fast and easy navigation of large and complex JSON structures through the use of indexes,
  allowing for quick expanding and collapsing of nodes even deep in the structure.
* Customizable appearance options include initial expand depth, icons for expanded/collapsed state,
  indent for each node, font style and weight, and color scheme.
* Supports hiding values for specified keys.
* Supports large JSONs without any performance impacts, tested with up to 25 MB.

## Usage

To use the JSON widget in your app, import the package and create a `JsonWidget`
with your desired JSON input and appearance settings.

```dart
import 'package:flutter_json/flutter_json.dart';

const String jsonString = '{ "foo": "bar", "baz": [1, 2, 3] }';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON Example"),
      ),
      body: JsonWidget(
        json: json.decode(jsonString),
        initialExpandDepth: 2,
        hiddenKeys: const ["foo"],
      ),
    );
  }
}
```

## Customization

The JSON Tree Widget offers extensive customization options for appearance and styling. Here are
some of the available properties:

* `json`: The input JSON to render as a tree.
* `initialExpandDepth`: The initial depth to which nodes are expanded.
* `expandIcon`: The icon used for expanded nodes. Defaults to a chevron icon.
* `collapseIcon`: The icon used for collapsed nodes. Defaults to a chevron icon.
* `nodeIndent`: The amount of indentation to use for each node.
* `additionalLeafIndent`: The amount of indentation to use for leaf nodes (no children).
* `fontStyle`: The font style to use for all text in the widget.
* `fontWeight`: The font weight to use for all text in the widget.
* `hiddenKeys`: A list of keys to hide in the tree. Values for these keys will not be displayed.
* Various color parameters for different data types.

For a complete list of available properties, please refer to the
[documentation](https://pub.dev/documentation/flutter_json/latest/).

## Current Limitations (due to lazy loading)

* Requires a bounded height.
* Forces fixed-width constraints for nodes to allow horizontal scrolling.

## Planned improvements

* Expose a widget version which returns a SliverList.
* Incorporate the upcoming TwoDimensionalScrollable.

## Additional information

If you have any questions or issues with the library, please don't hesitate to open an issue on
GitHub. Contributions are always welcome, so feel free to submit a pull request if you have any
improvements or bug fixes to share.

## Acknowledgments

Inspired by [cr_json_widget](https://github.com/Cleveroad/cr_json_widget).
