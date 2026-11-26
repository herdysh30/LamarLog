import 'dart:convert';

import 'package:flutter/services.dart';

enum RegionLevel { globalHub, regency, district, province }

class RegionSuggestion {
  const RegionSuggestion({
    required this.displayLabel,
    required this.primaryText,
    required this.secondaryText,
    required this.level,
    required this.searchKey,
  });

  /// Full formatted location string inserted into the form field.
  /// e.g. "Setiabudi, Jakarta Selatan, DKI Jakarta" or "Kota Bandung, Jawa Barat".
  final String displayLabel;

  /// Bold primary label shown in the autocomplete dropdown.
  final String primaryText;

  /// Subtle subtitle shown below the primary label (regency/province).
  final String secondaryText;

  final RegionLevel level;

  /// Lowercased concatenated search key for fast substring matching.
  final String searchKey;
}

class IndonesiaRegionsService {
  IndonesiaRegionsService._();

  static final IndonesiaRegionsService instance = IndonesiaRegionsService._();

  static const String assetPath = 'assets/data/indonesia_regions.json';

  List<RegionSuggestion>? _cache;
  Future<List<RegionSuggestion>>? _loading;

  Future<List<RegionSuggestion>> ensureLoaded() {
    if (_cache != null) return Future.value(_cache!);
    return _loading ??= _loadFromAsset();
  }

  Future<List<RegionSuggestion>> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final parsed = parseFromJsonString(raw);
      _cache = parsed;
      return parsed;
    } catch (_) {
      // Gracefully fall back to free-text typing if bundled asset fails to load
      return const [];
    }
  }

  /// Pure parser so the dataset & ranking can be unit-tested directly.
  static List<RegionSuggestion> parseFromJsonString(String rawJson) {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final provinces =
        (decoded['p'] as List<dynamic>? ?? const []).cast<String>();
    final regencies = decoded['r'] as List<dynamic>? ?? const [];
    final globalHubs =
        (decoded['g'] as List<dynamic>? ?? const []).cast<String>();

    final results = <RegionSuggestion>[];

    // 1. Global / remote hubs
    for (final hub in globalHubs) {
      results.add(
        RegionSuggestion(
          displayLabel: hub,
          primaryText: hub,
          secondaryText: 'Global / Remote',
          level: RegionLevel.globalHub,
          searchKey: hub.toLowerCase(),
        ),
      );
    }

    // 2. Regencies / Cities (514) and their Districts (~7,285)
    for (final entry in regencies) {
      final row = entry as List<dynamic>;
      final provIdx = (row[0] as num).toInt();
      final regName = row[1] as String;
      final provName =
          (provIdx >= 0 && provIdx < provinces.length) ? provinces[provIdx] : '';
      final districts = (row[2] as List<dynamic>? ?? const []).cast<String>();

      final regLabel =
          provName.isEmpty ? regName : '$regName, $provName';
      results.add(
        RegionSuggestion(
          displayLabel: regLabel,
          primaryText: regName,
          secondaryText: provName,
          level: RegionLevel.regency,
          searchKey: '$regName $provName'.toLowerCase(),
        ),
      );

      for (final distName in districts) {
        final distLabel = provName.isEmpty
            ? '$distName, $regName'
            : '$distName, $regName, $provName';
        results.add(
          RegionSuggestion(
            displayLabel: distLabel,
            primaryText: distName,
            secondaryText: '$regName, $provName',
            level: RegionLevel.district,
            searchKey: '$distName $regName $provName'.toLowerCase(),
          ),
        );
      }
    }

    // 3. Provinces (38)
    for (final prov in provinces) {
      results.add(
        RegionSuggestion(
          displayLabel: prov,
          primaryText: prov,
          secondaryText: 'Indonesia',
          level: RegionLevel.province,
          searchKey: '$prov indonesia'.toLowerCase(),
        ),
      );
    }

    return results;
  }

  /// Instant offline ranked search across all provinces, cities/regencies,
  /// districts (kecamatan), and global hubs.
  static List<RegionSuggestion> searchInList(
    List<RegionSuggestion> items,
    String query, {
    int limit = 15,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      // Return popular hubs & major Indonesian cities when field is empty/focused
      const featured = {
        'jakarta selatan',
        'jakarta pusat',
        'kota bandung',
        'kota surabaya',
        'kota tangerang selatan',
        'kota yogyakarta',
        'remote (indonesia)',
        'singapore',
      };
      return items
          .where((item) =>
              (item.level == RegionLevel.regency ||
                  item.level == RegionLevel.globalHub) &&
              featured.contains(item.primaryText.toLowerCase()))
          .take(limit)
          .toList();
    }

    final tokens =
        normalized.split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return const [];

    final scored = <(int, RegionSuggestion)>[];

    for (final item in items) {
      var allMatch = true;
      for (final token in tokens) {
        if (!item.searchKey.contains(token)) {
          allMatch = false;
          break;
        }
      }
      if (!allMatch) continue;

      final primaryLower = item.primaryText.toLowerCase();
      int score = 0;

      // Exact primary match
      if (primaryLower == normalized) {
        score += 100;
      } else if (primaryLower.startsWith(normalized)) {
        score += 65;
      } else if (primaryLower.startsWith(tokens.first)) {
        score += 45;
      } else if (item.searchKey.startsWith(normalized)) {
        score += 30;
      } else {
        score += 10;
      }

      // Slight preference for Cities/Regencies & Global Hubs over Districts
      // when both match the query equally (e.g., "Bandung" shows Kota Bandung first).
      switch (item.level) {
        case RegionLevel.globalHub:
          score += 18;
        case RegionLevel.regency:
          score += 15;
        case RegionLevel.province:
          score += 10;
        case RegionLevel.district:
          score += 6;
      }

      scored.add((score, item));
    }

    scored.sort((a, b) {
      final cmp = b.$1.compareTo(a.$1);
      if (cmp != 0) return cmp;
      return a.$2.displayLabel.length.compareTo(b.$2.displayLabel.length);
    });

    return scored.take(limit).map((e) => e.$2).toList();
  }

  Future<List<RegionSuggestion>> search(String query, {int limit = 15}) async {
    final items = await ensureLoaded();
    return searchInList(items, query, limit: limit);
  }
}
