import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            'Wallet',
            style: context.tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Money, offers and payment methods in one place.',
            style: TextStyle(color: context.muted),
          ),
          const SizedBox(height: 18),
          _BalanceCard(balance: s.wallet),
          const SizedBox(height: 26),

          const SectionHeader('Payment methods'),
          const SizedBox(height: 12),
          for (final m in PaymentMethod.values) _MethodTile(method: m),
          const SizedBox(height: 26),

          const SectionHeader('Offers for you'),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.offers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _OfferCard(offer: MockData.offers[i]),
            ),
          ),
          const SizedBox(height: 26),

          const SectionHeader('Recent activity'),
          const SizedBox(height: 8),
          for (final tx in s.transactions.take(8)) _TxTile(tx: tx),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.o(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.o(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -70,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.o(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Raahi Wallet',
                    style: TextStyle(
                      color: Colors.white.o(0.85),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.contactless_rounded, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Available balance',
                style: TextStyle(color: Colors.white.o(0.7), fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                money(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => showAddMoneySheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 20, color: Color(0xFF4C1D95)),
                      SizedBox(width: 6),
                      Text(
                        'Add money',
                        style: TextStyle(
                          color: Color(0xFF4C1D95),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final selected = s.payment == method;

    String detail;
    switch (method) {
      case PaymentMethod.wallet:
        detail = 'Balance ${money(s.wallet)}';
        break;
      case PaymentMethod.upi:
        detail = 'ananya@okaxis';
        break;
      case PaymentMethod.cash:
        detail = 'Pay your driver directly';
        break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        s.setPayment(method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.indigo : context.border,
            width: selected ? 2 : 1.2,
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
              child: Icon(method.icon, color: context.cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(color: context.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (selected)
              const Pill(
                label: 'Default',
                color: AppColors.indigo,
                filled: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final PromoOffer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: offer.code));
        showSnack(context, 'Code ${offer.code} copied to clipboard.');
      },
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amber.o(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                offer.code,
                style: const TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Spacer(),
            Text(
              offer.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              offer.description,
              style: TextStyle(color: context.muted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});

  final WalletTx tx;

  @override
  Widget build(BuildContext context) {
    final credit = tx.isCredit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (credit ? AppColors.green : AppColors.red).o(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              credit
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              size: 20,
              color: credit ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  dateTime(tx.date),
                  style: TextStyle(color: context.muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Text(
            '${credit ? '+' : ''}${money(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              color: credit ? AppColors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
