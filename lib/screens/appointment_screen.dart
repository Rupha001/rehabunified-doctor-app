import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import 'video_call_screen.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apptProvider = context.watch<AppointmentProvider>();
    final appt = apptProvider.appointment;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              theme.colorScheme.primary.withAlpha(30),
                          child: Icon(Icons.person,
                              color: theme.colorScheme.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.patientName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              _StatusBadge(status: appt.status),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Patient ID',
                        value: appt.patientId),
                    _DetailRow(
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: '${appt.age} years'),
                    _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: appt.phoneNumber),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat('EEEE, d MMMM yyyy')
                            .format(appt.dateTime)),
                    _DetailRow(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: DateFormat('h:mm a').format(appt.dateTime)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons based on status
            if (appt.status == AppointmentStatus.confirmed) ...[
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoCallScreen(
                      patientName: appt.patientName,
                      patientId: appt.patientId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.video_call_rounded),
                label: const Text('Start Video Call',
                    style: TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            if (appt.status == AppointmentStatus.unconfirmed) ...[
              OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context, apptProvider),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text('Cancel Appointment',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            if (appt.status == AppointmentStatus.cancelled) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Text(
                      'This appointment has been cancelled.',
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, AppointmentProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No, Keep It'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.cancelAppointment();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Appointment cancelled.'),
                    backgroundColor: Colors.red),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
      case AppointmentStatus.unconfirmed:
        color = Colors.orange;
        label = 'Unconfirmed';
      case AppointmentStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
