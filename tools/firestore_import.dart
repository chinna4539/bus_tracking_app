import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

const _projectId = 'visakhapatnam-bus-tracking';
const _baseUrl =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)';
const _resourcePrefix = 'projects/$_projectId/databases/(default)/documents';
const _batchSize = 500;

Future<void> main(List<String> args) async {
  final params = _parseArgs(args);

  print('='.padRight(60, '='));
  print('Firestore Bulk Import Tool');
  print('='.padRight(60, '='));
  print('Project: $_projectId');
  print('Mode: ${params.dryRun ? "DRY RUN (no changes)" : "REAL IMPORT"}');
  print('Data directory: ${params.dataDir}');
  print('Service account: ${params.serviceAccountPath}');
  print('');

  http.Client? authClient;

  if (!params.dryRun) {
    final saFile = File(params.serviceAccountPath);
    if (!saFile.existsSync()) {
      print(
        'ERROR: Service account file not found: ${params.serviceAccountPath}',
      );
      print(
        'Download it from: Firebase Console > Project Settings > Service Accounts',
      );
      exit(1);
    }

    print('Authenticating with service account...');
    final serviceAccount = ServiceAccountCredentials.fromJson(
      json.decode(saFile.readAsStringSync()),
    );
    final scopes = ['https://www.googleapis.com/auth/datastore'];
    authClient = await clientViaServiceAccount(serviceAccount, scopes);
    print('Authenticated successfully.');
    print('');
  } else {
    print('Dry-run mode: no authentication required.');
    print('');
  }

  final collections = ['routes', 'stops', 'buses'];
  int totalImported = 0;
  int totalSkipped = 0;
  int totalFailed = 0;

  for (final collection in collections) {
    final result = await _processCollection(
      collection,
      params.dataDir,
      params.dryRun,
      authClient,
    );
    totalImported += result.imported;
    totalSkipped += result.skipped;
    totalFailed += result.failed;
  }

  print('');
  print('='.padRight(60, '='));
  print('SUMMARY');
  print('='.padRight(60, '='));
  print('Imported: $totalImported');
  print('Skipped:  $totalSkipped');
  print('Failed:   $totalFailed');
  print('');
  print('Mode: ${params.dryRun ? "DRY RUN" : "REAL IMPORT"}');
  if (params.dryRun && totalImported > 0) {
    print('');
    print('To perform the real import, run:');
    print(
      '  dart tools/firestore_import.dart --service-account <service-account.json>',
    );
  }
  print('='.padRight(60, '='));

  authClient?.close();
  exit(totalFailed > 0 ? 1 : 0);
}

Future<http.Response> _get(http.Client client, String url) async {
  final request = http.Request('GET', Uri.parse(url));
  final streamedResponse = await client.send(request);
  return await http.Response.fromStream(streamedResponse);
}

Future<http.Response> _post(
  http.Client client,
  String url,
  Map<String, dynamic> body,
) async {
  final request = http.Request('POST', Uri.parse(url));
  request.headers['Content-Type'] = 'application/json';
  request.body = json.encode(body);
  final streamedResponse = await client.send(request);
  return await http.Response.fromStream(streamedResponse);
}

