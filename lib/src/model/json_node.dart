import 'tree_path.dart';
import 'value_type.dart';

class JsonNode {
  // String or int
  final dynamic key;
  final dynamic value;
  final ValueType type;
  final int depth;
  bool expanded;

  JsonNode({
    this.key,
    required this.value,
    required this.type,
    this.expanded = false,
    this.depth = 0,
  });

  bool get isExpandable =>
      [ValueType.array, ValueType.object].contains(type) &&
      value is List &&
      value.length > 0;

  dynamic toJson() {
    if (type == ValueType.object) {
      return {
        for (var node in value) node.key: node,
      };
    }
    if (type == ValueType.array) {
      return [
        for (var node in value) node,
      ];
    }
    return value;
  }

  String toPrettyString() {
    if (key == null) {
      if (value is List) {
        return "$value\n";
      }
      return "$value";
    }
    String val;
    if (value is List) {
      val = "\n\t$value";
    } else {
      val = "$value";
    }
    return "\n$key: $val";
  }

  @override
  String toString() {
    return 'JsonNode{key: $key, value: ${value.runtimeType}, depth: $depth, expanded: $expanded}';
  }

  /// Collects all children and their children.
  ///
  /// [collectOnlyExpanded] controls if [expanded] is taken into account.
  List<JsonNode> collectChildren([bool collectOnlyExpanded = false]) {
    List<JsonNode> nodes = [];
    if (value is List && (!collectOnlyExpanded || expanded)) {
      for (var subNode in value) {
        nodes.add(this);
        nodes.addAll(subNode.collectChildren(collectOnlyExpanded));
      }
    }
    return nodes;
  }

  /// Collects indices from all sub nodes.
  ///
  /// This takes [expanded] into account!
  List<TreePath> getSubIndices(
    TreePath parentPath, [
    TreePath? targetPath,
  ]) {
    List<TreePath> paths = [];
    if (value is List && expanded) {
      for (int i = 0; i < value.length; i++) {
        JsonNode subNode = value[i];
        TreePath subPath = TreePath([...parentPath.path, i]);
        paths.add(subPath);
        if (targetPath == null || subPath != targetPath) {
          paths.addAll(subNode.getSubIndices(subPath, targetPath));
        } else {
          break;
        }
      }
    }
    return paths;
  }
}
