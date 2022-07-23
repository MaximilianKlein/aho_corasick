part of aho_corasick;

class Match {
  const Match({required this.startIndex, required this.word});

  final int startIndex;
  final String word;

  Match copyWith({int? startIndex, String? word}) => Match(
        startIndex: startIndex ?? this.startIndex,
        word: word ?? this.word,
      );
}
