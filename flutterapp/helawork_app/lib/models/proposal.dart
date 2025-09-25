class Proposal {
  final int? id;
  final int taskId;
  final int freelancerId;
  final String? title;       
  final String coverLetter;
  final double bidAmount;
  String status;             

  Proposal({
    this.id,
    required this.taskId,
    required this.freelancerId,
    this.title,
    required this.coverLetter,
    required this.bidAmount,
    this.status = "Pending", // <-- default value
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      taskId: json['taskId'],
      freelancerId: json['freelancerId'],
      title: json['title'],
      coverLetter: json['coverLetter'],
      bidAmount: (json['bidAmount'] as num).toDouble(),
      status: json['status'] ?? "Pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'freelancerId': freelancerId,
      'title': title,
      'coverLetter': coverLetter,
      'bidAmount': bidAmount,
      'status': status,
    };
  }
}
