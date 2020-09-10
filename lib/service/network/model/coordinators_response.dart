import 'pagination.dart';
import 'coordinator.dart';

class CoordinatorsResponse {
  final List<Coordinator> coordinators;
  final Pagination pagination;

  CoordinatorsResponse({this.coordinators, this.pagination});

  factory CoordinatorsResponse.fromJson(Map<String, dynamic> json) {
    return CoordinatorsResponse(
        coordinators: json['coordinators'],
        pagination: json['pagination']);
  }

  Map<String, dynamic> toJson() => {
    'coordinators': coordinators,
    'pagination': pagination,
  };

}
