import 'dart:typed_data';


class Proposal {
  final int taskId;
  final int freelancerId;
  final String coverLetter; // This field exists but you're not using it for PDF
  final double bidAmount;
  String status;
  String? title;
  
  // PDF file properties
  String? coverLetterFileName;     
  Uint8List? coverLetterFileBytes;
  String? pdfFileName; // Add this back if you need it

  Proposal({
    required this.taskId,
    required this.freelancerId,
    required this.coverLetter, // This is required
    required this.bidAmount,
    this.status = "Pending",
    this.title,
    this.coverLetterFileName,      
    this.coverLetterFileBytes,
    this.pdfFileName, // Make this optional
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'freelancer_id': freelancerId,
      'bid_amount': bidAmount,
      'status': status,
      'title': title,
      'cover_letter_file_name': coverLetterFileName,
      'pdf_file_name': pdfFileName, // Include if needed
    };
  }

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      taskId: json['task_id'] ?? json['task'],
      freelancerId: json['freelancer_id'] ?? json['freelancer'],
      coverLetter: json['cover_letter'] ?? 'Cover letter provided as PDF',
      bidAmount: (json['bid_amount'] ?? json['bidAmount']).toDouble(),
      status: json['status'] ?? 'Pending',
      title: json['title'],
      coverLetterFileName: json['cover_letter_file_name'] ?? json['pdf_file_name'],
      pdfFileName: json['pdf_file_name'],
    );
  }
}