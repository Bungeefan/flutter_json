import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'json_controller.dart';
import 'json_node_widget.dart';
import 'json_parser.dart';
import 'model/json_node.dart';
import 'model/tree_path.dart';
import 'model/value_type.dart';

typedef JsonNodeWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  JsonNode node,
  Widget child,
);

typedef JsonErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// A widget that renders JSON data as an interactive hierarchical tree structure.
///
/// The JSON data is parsed into a tree structure and rendered as a list of nested
/// [JsonNodeWidget] widgets. The tree is built lazily, so only visible children are
/// rendered at any given time for improved performance. The appearance of the tree
/// can be customized using various properties.
///
/// Example usage:
///
/// ```dart
/// JsonWidget(
///   json: json,
///   initialExpandDepth: 2,
///   hiddenKeys: ["hiddenKey"],
/// )
/// ```
class JsonWidget extends StatefulWidget {
  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// Controller to expand or collapse nodes.
  final JsonController? controller;

  /// The JSON object to display.
  final dynamic json;

  /// {@macro node.hiddenKeys}
  final List<String> hiddenKeys;

  /// Called when the user double-taps a node.
  final void Function(JsonNode node)? onDoubleTap;

  /// Called when the user long-presses a node.
  final void Function(JsonNode node)? onLongPress;

  /// Which nodes should be initially expanded.
  ///
  /// -1 expands all nodes by default.
  final int initialExpandDepth;

  /// Widget used by the node to display the expanded state.
  final Widget expandIcon;

  /// Widget used by the node to display the collapsed state.
  final Widget collapseIcon;

  /// Minimum height for each single node.
  final double minNodeHeight;

  /// {@macro node.nodeIndent}
  final double nodeIndent;

  /// {@macro node.additionalLeafIndent}
  final double additionalLeafIndent;

  /// The FontStyle used for the nodes (e.g. italics).
  final FontStyle? fontStyle;

  /// The FontWeight used for the nodes (e.g. bold).
  final FontWeight fontWeight;

  /// {@macro node.keyColor}
  ///
  /// Defaults to [ColorScheme.primary].
  final Color? keyColor;

  /// {@macro node.numColor}
  final Color numColor;

  /// {@macro node.stringColor}
  final Color stringColor;

  /// {@macro node.boolColor}
  final Color boolColor;

  /// {@macro node.arrayColor}
  final Color arrayColor;

  /// {@macro node.objectColor}
  final Color objectColor;

  /// {@macro node.noneColor}
  final Color noneColor;

  /// {@macro node.hiddenColor}
  final Color hiddenColor;

  /// {@macro node.nodeBuilder}
  final JsonNodeWidgetBuilder? nodeBuilder;

  /// A builder that specifies the widget shown while loading the json.
  final WidgetBuilder? loadingBuilder;

  /// A builder that is called if an error occurred while loading the json.
  final JsonErrorWidgetBuilder? errorBuilder;

  /// Creates a [JsonWidget].
  JsonWidget({
    super.key,
    this.primary,
    this.physics,
    this.controller,
    this.json,
    List<String> hiddenKeys = const [],
    this.onDoubleTap,
    this.onLongPress,
    this.initialExpandDepth = -1,
    this.expandIcon = const Icon(Icons.keyboard_arrow_down),
    this.collapseIcon = const Icon(Icons.keyboard_arrow_right),
    this.minNodeHeight = 32.0,
    this.nodeIndent = 10.0,
    this.additionalLeafIndent = 24.0,
    this.fontStyle,
    this.fontWeight = FontWeight.bold,
    this.keyColor,
    this.numColor = const Color(0xFF199B4D),
    this.stringColor = const Color(0xFFCD44D9),
    this.boolColor = Colors.orange,
    this.arrayColor = Colors.grey,
    this.objectColor = Colors.grey,
    this.noneColor = Colors.grey,
    this.hiddenColor = const Color(0xFFBB5BC3),
    this.nodeBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : hiddenKeys = hiddenKeys.map((e) => e.toLowerCase()).toList();

  @override
  State<JsonWidget> createState() => _JsonWidgetState();
}

class _JsonWidgetState extends State<JsonWidget>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  late JsonNode root;
  late int maxDepth;

  late Future<void> future;
  final List<TreePath> indices = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.controller?.expandNotifier.addListener(_expandAll);
    widget.controller?.collapseNotifier.addListener(_collapseAll);
    _processJson();
  }

