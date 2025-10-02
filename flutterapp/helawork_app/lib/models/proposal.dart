import 'dart:typed_data';

class Proposal {
  final int taskId;
  final int freelancerId;
  final String coverLetter;
  final double bidAmount;
  String status;
  String? title;
  String? pdfFileName;     // Add this
  String? pdfFilePath;     // Add this
  Uint8List? pdfFileBytes; // Add this - for storing actual file bytes

  Proposal({
    required this.taskId,
    required this.freelancerId,
    required this.coverLetter,
    required this.bidAmount,
    this.status = "Pending",
    this.title,
    this.pdfFileName,      // Add this
    this.pdfFilePath,      // Add this
    this.pdfFileBytes,     // Add this
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'freelancer_id': freelancerId,
      'cover_letter': coverLetter,
      'bid_amount': bidAmount,
      'status': status,
      'title': title,
      'pdf_file_name': pdfFileName,  // Add this
      // Note: file path/bytes typically not included in JSON
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
      pdfFileName: json['pdf_file_name'],  // Add this
    );
  }
}