import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

extension STRINGPARSER on String {
  Uri get toUri => Uri.parse(this);
  String pascalToNormal() {
    return replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (match) => ' ',
    ).replaceAllMapped(
      RegExp(r'(?<=\w)(?=-)'),
      (match) => ' ',
    ); // Handles hyphenated names
  }

  String snakeToNormal() {
    return replaceAll("_", " ");
  }

  String obscureEmail() {
    // Split the email into username and domain
    final parts = split('@');
    if (parts.length != 2) {
      return this; // Return original email if it's invalid
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      // If the username is too short, handle it specially
      return '${username[0]}*@$domain';
    }

    // Obscure the middle part of the username
    final firstLetter = username[0];
    final lastLetter = username[username.length - 1];
    final obscuredUsername =
        firstLetter +
        '*' * (username.length - 2) +
        lastLetter; // Replace middle characters with *

    return '$obscuredUsername@$domain';
  }

  TimeOfDay get toTimeOfDay {
    final List<int> ff = split(':').map((e) => int.parse(e)).toList();
    return TimeOfDay(hour: ff.first, minute: ff[1]);
  }

  GeoPoint toGeopoint() {
    List<String> coords = split(',');

    if (coords.length != 2) {
      throw FormatException(
        'Invalid geoString format. Expected "latitude,longitude".',
      );
    }
    // Parse the latitude and longitude from the string
    double latitude = double.parse(coords[0].trim());
    double longitude = double.parse(coords[1].trim());
    return GeoPoint(latitude, longitude);
  }
}
