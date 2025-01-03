import 'dart:math';

import 'geo_bounds.dart';
import 'geo_point.dart';

/// 32 codes to use aas Base32.
const _base32Codes = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Base 32 codes map.
const _base32CodesMap = <String, int>{
  '0': 0,
  '1': 1,
  '2': 2,
  '3': 3,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
  'b': 10,
  'c': 11,
  'd': 12,
  'e': 13,
  'f': 14,
  'g': 15,
  'h': 16,
  'j': 17,
  'k': 18,
  'm': 19,
  'n': 20,
  'p': 21,
  'q': 22,
  'r': 23,
  's': 24,
  't': 25,
  'u': 26,
  'v': 27,
  'w': 28,
  'x': 29,
  'y': 30,
  'z': 31,
};

/// Returns geohash String from [latitude] and [longitude],
/// whose length is equal to [geohashLength].
String encode({
  required final double latitude,
  required final double longitude,
  final int geohashLength = 9,
}) {
  final characters = <String>[];
  var bits = 0;
  var bitsTotal = 0;
  var hashValue = 0;
  var maxLatitude = 90.0;
  var minLatitude = -90.0;
  var maxLongitude = 180.0;
  var minLongitude = -180.0;

  while (characters.length < geohashLength) {
    if (bitsTotal.isEven) {
      final middle = _getMiddleOf(maxLongitude, minLongitude);
      if (longitude > middle) {
        hashValue = (hashValue << 1) + 1;
        minLongitude = middle;
      } else {
        hashValue = (hashValue << 1) + 0;
        maxLongitude = middle;
      }
    } else {
      final middle = _getMiddleOf(maxLatitude, minLatitude);
      if (latitude > middle) {
        hashValue = (hashValue << 1) + 1;
        minLatitude = middle;
      } else {
        hashValue = (hashValue << 1) + 0;
        maxLatitude = middle;
      }
    }

    bits++;
    bitsTotal++;
    if (bits == 5) {
      final code = _base32Codes[hashValue];
      characters.add(code);
      bits = 0;
      hashValue = 0;
    }
  }
  return characters.join();
}

/// Decodes a [geohash] string into [_CoordinatesWithErrors].
/// It includes 'latitude', 'longitude', 'latitudeError', 'longitudeError'.
_CoordinatesWithErrors _decode(final String geohash) {
  final bounds = _decodedBounds(geohash);
  final latitude = _getMiddleOf(
    bounds.southwest.latitude,
    bounds.northeast.latitude,
  );
  final longitude = _getMiddleOf(
    bounds.southwest.longitude,
    bounds.northeast.longitude,
  );
  final latitudeError = bounds.northeast.latitude - latitude;
  final longitudeError = bounds.northeast.longitude - longitude;

  return _CoordinatesWithErrors(
    latitude: latitude,
    longitude: longitude,
    latitudeError: latitudeError,
    longitudeError: longitudeError,
  );
}

/// Decodes a hashString into bounds that match it.
GeoBounds _decodedBounds(final String geohash) {
  var isLongitude = true;
  var maxLatitude = 90.0;
  var minLatitude = -90.0;
  var maxLongitude = 180.0;
  var minLongitude = -180.0;

  for (var i = 0; i < geohash.length; i++) {
    final code = geohash[i].toLowerCase();
    final hashValue = _base32CodesMap[code];
    for (var bits = 4; bits >= 0; bits--) {
      final bit = (hashValue! >> bits) & 1;
      if (isLongitude) {
        final middle = _getMiddleOf(maxLongitude, minLongitude);
        if (bit == 1) {
          minLongitude = middle;
        } else {
          maxLongitude = middle;
        }
      } else {
        final middle = _getMiddleOf(maxLatitude, minLatitude);
        if (bit == 1) {
          minLatitude = middle;
        } else {
          maxLatitude = middle;
        }
      }
      isLongitude = !isLongitude;
    }
  }

  return GeoBounds(
    southwest: GeoPoint(minLatitude, minLongitude),
    northeast: GeoPoint(maxLatitude, maxLongitude),
  );
}

