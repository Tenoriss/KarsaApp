class QuizQuestion {
  final String question;
  final List<String> choices;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'];
    final choices = rawChoices is List
        ? <String>[for (final c in rawChoices) c.toString()]
        : const <String>[];
    final idx = int.tryParse(json['answerIndex']?.toString() ?? '') ?? 0;
    return QuizQuestion(
      question: (json['question'] ?? '').toString(),
      choices: choices,
      // Jaga agar indeks jawaban tidak menunjuk ke luar daftar pilihan;
      // data tersimpan yang rusak tidak boleh membuat aplikasi gagal.
      answerIndex: choices.isEmpty ? 0 : idx.clamp(0, choices.length - 1),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'question': question,
        'choices': choices,
        'answerIndex': answerIndex,
        'explanation': explanation,
      };
}

class EssayPrompt {
  final String prompt;
  final String sampleAnswer;

  const EssayPrompt({
    required this.prompt,
    required this.sampleAnswer,
  });
}
