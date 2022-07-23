import 'package:aho_corasick/aho_corasick.dart';

void main() {
  final aho = AhoCorasick.fromWordList(['abc', 'bcd', 'bcde']);
  final results = aho.matches('search in abcd');
  print(results
      .map((match) => 'found ${match.word} at ${match.startIndex}')
      .join('\n'));

  final longest = aho.firstMatch('bcde', longest: true);
  print(longest?.word ?? 'no match found');
}
