// --- ИЗМЕНЕНИЕ: Модель полностью переписана для соответствия новому API ---
// Вместо одной большой модели для всего экрана, теперь есть модель для одного талона,
// так как данные приходят в виде списка талонов.

import '../../domain/entities/waiting_screen_entity.dart';

// --- ИСПРАВЛЕНИЕ: Класс теперь корректно наследуется от DoctorQueueTicketEntity ---
class DoctorQueueTicketModel extends DoctorQueueTicketEntity {
  const DoctorQueueTicketModel({
    // --- ИСПРАВЛЕНИЕ: Параметры конструктора теперь правильно передаются в super() ---
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
