import 'dart:async';
import '../../domain/entities/queue_entity.dart';
import '../models/queue_model.dart';
import '../../data/datasourcers/queue_data_source.dart';

class LocalQueueDataSource implements QueueDataSource {
  QueueModel _currentStatus = QueueModel(
    isAppointmentInProgress: false,
    isOnBreak: false,
    queueLength: 5,
  );

  @override
  Future<QueueEntity> getQueueStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentStatus;
  }

  @override
  Future<QueueEntity> startAppointment(String ticket) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentStatus = QueueModel(
      isAppointmentInProgress: true,
      isOnBreak: false,
      queueLength: _currentStatus.queueLength,
      currentTicket: ticket,
    );
    return _currentStatus;
  }

  @override
  Future<QueueEntity> endAppointment() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentStatus = QueueModel(
      isAppointmentInProgress: false,
      isOnBreak: false,
      queueLength: _currentStatus.queueLength - 1,
      currentTicket: _currentStatus.currentTicket,
    );
    return _currentStatus;
  }

  @override
  Stream<void> ticketUpdates() {
     return Stream.value(null).asBroadcastStream();
   }

  @override
  Future<QueueEntity> startBreak() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentStatus = QueueModel(
      isAppointmentInProgress: false,
      isOnBreak: true,
      queueLength: _currentStatus.queueLength,
      currentTicket: _currentStatus.currentTicket,
    );
    return _currentStatus;
  }

  @override
  Future<QueueEntity> endBreak() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentStatus = QueueModel(
      isAppointmentInProgress: false,
      isOnBreak: false,
      queueLength: _currentStatus.queueLength,
      currentTicket: _currentStatus.currentTicket,
    );
    return _currentStatus;
  }

}
