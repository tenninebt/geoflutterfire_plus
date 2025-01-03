import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire_plus/src/geo_collection_reference.dart';
import 'package:geoflutterfire_plus/src/geo_fire_bounds.dart';
import 'package:geoflutterfire_plus/src/geo_fire_point.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'geo_collection_reference_test.mocks.dart';

@GenerateMocks([
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  Query,
])
void main() {
  group('Test GeoCollectionReference writing methods.', () {
    late final MockCollectionReference<Object> mockCollectionReference;
    late final MockDocumentReference<Object> mockDocumentReference;
    late final GeoCollectionReference<Object> geoCollectionReference;

    setUpAll(() {
      mockCollectionReference = MockCollectionReference<Object>();
      mockDocumentReference = MockDocumentReference<Object>();
      geoCollectionReference =
          GeoCollectionReference<Object>(mockCollectionReference);
    });

    test(
        'Test when GeoCollectionReference.add method is called, '
        'CollectionReference.add method is called once.', () async {
      final data = {'field': 'value'};
      when(mockCollectionReference.add(data))
          .thenAnswer((final _) => Future.value(mockDocumentReference));
      await geoCollectionReference.add(data);
      verify(mockCollectionReference.add(data)).called(1);
    });

    test(
        'Test when GeoCollectionReference.set method is called, '
        'DocumentReference.set method is called once.', () async {
      const id = 'documentId';
      final data = {'field': 'value'};
      final options = SetOptions(merge: true);
      when(mockCollectionReference.doc(id))
          .thenAnswer((final _) => mockDocumentReference);
      when(mockDocumentReference.set(data))
          .thenAnswer((final _) => Future<void>.value());
      await geoCollectionReference.set(id: id, data: data, options: options);
      verify(mockDocumentReference.set(data, options)).called(1);
    });

    test(
        'Test when GeoCollectionReference.updatePoint method is called, '
        'DocumentReference.update method is called once.', () async {
      const id = 'documentId';
      const field = 'geo';
      const geopoint = GeoPoint(35.681236, 139.767125);
      final data = <String, dynamic>{field: const GeoFirePoint(geopoint).data};
      when(mockCollectionReference.doc(id))
          .thenAnswer((final _) => mockDocumentReference);
      when(mockDocumentReference.update(data))
          .thenAnswer((final _) => Future<void>.value());
      await geoCollectionReference.updatePoint(
        id: id,
        field: field,
        geopoint: geopoint,
      );
      verify(mockDocumentReference.update(data)).called(1);
    });

    test(
        'Test when GeoCollectionReference.delete method is called, '
        'DocumentReference.delete method is called once.', () async {
      const id = 'documentId';
      when(mockCollectionReference.doc(id))
          .thenAnswer((final _) => mockDocumentReference);
      when(mockDocumentReference.delete())
          .thenAnswer((final _) => Future<void>.value());
      await geoCollectionReference.delete(id);
      verify(mockDocumentReference.delete()).called(1);
    });
  });

  // group('GeoCollectionReference.geoQuery', () {
  //   /// FakeFirebaseFirestore collection reference.
  //   final fakeCollectionReference =
  //       FakeFirebaseFirestore().collection('locations');

  //   /// Geohash strings to be stored, includes invalid characters as geohashes
  //   /// for testing.
  //   const geohashes = <String>[
  //     'a',
  //     'aaa',
  //     'aab',
  //     'aabaaaa',
  //     'aaz',
  //     'aa{',
  //     'aa|',
  //     'aa}',
  //     'aa~',
  //     'aba',
  //     'bbb',
  //     'efg',
  //   ];

  //   /// A field name of geohashes to be stored.
  //   const field = 'geo';

  //   setUpAll(() async {
  //     await Future.forEach<String>(geohashes, (final geohash) async {
  //       await fakeCollectionReference.add({
  //         '$field.geohash': geohash,
  //       });
  //     });
  //   });

  //   test('fetch geohashes with Firestore startAt, endAt query.', () async {
  //     final geoCollectionReference =
  //         GeoCollectionReference(fakeCollectionReference);
  //     final querySnapshot = await geoCollectionReference
  //         .geoQuery(field: field, geohash: 'aa')
  //         .get();
  //     final fetchedGeohashes =
  //         querySnapshot.docs.map((final queryDocumentSnapshot) {
  //       final data = queryDocumentSnapshot.data();
  //       return (data['geo'] as Map<String, dynamic>)['geohash'] as String;
  //     }).toList();
  //     expect(fetchedGeohashes, ['aaa', 'aab', 'aabaaaa', 'aaz', 'aa{']);
  //   });

  //   test(
  //       'fetch geohashes with Firestore startAt, endAt query, '
  //       'overriding rangeQueryEndAtCharacter parameter', () async {
  //     final geoCollectionReference = GeoCollectionReference(
  //       fakeCollectionReference,
  //       rangeQueryEndAtCharacter: '~',
  //     );
  //     final querySnapshot = await geoCollectionReference
  //         .geoQuery(field: field, geohash: 'aa')
  //         .get();
  //     final fetchedGeohashes =
  //         querySnapshot.docs.map((final queryDocumentSnapshot) {
  //       final data = queryDocumentSnapshot.data();
  //       return (data['geo'] as Map<String, dynamic>)['geohash'] as String;
  //     }).toList();
  //     expect(
  //       fetchedGeohashes,
  //       ['aaa', 'aab', 'aabaaaa', 'aaz', 'aa{', 'aa|', 'aa}', 'aa~'],
  //     );
  //   });
  // });

  group('Test bounds query methods', () {
    test('fetchWithinBounds returns correct documents', () async {
      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      final geoCollectionReference =
          GeoCollectionReference(mockCollectionReference);

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      when(mockCollectionReference.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.startAt(any)).thenReturn(mockQuery);
      when(mockQuery.endAt(any)).thenReturn(mockQuery);
      when(mockQuery.get(any))
          .thenAnswer((final _) => Future.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      final docs = await geoCollectionReference.fetchWithinBounds(
        bounds: const GeoFireBounds(
          southwest: GeoFirePoint(GeoPoint(35, 139)),
          northeast: GeoFirePoint(GeoPoint(36, 140)),
        ),
        field: 'geo',
        geopointFrom: (final data) =>
            (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      );

      expect(docs, isA<List<DocumentSnapshot>>());
      verify(mockQuery.get(any)).called(greaterThan(0));
    });

    test('subscribeWithinBounds emits correct documents', () {
      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      final geoCollectionReference =
          GeoCollectionReference(mockCollectionReference);

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      when(mockCollectionReference.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.startAt(any)).thenReturn(mockQuery);
      when(mockQuery.endAt(any)).thenReturn(mockQuery);
      when(mockQuery.snapshots())
          .thenAnswer((final _) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      final stream = geoCollectionReference.subscribeWithinBounds(
        bounds: const GeoFireBounds(
          southwest: GeoFirePoint(GeoPoint(35, 139)),
          northeast: GeoFirePoint(GeoPoint(36, 140)),
        ),
        field: 'geo',
        geopointFrom: (final data) =>
            (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      );

      expect(stream, emits(isA<List<DocumentSnapshot>>()));
    });
  });
}
