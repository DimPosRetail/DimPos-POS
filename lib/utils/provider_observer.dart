import 'package:dimpos_store/constants/constants.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    // Use structured logging with visual indicators for provider initialization
    // final providerName = provider.name ?? 'unnamed';
    // final formattedValue = _formatValue(value);

    // providerLogger.d('${Constants.tag} 🔰 PROVIDER INITIALIZED\n'
    //     'Provider: $providerName\n'
    //     'Value: $formattedValue');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    // Use structured logging for provider disposal
    // final providerName = provider.name ?? 'unnamed';

    // providerLogger.i('${Constants.tag} 🗑️ PROVIDER DISPOSED\n'
    //     'Provider: $providerName');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Skip logging if values are identical to reduce noise
    if (previousValue == newValue) return;

    final providerName = provider.name ?? 'unnamed';
    final formattedPrevValue = _formatValue(previousValue);
    final formattedNewValue = _formatValue(newValue);

    // Use structured logging with visual indicators for state changes
    providerLogger.i('${Constants.tag} 🔄 PROVIDER UPDATED\n'
        'Provider: $providerName\n'
        'Previous: $formattedPrevValue\n'
        'New: $formattedNewValue\n'
        'Changed: ${_describeDifference(previousValue, newValue)}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Use error logging with more detailed stack trace for failed providers
    final providerName = provider.name ?? 'unnamed';

    providerLogger.e(
      '${Constants.tag} ❌ PROVIDER ERROR\n'
      'Provider: $providerName\n'
      'Error: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Helper method to format values for better readability
  String _formatValue(Object? value) {
    if (value == null) return 'null';

    // Handle common types specially
    if (value is String) return '"$value"';
    if (value is List) return '[length: ${value.length}]';
    if (value is Map) return '{size: ${value.length}}';

    // Use toString() for other types but truncate if too long
    final stringValue = value.toString();
    return stringValue;
  }

  // Helper method to describe what changed between values
  String _describeDifference(Object? previous, Object? current) {
    if (previous == null && current != null) return 'Initialized';
    if (previous != null && current == null) return 'Nullified';

    if (previous is List && current is List) {
      if (previous.length != current.length) {
        return 'List size changed from ${previous.length} to ${current.length}';
      }
      return 'List content changed';
    }

    if (previous is Map && current is Map) {
      if (previous.length != current.length) {
        return 'Map size changed from ${previous.length} to ${current.length}';
      }
      return 'Map content changed';
    }

    // Simple change for other types
    return 'Value changed';
  }
}