const _clockwiseNeighborDirections = [
  _NeighborDirection(latitudeDirection: 1, longitudeDirection: 0),
  _NeighborDirection(latitudeDirection: 1, longitudeDirection: 1),
  _NeighborDirection(latitudeDirection: 0, longitudeDirection: 1),
  _NeighborDirection(latitudeDirection: -1, longitudeDirection: 1),
  _NeighborDirection(latitudeDirection: -1, longitudeDirection: 0),
  _NeighborDirection(latitudeDirection: -1, longitudeDirection: -1),
  _NeighborDirection(latitudeDirection: 0, longitudeDirection: -1),
  _NeighborDirection(latitudeDirection: 1, longitudeDirection: -1),
];

/// Returns all neighbors' geohash strings of given [geohash] clockwise,
/// in the following order, north, east, south, and then west.
List<String> neighborGeohashesOf(final String geohash) {
  final coordinatesWithErrors = _decode(geohash);
  return _clockwiseNeighborDirections
      .map(
        (final direction) =>
            direction.encodeNeighbor(coordinatesWithErrors, geohash.length),
      )
      .toList();
}

class _NeighborDirection {
  const _NeighborDirection({
    required this.latitudeDirection,
    required this.longitudeDirection,
  });

  final int latitudeDirection;
  final int longitudeDirection;

  /// Returns neighbor geohash of given [coordinatesWithErrors].
  String encodeNeighbor(
    final _CoordinatesWithErrors coordinatesWithErrors,
    final int geohashLength,
  ) {
    return encode(
      latitude: coordinatesWithErrors.latitude +
          latitudeDirection * coordinatesWithErrors.latitudeError * 2,
      longitude: coordinatesWithErrors.longitude +
          longitudeDirection * coordinatesWithErrors.longitudeError * 2,
      geohashLength: geohashLength,
    );
  }
}

/// Returns geohash digits from [radius] in kilometers,
/// which decide how precisely detect neighbors.
///
/// * 1	≤ 5,000km x 5,000km
/// * 2	≤ 1,250km x 625km
/// * 3	≤ 156km x 156km
/// * 4	≤ 39.1km x 19.5km
/// * 5	≤ 4.89km x 4.89km
/// * 6	≤ 1.22km x 0.61km
/// * 7	≤ 153m x 153m
/// * 8	≤ 38.2m x 19.1m
/// * 9	≤ 4.77m x 4.77m
int geohashDigitsFromRadius(final double radius) {
  if (radius <= 0.00477) {
    return 9;
  } else if (radius <= 0.0382) {
    return 8;
  } else if (radius <= 0.153) {
    return 7;
  } else if (radius <= 1.22) {
    return 6;
  } else if (radius <= 4.89) {
    return 5;
  } else if (radius <= 39.1) {
    return 4;
  } else if (radius <= 156) {
    return 3;
  } else if (radius <= 1250) {
    return 2;
  } else {
    return 1;
  }
}

/// The equatorial radius of the earth in meters.
const double _earthEquatorialRadius = 6378137;

/// The meridional radius of the earth in meters.
const double _earthPolarRadius = 6357852.3;

/// Returns distance between [geopoint1] and [geopoint2] in kilometers.
double distanceInKm({
  required final GeoPoint geopoint1,
  required final GeoPoint geopoint2,
}) {
  const radius = (_earthEquatorialRadius + _earthPolarRadius) / 2;
  final latDelta = _toRadians(geopoint2.latitude - geopoint1.latitude);
  final lonDelta = _toRadians(geopoint2.longitude - geopoint1.longitude);

  final a = (sin(latDelta / 2) * sin(latDelta / 2)) +
      (cos(_toRadians(geopoint2.latitude)) *
          cos(_toRadians(geopoint1.latitude)) *
          sin(lonDelta / 2) *
          sin(lonDelta / 2));
  final distance = radius * 2 * atan2(sqrt(a), sqrt(1 - a)) / 1000;
  return double.parse(distance.toStringAsFixed(3));
}

