import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'common.dart';

Future<void> _openSheet(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.o(0.45),
    builder: builder,
  );
}

Future<void> showPaymentSheet(BuildContext context) =>
    _openSheet(context, (_) => const _PaymentSheet());

Future<void> showPromoSheet(BuildContext context) =>
    _openSheet(context, (_) => const _PromoSheet());

Future<void> showAddMoneySheet(BuildContext context) =>
    _openSheet(context, (_) => const _AddMoneySheet());

Future<void> showTripSheet(BuildContext context, Trip trip) =>
    _openSheet(context, (_) => _TripSheet(trip: trip));

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        22 + mq.padding.bottom + mq.viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.cardColor2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: context.tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: TextStyle(color: context.muted)),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- payment
class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet();

  String _detail(PaymentMethod m, double wallet) {
    switch (m) {
      case PaymentMethod.wallet:
        return 'Balance ${money(wallet)}';
      case PaymentMethod.upi:
        return 'ananya@okaxis';
      case PaymentMethod.cash:
        return 'Pay your driver directly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return _SheetFrame(
      title: 'Payment method',
      subtitle: 'Choose how you would like to pay for this ride.',
      child: Column(
        children: [
          for (final m in PaymentMethod.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  s.setPayment(m);
                  Navigator.of(context).pop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: s.payment == m
                        ? AppColors.indigo.o(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: s.payment == m ? AppColors.indigo : context.border,
                      width: s.payment == m ? 2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.soft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.icon, color: context.cs.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                              ),
                            ),
                            Text(
                              _detail(m, s.wallet),
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (s.payment == m)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.indigo,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ promo
class _PromoSheet extends StatefulWidget {
  const _PromoSheet();

  @override
  State<_PromoSheet> createState() => _PromoSheetState();
}

class _PromoSheetState extends State<_PromoSheet> {
  final TextEditingController _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _apply(String code) {
    final ok = AppScope.read(context).applyPromo(code);
    if (ok) {
      Navigator.of(context).pop();
      showSnack(context, 'Promo ${code.trim().toUpperCase()} applied!');
    } else {
      setState(() => _error = 'That code is invalid or has expired.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return _SheetFrame(
      title: 'Promo code',
      subtitle: 'Enter a code or pick one of your offers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. RAAHI50',
                    errorText: _error,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: PrimaryButton(
                  label: 'Apply',
                  height: 54,
                  onPressed: () => _apply(_code.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final offer in MockData.offers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _apply(offer.code),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: s.promoCode == offer.code
                          ? AppColors.green
                          : context.border,
                      width: s.promoCode == offer.code ? 2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber.o(0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          offer.code,
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              offer.description,
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (s.promoCode == offer.code)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (s.promoCode != null)
            Center(
              child: TextButton(
                onPressed: () {
                  s.removePromo();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Remove applied promo',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- add money
class _AddMoneySheet extends StatefulWidget {
  const _AddMoneySheet();

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  static const _amounts = <int>[100, 200, 500, 1000];
  int _selected = 500;

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Add money',
      subtitle: 'Top up your Raahi Wallet instantly via UPI (demo).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in _amounts)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = a);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _selected == a
                          ? AppColors.indigo
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _selected == a ? AppColors.indigo : context.border,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      money(a),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: _selected == a ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Add ${money(_selected)}',
            icon: Icons.add_rounded,
            onPressed: () {
              AppScope.read(context).topUp(_selected.toDouble());
              Navigator.of(context).pop();
              showSnack(context, '${money(_selected)} added to your wallet.');
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- trip
class _TripSheet extends StatelessWidget {
  const _TripSheet({required this.trip});

  final Trip trip;

  Widget _row(BuildContext context, String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(k, style: TextStyle(color: context.muted, fontSize: 14)),
          const Spacer(),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                fontSize: bold ? 17 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: trip.cancelled ? 'Cancelled ride' : 'Ride receipt',
      subtitle: '${trip.id} · ${dateTime(trip.date)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.soft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 2, height: 28, color: context.border),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: context.textStrong,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.from,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        trip.to,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _row(context, 'Ride type', trip.rideType),
          if (!trip.cancelled) ...[
            _row(context, 'Driver', trip.driver),
            _row(context, 'Distance', '${trip.km} km'),
            _row(context, 'Duration', '${trip.minutes} min'),
            _row(context, 'Payment', trip.payment.label),
            Divider(color: context.border, height: 22),
            _row(context, 'Total', money(trip.fare), bold: true),
            if (trip.rating != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      'You rated',
                      style: TextStyle(color: context.muted, fontSize: 14),
                    ),
                    const Spacer(),
                    StarRating(rating: trip.rating!, size: 20),
                  ],
                ),
              ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'No charge was made for this ride.',
                style: TextStyle(color: context.muted),
              ),
            ),
          const SizedBox(height: 20),
          if (!trip.cancelled)
            GhostButton(
              label: 'Download receipt',
              icon: Icons.download_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                showSnack(context, 'Receipt saved (demo).');
              },
            ),
        ],
      ),
    );
  }
}
