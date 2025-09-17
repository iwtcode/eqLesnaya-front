import '../../domain/entities/waiting_screen_entity.dart';

class DoctorQueueTicketModel extends DoctorQueueTicketEntity {
  const DoctorQueueTicketModel({
    required super.ticketNumber,
    required super.status,
    super.cabinetNumber,
    super.patientFullName,
  });

  factory DoctorQueueTicketModel.fromJson(Map<String, dynamic> json) {
    return DoctorQueueTicketModel(
      ticketNumber: json['ticket_number'] as String? ?? '?',
      status: json['status'] as String? ?? 'неизвестен',
      cabinetNumber: json['cabinet_number'] as int?,
      patientFullName: json['patient_full_name'] as String?,
    );
  }
}
