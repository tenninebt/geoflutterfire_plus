import 'package:meta/meta.dart';

import 'geo_point.dart';

@internal
class GeoBounds {
  const GeoBounds({
    required this.southwest,
    required this.northeast,
  });

  final GeoPoint southwest;
  final GeoPoint northeast;

  /// Get the latitude delta of the bounds
  double get latitudeDelta => (northeast.latitude - southwest.latitude).abs();

  /// Get the longitude delta of the bounds
  double get longitudeDelta =>
      (northeast.longitude - southwest.longitude).abs();

  /// Get the maximum delta (used for precision calculations)
  double get maxDelta =>
      latitudeDelta > longitudeDelta ? latitudeDelta : longitudeDelta;
}
