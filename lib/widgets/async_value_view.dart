import 'package:flutter/material.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.snapshot,
    required this.builder,
    super.key,
  });

  final AsyncSnapshot<T> snapshot;
  final Widget Function(T value) builder;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No se pudieron cargar los datos:\n${snapshot.error}'),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    return builder(snapshot.data as T);
  }
}
