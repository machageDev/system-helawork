
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';

class PaymentSummaryPage extends StatelessWidget {
  const PaymentSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Payment Summary"),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
          }

          if (provider.paymentData == null) {
            return const Center(child: Text("No data", style: TextStyle(color: Colors.white)));
          }

          final paymentData = provider.paymentData!;
          // ✅ Here you reuse your _buildInfoCard, _buildBreakdownRow, etc.
          return Column(
            children: [
              Text("Total Hours: ${paymentData['total_hours']}", style: const TextStyle(color: Colors.white)),
              // ... rest of UI
              ElevatedButton(
                onPressed: () async {
                  final msg = await provider.withdraw();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? "")));
                },
                child: const Text("Withdraw via M-PESA"),
              )
            ],
          );
        },
      ),
    );
  }
}
