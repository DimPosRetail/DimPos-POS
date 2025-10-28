import 'dart:io';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class PrinterDiscoveryRepository {
  final NetworkInfo _networkInfo = NetworkInfo();
  final List<int> _commonPrinterPorts = [9100, 515, 631, 9101, 9102];

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.location.request();
      await Permission.nearbyWifiDevices.request();
    }
  }

  Stream<Printer> scanWirelessPrinters() async* {
    try {
      final wifiIP = await _networkInfo.getWifiIP();

      if (wifiIP == null) {
        throw Exception('Not connected to WiFi');
      }

      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

      final stream = NetworkAnalyzer.discover2(
        subnet,
        9100,
        timeout: const Duration(milliseconds: 500),
      );

      final discoveredIPs = <String>{};

      await for (final addr in stream) {
        // Wrap in try-catch to handle individual connection errors
        try {
          if (addr.exists && !discoveredIPs.contains(addr.ip)) {
            discoveredIPs.add(addr.ip);

            for (final port in _commonPrinterPorts) {
              final isOpen = await _checkPort(addr.ip, port);
              if (isOpen) {
                yield Printer(
                  url: "",
                  ip: addr.ip,
                  port: port,
                  name: 'Printer at ${addr.ip}',
                );
                break;
              }
            }
          }
        } on SocketException catch (e) {
          // Silently skip connection errors for individual IPs
          providerLogger.e('Skipping ${addr.ip}: $e');
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _checkPort(String ip, int port) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 500),
      );
      socket.destroy();
      return true;
    } on SocketException catch (_) {
      // Expected - port is closed or unreachable
      return false;
    } catch (e) {
      return false;
    }
  }
}