import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire_plus/src/geo_bounds.dart';
import 'package:geoflutterfire_plus/src/geo_point.dart';
import 'package:geoflutterfire_plus/src/math.dart';

void main() {
  test(
    'Test geohashDigitsFromRadius method.',
    () {
      expect(geohashDigitsFromRadius(0.00477), 9);
      expect(geohashDigitsFromRadius(0.0382), 8);
      expect(geohashDigitsFromRadius(0.153), 7);
      expect(geohashDigitsFromRadius(1.22), 6);
      expect(geohashDigitsFromRadius(4.89), 5);
      expect(geohashDigitsFromRadius(39.1), 4);
      expect(geohashDigitsFromRadius(156), 3);
      expect(geohashDigitsFromRadius(1250), 2);
      expect(geohashDigitsFromRadius(1251), 1);
    },
  );

  group(
    'geohashPrecisionForBounds',
    () {
      test('handles large areas with precision 1 (~5000km cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(50, 140),
              southwest: GeoPoint(30, 120),
            ),
          ),
          1,
          reason: 'Large areas should use precision 1',
        );
      });

      test('handles regional areas with precision 2 (~1250km cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(40, 140),
              southwest: GeoPoint(35, 135),
            ),
          ),
          2,
          reason: 'Regional areas should use precision 2',
        );
      });

      test('handles city-sized areas with precision 3 (~156km cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(36, 140),
              southwest: GeoPoint(35, 139),
            ),
          ),
          3,
          reason: 'City-sized areas should use precision 3',
        );
      });

      test('handles district-sized areas with precision 4 (~39km cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.25, 139.25),
              southwest: GeoPoint(35, 139),
            ),
          ),
          4,
          reason: 'District-sized areas should use precision 4',
        );
      });

      test('handles neighborhood-sized areas with precision 5 (~4.9km cells)',
          () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.02, 139.02),
              southwest: GeoPoint(35, 139),
            ),
          ),
          5,
          reason: 'Neighborhood-sized areas should use precision 5',
        );
      });

      test('handles block-sized areas with precision 6 (~1.2km cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.005, 139.005),
              southwest: GeoPoint(35, 139),
            ),
          ),
          6,
          reason: 'Block-sized areas should use precision 6',
        );
      });

      test('handles street-sized areas with precision 7 (~153m cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.001, 139.001),
              southwest: GeoPoint(35, 139),
            ),
          ),
          7,
          reason: 'Street-sized areas should use precision 7',
        );
      });

      test('handles building-sized areas with precision 8 (~38m cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.0002, 139.0002),
              southwest: GeoPoint(35, 139),
            ),
          ),
          8,
          reason: 'Building-sized areas should use precision 8',
        );
      });

      test('handles room-sized areas with precision 9 (~4.8m cells)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              northeast: GeoPoint(35.00004, 139.00004),
              southwest: GeoPoint(35, 139),
            ),
          ),
          9,
          reason: 'Room-sized areas should use precision 9',
        );
      });

      test('handles single point (0,0) with maximum precision', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(0, 0),
              northeast: GeoPoint(0, 0),
            ),
          ),
          9,
          reason: 'Single point should use maximum precision',
        );
      });

      test('handles reversed north/south coordinates', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(36, 139),
              northeast: GeoPoint(35, 140),
            ),
          ),
          3,
        );
      });

      test('handles reversed east/west coordinates', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(35, 140),
              northeast: GeoPoint(36, 139),
            ),
          ),
          3,
        );
      });

      test('handles completely reversed coordinates', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(36, 140),
              northeast: GeoPoint(35, 139),
            ),
          ),
          3,
        );
      });

      test('handles horizontal line (same latitude)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(35, 139),
              northeast: GeoPoint(35, 140),
            ),
          ),
          3,
        );
      });

      test('handles vertical line (same longitude)', () {
        expect(
          geohashPrecisionForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(35, 139),
              northeast: GeoPoint(36, 139),
            ),
          ),
          3,
        );
      });

      test('handles extreme coordinates', () {
        const bounds = GeoBounds(
          southwest: GeoPoint(-90, -180),
          northeast: GeoPoint(90, 180),
        );
        expect(
          geohashPrecisionForBounds(bounds: bounds),
          1,
          reason: 'Should use minimum precision for world-sized bounds',
        );
      });
    },
  );

  group(
    'geohashesForBounds',
    () {
      test(
        'returns valid geohashes for normal bounds',
        () {
          final geohashes = geohashesForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(35.6, 139.7),
              northeast: GeoPoint(35.7, 139.8),
            ),
            precision: 5,
          );

          expect(geohashes, isNotEmpty);
          expect(geohashes.every((final hash) => hash.length == 5), true);
        },
      );

      test(
        'returns single geohash for single point (0,0)',
        () {
          final singlePointGeohashes = geohashesForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(0, 0),
              northeast: GeoPoint(0, 0),
            ),
            precision: 5,
          );
          expect(singlePointGeohashes.length, 1);
        },
      );

      test(
        'handles reversed coordinates correctly',
        () {
          final reversedGeohashes = geohashesForBounds(
            bounds: const GeoBounds(
              southwest: GeoPoint(35.7, 139.8),
              northeast: GeoPoint(35.6, 139.7),
            ),
            precision: 5,
          );
          expect(reversedGeohashes, isNotEmpty);
        },
      );

      test('handles very small area with high precision', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(35.68123, 139.76712),
            northeast: GeoPoint(35.68124, 139.76713),
          ),
          precision: 9,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 9), true);
      });

      test('handles area crossing the 180th meridian', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(35, 179),
            northeast: GeoPoint(36, -179),
          ),
          precision: 5,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 5), true);
      });

      test('handles area crossing the equator', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(-1, 35),
            northeast: GeoPoint(1, 36),
          ),
          precision: 5,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 5), true);
      });

      test('handles extreme precision values', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(35, 139),
            northeast: GeoPoint(35.1, 139.1),
          ),
          precision: 1,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 1), true);
      });

      test('handles polar regions', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(85, 0),
            northeast: GeoPoint(89, 1),
          ),
          precision: 5,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 5), true);
      });

      test('handles minimum and maximum valid coordinates', () {
        final geohashes = geohashesForBounds(
          bounds: const GeoBounds(
            southwest: GeoPoint(-90, -180),
            northeast: GeoPoint(90, 180),
          ),
          precision: 3,
        );
        expect(geohashes, isNotEmpty);
        expect(geohashes.every((final hash) => hash.length == 3), true);
      });

      test('verifies geohash precision behavior at each level', () {
        final failures = <String>[];
        final testCases = {
          1: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-1 cell
              const GeoPoint(36, 140),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different hemispheres
              const GeoPoint(-35, 139),
            ),
          ),
          2: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-2 cell
              const GeoPoint(35.5, 139.5),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-2 cells
              const GeoPoint(35, 150),
            ),
          ),
          3: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-3 cell
              const GeoPoint(35.1, 139.1),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-3 cells
              const GeoPoint(35, 137),
            ),
          ),
          4: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-4 cell
              const GeoPoint(35.05, 139.05),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-4 cells
              const GeoPoint(35, 139.5),
            ),
          ),
          5: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-5 cell
              const GeoPoint(35.01, 139.01),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-5 cells
              const GeoPoint(35, 139.05),
            ),
          ),
          6: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-6 cell
              const GeoPoint(35.002, 139.002),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-6 cells
              const GeoPoint(35, 139.015),
            ),
          ),
          7: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-7 cell
              const GeoPoint(35.0001, 139.0001),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-7 cells
              const GeoPoint(35, 139.002),
            ),
          ),
          8: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-8 cell
              const GeoPoint(35.00001, 139.00001),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-8 cells
              const GeoPoint(35, 139.0005),
            ),
          ),
          9: (
            shouldMatch: (
              const GeoPoint(35, 139), // Points within same level-9 cell
              const GeoPoint(35.000001, 139.000001),
            ),
            shouldDiffer: (
              const GeoPoint(35, 139), // Points in different level-9 cells
              const GeoPoint(35, 139.00007),
            ),
          ),
        };

        for (final entry in testCases.entries) {
          final precision = entry.key;
          final matchingCase = entry.value.shouldMatch;
          final differingCase = entry.value.shouldDiffer;

          // Test matching case
          final matchingHash1 = encode(
            latitude: matchingCase.$1.latitude,
            longitude: matchingCase.$1.longitude,
            geohashLength: precision,
          );
          final matchingHash2 = encode(
            latitude: matchingCase.$2.latitude,
            longitude: matchingCase.$2.longitude,
            geohashLength: precision,
          );

          if (matchingHash1 != matchingHash2) {
            failures.add(
              'Precision $precision: Points should have matching geohashes',
            );
          }

          // Test differing case
          final differingHash1 = encode(
            latitude: differingCase.$1.latitude,
            longitude: differingCase.$1.longitude,
            geohashLength: precision,
          );
          final differingHash2 = encode(
            latitude: differingCase.$2.latitude,
            longitude: differingCase.$2.longitude,
            geohashLength: precision,
          );

          if (differingHash1 == differingHash2) {
            failures.add(
              'Precision $precision: Points should have different geohashes',
            );
          }
        }

        expect(failures, isEmpty, reason: failures.join('\n'));
      });

      test('geohashesForBounds handles partial cell coverage correctly', () {
        // Create bounds that definitely intersect with multiple cells
        const bounds = GeoBounds(
          northeast: GeoPoint(35.001, 139.001),
          southwest: GeoPoint(34.999, 138.999),
        );

        // Get precision for these bounds
        final precision = geohashPrecisionForBounds(bounds: bounds);

        // Get all intersecting geohashes
        final geohashes = geohashesForBounds(
          bounds: bounds,
          precision: precision,
        );

        const expectedCount = 9;
        expect(
          geohashes.length,
          expectedCount,
          reason:
              'Should return exactly $expectedCount geohashes for a 3x3 grid',
        );
      });
    },
  );

  group('distanceInKm', () {
    test('calculates large distance across hemispheres (Sydney to Paris)', () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(-33.854816, 151.216454), // Sydney
        geopoint2: const GeoPoint(48.856610, 2.351499), // Paris
      );
      expect(distance, closeTo(16960.01, 10.0));
    });

    test('calculates trans-atlantic distance (Paris to New York)', () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(48.856610, 2.351499), // Paris
        geopoint2: const GeoPoint(40.714270, -74.005970), // New York
      );
      expect(distance, closeTo(5837.10, 5.0));
    });

    test('calculates sub-kilometer precision for very short distances', () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(43.613190, 3.882199), // Le Corum
        geopoint2: const GeoPoint(43.608687, 3.880005), // Place de la Comédie
      );
      expect(distance, closeTo(0.53, 0.01));
    });

    test(
        'calculates distance across polar region (Baker Lake to Saint Petersburg)',
        () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(64.318858, -96.021424), // Baker Lake
        geopoint2: const GeoPoint(59.938630, 30.314130), // Saint Petersburg
      );
      expect(distance, closeTo(5488.02, 5.0));
    });

    test(
        'calculates distance across southern hemisphere (Buenos Aires to Perth)',
        () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(-34.613150, -58.377230), // Buenos Aires
        geopoint2: const GeoPoint(-31.952712, 115.860480), // Perth
      );
      expect(distance, closeTo(12588.84, 10.0));
    });

    test('calculates distance across 180th meridian (Fiji to Samoa)', () {
      final distance = distanceInKm(
        geopoint1: const GeoPoint(-18, 178), // Fiji
        geopoint2: const GeoPoint(-13.800000, -172.133330), // Samoa
      );
      expect(distance, closeTo(1153.53, 1.0));
    });
  });
}
