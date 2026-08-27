import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/trip_provider.dart';
class TripsScreen extends StatelessWidget { const TripsScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<TripProvider>(title: 'Trips & Meetings'); }
