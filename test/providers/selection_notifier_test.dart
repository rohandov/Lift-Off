import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/features/library/library_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('toggle adds when absent', () {
    container.read(selectionProvider.notifier).toggle(1);
    expect(container.read(selectionProvider), [1]);
  });

  test('toggle removes when present', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.toggle(1);
    expect(container.read(selectionProvider), [2]);
  });

  test('toggle preserves pick order', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(3);
    notifier.toggle(1);
    notifier.toggle(2);
    expect(container.read(selectionProvider), [3, 1, 2]);
  });

  test('reorder moves an item', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.toggle(3);
    notifier.reorder(0, 2);
    expect(container.read(selectionProvider), [2, 1, 3]);
  });

  test('clear empties the selection', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.clear();
    expect(container.read(selectionProvider), isEmpty);
  });
}
