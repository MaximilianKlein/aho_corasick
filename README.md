Implementation of the Aho-Corasick algorithm for finding words in a text.
The Aho-Corasick algorithm is especially fast if you have a large list
of words that might have some matches in your text.

## Usage

You can either search for all or for the first match with the optional
flag to search for the first, but longest match.

```dart
import 'package:aho_corasick/aho_corasick.dart';

main() {
  final aho = AhoCorasick.fromWordList(['abc', 'bcd', 'bcde']);
  final results = aho.matches('search in abcd');
  print(results
      .map((match) => 'found ${match.word} at ${match.startIndex}')
      .join('\n'));
  // > found abc at 10
  // > found bcd at 11

  final longest = aho.firstMatch('search bcde', longest: true);
  print(longest.word); // > bcde
}
```


## Some Technical Details

It creates a state machine for all
the words with a failure mechanism, if a word does not match it can easily find
other words whose prefix was just read by the algorithm. Therefore it
has a initialization that is proportional to the number of words and the
characters used. The Search phase is usually linear for "normal texts".
Edge cases like "only one character" can lead to a quadratic time complexity,
but that is only because the number of results can be quadratic in the length of
the text.

More information at: https://en.wikipedia.org/wiki/Aho–Corasick_algorithm

Sadly the original paper is not open access. But there is ample material
elsewhere.
