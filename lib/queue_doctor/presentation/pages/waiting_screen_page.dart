import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/waiting_screen_entity.dart';
import '../blocs/waiting_screen_bloc.dart';
import '../blocs/waiting_screen_event.dart';
import '../blocs/waiting_screen_state.dart';

const Size _kBaseTicketSize = Size(180, 80);
const double _kSpacing = 16.0;
const double _kOuterPadding = 16.0;

class _LayoutConfiguration {
  final int columnCount;
  final Size ticketSize;
  const _LayoutConfiguration({
    required this.columnCount,
    required this.ticketSize,
  });
}

class WaitingScreenPage extends StatefulWidget {
  const WaitingScreenPage({super.key});

  @override
  State<WaitingScreenPage> createState() => _WaitingScreenPageState();
}

class _WaitingScreenPageState extends State<WaitingScreenPage> {
  @override
  void initState() {
    super.initState();
    context.read<WaitingScreenBloc>().add(SubscribeToQueueUpdates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<WaitingScreenBloc, WaitingScreenState>(
        builder: (context, state) {
          if (state is WaitingScreenError) {
            return _buildError(state.message);
          }

          if (state is DoctorQueueLoaded) {
            final inProgressTickets = state.tickets
                .where((t) => t.status == 'на_приеме')
                .toList();
            final waitingTickets = state.tickets
                .where((t) => t.status == 'зарегистрирован')
                .toList();

            return Column(
              children: [
                _buildNewHeader(),
                _buildQueueStatusHeader(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTicketDisplayArea(
                          tickets: waitingTickets,
                          isWaiting: true,
                        ),
                      ),
                      Container(width: 1, color: const Color(0xFFE0E0E0)),
                      Expanded(
                        flex: 1,
                        child: _buildTicketDisplayArea(
                          tickets: inProgressTickets,
                          isWaiting: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildNewHeader(),
              _buildQueueStatusHeader(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B4193),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _LayoutConfiguration _calculateLayout(Size availableSize, int itemCount) {
    if (itemCount == 0 || availableSize.isEmpty) {
      return const _LayoutConfiguration(columnCount: 1, ticketSize: Size.zero);
    }
    _LayoutConfiguration? bestLayout;
    double maxArea = 0.0;
    final double baseAspectRatio = _kBaseTicketSize.aspectRatio;

    for (int cols = 1; cols <= itemCount; cols++) {
      final int rows = (itemCount / cols).ceil();
      const double safetyMargin = 0.01;
      final double totalHorizontalSpacing = (cols - 1) * _kSpacing;
      final double availableWidth =
          availableSize.width - totalHorizontalSpacing - safetyMargin;
      final double widthPerTicket = availableWidth / cols;
      final double availableHeight = availableSize.height - safetyMargin;
      final double heightPerCell = availableHeight / rows;
      final double heightPerTicket = heightPerCell - _kSpacing;

      if (widthPerTicket <= 0 || heightPerTicket <= 0) continue;

      double finalTicketWidth;
      double finalTicketHeight;

      if (widthPerTicket < heightPerTicket * baseAspectRatio) {
        finalTicketWidth = widthPerTicket;
        finalTicketHeight = finalTicketWidth / baseAspectRatio;
      } else {
        finalTicketHeight = heightPerTicket;
        finalTicketWidth = finalTicketHeight * baseAspectRatio;
      }

      finalTicketWidth = min(finalTicketWidth, _kBaseTicketSize.width);
      finalTicketHeight = finalTicketWidth / baseAspectRatio;

      final double currentArea = finalTicketWidth * finalTicketHeight;
      if (currentArea > maxArea) {
        maxArea = currentArea;
        bestLayout = _LayoutConfiguration(
          columnCount: cols,
          ticketSize: Size(finalTicketWidth, finalTicketHeight),
        );
      }
    }
    return bestLayout ??
        const _LayoutConfiguration(columnCount: 1, ticketSize: Size.zero);
  }

  Widget _buildTicketDisplayArea({
    required List<DoctorQueueTicketEntity> tickets,
    required bool isWaiting,
  }) {
    return Padding(
      padding: const EdgeInsets.all(_kOuterPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (tickets.isEmpty) {
            return Center(
              child: Text(
                isWaiting
                    ? 'Нет пациентов в очереди'
                    : 'Нет пациентов на приеме',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }
          final layout = _calculateLayout(constraints.biggest, tickets.length);
          if (layout.ticketSize.isEmpty || layout.ticketSize.width <= 0) {
            return const SizedBox.shrink();
          }

          final int columnCount = layout.columnCount;
          final int itemsPerColumn = (tickets.length / columnCount).ceil();

          List<List<DoctorQueueTicketEntity>> columnsData = List.generate(
            columnCount,
            (_) => [],
          );
          for (int i = 0; i < tickets.length; i++) {
            columnsData[i ~/ itemsPerColumn].add(tickets[i]);
          }

          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(columnCount, (colIndex) {
                final bool isLastColumn = colIndex == columnCount - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    left: colIndex == 0 ? 0 : _kSpacing / 2,
                    right: isLastColumn ? 0 : _kSpacing / 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(columnsData[colIndex].length, (
                      itemIndex,
                    ) {
                      return _buildTicketItem(
                        ticket: columnsData[colIndex][itemIndex],
                        isWaiting: isWaiting,
                        size: layout.ticketSize,
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketItem({
    required DoctorQueueTicketEntity ticket,
    required bool isWaiting,
    required Size size,
  }) {
    final Color backgroundColor = isWaiting
        ? Colors.white
        : const Color(0xFF4CAF50);
    final Color textColor = isWaiting ? const Color(0xFF333333) : Colors.white;
    final double fontSize = size.height * (isWaiting ? 0.4 : 0.35);

    return SizedBox(
      width: size.width,
      height: size.height + _kSpacing,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isWaiting
                ? Text(
                    ticket.ticketNumber,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        ticket.ticketNumber,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: textColor,
                        size: fontSize,
                      ),
                      Text(
                        '${ticket.cabinetNumber ?? '?'}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B4193),
            const Color(0xFF2563EB),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4193),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: SizedBox(
        height: 132,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1AFFFFFF),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Text(
              'ОЧЕРЕДЬ В КАБИНЕТЫ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0x73000000),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                  Shadow(
                    color: const Color(0x4DFFFFFF),
                    offset: const Offset(0, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueStatusHeader() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4193),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B4193),
                    const Color(0xFF2563EB),
                    const Color(0xFF3B82F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  'В ОЧЕРЕДИ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: const Color(0x61000000),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4CAF50), const Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  'ВЫЗЫВАЮТСЯ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: const Color(0x61000000),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      color: const Color(0xFFFEE2E2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 80),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки данных',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF991B1B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFFB91C1C)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Попытка переподключения...',
              style: TextStyle(fontSize: 16, color: Color(0xFF991B1B)),
            ),
          ],
        ),
      ),
    );
  }
}
