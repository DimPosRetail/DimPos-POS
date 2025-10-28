import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/setting/ui/view_models/printer_view_model.dart';
import 'package:dimpos_store/features/setting/ui/widgets/printer_connect_confirm_dialog.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_section.dart';
// import 'package:dimpos_store/utils/logger_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class PrinterScreen extends ConsumerStatefulWidget {
  const PrinterScreen({super.key});

  @override
  ConsumerState<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends ConsumerState<PrinterScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerViewModelProvider.notifier).startDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final printerState = ref.watch(printerViewModelProvider);
    final iconSize = 20.w;
    List<SectionItem> buildMyPrinterItems() {
      if (printerState.isLoading || printerState.value == null) {
        return [
          const SectionItem(
            title: 'Đang quét máy in...',
            subtitle: 'Vui lòng đợi',
            icon: Icons.scanner,
          ),
        ];
      }

      if (printerState.value!.availableWirePrinters.isEmpty &&
          printerState.value!.availableWirelessPrinters.isEmpty) {
        return [
          SectionItem(
            title: 'Không tìm thấy máy in',
            subtitle: 'Vui lòng kết nối máy in',
            icon: Icons.print_outlined,
            //   onTap: () =>
            //     _showConnectPrinterDialog(context, ref, printer: Printer(url: "")),
          ),
        ];
      }

      return [
        ...printerState.value!.availableWirePrinters,
        ...printerState.value!.availableWirelessPrinters,
      ].map((printer) {
        final selectedPrinter = printerState.value?.selectedPrinter;
        return SectionItem(
          title: printer.name,
          subtitle:
              (selectedPrinter != null && selectedPrinter.name == printer.name)
                  ? 'Đã kết nối'
                  : 'Có thể kết nối',
          icon: Icons.print_outlined,
          onTap: () =>
              _showConnectPrinterDialog(context, ref, printer: printer),
        );
      }).toList();
    }

    // providerLogger.d(
    //   'Current printer state: $printerState',
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20.h,
      children: [
        SettingSection(
          title: 'Thiết bị của tôi',
          items: buildMyPrinterItems(),
          button: (printerState.value?.isScanning ?? false)
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : InkWell(
                  onTap: (printerState.value?.isScanning ?? false)
                      ? () {}
                      : ref
                          .watch(printerViewModelProvider.notifier)
                          .startDiscovery,
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.refresh,
                      size: iconSize,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

void _showConnectPrinterDialog(BuildContext context, WidgetRef ref,
    {required Printer printer}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PrinterConnectConfirmDialog(
        printer: printer,
      );
    },
  );
}
