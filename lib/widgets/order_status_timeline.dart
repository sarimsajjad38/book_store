import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.surfaceDark : const Color(0xFFE4DCD0);
    final steps = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final isCancelled = currentStatus == OrderStatus.cancelled;
    final currentIndex = isCancelled ? -1 : steps.indexOf(currentStatus);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = !isCancelled && index <= currentIndex;
        final isCurrent = !isCancelled && index == currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 26 : 20,
                  height: isCurrent ? 26 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : inactiveColor,
                    border: isCurrent
                        ? Border.all(
                            color: AppColors.success.withOpacity(0.35),
                            width: 3,
                          )
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.25),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: isCompleted && index < currentIndex
                        ? AppColors.success
                        : inactiveColor,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Step info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStepTitle(step),
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        fontSize: isCurrent ? 15 : 14,
                        color: isCompleted
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStepSubtitle(step, isCompleted, isCurrent),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getStepTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Packing & Preparing';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String _getStepSubtitle(
      OrderStatus status, bool isCompleted, bool isCurrent) {
    if (isCurrent) return 'Currently in this stage';
    if (isCompleted) return 'Completed';
    return 'Upcoming';
  }
}
