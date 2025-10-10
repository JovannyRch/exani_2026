class QuestionStat {
  final int id;
  final int viewCount;

  QuestionStat({required this.id, required this.viewCount});

  factory QuestionStat.fromMap(Map<String, dynamic> map) {
    return QuestionStat(id: map['question_id'], viewCount: map['view_count']);
  }
}
