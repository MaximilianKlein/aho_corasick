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

    test('Can work with an empty set of patterns when separating with spaces',
        () {
      // given
      final aho = AhoCorasick.fromWordList([], separateBySpaces: true);
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

    test('if separate by spaces is active it does not find inside other words',
        () {
      // given
      const patterns = ['vier', 'ei'];
      final aho = AhoCorasick.fromWordList(patterns, separateBySpaces: true);
      const input = 'drei vier';
      // when
      final res = aho.firstMatch(input);
      final resLongest = aho.firstMatch(input, longest: true);
      // then
      expect(res, isNotNull);
      expect(res.startIndex, input.indexOf(patterns[0]));
      expect(res.word, 'vier');

      expect(resLongest, isNotNull);
      expect(resLongest.startIndex, input.indexOf(patterns[0]));
      expect(resLongest.word, 'vier');
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

    test('if separate by spaces is active it does not find inside other words',
        () {
      // given
      const patterns = ['drei', 'ei'];
      final aho = AhoCorasick.fromWordList(patterns, separateBySpaces: true);
      const input = 'drei';
      // when
      final res = aho.matches(input);
      // then
      expect(res, hasLength(1));
      expect(res.first.word, input);
    });

    test('it finds adjacent patterns with space separation', () {
      // given
      const patterns = ['eins', 'zwei'];
      final aho = AhoCorasick.fromWordList(patterns, separateBySpaces: true);
      const input = 'eins zwei';
      // when
      final res = aho.matches(input);
      // then
      expect(res, hasLength(2));
      expect(res.first.word, patterns[0]);
      expect(res.last.word, patterns[1]);
    });
  });
}
