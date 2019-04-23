class WordState {
  const WordState(
      {this.index, this.words, this.isFinal = false, this.failure = -1});

  /// the actual word represented by this state
  final List<String> words;

  /// index of the state (for faster transitions)
  final int index;

  /// flag determining
  final bool isFinal;

  /// where to continue when checking for matches failed
  final int failure;

  WordState copyWith(
          {int index, bool isFinal, List<String> words, int failure}) =>
      WordState(
        failure: failure ?? this.failure,
        index: index ?? this.index,
        words: words ?? this.words,
        isFinal: isFinal ?? this.isFinal,
      );
}
