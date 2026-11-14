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
}

class EssayPrompt {
  final String prompt;
  final String sampleAnswer;

  const EssayPrompt({
    required this.prompt,
    required this.sampleAnswer,
  });
}