Future<_ImportResult> _processCollection(
  String collection,
  String dataDir,
  bool dryRun,
  http.Client? authClient,
) async {
  print('--- Collection: $collection ---');

  final filePath = '$dataDir/$collection.json';
  final file = File(filePath);

  if (!file.existsSync()) {
    print('  SKIP: $filePath not found');
    return _ImportResult.zero();
  }

  final raw = file.readAsStringSync().trim();
  if (raw.isEmpty || raw == '[]') {
    print('  SKIP: empty file');
    return _ImportResult.zero();
  }

  List<dynamic> data;
  try {
    data = json.decode(raw) as List<dynamic>;
  } on FormatException catch (e) {
    print('  ERROR: Invalid JSON in $filePath: ${e.message}');
    return _ImportResult.zero();
  }

  if (data.isEmpty) {
    print('  SKIP: empty array');
    return _ImportResult.zero();
  }

  final validRecords = <Map<String, dynamic>>[];
  final invalidRecords = <String>[];

  for (var i = 0; i < data.length; i++) {
    final record = data[i] as Map<String, dynamic>;
    final validation = _validateRecord(collection, record, i + 1);
    if (validation.isValid) {
      validRecords.add(record);
    } else {
      invalidRecords.add('  Record ${i + 1}: ${validation.error}');
    }
  }

  if (invalidRecords.isNotEmpty) {
    print('  VALIDATION ERRORS (${invalidRecords.length}):');
    for (final error in invalidRecords) {
      print(error);
    }
    print('  Skipping ${invalidRecords.length} invalid records.');
  }

  if (validRecords.isEmpty) {
    print('  No valid records to process.');
    return _ImportResult.zero();
  }

  List<Map<String, dynamic>> newRecords;
  if (dryRun || authClient == null) {
    newRecords = validRecords;
  } else {
    print('  Checking for existing documents...');
    final existingIds = await _getExistingDocumentIds(collection, authClient);
    newRecords = validRecords.where((record) {
      final id = record['id'] as String?;
      return id != null && !existingIds.contains(id);
    }).toList();
  }

  final duplicateCount = validRecords.length - newRecords.length;
  if (duplicateCount > 0) {
    print('  SKIP: $duplicateCount duplicate documents already exist');
  }

  if (newRecords.isEmpty) {
    print('  No new documents to import.');
    return _ImportResult.zero();
  }

  if (dryRun) {
    print('  DRY RUN: Would import ${newRecords.length} documents:');
    for (final record in newRecords) {
      final id = record['id'] as String? ?? '(no id)';
      final label = _getRecordLabel(collection, record);
      print('    + $id: $label');
    }
    return _ImportResult(
      imported: newRecords.length,
      skipped: validRecords.length - newRecords.length + invalidRecords.length,
      failed: 0,
    );
  }

  print('  Importing ${newRecords.length} documents...');
  int imported = 0;
  int failed = 0;

  for (var i = 0; i < newRecords.length; i += _batchSize) {
    final batch = newRecords.skip(i).take(_batchSize).toList();
    try {
      await _batchWrite(collection, batch, authClient!);
      imported += batch.length;
      print(
        '    Batch ${(i ~/ _batchSize) + 1}: ${batch.length} documents written',
      );
    } catch (e) {
      failed += batch.length;
      print('    Batch ${(i ~/ _batchSize) + 1} FAILED: $e');
    }
  }

  print('  Imported: $imported, Failed: $failed');
  return _ImportResult(
    imported: imported,
    skipped: validRecords.length - newRecords.length + invalidRecords.length,
    failed: failed,
  );
}

class _ValidationResult {
  final bool isValid;
  final String? error;

  const _ValidationResult(this.isValid, [this.error]);
}

_ValidationResult _validateRecord(
  String collection,
  Map<String, dynamic> record,
  int recordNumber,
) {
  final id = record['id'];
  if (id == null || (id is String && id.isEmpty)) {
    return const _ValidationResult(false, 'Missing or empty "id" field');
  }

  switch (collection) {
    case 'buses':
      return _validateBus(record);
    case 'routes':
      return _validateRoute(record);
    case 'stops':
      return _validateStop(record);
    default:
      return _ValidationResult(false, 'Unknown collection: $collection');
  }
}

_ValidationResult _validateBus(Map<String, dynamic> record) {
  final required = [
    'busNumber',
    'routeNumber',
    'routeName',
    'startingPoint',
    'destination',
    'stops',
    'currentStop',
    'nextStop',
    'eta',
    'status',
    'busType',
    'driverName',
    'capacity',
    'availableSeats',
    'speed',
    'lastUpdated',
    'distanceRemaining',
    'estimatedJourneyTime',
    'isActive',
    'latitude',
    'longitude',
  ];

  for (final field in required) {
    if (!record.containsKey(field) || record[field] == null) {
      return _ValidationResult(false, 'Missing required field: $field');
    }
  }

  final validStatuses = <String>{
    'onTime',
    'delayed',
    'diverted',
    'cancelled',
    'arrivingSoon',
  };
  final status = record['status'] as String;
  if (!validStatuses.contains(status)) {
    return _ValidationResult(
      false,
      'Invalid status: $status (must be one of ${validStatuses.join(", ")})',
    );
  }

  final validTypes = <String>{'standard', 'express', 'ac'};
  final busType = record['busType'] as String;
  if (!validTypes.contains(busType)) {
    return _ValidationResult(
      false,
      'Invalid busType: $busType (must be one of ${validTypes.join(", ")})',
    );
  }

  final stops = record['stops'];
  if (stops is! List || stops.isEmpty) {
    return const _ValidationResult(false, 'stops must be a non-empty array');
  }

  return const _ValidationResult(true);
}

