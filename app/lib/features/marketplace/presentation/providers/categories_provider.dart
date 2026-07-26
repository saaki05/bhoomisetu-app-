import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';

part 'categories_provider.g.dart';

@riverpod
Future<List<CategoryEntity>> categories(CategoriesRef ref) async {
  final result = await ref.watch(getCategoriesUseCaseProvider).call();
  return result.fold((failure) => throw failure, (categories) => categories);
}
