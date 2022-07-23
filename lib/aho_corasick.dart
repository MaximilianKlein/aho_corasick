/// Implementation of the state-machine based pattern matchinig
/// algorithm "Aho-Corasick". It is especially useful, when you
/// have a huge set of words that might occur in your text and you want
/// to search for any of those
library aho_corasick;

import 'dart:collection';
import 'dart:math';

part 'src/aho_corasick.dart';
part 'src/match.dart';
part 'src/state_machine.dart';
part 'src/word_state.dart';