_ValidationResult _validateRoute(Map<String, dynamic> record) {
  final required = [
    'routeNumber',
    'title',
    'startingPoint',
    'destination',
    'stops',
    'distance',
    'duration',
    'totalStops',
    'firstBus',
    'lastBus',
    'frequency',
    'description',
  ];

  for (final field in required) {
    if (!record.containsKey(field) || record[field] == null) {
      return _ValidationResult(false, 'Missing required field: $field');
    }
  }

  final stops = record['stops'];
  if (stops is! List || stops.isEmpty) {
    return const _ValidationResult(false, 'stops must be a non-empty array');
  }

  return const _ValidationResult(true);
}

_ValidationResult _validateStop(Map<String, dynamic> record) {
  if (!record.containsKey('name') ||
      record['name'] == null ||
      (record['name'] as String).isEmpty) {
    return const _ValidationResult(
      false,
      'Missing or empty required field: name',
    );
  }
  return const _ValidationResult(true);
}

Future<Set<String>> _getExistingDocumentIds(
  String collection,
  http.Client authClient,
) async {
  final ids = <String>{};
  String? pageToken;

  do {
    final url = '$_baseUrl/$collection?pageToken=$pageToken&pageSize=300';
    final response = await _get(authClient, url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final documents = data['documents'] as List<dynamic>? ?? [];
      for (final doc in documents) {
        final name = doc['name'] as String;
        final id = name.split('/').last;
        ids.add(id);
      }
      pageToken = data['nextPageToken'] as String?;
    } else if (response.statusCode == 404) {
      break;
    } else {
      print(
        '  WARNING: Failed to list $collection documents: ${response.statusCode}',
      );
      break;
    }
  } while (pageToken != null);

  return ids;
}

Future<void> _batchWrite(
  String collection,
  List<Map<String, dynamic>> records,
  http.Client authClient,
) async {
  for (var i = 0; i < records.length; i += _batchSize) {
    final batch = records.skip(i).take(_batchSize).toList();
    final writes = <Map<String, dynamic>>[];

    for (final record in batch) {
      final id = record['id'] as String;
      final fields = _convertToFirestoreFields(record);
      writes.add({
        'update': {'name': '$_resourcePrefix/$collection/$id', 'fields': fields},
      });
    }

    final response = await _post(authClient, '$_baseUrl/documents:batchWrite', {
      'writes': writes,
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}

Map<String, dynamic> _convertToFirestoreFields(Map<String, dynamic> record) {
  final fields = <String, dynamic>{};
  for (final entry in record.entries) {
    if (entry.key == 'id') continue;
    fields[entry.key] = _convertValue(entry.value);
  }
  return fields;
}

Map<String, dynamic> _convertValue(dynamic value) {
  if (value == null) return {'nullValue': null};
  if (value is String) return {'stringValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value.toString()};
  if (value is bool) return {'booleanValue': value};
  if (value is List) {
    return {
      'arrayValue': {'values': value.map(_convertValue).toList()},
    };
  }
  if (value is Map) {
    return {
      'mapValue': {
        'fields': value.map((k, v) => MapEntry(k, _convertValue(v))),
      },
    };
  }
  throw UnsupportedError(
    'Unsupported value type: ${value.runtimeType} for value: $value',
  );
}

String _getRecordLabel(String collection, Map<String, dynamic> record) {
  switch (collection) {
    case 'buses':
      return '${record['busNumber']} - ${record['routeName']}';
    case 'routes':
      return '${record['routeNumber']} - ${record['title']}';
    case 'stops':
      return record['name'] as String;
    default:
      return record['id'] as String? ?? '(unknown)';
  }
}

_ImportParams _parseArgs(List<String> args) {
  bool dryRun = false;
  String serviceAccount = 'service-account.json';
  String dataDir = 'tools/data';

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--dry-run') {
      dryRun = true;
    } else if (arg == '--service-account') {
      if (i + 1 < args.length) {
        serviceAccount = args[i + 1];
        i++;
      }
    } else if (arg == '--data-dir') {
      if (i + 1 < args.length) {
        dataDir = args[i + 1];
        i++;
      }
    }
  }

  return _ImportParams(
    dryRun: dryRun,
    serviceAccountPath: serviceAccount,
    dataDir: dataDir,
  );
}

class _ImportParams {
  final bool dryRun;
  final String serviceAccountPath;
  final String dataDir;

  const _ImportParams({
    required this.dryRun,
    required this.serviceAccountPath,
    required this.dataDir,
  });
}

class _ImportResult {
  final int imported;
  final int skipped;
  final int failed;

  const _ImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });

  factory _ImportResult.zero() =>
      const _ImportResult(imported: 0, skipped: 0, failed: 0);
}
