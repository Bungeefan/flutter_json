import 'package:collection/collection.dart';

import 'model/json_node.dart';
import 'model/value_type.dart';

class JsonParser {
  int maxDepth = 0;

  Future<Map<String, dynamic>> parseTree(Map<String, dynamic> args) async {
    var tree = _buildTree(args["initialDepth"], null, args["json"]);
    return {
      "tree": tree,
      "maxDepth": maxDepth,
    };
  }

  JsonNode _buildTree(
    int initialDepth,
    dynamic key,
    dynamic json, [
    int depth = 0,
  ]) {
    if (depth > maxDepth) {
      maxDepth = depth;
    }

    JsonNode node;
    if (json == null) {
      node = JsonNode(
        key: key,
        value: null,
        type: ValueType.none,
        depth: depth,
      );
    } else if (json is num) {
      node = JsonNode(
        key: key,
        value: json,
        type: ValueType.num,
        depth: depth,
      );
    } else if (json is bool) {
      node = JsonNode(
        key: key,
        value: json,
        type: ValueType.bool,
        depth: depth,
      );
    } else if (json is Iterable || json is Map) {
      final List<JsonNode> nodes = [];
      final ValueType type;
      if (json is Iterable) {
        type = ValueType.array;
        nodes.addAll(
          json.toList().mapIndexed(
                (index, element) =>
                    _buildTree(initialDepth, index, element, depth + 1),
              ),
        );
      } else {
        assert(json is Map);
        type = ValueType.object;
        for (MapEntry entry in json.entries) {
          nodes
              .add(_buildTree(initialDepth, entry.key, entry.value, depth + 1));
        }
      }
      node = JsonNode(
        key: key,
        value: nodes,
        type: type,
        expanded: initialDepth == -1 || depth < initialDepth,
        depth: depth,
      );
    } else {
      node = JsonNode(
        key: key,
        value: json.toString(),
        type: ValueType.string,
        depth: depth,
      );
    }
    // } else {
    //   throw ArgumentError("Unknown JSON type: ${json.runtimeType}");
    // }
    return node;
  }
}
