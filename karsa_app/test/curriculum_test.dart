import 'package:flutter_test/flutter_test.dart';
import 'package:karsa_app/data/curriculum_data.dart';

void main() {
  group('CurriculumData parity with curriculum.js', () {
    test('has 9 subjects, 90 quiz questions, and 45 practice prompts', () {
      expect(CurriculumData.subjects.length, 9);
      final totalQuiz = CurriculumData.quizBank.values
          .fold<int>(0, (acc, list) => acc + list.length);
      final totalPractice = CurriculumData.practiceBank.values
          .fold<int>(0, (acc, list) => acc + list.length);
      expect(totalQuiz, 90);
      expect(totalPractice, 45);
    });

    test('excludes IPAS for Kelas 1-2 and includes IPAS for Kelas 3-6', () {
      expect(
        CurriculumData.subjectsForClass('Kelas 1')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isFalse,
      );
      expect(
        CurriculumData.subjectsForClass('Kelas 2')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isFalse,
      );
      expect(
        CurriculumData.subjectsForClass('Kelas 3')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isTrue,
      );
      expect(
        CurriculumData.subjectsForClass('Kelas 6')
            .contains('Ilmu Pengetahuan Alam dan Sosial (IPAS)'),
        isTrue,
      );
    });

    test('normalizes legacy IPA subject and customizes Katolik faith question', () {
      expect(
        CurriculumData.normalizeSubject('IPA'),
        'Ilmu Pengetahuan Alam dan Sosial (IPAS)',
      );
      final katolikQuiz = CurriculumData.questionsFor(
        'Pendidikan Agama dan Budi Pekerti',
        'Katolik',
      );
      expect(katolikQuiz.length, 10);
      expect(katolikQuiz.first.question, contains('pembinaan iman Katolik'));
      expect(katolikQuiz.first.choices.first, 'mengasihi sesama');
    });
  });
}
