import 'dart:io';
import 'dart:typed_data';

import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:dimpos_store/features/product/models/store.dart';
import 'package:dimpos_store/features/setting/repositories/printer_discovery_repository.dart';
import 'package:dimpos_store/features/setting/ui/state/printer_state.dart';
import 'package:dimpos_store/utils/bill_printing.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toastification/toastification.dart';

part 'printer_view_model.g.dart';

@Riverpod(keepAlive: true)
class PrinterViewModel extends _$PrinterViewModel {
  final PrinterDiscoveryRepository _discoveryRepository =
      PrinterDiscoveryRepository();

  @override
  FutureOr<PrinterState> build() async {
    try {
      final availablePrinters = await scanWirePrinters();
      return PrinterState(
        availableWirePrinters: availablePrinters,
        availableWirelessPrinters: [],
        selectedPrinter: null,
        errorMessage: null,
      );
    } catch (e) {
      providerLogger.e('Error initializing printer state: $e');
      return PrinterState(
        availableWirePrinters: [],
        availableWirelessPrinters: [],
        selectedPrinter: null,
        errorMessage: 'Failed to initialize: $e',
      );
    }
  }

  Future<List<Printer>> scanWirePrinters() async {
    try {
      final printers = await Printing.listPrinters();

      // Update state with found printers
      final currentState = state.valueOrNull ??
          PrinterState(
            availableWirePrinters: [],
            availableWirelessPrinters: [],
            selectedPrinter: null,
          );

      state = AsyncData(
        currentState.copyWith(
          availableWirePrinters: printers,
        ),
      );

      return printers;
    } catch (e) {
      providerLogger.e('Error scanning printers: $e');
      return [];
    }
  }

  Future<void> startDiscovery() async {
    // Get current state or use default
    final currentState = state.valueOrNull ??
        PrinterState(
          availableWirePrinters: [],
          availableWirelessPrinters: [],
          selectedPrinter: null,
        );

    state = AsyncData(currentState.copyWith(
      isScanning: true,
      availableWirelessPrinters: [],
      errorMessage: null,
    ));

    try {
      await requestPermissions();

      await for (final printer in _discoveryRepository.scanWirelessPrinters()) {
        final stateValue = state.valueOrNull;
        if (stateValue == null) break;

        state = AsyncData(stateValue.copyWith(
          availableWirelessPrinters: [
            ...stateValue.availableWirelessPrinters,
            printer
          ],
        ));
      }
    } on SocketException catch (e) {
      providerLogger.e('Network error during discovery: $e');
      final stateValue = state.valueOrNull;
      if (stateValue != null) {
        state = AsyncData(
          stateValue.copyWith(
            errorMessage: 'Network error: Check WiFi connection',
          ),
        );
      }
    } catch (e) {
      providerLogger.e('Discovery error: $e');
      final stateValue = state.valueOrNull;
      if (stateValue != null) {
        state = AsyncData(
          stateValue.copyWith(
            errorMessage: 'Discovery error: $e',
          ),
        );
      }
    } finally {
      final stateValue = state.valueOrNull;
      if (stateValue != null) {
        state = AsyncData(stateValue.copyWith(
          isScanning: false,
        ));
      }
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.location.request();
      await Permission.nearbyWifiDevices.request();
    }
  }

  Future<bool> choosePrinter(Printer printer) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    if (currentState.availableWirePrinters.isEmpty &&
        currentState.availableWirelessPrinters.isEmpty) {
      return false;
    }

