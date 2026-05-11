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
                  duration: const Duration(milliseconds: 400),
                  width: isCurrent ? 28 : 22,
                  height: isCurrent ? 28 : 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : Colors.grey.shade300,
                    border: isCurrent
                        ? Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                            width: 3,
                          )
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: Theme.of(context).cardColor,
                          size: 14,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: isCompleted && index < currentIndex
                        ? AppColors.success
                        : Colors.grey.shade300,
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
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStepSubtitle(step),
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
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStepSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been placed successfully';
      case OrderStatus.confirmed:
        return 'Seller has confirmed your order';
      case OrderStatus.processing:
        return 'Your order is being prepared';
      case OrderStatus.shipped:
        return 'Your package is on its way';
      case OrderStatus.outForDelivery:
        return 'Your package is nearby';
      case OrderStatus.delivered:
        return 'Package delivered successfully';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }
}
