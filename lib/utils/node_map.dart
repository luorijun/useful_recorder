import 'dart:collection';

import 'package:flutter/material.dart';

typedef K KeyGetter<K, V>(Node<V> node);

class NodeMap<K, V> extends IterableMixin<Node<V>> {
  final Map<K, Node<V>> data;
  final Comparator<K> comparator;
  final KeyGetter<K, V> getKey;

  Node<V> first;
  Node<V> last;

  int get length => data.length;

  bool get isEmpty => data.isEmpty;

  NodeMap({@required this.comparator, @required this.getKey}) : data = {};

  Node<V> operator [](K key) => data[key];

  void operator []=(K key, Node<V> value) => data[key] = value;

  void set(K key, V value) {
    data[key].value = value;
  }

  void add(K key, V value, [Order order = Order.desc]) {
    var next = order == Order.desc ? _findDesc(key) : _findAsc(key);
    next != null ? addBefore(key, value, next) : addAfter(key, value, last);
  }

  Node<V> _findDesc(K key) => firstWhere(
        (node) => comparator.call(key, getKey.call(node)) > -1,
        orElse: () => null,
      );

  Node<V> _findAsc(K key) => firstWhere(
        (node) => comparator.call(key, getKey.call(node)) > -1,
        orElse: () => null,
      );

  void addBefore(K key, V value, Node<V> next) {
    final node = Node(value);

    if (isEmpty) {
      _addRoot(key, node.value);
      return;
    }

    final prev = next.prev;
    if (prev == null) {
      first = node;
    } else {
      node.prev = prev;
      prev.next = node;
    }

    node.next = next;
    next.prev = node;

    data[key] = node;

    // log("first: ${first.value}");
    // this.forEach((element) {
    //   log("${element.value}");
    // });
    // log("last: ${last.value}");
    // log("==============================");
  }

  void addAfter(K key, V value, Node<V> prev) {
    final node = Node(value);

    if (isEmpty) {
      _addRoot(key, node.value);
      return;
    }

    final next = prev.next;
    if (next == null) {
      last = node;
    } else {
      node.next = next;
      next.prev = node;
    }

    node.prev = prev;
    prev.next = node;

    data[key] = node;

    // log("first: ${first.value}");
    // this.forEach((element) {
    //   log("${element.value}");
    // });
    // log("last: ${last.value}");
    // log("==============================");
  }

  void _addRoot(K key, V value) {
    data[key] = Node(value);
    first = data[key];
    last = data[key];
  }

  void remove(K key) {
    final node = data[key];

    if (node.prev != null)
      node.prev.next = node.next;
    else
      first = node.next;

    if (node.next != null)
      node.next.prev = node.prev;
    else
      last = node.prev;

    data.remove(key);
  }

  has(K key) => data.containsKey(key);

  @override
  NodeMapIterator<K, V> get iterator => NodeMapIterator<K, V>(first);
}

class NodeMapIterator<K, V> implements Iterator<Node<V>> {
  Node<V> _current;

  NodeMapIterator(Node<V> first) {
    _current = Node(null);
    _current.next = first;
  }

  @override
  Node<V> get current => _current;

  @override
  bool moveNext() {
    _current = _current.next;
    return _current != null;
  }
}

class Node<T> {
  T value;
  Node<T> prev;
  Node<T> next;

  Node(this.value);

  @override
  String toString() {
    return 'Node{value: $value, prev: ${prev?.value}, next: ${next?.value}';
  }
}

enum Order { desc, asc }
