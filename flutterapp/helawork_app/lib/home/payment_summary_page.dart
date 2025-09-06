import 'package:flutter/material.dart';
import 'package:helawork_app/Api/api_service.dart';

class PaymentSummaryPage extends StatefulWidget {
  const PaymentSummaryPage({super.key});

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  Map<String, dynamic>? paymentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentSummary();
  }

  Future<void> _loadPaymentSummary() async {
    try {
      final data = await ApiService.getPaymentSummary();
      setState(() {
        paymentData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading payment summary: $e")),
      );
    }
  }

  Future<void> _withdraw() async {
    try {
      final result = await ApiService.withdrawMpesa();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Withdraw: ${result['ResponseDescription']}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Withdraw failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (paymentData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No data", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Payment Summary", style: TextStyle(fontWeight: FontWeight.bold)),
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
              value: "${paymentData!['total_hours']}",
              unit: "hours",
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              title: "Hourly Rate",
              subtitle: "Current rate",
              value: "Ksh${paymentData!['hourly_rate']}",
              unit: "per hour",
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.attach_money,
              iconColor: Colors.orange,
              title: "Total Payment",
              subtitle: "Ready for withdrawal",
              value: "Ksh${paymentData!['total_payment']}",
              unit: paymentData!['currency'],
              highlight: true,
            ),
            const SizedBox(height: 16),
            
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
                      "Base earnings", "Ksh${paymentData!['breakdown']['base_earnings']}"),
                  _buildBreakdownRow("Bonus payments", "\$${paymentData!['breakdown']['bonus']}"),
                  const Divider(color: Colors.white24),
                  _buildBreakdownRow("Total", "Ksh${paymentData!['breakdown']['total']}",
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
                onPressed: _withdraw,
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
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
