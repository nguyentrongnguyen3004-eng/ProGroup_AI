class TrainingImportRecordModel {
  final DateTime importedAt;
  final String dataType;
  final String fileName;
  final int totalRecords;
  final int successfulRecords;
  final int failedRecords;
  final String status;

  const TrainingImportRecordModel({
    required this.importedAt,
    required this.dataType,
    required this.fileName,
    required this.totalRecords,
    required this.successfulRecords,
    required this.failedRecords,
    required this.status,
  });
}
