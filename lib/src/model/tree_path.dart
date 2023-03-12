class TreePath {
  final List<int> path;

  TreePath(this.path);

  bool canGoUp() {
    return path.length > 1;
  }

  TreePath? up() {
    if (canGoUp()) {
      return TreePath(List.from(path)..removeLast());
    }
    return null;
  }

  TreePath nextSibling() {
    List<int> newPath = List.from(path);
    // Increment last part
    newPath[newPath.length - 1] = newPath.last + 1;
    return TreePath(newPath);
  }

  @override
  String toString() {
    return path.toString();
  }
}
