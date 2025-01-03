import 'geo_bounds.dart';
import 'geo_fire_point.dart';

/// Represents a rectangular geographical area defined by its southwest and northeast corners.
class GeoFireBounds {
  /// Creates a [GeoFireBounds] from two [GeoFirePoint]s representing the
  /// southwest and northeast corners of the rectangle.
  const GeoFireBounds({
    required this.southwest,
    required this.northeast,
  });

  /// The southwest corner of the rectangle.
  final GeoFirePoint southwest;

  /// The northeast corner of the rectangle.
  final GeoFirePoint northeast;

  /// Converts this [GeoFireBounds] to a [GeoBounds].
  GeoBounds toGeoBounds() => GeoBounds(
        southwest: southwest.toGeoPoint(),
        northeast: northeast.toGeoPoint(),
      );
}
