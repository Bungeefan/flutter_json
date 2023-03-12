import 'package:flutter/widgets.dart';
import 'package:flutter_json/src/json_widget.dart';

/// A controller for the [JsonWidget] widget.
class JsonController {
  final ChangeNotifier _expandAll = ChangeNotifier();
  final ChangeNotifier _collapseAll = ChangeNotifier();

  Listenable get expandNotifier => _expandAll;

  Listenable get collapseNotifier => _collapseAll;

  /// Expands all nodes.
  ///
  /// Calling this will notify all the listeners.
  void expandAllNodes() {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _expandAll.notifyListeners();
  }

  /// Collapses all nodes.
  ///
  /// Calling this will notify all the listeners.
  void collapseAllNodes() {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _collapseAll.notifyListeners();
  }

  /// Discards any resources used by the object.
  void dispose() {
    _expandAll.dispose();
    _collapseAll.dispose();
  }
}
