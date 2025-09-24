class Proposal {
  final String title;
  final String coverLetter;
  final double bidAmount;
  final String status;

  Proposal({
    required this.title,
    required this.coverLetter,
    required this.bidAmount,
    required this.status,
  });

  // Factory method if converting from JSON (optional)
  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      title: json['title'] ?? '',
      coverLetter: json['cover_letter'] ?? '',
      bidAmount: (json['bid_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
    );
  }
}
