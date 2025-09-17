import 'package:equatable/equatable.dart';
import '../../domain/entities/waiting_screen_entity.dart';

abstract class WaitingScreenState extends Equatable {
  const WaitingScreenState();

  @override
  List<Object> get props => [];
}

class WaitingScreenInitial extends WaitingScreenState {}

class WaitingScreenLoading extends WaitingScreenState {}

class DoctorQueueLoaded extends WaitingScreenState {
  final List<DoctorQueueTicketEntity> tickets;

  const DoctorQueueLoaded({required this.tickets});

  @override
  List<Object> get props => [tickets];
}

class WaitingScreenError extends WaitingScreenState {
  final String message;

  const WaitingScreenError({required this.message});

  @override
  List<Object> get props => [message];
}