  @override
  void didUpdateWidget(covariant JsonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      widget.controller?.expandNotifier.removeListener(_expandAll);
      widget.controller?.collapseNotifier.removeListener(_collapseAll);
      widget.controller?.expandNotifier.addListener(_expandAll);
      widget.controller?.collapseNotifier.addListener(_collapseAll);
    }
    if (widget.json != oldWidget.json) {
      _processJson();
    }
  }

  @override
  void dispose() {
    widget.controller?.expandNotifier.removeListener(_expandAll);
    widget.controller?.collapseNotifier.removeListener(_collapseAll);
    super.dispose();
  }

  /// Collects all children and updates the expanded state.
  ///
  /// Searches for the first collapsed node
  /// and drops every index after this node.
  void _expandAll() {
    List<JsonNode> list = root.collectChildren();
    bool firstIndexFound = false;
    for (int i = 0; i < list.length; i++) {
      var node = list[i];
      if (!firstIndexFound && !node.expanded) {
        firstIndexFound = true;

        // Drop indices higher than this index.
        indices.removeRange(math.min(indices.length, i + 1), indices.length);
      }
      node.expanded = true;
    }
    setState(() {});
  }

  /// Collects all children and updates the expanded state.
  ///
  /// This method simply drops all indices.
  void _collapseAll() {
    root.collectChildren().forEach((node) => node.expanded = false);
    indices.clear();
    setState(() {});
  }

  void _processJson() {
    indices.clear();
    future = compute<Map<String, Object>, Map<String, dynamic>>(
      (args) => JsonParser().parseTree(args),
      {
        "json": widget.json,
        "initialDepth": widget.initialExpandDepth,
      },
    ).then((value) {
      root = value["tree"];
      maxDepth = value["maxDepth"];
    }).catchError((error, stackTrace) {
      log("Failed to compute json", error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  /// Creates indices for the [JsonNode]s in [root].
  ///
  /// The system works like the following:
  ///
  /// When the itemBuilder asks for a new child it first fills
  /// the index list to meet the required index.
  ///
  /// Then it retrieves the requested node via the index (fast).
  /// See also: [getNodeByPath].
  ///
  /// The index cache is built and kept in memory
  /// as long as the model doesn't change and
  /// no expansion or a contraction happens.
  void fillIndices(int? targetIndex) {
    if (indices.isEmpty) {
      // Add root node.
      indices.add(TreePath([0]));
    }

    TreePath startingPoint = indices.last;
    while (targetIndex == null || indices.length <= targetIndex) {
      JsonNode? node = getNode(startingPoint.path);

      if (node != null) {
        if (startingPoint != indices.last) {
          indices.add(startingPoint);
        }
        if (node.value is List && node.value.isNotEmpty && node.expanded) {
          var treePath = TreePath(List.from(startingPoint.path)..add(0));
          startingPoint = treePath;
          continue;
        } else {
          startingPoint = startingPoint.nextSibling();
        }
      } else {
        if (startingPoint.canGoUp()) {
          startingPoint = startingPoint.up()!.nextSibling();
        } else {
          break;
        }
      }
    }
  }

  /// Modifies the indices on node change.
  ///
  /// If expansion happens, build needed indexes and insert into index.
  /// (handled by [fillIndices])
  /// If contraction happens, just drop after the node where the index/path
  /// is longer than the next sibling/parent.
  ///
  /// Example:
  /// 1. Path [0, 0] collapses
  /// 2. Remove every index from the list after [0, 0] where path length > 2 (e.g. [0, 0, 1]).
  void _modifyIndices(
    int index,
    TreePath nodePath,
    JsonNode node,
    bool expanded,
  ) {
    if (!expanded) {
      // Drop indices higher that this index but lower than the next sibling.
      int? removeTo;
      for (int i = index + 1; i < indices.length; i++) {
        if (indices[i].path.length <= nodePath.path.length) {
          removeTo = i;
          break;
        }
      }
      if (removeTo != null) {
        indices.removeRange(math.min(indices.length, index + 1), removeTo);
      } else {
        indices.removeRange(
            math.min(indices.length, index + 1), indices.length);
      }
    } else {
      // Re-insert children indices after the parent.
      if (index + 1 < indices.length) {
        indices.insertAll(
            index + 1, node.getSubIndices(nodePath, indices[index + 1]));
      }
    }
  }

  JsonNode? getNode(List<int> path) {
    return getNodeByPath(JsonNode(value: [root], type: ValueType.array), path);
  }

  /// Retrieves a node via its path.
  ///
  /// Example index: [0, 15, 3, 5]
  ///
  /// Which gets resolved like this:
  /// * Take the nought (0) element from the top node (root).
  /// * Then take its 15th child and use it as new node.
  /// * Then take its 3rd child and again use it as new node.
  /// * Finally take its 5th child.
  static JsonNode? getNodeByPath(JsonNode root, List<int> path) {
    var node = root;
    for (int index in path) {
      if (node.value is List && index < node.value.length) {
        node = node.value[index];
      } else {
        return null;
      }
    }
    return node;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontStyle: widget.fontStyle,
        fontWeight: widget.fontWeight,
      ),
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            Widget child = Center(
              child: snapshot.hasError
                  ? widget.errorBuilder?.call(
                          context, snapshot.error!, snapshot.stackTrace!) ??
                      const Text("Error while analyzing the json")
                  : widget.loadingBuilder?.call(context) ??
                      const CircularProgressIndicator.adaptive(),
            );
            return child;
          }

          return LayoutBuilder(builder: (context, constraints) {
            return Scrollbar(
              controller: _scrollController,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                physics: widget.physics,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(
                      constraints.maxWidth,
                      widget.nodeIndent * maxDepth +
                          widget.additionalLeafIndent +
                          750),
                  child: CustomScrollView(
                    primary: widget.primary,
                    physics: widget.physics,
                    // https://github.com/flutter/flutter/issues/52681
                    // scrollBehavior: ScrollConfiguration.of(context)
                    //     .copyWith(scrollbars: true),
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          _buildNode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget? _buildNode(BuildContext context, int index) {
    // Fill indices until given index.
    fillIndices(index);
    if (index >= indices.length) {
      return null;
    }
    // Retrieve node via indices.
    final TreePath nodePath = indices[index];
    JsonNode node = getNode(nodePath.path)!;

    return JsonNodeWidget(
      index: index,
      node: node,
      hiddenKeys: widget.hiddenKeys,
      onDoubleTap: widget.onDoubleTap != null
          ? () => widget.onDoubleTap?.call(node)
          : null,
      onLongPress: widget.onLongPress != null
          ? () => widget.onLongPress?.call(node)
          : null,
      onToggle: (expanded) => setState(() {
        _modifyIndices(index, nodePath, node, expanded);
      }),
      minHeight: widget.minNodeHeight,
      nodeIndent: widget.nodeIndent,
      additionalLeafIndent: widget.additionalLeafIndent,
      expandIcon: widget.expandIcon,
      collapseIcon: widget.collapseIcon,
      keyColor: widget.keyColor ?? Theme.of(context).colorScheme.primary,
      numColor: widget.numColor,
      stringColor: widget.stringColor,
      boolColor: widget.boolColor,
      arrayColor: widget.arrayColor,
      objectColor: widget.objectColor,
      noneColor: widget.noneColor,
      hiddenColor: widget.hiddenColor,
      nodeBuilder: widget.nodeBuilder,
    );
  }
}
