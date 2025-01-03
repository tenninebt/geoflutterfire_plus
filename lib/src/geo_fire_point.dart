import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:meta/meta.dart';

import 'geo_point.dart';
import 'math.dart';
import 'utils.dart' as utils;

/// A model corresponds to Cloud Firestore as geopoint field.
class GeoFirePoint {
  /// Instantiates [GeoFirePoint].
  const GeoFirePoint(this.geopoint);

  /// [firestore.GeoPoint] of the location.
  final firestore.GeoPoint geopoint;

  /// Returns latitude of the location.
  double get latitude => geopoint.latitude;

  /// Returns longitude of the location.
  double get longitude => geopoint.longitude;

  /// Returns geohash of [GeoFirePoint].
  String get geohash =>
      encode(latitude: geopoint.latitude, longitude: geopoint.longitude);

  /// Returns all neighbors of [GeoFirePoint].
  List<String> get neighbors => utils.neighborGeohashesOf(geohash: geohash);

  /// Returns distance in kilometers between [GeoFirePoint] and given
  /// [geopoint].
  double distanceToInKm({required final GeoFirePoint geopoint}) =>
      distanceInKm(geopoint1: toGeoPoint(), geopoint2: geopoint.toGeoPoint());

  /// Internal method to convert to [GeoPoint].
  @internal
  GeoPoint toGeoPoint() {
    return GeoPoint(geopoint.latitude, geopoint.longitude);
  }

  /// Returns [geopoint] and [geohash] as Map<String, dynamic>. Can be used when
  /// adding or updating to Firestore document.
  Map<String, dynamic> get data => {'geopoint': geopoint, 'geohash': geohash};
}