double _toRadians(final double num) => num * (pi / 180.0);

double _getMiddleOf(final double x1, final double x2) => (x1 + x2) / 2;

/// Coordinates ([latitude], [longitude])
/// with each errors ([latitudeError], [longitudeError]).
class _CoordinatesWithErrors {
  const _CoordinatesWithErrors({
    required this.latitude,
    required this.longitude,
    required this.latitudeError,
    required this.longitudeError,
  });

  final double latitude;
  final double longitude;
  final double latitudeError;
  final double longitudeError;
}

/// Returns geohashes that cover the given bounds
List<String> geohashesForBounds({
  required final GeoBounds bounds,
  required final int precision,
}) {
  // Normalize coordinates
  final minLat = min(bounds.southwest.latitude, bounds.northeast.latitude);
  final maxLat = max(bounds.southwest.latitude, bounds.northeast.latitude);
  final minLon = min(bounds.southwest.longitude, bounds.northeast.longitude);
  final maxLon = max(bounds.southwest.longitude, bounds.northeast.longitude);

  // Check if it's a single point
  if (minLat == maxLat && minLon == maxLon) {
    // For single points, return just one geohash
    final hash = encode(
      latitude: minLat,
      longitude: minLon,
      geohashLength: precision,
    );
    return [hash];
  }

  // Get the center point's geohash
  final centerLat = (minLat + maxLat) / 2;
  final centerLon = (minLon + maxLon) / 2;
  final centerHash = encode(
    latitude: centerLat,
    longitude: centerLon,
    geohashLength: precision,
  );

  // Get the neighbors of the center hash
  final neighbors = neighborGeohashesOf(centerHash);

  // Add the center hash and all neighbors
  final geohashes = {centerHash, ...neighbors};
  return geohashes.toList();
}

/// Determines the optimal geohash precision for given bounds.
///
/// While radius-based precision (used in [geohashDigitsFromRadius]) finds cells small
/// enough to provide granular coverage around a point, bounds-based precision needs
/// to optimize for area coverage with minimal cell count.
///
/// For example:
/// - A 0.5km x 0.5km area is best served by precision 7 (0.153km cells)
///   giving a 3x3 grid (9 cells) rather than precision 8 (0.038km cells)
///   which would result in many more cells (about 13x13 = 169 cells)
///
/// The function chooses the first precision level where cells are smaller than
/// the area's largest dimension, ensuring efficient coverage without over-fragmentation.
int geohashPrecisionForBounds({required final GeoBounds bounds}) {
  final latDelta =
      (bounds.northeast.latitude - bounds.southwest.latitude).abs();
  final lonDelta =
      (bounds.northeast.longitude - bounds.southwest.longitude).abs();

  // Handle single point case
  if (latDelta == 0 && lonDelta == 0) {
    return 9; // Maximum precision for single points
  }

  // Convert to km
  final latDistance = latDelta * 111.32;
  // Use average latitude for more accurate longitude distance
  final avgLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
  final lonDistance = lonDelta * 111.32 * cos(avgLat * pi / 180);

  // Use the larger dimension to determine precision
  final maxDistance = max(latDistance, lonDistance);

  // Find the appropriate precision level
  if (maxDistance > 1250.0) return 1;
  if (maxDistance > 156.0) return 2;
  if (maxDistance > 39.1) return 3;
  if (maxDistance > 4.89) return 4;
  if (maxDistance > 1.22) return 5;
  if (maxDistance > 0.153) return 6;
  if (maxDistance > 0.0382) return 7;
  if (maxDistance > 0.00477) return 8;
  return 9;
}
