enum AppointmentStatus { confirmed, unconfirmed, cancelled }

class Appointment {
  final String patientName;
  final String patientId;
  final int age;
  final String phoneNumber;
  final DateTime dateTime;
  AppointmentStatus status;

  Appointment({
    required this.patientName,
    required this.patientId,
    required this.age,
    required this.phoneNumber,
    required this.dateTime,
    required this.status,
  });
}
