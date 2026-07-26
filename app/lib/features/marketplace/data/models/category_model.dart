import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable(createToJson: false)
class CategoryModel {
  CategoryModel({required this.id, required this.name, required this.slug, this.iconName, this.parentId});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  final String id;
  final String name;
  final String slug;
  final String? iconName;
  final String? parentId;

  CategoryEntity toEntity() => CategoryEntity(id: id, name: name, slug: slug, iconName: iconName, parentId: parentId);
}
