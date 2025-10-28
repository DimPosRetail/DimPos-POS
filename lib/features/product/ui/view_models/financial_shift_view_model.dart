import 'package:dimpos_store/features/order/repositories/order_repository.dart';
import 'package:dimpos_store/features/product/repositories/financial_shift_repository.dart';
import 'package:dimpos_store/features/product/ui/state/financial_shift_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'financial_shift_view_model.g.dart';

@Riverpod(keepAlive: true)
class FinancialShiftViewModel extends _$FinancialShiftViewModel {
  @override
  FutureOr<FinancialShiftState> build() {
    return const FinancialShiftState();
  }

  Future<void> openShift({
    required double openingCashActual,
    required String openingDifferenceReason,
  }) async {
    try {
      state = const AsyncLoading();
      await ref.read(financialShiftRepositoryProvider).openShift(
            openingCashActual: openingCashActual,
            openingDifferenceReason: openingDifferenceReason,
          );
    } catch (e) {
      state = const AsyncData(FinancialShiftState(isShiftOpen: false));
      rethrow;
    }
    state = const AsyncData(FinancialShiftState(isShiftOpen: true));
  }

  Future<void> closeShift() async {
    try {
      state = const AsyncLoading();
      await ref.read(financialShiftRepositoryProvider).closeShift();
    } catch (e) {
      state = const AsyncData(FinancialShiftState(isShiftOpen: true));
      rethrow;
    }
    state = const AsyncData(FinancialShiftState(isShiftOpen: false));
  }

  Future<void> checkFinancialShiftOpen() async {
    try {
      final financialShiftId = await ref
          .read(financialShiftRepositoryProvider)
          .getFinancialShiftId();
      state = AsyncData(
        FinancialShiftState(
          isShiftOpen: financialShiftId != null,
          financialShiftId: financialShiftId,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getTakedTableNumber() async {
    try {
      final financialShiftId = state.value?.financialShiftId;
      if (financialShiftId == null) return;

      final takedTableNumber = await ref
          .read(orderRepositoryProvider)
          .getExistingTableNumber(financialShiftId);

      state = AsyncData(
        state.value!.copyWith(
          takedTableNumber: takedTableNumber,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
