part of 'schedule_widget.dart';

class ScheduleCard extends StatelessWidget {
  final String time;
  final String status;
  final AppTheme appTheme;

  const ScheduleCard({
    super.key,
    required this.appTheme,
    required this.status,
    required this.time,
  });

  // Определяет цвет рамки в зависимости от статуса
  Color _getStatusColor() {
    final statusColors = appTheme.getStatusColors();
    switch (status) {
      case 'busy':
        return statusColors['emergency']!; // Красный
      case 'free':
        return statusColors['completed']!; // Зелёный
      case 'unavailable':
      default:
        return statusColors['stopped']!; // Серый
    }
  }

  static const Map<String, String> statusToRussian = {
    'busy': 'Занято',
    'free': 'Свободно',
    'unavailable': 'Недоступно',
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    // ИЗМЕНЕНИЕ: Стиль текста теперь черный, крупнее (bodyMedium) и жирный
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor, // Цвет рамки зависит от статуса
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: textStyle),
              Text(
                statusToRussian[status] ?? '',
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}