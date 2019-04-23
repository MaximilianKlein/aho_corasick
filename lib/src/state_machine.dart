part of aho_corasick;

typedef Transition<State, Input> = State Function(
    {State activeState, Input input});

class StateMachineState<State, Input> {
  StateMachineState({this.stateMachine});
  final StateMachine<State, Input> stateMachine;

  int _activeStateIndex = 0;
  State get activeState => stateMachine.states[_activeStateIndex];

  bool get activeStateIsSuccess => stateMachine.isSuccessState(activeState);

  int _stateIndex(State state) => stateMachine.stateIndexMap[state];

  void performStep(Input input) {
    _activeStateIndex = _stateIndex(
        stateMachine.transition(activeState: activeState, input: input));
  }
}

class StateMachine<State, Input> {
  StateMachine(
      {@required this.states,
      @required this.isSuccessState,
      @required this.transition}) {
    _initializeStateIndexMap();
  }

  /// list of states for this machine. First state is starting state.
  final List<State> states;

  /// list of states considered to be successes
  final bool Function(State) isSuccessState;

  /// the transitions that define how this automaton works
  final Transition<State, Input> transition;

  Map<State, int> stateIndexMap;

  // create the map that assigns the index to every state
  void _initializeStateIndexMap() {
    // cache map so that we only create it once
    if (stateIndexMap != null) {
      return;
    }
    stateIndexMap = {};
    for (var i = 0; i < states.length; i++) {
      stateIndexMap[states[i]] = i;
    }
  }

  StateMachineState<State, Input> createState() =>
      StateMachineState(stateMachine: this);
}
