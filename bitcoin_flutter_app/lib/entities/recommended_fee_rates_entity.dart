import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class RecommendedFeeRatesEntity extends Equatable {
  final double highPriority;
  final double mediumPriority;
  final double lowPriority;
  final double noPriority;

  const RecommendedFeeRatesEntity({
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.noPriority,
  });

  @override
  List<Object> get props => [
        highPriority,
        mediumPriority,
        lowPriority,
        noPriority,
      ];
}
