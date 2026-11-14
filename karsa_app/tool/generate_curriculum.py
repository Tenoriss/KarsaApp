#!/usr/bin/env python3
"""Generate lib/data/curriculum_data.dart directly from ../curriculum.js via Node."""

import json
import os
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO_ROOT = os.path.dirname(ROOT)
CURRICULUM_JS = os.path.join(REPO_ROOT, "curriculum.js")
DART_OUT = os.path.join(ROOT, "lib", "data", "curriculum_data.dart")


def dart_str(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\n", "\\n")
    )
    return f"'{escaped}'"


def hex_to_color(hex_str: str) -> str:
    h = hex_str.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return f"Color(0xFF{h.upper()})"


def main() -> None:
    node_code = """
import { pathToFileURL } from 'url';
const mod = await import(pathToFileURL(process.argv[1]).href);
console.log(JSON.stringify({
  subjectInfo: mod.subjectInfo,
  subjects: mod.subjects,
  quizBank: mod.quizBank,
  practiceBank: mod.practiceBank,
  religions: mod.religions,
}));
"""
    res = subprocess.run(
        ["node", "--input-type=module", "-e", node_code, CURRICULUM_JS],
        check=True,
        capture_output=True,
        text=True,
    )
    payload = json.loads(res.stdout)

    os.makedirs(os.path.dirname(DART_OUT), exist_ok=True)
    out = [
        "// GENERATED FROM ../curriculum.js BY tool/generate_curriculum.py",
        "// Materi contoh untuk demo. Bukan kurikulum atau penilaian resmi sekolah.",
        "import 'package:flutter/painting.dart';",
        "import '../models/practice_item.dart';",
        "import '../models/quiz_question.dart';",
        "import '../models/subject_model.dart';",
        "",
        "class CurriculumData {",
        "  CurriculumData._();",
        "",
        "  static const Map<String, SubjectMeta> subjectInfo = <String, SubjectMeta>{",
    ]

    for subj, meta in payload["subjectInfo"].items():
        out.append(
            f"    {dart_str(subj)}: SubjectMeta("
            f"name: {dart_str(subj)}, "
            f"icon: {dart_str(meta['icon'])}, "
            f"color: {hex_to_color(meta['color'])}, "
            f"colorHex: {dart_str(meta['color'].upper())}),"
        )
    out.append("  };")
    out.append("")

    out.append("  static const List<String> subjects = <String>[")
    for subj in payload["subjects"]:
        out.append(f"    {dart_str(subj)},")
    out.append("  ];")
    out.append("")

    out.append("  static const List<String> religions = <String>[")
    for rel in payload["religions"]:
        out.append(f"    {dart_str(rel)},")
    out.append("  ];")
    out.append("")

    out.append(
        "  static const Map<String, List<String>> faithExamples = <String, List<String>>{"
    )
    faith_map = {
        "Islam": ["masjid", "salat"],
        "Kristen": ["gereja", "berdoa"],
        "Katolik": ["gereja", "mengasihi sesama"],
        "Hindu": ["pura", "berdoa"],
        "Buddha": ["vihara", "berbuat baik"],
        "Konghucu": ["kelenteng", "menghormati sesama"],
    }
    for rel, pair in faith_map.items():
        out.append(f"    {dart_str(rel)}: <String>[{dart_str(pair[0])}, {dart_str(pair[1])}],")
    out.append("  };")
    out.append("")

    out.append(
        "  static const Map<String, List<QuizQuestion>> quizBank = <String, List<QuizQuestion>>{"
    )
    for subj, questions in payload["quizBank"].items():
        out.append(f"    {dart_str(subj)}: <QuizQuestion>[")
        for item in questions:
            choices_str = ", ".join(dart_str(c) for c in item["choices"])
            out.append(
                f"      QuizQuestion("
                f"question: {dart_str(item['q'])}, "
                f"choices: <String>[{choices_str}], "
                f"answerIndex: {item['answer']}, "
                f"explanation: {dart_str(item['explain'])}),"
            )
        out.append("    ],")
    out.append("  };")
    out.append("")

    out.append(
        "  static const Map<String, List<EssayPrompt>> practiceBank = <String, List<EssayPrompt>>{"
    )
    for subj, prompts in payload["practiceBank"].items():
        out.append(f"    {dart_str(subj)}: <EssayPrompt>[")
        for pair in prompts:
            out.append(
                f"      EssayPrompt(prompt: {dart_str(pair[0])}, sampleAnswer: {dart_str(pair[1])}),"
            )
        out.append("    ],")
    out.append("  };")
    out.append("")

    out.extend(
        [
            "  static String normalizeSubject(String? raw) {",
            "    if (raw == null || raw.isEmpty) return 'Matematika';",
            "    if (raw == 'IPA') return 'Ilmu Pengetahuan Alam dan Sosial (IPAS)';",
            "    return raw;",
            "  }",
            "",
            "  static List<String> subjectsForClass(String className) {",
            "    final digits = className.replaceAll(RegExp(r'\\D'), '');",
            "    final grade = int.tryParse(digits) ?? 1;",
            "    return subjects",
            "        .where((s) => s != 'Ilmu Pengetahuan Alam dan Sosial (IPAS)' || grade >= 3)",
            "        .toList();",
            "  }",
            "",
            "  static SubjectMeta metaFor(String subject) {",
            "    final normalized = normalizeSubject(subject);",
            "    return subjectInfo[normalized] ?? subjectInfo['Matematika']!;",
            "  }",
            "",
            "  static List<QuizQuestion> questionsFor(String subject, String? religion) {",
            "    final normalized = normalizeSubject(subject);",
            "    final base = quizBank[normalized] ?? quizBank['Matematika']!;",
            "    final faith = (religion != null && religion.isNotEmpty) ? faithExamples[religion] : null;",
            "    if (normalized != 'Pendidikan Agama dan Budi Pekerti' || faith == null) {",
            "      return base;",
            "    }",
            "    final QuizQuestion first = religion == 'Katolik'",
            "        ? QuizQuestion(",
            "            question: 'Dalam pembinaan iman Katolik, teladan Yesus mengajak kita untuk ...',",
            "            choices: <String>['mengasihi sesama', 'mengejek teman', 'berbuat curang', 'mengabaikan teman'],",
            "            answerIndex: 0,",
            "            explanation: 'Mengasihi sesama merupakan bagian dari teladan Yesus.',",
            "          )",
            "        : QuizQuestion(",
            "            question: 'Tempat ibadah yang dikenal dalam agama $religion adalah ...',",
            "            choices: <String>[faith[0], 'perpustakaan', 'pasar', 'lapangan'],",
            "            answerIndex: 0,",
            "            explanation: '${faith[0]} merupakan salah satu tempat ibadah umat $religion.',",
            "          );",
            "    return <QuizQuestion>[first, ...base.skip(1)];",
            "  }",
            "",
            "  static List<EssayPrompt> exercisesFor(String subject, String? religion) {",
            "    final normalized = normalizeSubject(subject);",
            "    final base = practiceBank[normalized] ?? practiceBank['Matematika']!;",
            "    final faith = (religion != null && religion.isNotEmpty) ? faithExamples[religion] : null;",
            "    if (normalized != 'Pendidikan Agama dan Budi Pekerti' || faith == null) {",
            "      return base;",
            "    }",
            "    final first = EssayPrompt(",
            "      prompt: 'Ceritakan contoh ${faith[1]} dalam kehidupan sehari-hari sesuai ajaran $religion.',",
            "      sampleAnswer: 'Jawaban dapat beragam. Diskusikan dengan guru dan keluarga sesuai ajaran $religion.',",
            "    );",
            "    return <EssayPrompt>[first, ...base.skip(1)];",
            "  }",
            "}",
            "",
        ]
    )

    with open(DART_OUT, "w", encoding="utf-8") as fp:
        fp.write("\n".join(out))

    total_q = sum(len(v) for v in payload["quizBank"].values())
    total_p = sum(len(v) for v in payload["practiceBank"].values())
    print(f"Wrote {DART_OUT}: {len(payload['subjects'])} subjects, {total_q} quiz questions, {total_p} practice prompts.")


if __name__ == "__main__":
    main()