    try {
      state = AsyncData(
        currentState.copyWith(selectedPrinter: printer),
      );
      return true;
    } catch (e) {
      providerLogger.e('Error choosing printer: $e');
      return false;
    }
  }

  Future<void> printDraftBill({
    required BuildContext context,
    required Cart selectedCart,
    required Store storeInfo,
    required String orderCode,
  }) async {
    try {
      final pdfBytes = await generateBillPdf(
        selectedCart: selectedCart,
        format: pdf.PdfPageFormat(
          72 * pdf.PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * pdf.PdfPageFormat.mm,
        ),
        storeInfo: storeInfo,
        orderCode: orderCode,
        isBill: false,
      );
      await Printing.layoutPdf(
        onLayout: (pdf.PdfPageFormat format) => pdfBytes,
      );
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        title: Text('Lỗi in hóa đơn'),
        description: Text(e.toString()),
      );
    }
  }

  Future<void> printBillInvoice({
    required BuildContext context,
    required Cart selectedCart,
    required Store storeInfo,
    required String paymentMethod,
    required String orderCode,
    required bool isBill,
    String? qrLink,
    int? tableNumber,
  }) async {
    try {
      final chosenPrinter = state.valueOrNull?.selectedPrinter;

      if (chosenPrinter == null) {
        toastification.show(
          type: ToastificationType.warning,
          title: Text('Chưa chọn máy in'),
          description: Text('Vui lòng chọn máy in trước khi in'),
        );
        return;
      }

      // Check if it's a wired printer
      if (chosenPrinter.name.isNotNullOrEmpty &&
          chosenPrinter.url.isNotNullOrEmpty) {
        final pdfBytes = await generateBillPdf(
          selectedCart: selectedCart,
          format: pdf.PdfPageFormat(
            72 * pdf.PdfPageFormat.mm,
            double.infinity,
            marginAll: 5 * pdf.PdfPageFormat.mm,
          ),
          storeInfo: storeInfo,
          paymentMethod: paymentMethod,
          qrLink: qrLink,
          tableNumber: tableNumber,
          orderCode: orderCode,
          isBill: isBill,
        );
        final printers = await Printing.listPrinters();
        final printer = printers.firstWhere(
          (p) => p.name == chosenPrinter.name,
          orElse: () => printers.first,
        );
        await Printing.directPrintPdf(
          printer: printer,
          onLayout: (pdf.PdfPageFormat format) => pdfBytes,
        );
      } else if (chosenPrinter.ip.isNotNullOrEmpty &&
          chosenPrinter.port != null) {
        // Generate PDF bytes first
        final pdfBytes = await generateBillEscPos(
          selectedCart: selectedCart,
          format: pdf.PdfPageFormat(
            72 * pdf.PdfPageFormat.mm,
            double.infinity,
            marginAll: 5 * pdf.PdfPageFormat.mm,
          ),
          storeInfo: storeInfo,
          paymentMethod: paymentMethod,
          qrLink: qrLink,
          tableNumber: tableNumber,
          orderCode: orderCode,
          isBill: isBill,
        );

        // Convert PDF to images
        final escPosBytes = await _convertPdfToEscPos(pdfBytes);

        // Wireless printer - send raw data
        Socket? socket;
        try {
          socket = await Socket.connect(
            chosenPrinter.ip!,
            chosenPrinter.port!,
            timeout: const Duration(seconds: 5),
          );
          socket.add(escPosBytes);
          await socket.flush();
          await Future.delayed(const Duration(milliseconds: 500));

          toastification.show(
            type: ToastificationType.success,
            title: Text('In thành công'),
          );
        } on SocketException catch (e) {
          providerLogger.e('Print socket error: $e');
          toastification.show(
            type: ToastificationType.error,
            title: Text('Lỗi kết nối máy in'),
            description: Text('Không thể kết nối tới ${chosenPrinter.ip}'),
          );
        } finally {
          socket?.destroy();
        }
      }
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        title: Text('Lỗi in hóa đơn'),
        description: Text(e.toString()),
      );
    }
  }

  Future<List<int>> _convertPdfToEscPos(Uint8List pdfBytes) async {
    try {
      // Convert PDF to images
      final document = await PdfDocument.openData(pdfBytes);
      final page = await document.getPage(1);

      // Render at higher DPI for better quality (203 DPI is standard for thermal printers)
      // 58mm width = ~2.28 inches * 203 DPI ≈ 463 pixels
      // Using 576 pixels for better quality
      final pageImage = await page.render(
        width: 576, // For 58mm thermal printer
        height: (page.height * 576 / page.width),
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF', // ✅ THÊM: Đặt background trắng
      );

      if (pageImage == null) {
        throw Exception('Failed to render PDF page');
      }

      // Get the image bytes
      final pngBytes = pageImage.bytes;

      // Convert to image package format
      img.Image? image = img.decodeImage(pngBytes);

      if (image == null) {
        throw Exception('Failed to decode PDF image');
      }

      // ✅ THÊM: Đảo ngược màu nếu background đen
      // Kiểm tra xem ảnh có background đen không
      final averageBrightness = _getAverageBrightness(image);
      if (averageBrightness < 128) {
        // Background tối, cần đảo màu
        image = img.invert(image);
      }

      // Convert to grayscale and adjust contrast for better printing
      final grayscale = img.grayscale(image);
      final adjusted = img.adjustColor(
        grayscale,
        contrast: 1.5, // ✅ Tăng contrast
        brightness: 1.0, // ✅ Giảm brightness về mức bình thường
      );

      // ✅ THÊM: Tăng độ sắc nét
      final sharpened = img.adjustColor(adjusted, contrast: 1.2);

      // Initialize ESC/POS generator
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Add ESC/POS commands
      bytes += generator.reset();

      // Print the image
      bytes += generator.imageRaster(sharpened, align: PosAlign.center);

      // Add some spacing and cut command
      bytes += generator.feed(3);
      bytes += generator.cut();

      // Clean up
      await page.close();
      await document.close();

      return bytes;
    } catch (e) {
      providerLogger.e('Error converting PDF to ESC/POS: $e');
      rethrow;
    }
  }

// ✅ THÊM: Hàm kiểm tra độ sáng trung bình
  int _getAverageBrightness(img.Image image) {
    int totalBrightness = 0;
    int sampleSize = 100; // Lấy mẫu 100 pixel để kiểm tra nhanh

    for (int i = 0; i < sampleSize; i++) {
      int x = (image.width * i / sampleSize).toInt();
      int y = (image.height * i / sampleSize).toInt();

      final pixel = image.getPixel(x, y);
      // Tính brightness từ RGB
      totalBrightness += ((pixel.r + pixel.g + pixel.b) / 3).toInt();
    }

    return totalBrightness ~/ sampleSize;
  }
}
