import 'package:equatable/equatable.dart';

// --- ИСПРАВЛЕНИЕ: Удалено дублирующее определение класса и лишние импорты. ---
// Теперь здесь находится только одно, корректное определение сущности.

class DoctorQueueTicketEntity extends Equatable {
  final String ticketNumber;
  final String status; // 'на_приеме', 'зарегистрирован'
  final int? cabinetNumber;
  final String? patientFullName;

  const DoctorQueueTicketEntity({
    required this.ticketNumber,
    required this.status,
    this.cabinetNumber,
    this.patientFullName,
  });

  @override
  List<Object?> get props => [
    ticketNumber,
    status,
    cabinetNumber,
    patientFullName,
  ];
}
