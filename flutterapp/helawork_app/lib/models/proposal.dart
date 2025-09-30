class Proposal {
  final int taskId;
  final int freelancerId;
  final String coverLetter;
  final double bidAmount;
  String status;
  String? title;

  Proposal({
    required this.taskId,
    required this.freelancerId,
    required this.coverLetter,
    required this.bidAmount,
    this.status = "Pending",
    this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'freelancer_id': freelancerId,
      'cover_letter': coverLetter,
      'bid_amount': bidAmount,
      'status': status,
    };
  }

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      taskId: json['task_id'] ?? json['id'],
      freelancerId: json['freelancer_id'] ?? json['freelancerId'],
      coverLetter: json['cover_letter'] ?? json['coverLetter'],
      bidAmount: (json['bid_amount'] ?? json['bidAmount']).toDouble(),
      status: json['status'] ?? 'Pending',
      title: json['title'],
    );
  }
}