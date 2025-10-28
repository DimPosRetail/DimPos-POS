import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/financial_shift.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'financial_shift_repository.g.dart';

@riverpod
FinancialShiftRepository financialShiftRepository(Ref ref) {
  return const FinancialShiftRepository();
}

class FinancialShiftRepository {
  const FinancialShiftRepository();

  Future<void> openShift({
    required double openingCashActual,
    required String openingDifferenceReason,
  }) async {
    await apiClient.getClient(ApiUrl.store).post(
      '/financial-shifts/open',
      data: {
        'openingCashActual': openingCashActual,
        'openingDifferenceReason': openingDifferenceReason,
      },
    );
  }

  Future<void> closeShift() async {
    await apiClient.getClient(ApiUrl.store).put(
          '/financial-shifts/close',
        );
  }

  Future<String?> getFinancialShiftId() async {
    final response = await apiClient.getClient(ApiUrl.store).get(
          '/financial-shifts/opening',
        );
    final financialShiftId = BaseResponse<FinancialShift?>.fromJson(
            response.data,
            (json) => FinancialShift.fromJson(json as Map<String, dynamic>))
        .data
        ?.id;
    return financialShiftId;
  }
}
