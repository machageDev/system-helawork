class Contract {
  final int contractId;
  final String taskTitle;
  final String freelancerName;
  final String employerName;
  final String startDate;
  final String? endDate;
  final bool isActive;

  Contract({
    required this.contractId,
    required this.taskTitle,
    required this.freelancerName,
    required this.employerName,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractId: json['contract_id'],
      taskTitle: json['task_title'],
      freelancerName: json['freelancer_name'],
      employerName: json['employer_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'],
    );
  }
}
