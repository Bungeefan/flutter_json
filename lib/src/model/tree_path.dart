import 'package:flutter_json/flutter_json.dart';

/// Represents the immutable path to a node in the json tree.
///
/// Example path: `[0, 15, 3, 5]`
///
/// See also:
/// * [JsonWidgetState.getNodeByPath]
class TreePath {
  final List<int> path;

  TreePath(this.path) {
    assert(path.isNotEmpty, "Path cannot be empty");
  }

  /// Whether this path has a parent.
  bool canGoUp() {
    return path.length > 1;
  }

  /// Returns a new path that points to the parent.
  TreePath? up() {
    if (canGoUp()) {
      return TreePath(List.from(path)..removeLast());
    }
    return null;
  }

  /// Returns a new path that points to the next sibling.
  TreePath nextSibling() {
    List<int> newPath = List.from(path);
    // Increment last part
    newPath.last = newPath.last + 1;
    return TreePath(newPath);
  }

  @override
  String toString() {
    return path.toString();
  }
}
