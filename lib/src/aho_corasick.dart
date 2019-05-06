part of aho_corasick;

/// Pattern Matching algorithm that searches for all occurences of
/// any word in the word list.
class AhoCorasick {
  const AhoCorasick._({
    @required this.stateMachine,
    @required int longestPattern,
    @required this.separateBySpaces,
  }) : _longestPattern = longestPattern;

  /// initialize the aho corasick algorithm with a given list of words
  /// this will create the state machine. If you want to force that recognized
  /// words are either at the beginning / end or are surounded by spaces
  /// set [separateBySpaces] to true
  factory AhoCorasick.fromWordList(List<String> patterns,
      {bool separateBySpaces = false}) {
    // initial state is the empty word
    List<WordState> states = [WordState(index: 0, words: [], failure: 0)];
    var longest = 0;
    Map<int, Map<String, int>> transitionMap = {};
    patterns.forEach((inputPattern) {
      final pattern = separateBySpaces ? ' $inputPattern ' : inputPattern;
      int curStateIndex = 0;
      longest = max(longest, pattern.length);
      for (var i = 0; i < pattern.length; i++) {
        final stateMap = transitionMap[curStateIndex] ?? {};
        final resState = stateMap[pattern[i]];
        if (resState == null) {
          final newStateIdx = states.length;
          final newState = WordState(
              index: newStateIdx,
              words: (i == pattern.length - 1) ? [pattern] : [],
              isFinal: i == pattern.length - 1);
          states.add(newState);
          stateMap.putIfAbsent(pattern[i], () => newStateIdx);
          transitionMap.update(curStateIndex, (_) => stateMap,
              ifAbsent: () => stateMap);
          curStateIndex = newStateIdx;
        } else {
          curStateIndex = resState;
          if (i == pattern.length - 1) {
            final curState = WordState(
                index: curStateIndex,
                words: states[curStateIndex].words..add(pattern),
                isFinal: i == pattern.length - 1);
            states[curStateIndex] = curState;
          }
        }
      }
    });
    // edge case when there are no patterns ;)
    if (transitionMap.containsKey(0)) {
      // if the state machine cannot follow up on a pattern it might
      // follow up on other patterns those are tracked with this
      // failure map
      final queue = Queue<int>();
      transitionMap[0].forEach((character, resState) {
        states[resState] = states[resState].copyWith(
          failure: 0,
        );
        queue.add(resState);
      });
      while (queue.isNotEmpty) {
        final stateIdx = queue.removeFirst();
        (transitionMap[stateIdx] ?? {}).forEach((character, resState) {
          queue.add(resState);
          var failStateIdx = states[stateIdx].failure;
          while ((transitionMap[failStateIdx] ?? {})[character] == null) {
            if (failStateIdx == 0) {
              break;
            }
            failStateIdx = states[failStateIdx].failure;
          }
          failStateIdx = (transitionMap[failStateIdx] ?? {})[character] ?? 0;
          states[resState] = states[resState].copyWith(
            failure: failStateIdx,
            words: states[resState].words..addAll(states[failStateIdx].words),
            isFinal: states[failStateIdx].isFinal || states[resState].isFinal,
          );
        });
      }
    }
    return AhoCorasick._(
        separateBySpaces: separateBySpaces,
        longestPattern: longest,
        stateMachine: StateMachine<WordState, String>(
            states: states,
            isSuccessState: (state) => state.isFinal,
            transition: ({WordState activeState, String input}) {
              var curState = activeState.index;
              var endState = (transitionMap[curState] ?? {})[input] ?? -1;

              while (endState == -1) {
                endState = states[curState].failure;
                curState = endState;
              }
              return states[(transitionMap[curState] ?? {})[input] ?? 0];
            }));
  }

  /// state machine used to find words in an input text
  final StateMachine<WordState, String> stateMachine;

  /// parameter for optimizing `_firstMatchLongest` to not search
  /// through the full text by "knowing" how long a pattern can be
  /// this is not optimal, but good enough for now ;)
  final int _longestPattern;

  /// specifies whether patterns must be separated by spaces or if
  /// they can found anywhere
  final bool separateBySpaces;

  Match _firstMatchLongest(String input) {
    final state = stateMachine.createState();
    final results = <Match>[];
    var foundIdx;
    var smallestStartIndex = input.length;
    for (var i = 0; i < input.length; i++) {
      if (i - (foundIdx ?? input.length) > _longestPattern) {
        break;
      }
      state.performStep(input[i]);
      if (state.activeStateIsSuccess) {
        foundIdx ??= i;
        results.addAll(state.activeState.words.map((word) {
          smallestStartIndex = min(smallestStartIndex, i - word.length + 1);
          return Match(startIndex: i - word.length + 1, word: word);
        }));
      }
    }
    if (results.isNotEmpty) {
      return results
          .where((match) => match.startIndex == smallestStartIndex)
          .reduce((acc, other) =>
              acc.word.length > other.word.length ? acc : other);
    }
    return null;
  }

  Match _fixShiftedMatch(Match match) => separateBySpaces && match != null ? Match(
      startIndex: match.startIndex,
      word: match.word.substring(1, match.word.length - 1))
      : match;

  /// returns the first match or null if none was found
  /// optionally you can specify `longest: true` to search for the
  /// longest match at a specific position. If you have the words
  /// `['abc', 'abcd']` and your text is `'abcd'` the longest
  /// parameter will not fire when it finds `'abc'` but after it
  /// checked enough positions to find all possible longer words and then
  /// return `'abcd'`
  Match firstMatch(String input, {bool longest = false}) {
    final fullInput = separateBySpaces ? ' $input ' : input;
    if (longest) {
      return _fixShiftedMatch(_firstMatchLongest(fullInput));
    }
    final state = stateMachine.createState();
    for (var i = 0; i < fullInput.length; i++) {
      state.performStep(fullInput[i]);
      if (state.activeStateIsSuccess) {
        final word = state.activeState.words.first;
        return _fixShiftedMatch(Match(startIndex: i - word.length + 1, word: word));
      }
    }
    return null;
  }

  /// returns all matches found. If none were found it returns []
  List<Match> matches(String input) {
    final fullInput = separateBySpaces ? ' $input ' : input;
    final state = stateMachine.createState();
    final results = <Match>[];
    var smallestStartIndex = fullInput.length;
    for (var i = 0; i < fullInput.length; i++) {
      state.performStep(fullInput[i]);
      if (state.activeStateIsSuccess) {
        results.addAll(state.activeState.words.map((word) {
          smallestStartIndex = min(smallestStartIndex, i - word.length + 1);
          return _fixShiftedMatch(Match(
              startIndex: i - word.length + 1, word: word));
        }));
      }
    }
    return results;
  }
}
