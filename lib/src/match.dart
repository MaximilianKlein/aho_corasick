part of aho_corasick;

class Match {
  const Match({this.startIndex, this.word});

  final int startIndex;
  final String word;

  Match copyWith({int startIndex, String word}) => Match(
        startIndex: startIndex ?? this.startIndex,
        word: word ?? this.word,
      );
}
