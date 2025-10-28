import 'dart:typed_data';

import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:dimpos_store/features/product/models/store.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateBillPdf({
  required Cart selectedCart,
  required Store storeInfo,
  required PdfPageFormat format,
  required String orderCode,
  required bool isBill,
  String? qrLink,
  String? paymentMethod,
  int? tableNumber,
}) async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load('assets/fonts/Inter_18pt-Regular.ttf');
  final logoImage = await rootBundle.load(Assets.logo);
  Response<List<int>>? logoResponse;
  if (storeInfo.pictureUrl != null && storeInfo.pictureUrl!.isNotEmpty) {
    // Load the store logo image from the URL
    logoResponse = await Dio().get<List<int>>(
      "https://media-dimpos.orbitmap.xyz/proxy/${storeInfo.pictureUrl!}",
      options: Options(responseType: ResponseType.bytes),
    );
  }
  // Convert the qrLink to a QR code image
  pw.Widget? qrWidget;
  if (qrLink != null && qrLink.isNotEmpty) {
    // Load QR code image from the qrLink (assume it's a direct image URL)
    final qrImageData = await Dio().get<List<int>>(
      qrLink,
      options: Options(responseType: ResponseType.bytes),
    );
    qrWidget = pw.Image(
      pw.MemoryImage(Uint8List.fromList(qrImageData.data!)),
      width: 60,
      height: 60,
    );
  }
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());
  final dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
  final currentTime = dateFormat.format(DateTime.now());
  int sumQuantity =
      selectedCart.cartItems!.fold(0, (sum, item) => sum + item.quantity);
  int tt = 1;
  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (logoResponse != null)
                  pw.Image(
                    pw.MemoryImage(Uint8List.fromList(logoResponse.data!)),
                    width: 60,
                    height: 60,
                  )
                else
                  pw.Image(
                    pw.MemoryImage(logoImage.buffer.asUint8List()),
                    width: 30,
                    height: 30,
                  ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    storeInfo.name,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    storeInfo.address,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'SĐT: ${storeInfo.phone}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  isBill ? 'HÓA ĐƠN THANH TOÁN' : 'PHIẾU THANH TOÁN',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Mã đơn hàng: $orderCode',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
            if (tableNumber != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Bàn số: $tableNumber',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            pw.Text(
              'Thời gian: $currentTime',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 8,
              ),
            ),
            // pw.Text('Thu ngân: Administrator',
            //     style: pw.TextStyle(font: ttf, fontSize: 8)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
              columnWidths: {
                0: pw.FixedColumnWidth(20),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(30),
                3: pw.FixedColumnWidth(50),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('TT',
                          style: pw.TextStyle(font: ttf, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Tên món',
                          style: pw.TextStyle(font: ttf, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('SL',
                          style: pw.TextStyle(font: ttf, fontSize: 8),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('T.Tiền',
                          style: pw.TextStyle(font: ttf, fontSize: 8),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                ...selectedCart.cartItems!.map((item) {
                  final itemRows = <pw.TableRow>[];
                  itemRows.add(pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('$tt',
                            style: pw.TextStyle(font: ttf, fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(item.productVariantNameSnapshot,
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('x${item.quantity}',
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            (item.unitPriceAtAdditionSnapshot * item.quantity)
                                .currency,
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ));
                  tt++;
                  if (item.modifierGroupItems.isNotNullOrEmpty) {
                    itemRows.addAll(
                        item.modifierGroupItems!.map((modifier) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    '• ${modifier.modifierOptionSnapshot}',
                                    style: pw.TextStyle(
                                      font: ttf,
                                      fontSize: 6,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                              ],
                            )));
                  }
                  if (item.extraItems.isNotNullOrEmpty) {
                    itemRows.addAll(item.extraItems!.map((extra) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '+ ${extra.extraProductVariantNameSnapshot}',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 6,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'x${extra.quantity}',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 6,
                                  color: PdfColors.grey700,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                  (extra.unitPriceAtAdditionSnapshot *
                                          extra.quantity)
                                      .currency,
                                  style: pw.TextStyle(font: ttf, fontSize: 8),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ],
                        )));
                  }
                  return itemRows;
                }).expand((e) => e),
              ],
            ),
            pw.Divider(height: 10, thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TỔNG SỐ LƯỢNG:',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('$sumQuantity',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 4),
            if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Phương thức thanh toán:',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(paymentMethod,
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
            _buildSummaryRow(
                'Tạm tính', selectedCart.subtotalAmount.currency, ttf,
                size: 8),
            _buildSummaryRow(
                'Thuế', '+ ${selectedCart.totalTaxAmount.currency}', ttf,
                size: 8),
            _buildSummaryRow(
                'Giảm giá',
                '- ${(selectedCart.orderLevelDiscountAmount + selectedCart.totalItemDiscountAmount).currency}',
                ttf,
                color: PdfColors.red,
                size: 8),
            pw.Divider(height: 10, thickness: 0.5),
            _buildSummaryRow(
                'Tiền thanh toán', selectedCart.finalTotalAmount.currency, ttf,
                bold: true, color: PdfColors.red, size: 8),
            pw.SizedBox(height: 10),
            if (qrWidget != null) ...[
              pw.Center(child: qrWidget),
              pw.SizedBox(height: 10),
            ],
            if (storeInfo.wifiName != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Wifi: ${storeInfo.wifiName!}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            if (storeInfo.wifiPassword != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Password: ${storeInfo.wifiPassword!}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Xin cảm ơn và hẹn gặp lại!',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}

pw.Widget _buildSummaryRow(String label, String value, pw.Font font,
    {bool bold = false, PdfColor? color, double size = 12}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: font,
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value,
            style: pw.TextStyle(
                font: font,
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color ?? PdfColors.black)),
      ],
    ),
  );
}

Future<Uint8List> generateBillEscPos({
  required Cart selectedCart,
  required Store storeInfo,
  required PdfPageFormat format,
  required String orderCode,
  required bool isBill,
  String? qrLink,
  String? paymentMethod,
  int? tableNumber,
}) async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load('assets/fonts/Inter_18pt-Regular.ttf');
  final logoImage = await rootBundle.load(Assets.logo);
  Response<List<int>>? logoResponse;
  if (storeInfo.pictureUrl != null && storeInfo.pictureUrl!.isNotEmpty) {
    // Load the store logo image from the URL
    logoResponse = await Dio().get<List<int>>(
      "https://media-dimpos.orbitmap.xyz/proxy/${storeInfo.pictureUrl!}",
      options: Options(responseType: ResponseType.bytes),
    );
  }
  // Convert the qrLink to a QR code image
  pw.Widget? qrWidget;
  if (qrLink != null && qrLink.isNotEmpty) {
    // Load QR code image from the qrLink (assume it's a direct image URL)
    final qrImageData = await Dio().get<List<int>>(
      qrLink,
      options: Options(responseType: ResponseType.bytes),
    );
    qrWidget = pw.Image(
      pw.MemoryImage(Uint8List.fromList(qrImageData.data!)),
      width: 60,
      height: 60,
    );
  }
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());
  final dateFormat = DateFormat('d/M/yyyy h:mm:ss a');
  final currentTime = dateFormat.format(DateTime.now());
  int sumQuantity =
      selectedCart.cartItems!.fold(0, (sum, item) => sum + item.quantity);
  int tt = 1;
  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (logoResponse != null)
                  pw.Image(
                    pw.MemoryImage(Uint8List.fromList(logoResponse.data!)),
                    width: 60,
                    height: 60,
                  )
                else
                  pw.Image(
                    pw.MemoryImage(logoImage.buffer.asUint8List()),
                    width: 30,
                    height: 30,
                  ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    storeInfo.name,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    storeInfo.address,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'SĐT: ${storeInfo.phone}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  isBill ? 'HÓA ĐƠN THANH TOÁN' : 'PHIẾU THANH TOÁN',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Mã đơn hàng: $orderCode',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
            if (tableNumber != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Bàn số: $tableNumber',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            pw.Text(
              'Thời gian: $currentTime',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 8,
              ),
            ),
            // pw.Text('Thu ngân: Administrator',
            //     style: pw.TextStyle(font: ttf, fontSize: 8)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
              columnWidths: {
                0: pw.FixedColumnWidth(20),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(30),
                3: pw.FixedColumnWidth(50),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('TT',
                          style: pw.TextStyle(font: ttf, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Tên món',
                          style: pw.TextStyle(font: ttf, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('SL',
                          style: pw.TextStyle(font: ttf, fontSize: 8),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('T.Tiền',
                          style: pw.TextStyle(font: ttf, fontSize: 8),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                ...selectedCart.cartItems!.map((item) {
                  final itemRows = <pw.TableRow>[];
                  itemRows.add(pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('$tt',
                            style: pw.TextStyle(font: ttf, fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(item.productVariantNameSnapshot,
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('x${item.quantity}',
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            (item.unitPriceAtAdditionSnapshot * item.quantity)
                                .currency,
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ));
                  tt++;
                  if (item.modifierGroupItems.isNotNullOrEmpty) {
                    itemRows.addAll(
                        item.modifierGroupItems!.map((modifier) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    '• ${modifier.modifierOptionSnapshot}',
                                    style: pw.TextStyle(
                                      font: ttf,
                                      fontSize: 6,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(''),
                                ),
                              ],
                            )));
                  }
                  if (item.extraItems.isNotNullOrEmpty) {
                    itemRows.addAll(item.extraItems!.map((extra) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '+ ${extra.extraProductVariantNameSnapshot}',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 6,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'x${extra.quantity}',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 6,
                                  color: PdfColors.grey700,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                  (extra.unitPriceAtAdditionSnapshot *
                                          extra.quantity)
                                      .currency,
                                  style: pw.TextStyle(font: ttf, fontSize: 8),
                                  textAlign: pw.TextAlign.right),
                            ),
                          ],
                        )));
                  }
                  return itemRows;
                }).expand((e) => e),
              ],
            ),
            pw.Divider(height: 10, thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TỔNG SỐ LƯỢNG:',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('$sumQuantity',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 4),
            if (paymentMethod != null && paymentMethod.isNotEmpty) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Phương thức thanh toán:',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(paymentMethod,
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
            _buildSummaryRow(
                'Tạm tính', selectedCart.subtotalAmount.currency, ttf,
                size: 8),
            _buildSummaryRow(
                'Thuế', '+ ${selectedCart.totalTaxAmount.currency}', ttf,
                size: 8),
            _buildSummaryRow(
                'Giảm giá',
                '- ${(selectedCart.orderLevelDiscountAmount + selectedCart.totalItemDiscountAmount).currency}',
                ttf,
                color: PdfColors.red,
                size: 8),
            pw.Divider(height: 10, thickness: 0.5),
            _buildSummaryRow(
                'Tiền thanh toán', selectedCart.finalTotalAmount.currency, ttf,
                bold: true, color: PdfColors.red, size: 8),
            pw.SizedBox(height: 10),
            if (qrWidget != null) ...[
              pw.Center(child: qrWidget),
              pw.SizedBox(height: 10),
            ],
            if (storeInfo.wifiName != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Wifi: ${storeInfo.wifiName!}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            if (storeInfo.wifiPassword != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Password: ${storeInfo.wifiPassword!}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Xin cảm ơn và hẹn gặp lại!',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}
