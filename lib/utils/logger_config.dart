import 'package:logger/logger.dart';

final providerLogger = Logger(
  level: Level.debug,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 8,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
  output: ConsoleOutput(),
);
