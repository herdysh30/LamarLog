import 'dart:io';

import 'package:applyflow/core/models/pipeline_stage_config.dart';
import 'package:applyflow/core/services/indonesia_regions_service.dart';
import 'package:applyflow/core/utils/contact_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndonesiaRegionsService (bundled offline dataset)', () {
    late List<RegionSuggestion> items;

    setUpAll(() {
      final raw = File('assets/data/indonesia_regions.json').readAsStringSync();
      items = IndonesiaRegionsService.parseFromJsonString(raw);
    });

    test('contains all 38 provinces, 514 cities/regencies, and 7,285 districts',
        () {
      final provCount =
          items.where((e) => e.level == RegionLevel.province).length;
      final regCount =
          items.where((e) => e.level == RegionLevel.regency).length;
      final distCount =
          items.where((e) => e.level == RegionLevel.district).length;

      expect(provCount, 38);
      expect(regCount, 514);
      expect(distCount, 7285);
    });

    test('finds Kecamatan Setiabudi (Jakarta Selatan) & Coblong (Bandung)', () {
      final jktResults =
          IndonesiaRegionsService.searchInList(items, 'setiabudi');
      expect(jktResults, isNotEmpty);
      expect(
        jktResults.any(
          (r) => r.displayLabel == 'Setiabudi, Jakarta Selatan, DKI Jakarta',
        ),
        isTrue,
      );

      final bdgResults = IndonesiaRegionsService.searchInList(items, 'coblong');
      expect(bdgResults, isNotEmpty);
      expect(
        bdgResults.any(
          (r) => r.displayLabel == 'Coblong, Kota Bandung, Jawa Barat',
        ),
        isTrue,
      );
    });

    test('ranks Jakarta Selatan city ahead of its districts for exact city query',
        () {
      final results =
          IndonesiaRegionsService.searchInList(items, 'jakarta selatan');

      expect(results, isNotEmpty);
      expect(results.first.displayLabel, 'Jakarta Selatan, DKI Jakarta');
      expect(results.first.level, RegionLevel.regency);
    });

    test('supports multi-token search across district and city names', () {
      final results =
          IndonesiaRegionsService.searchInList(items, 'serpong tangerang');

      expect(results, isNotEmpty);
      expect(
        results.any(
          (r) => r.displayLabel.toLowerCase().contains('serpong') &&
              r.displayLabel.toLowerCase().contains('tangerang'),
        ),
        isTrue,
      );
    });

    test('returns featured hubs when query is empty', () {
      final featured = IndonesiaRegionsService.searchInList(items, '');
      expect(featured, isNotEmpty);
      expect(
        featured.any((r) => r.displayLabel.contains('Jakarta Selatan')),
        isTrue,
      );
    });
  });

  group('PipelineStageConfig', () {
    test('defaults to 5 active stages and separates terminal outcomes strictly',
        () {
      final defaults = PipelineStageConfig.defaults();
      expect(defaults.length, 5);
      expect(defaults.map((e) => e.id).toList(), [
        'wishlist',
        'applied',
        'screening',
        'interview',
        'offering',
      ]);

      expect(PipelineStageConfig.isTerminalStatusId('rejected'), isTrue);
      expect(PipelineStageConfig.isTerminalStatusId('offerAccepted'), isTrue);
      expect(PipelineStageConfig.isTerminalStatusId('noResponse'), isTrue);
      expect(PipelineStageConfig.isTerminalStatusId('custom_psikotes'), isFalse);
    });

    test('round-trips JSON cleanly and strips invalid/terminal stage IDs', () {
      final custom = [
        const PipelineStageConfig(
          id: 'wishlist',
          label: 'Target',
          colorKey: StageColorKey.slate,
        ),
        const PipelineStageConfig(
          id: 'custom_psikotes',
          label: 'Psikotes',
          colorKey: StageColorKey.violet,
        ),
        const PipelineStageConfig(
          id: 'custom_tech_test',
          label: 'Technical Test',
          colorKey: StageColorKey.emerald,
        ),
      ];

      final encoded = PipelineStageConfig.encodeList(custom);
      final decoded = PipelineStageConfig.decodeList(encoded);

      expect(decoded, equals(custom));
    });

    test('generates unique custom stage IDs safely', () {
      final existing = ['wishlist', 'custom_technical_test'];
      final next = PipelineStageConfig.generateCustomId(
        'Technical Test',
        existing,
      );
      expect(next, 'custom_technical_test_2');
    });
  });

  group('ContactLauncher.googleMapsUri', () {
    test('builds valid Google Maps search URI', () {
      final uri = ContactLauncher.googleMapsUri(
        'Setiabudi, Jakarta Selatan, DKI Jakarta',
      );
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/search/');
      expect(uri.queryParameters['api'], '1');
      expect(
        uri.queryParameters['query'],
        'Setiabudi, Jakarta Selatan, DKI Jakarta',
      );
    });
  });
}
