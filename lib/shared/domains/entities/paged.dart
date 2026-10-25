import 'package:equatable/equatable.dart';

/// One page of a list; [hasMore] = a full page came back, so ask for the next.
class Paged<T> extends Equatable {
  const Paged({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;

  static const pageSize = 20;

  @override
  List<Object?> get props => [items, hasMore];
}
