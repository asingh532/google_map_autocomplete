import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  double? latitude;
  double? longitude;
  String address;

  MapScreen(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.address})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition _cameraPosition;
  final List<Marker> _marker = <Marker>[];

  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();

    _cameraPosition = CameraPosition(
      target: LatLng(widget.latitude!, widget.longitude!),
      zoom: 14,
    );

    _marker.add(Marker(
        markerId: const MarkerId('1'),
        infoWindow: InfoWindow(title: widget.address),
        position: LatLng(widget.latitude!, widget.longitude!)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        compassEnabled: true,
        mapType: MapType.normal,
        markers: Set<Marker>.of(_marker),
        initialCameraPosition: _cameraPosition,
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
