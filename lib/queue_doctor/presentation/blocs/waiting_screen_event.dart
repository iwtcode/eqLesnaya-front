import 'package:equatable/equatable.dart';

// --- ИЗМЕНЕНИЕ: Список событий полностью переработан ---
// Убраны события InitializeCabinetSelection, FilterCabinets, LoadWaitingScreen,
// так как они больше не нужны.

abstract class WaitingScreenEvent extends Equatable {
  const WaitingScreenEvent();

  @override
  List<Object> get props => [];
}

// Новое единственное событие для запуска подписки на обновления
class SubscribeToQueueUpdates extends WaitingScreenEvent {}
