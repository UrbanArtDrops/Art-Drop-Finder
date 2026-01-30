class DropClaim {
  final String id;
  final String dropId;
  final String claimerName;
  final String? comment;
  final DateTime claimedAt;

  const DropClaim({
    required this.id,
    required this.dropId,
    required this.claimerName,
    this.comment,
    required this.claimedAt,
  });

  DropClaim copyWith({
    String? id,
    String? dropId,
    String? claimerName,
    String? comment,
    DateTime? claimedAt,
  }) {
    return DropClaim(
      id: id ?? this.id,
      dropId: dropId ?? this.dropId,
      claimerName: claimerName ?? this.claimerName,
      comment: comment ?? this.comment,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}
