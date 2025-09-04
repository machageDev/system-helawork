import 'package:flutter/material.dart';

class PaymentSummaryPage extends StatelessWidget {
  const PaymentSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Payment Summary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.access_time,
              iconColor: Colors.blue,
              title: "Total Approved Hours",
              subtitle: "This month",
              value: "47.2",
              unit: "hours",
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              title: "Hourly Rate",
              subtitle: "Current rate",
              value: "\$4.97",
              unit: "per hour",
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.attach_money,
              iconColor: Colors.orange,
              title: "Total Payment",
              subtitle: "Ready for withdrawal",
              value: "\$234.50",
              unit: "USD",
              highlight: true,
            ),
            const SizedBox(height: 16),
            // Payment Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Breakdown",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildBreakdownRow(
                      "Base earnings (47.2h × \$4.97)", "\$234.48"),
                  _buildBreakdownRow("Bonus payments", "\$0.02"),
                  const Divider(color: Colors.white24),
                  _buildBreakdownRow("Total", "\$234.50",
                      highlight: true),
                ],
              ),
            ),
            const Spacer(),
            // Withdraw button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.phone_iphone, color: Colors.white),
                label: const Text(
                  "Withdraw via M-PESA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                    color: highlight ? Colors.orange : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              Text(unit,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String amount,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(amount,
              style: TextStyle(
                color: highlight ? Colors.orange : Colors.white,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              )),
        ],
      ),
    );
  }
}
