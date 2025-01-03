import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire_plus/src/geo_bounds.dart';
import 'package:geoflutterfire_plus/src/geo_point.dart';
import 'package:geoflutterfire_plus/src/math.dart';

void main() {
  test('Test geohashDigitsFromRadius method.', () {
    expect(geohashDigitsFromRadius(0.00477), 9);
    expect(geohashDigitsFromRadius(0.0382), 8);
    expect(geohashDigitsFromRadius(0.153), 7);
    expect(geohashDigitsFromRadius(1.22), 6);
    expect(geohashDigitsFromRadius(4.89), 5);
    expect(geohashDigitsFromRadius(39.1), 4);
    expect(geohashDigitsFromRadius(156), 3);
    expect(geohashDigitsFromRadius(1250), 2);
    expect(geohashDigitsFromRadius(1251), 1);
  });

  test('Test geohashPrecisionForBounds method', () {
    expect(
      geohashPrecisionForBounds(
        bounds: const GeoBounds(
          southwest: GeoPoint(35.6, 139.7),
          northeast: GeoPoint(35.7, 139.8),
        ),
      ),
      7,
    );

    expect(
      geohashPrecisionForBounds(
        bounds: const GeoBounds(
          southwest: GeoPoint(35, 139),
          northeast: GeoPoint(36, 140),
        ),
      ),
      6,
    );
  });

  test('Test geohashesForBounds method', () {
    final geohashes = geohashesForBounds(
      bounds: const GeoBounds(
        southwest: GeoPoint(35.6, 139.7),
        northeast: GeoPoint(35.7, 139.8),
      ),
      precision: 5,
    );

    expect(geohashes, isNotEmpty);
    expect(geohashes.every((final hash) => hash.length == 5), true);
  });
}
