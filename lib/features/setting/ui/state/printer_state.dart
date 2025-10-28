import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:printing/printing.dart';

part 'printer_state.freezed.dart';

@freezed
class PrinterState with _$PrinterState {
  const factory PrinterState({
    @Default([]) List<Printer> availableWirePrinters,
    @Default([]) List<Printer> availableWirelessPrinters,
    Printer? selectedPrinter,
    @Default(false) bool isScanning,
    @Default(false) bool isPrinting,
    String? errorMessage,
  }) = _PrinterState;
}
