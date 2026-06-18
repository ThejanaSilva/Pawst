import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // for GeoPoint
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A simple screen that allows the user to pick a location on a Google Map.
/// Returns a [GeoPoint] via `Navigator.pop` when the user confirms the
/// selection. The caller can also provide an initial [GeoPoint] to centre the
/// map.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  final GeoPoint? initialLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _initialCenter;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    // Default to a generic location (e.g., New York) if none provided.
    final lat = widget.initialLocation?.latitude ?? 40.7128;
    final lng = widget.initialLocation?.longitude ?? -74.0060;
    _initialCenter = LatLng(lat, lng);
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(lat, lng);
    }
  }

  void _onMapTap(LatLng position) {
    // Log the tapped position for debugging.
    debugPrint('Map tapped at: ${position.latitude}, ${position.longitude}');
    setState(() {
      _selectedPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      // Use a Stack so we can overlay a short instruction for the user.
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              // Use the initial center and zoom when the map first loads.
              initialCenter: _initialCenter,
              initialZoom: 12,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.pawst_app',
              ),
              // Show a pin at the selected location (or the initial centre if none yet).
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition ?? _initialCenter,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          // Simple overlay hint.
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Tap the map to place a pin',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedPosition == null
            ? null
            : () {
                final point = _selectedPosition!;
                Navigator.of(context).pop(GeoPoint(point.latitude, point.longitude));
              },
        label: const Text('Confirm'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
