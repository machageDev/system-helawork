class Proposal {
  final String title;
  final String coverLetter;
  final double bidAmount;
  final String status; // Pending, Accepted, Rejected

  Proposal({
    required this.title,
    required this.coverLetter,
    required this.bidAmount,
    this.status = "Pending",
  });
}
