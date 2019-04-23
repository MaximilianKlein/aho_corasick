import 'package:aho_corasick/aho_corasick.dart';
import 'package:test/test.dart';

void main() {
  group('Aho-Corasick.firstMatch', () {
    test('Can work with an empty set of patterns', () {
      // given
      final aho = AhoCorasick.fromWordList([]);
      // when
      final res = aho.firstMatch('some input');
      // then
      expect(res, isNull);
    });

    test('finds matching patterns', () {
      // given
      final patterns = ['abc', 'def'];
      final aho = AhoCorasick.fromWordList(patterns);
      final input = 'text${patterns[1]}rest';
      // when
      final res = aho.firstMatch(input);
      // then
      expect(res, isNotNull);
      expect(res.startIndex, 4);
      expect(res.word, patterns[1]);
    });

    test('finds matches inside other partial matches', () {
      // given
      final patterns = ['abc', 'be'];
      final aho = AhoCorasick.fromWordList(patterns);
      final input = 'mabec';
      // when
      final res = aho.firstMatch(input);
      // then
      expect(res, isNotNull);
      expect(res.startIndex, 2);
      expect(res.word, patterns[1]);
    });

    test('finds first longest match', () {
      // given
      final patterns = ['abc', 'abcde', 'bcdefg'];
      final aho = AhoCorasick.fromWordList(patterns);
      final input = 'm${patterns[1]}fg';
      // when
      final res = aho.firstMatch(input, longest: true);
      // then
      expect(res, isNotNull);
      expect(res.startIndex, 1);
      expect(res.word, patterns[1]);
    });
  });

  group('find all matches', () {
    test('finds all occurences of a word', () {
      // given
      final word = 'word';
      final aho = AhoCorasick.fromWordList([word]);
      final input = '$word and $word$word';
      // when
      final res = aho.matches(input);
      // then
      expect(res, hasLength(3));
      res.forEach((match) => expect(match.word, word));
      expect(res.map((match) => match.startIndex), [0, 9, 13]);
    });

    test('finds occurences inside other matches', () {
      // given
      final patterns = ['abcba', 'bcb'];
      final aho = AhoCorasick.fromWordList(patterns);
      final input = 'abcba';
      // when
      final res = aho.matches(input);
      // then
      expect(res, hasLength(2));
      expect(res[0].startIndex, 1);
      expect(res[1].startIndex, 0);
    });
  });
}
