import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentProvider extends ChangeNotifier {
  late Appointment _appointment;

  AppointmentProvider() {
    _appointment = Appointment(
      patientName: 'Rahul Verma',
      patientId: 'PAT-20240712',
      age: 34,
      phoneNumber: '+91 98765 43210',
      dateTime: DateTime(2026, 7, 12, 10, 30),
      status: AppointmentStatus.confirmed,
    );
  }

  Appointment get appointment => _appointment;

  void cancelAppointment() {
    _appointment.status = AppointmentStatus.cancelled;
    notifyListeners();
  }

  void confirmAppointment() {
    _appointment.status = AppointmentStatus.confirmed;
    notifyListeners();
  }
}
