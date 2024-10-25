/// This is a single state with transitions
/// leading to other states.
class AutomatonState {
  String? label;
  List<AutomatonTransition> transitions;

  AutomatonState({this.label, List<AutomatonTransition>? transitions})
      : transitions = transitions ?? [];
}

class AutomatonTransition {
  String? label;
  AutomatonState state;

  AutomatonTransition({this.label, required this.state});
}

/// An implementation of Thompson's Construction algorithm. It accepts
/// a postfix expression and generates an NFA with nulls.
AutomatonState? thompsonConstruction(String postfixExpression) {
  final List<AutomatonState> stack = [];

  for (int index = 0; index < postfixExpression.length; ++index) {
    final token = postfixExpression[index];

    switch (token) {
      case '+':
      case '|':
        {
          /// This does a union operation by connecting
          /// both children's start state to a single start state
          /// and connecting their end states to a single end state.
          final child2 = stack.isNotEmpty ? stack.removeLast() : null;
          final child1 = stack.isNotEmpty ? stack.removeLast() : null;

          if (child1 != null && child2 != null) {
            final end = AutomatonState(label: null);

            child1.transitions[0].state.transitions.add(
                AutomatonTransition(label: null, state: end));
            child2.transitions[0].state.transitions.add(
                AutomatonTransition(label: null, state: end));

            final start = AutomatonState(
              label: null,
              transitions: [
                AutomatonTransition(label: null, state: child1),
                AutomatonTransition(label: null, state: child2),
              ],
            );

            stack.add(start);
          }
        }
        break;
      case '*':
        {
          /// This makes a circularity by making
          /// the diagram's end state transition
          /// connect to the start state.
          final child = stack.isNotEmpty ? stack.removeLast() : null;

          if (child != null) {
            final start = AutomatonState(
              label: null,
              transitions: [
                AutomatonTransition(label: null, state: child)
              ],
            );

            final end = AutomatonState(label: null);

            var foundEnd = child;

            while (foundEnd.transitions.isNotEmpty) {
              foundEnd = foundEnd.transitions[0].state;
            }

            foundEnd.transitions.add(AutomatonTransition(label: null, state: end));
            foundEnd.transitions.add(AutomatonTransition(label: null, state: child));
            stack.add(start);
          }
        }
        break;
      case '?':
        {
          final child2 = stack.isNotEmpty ? stack.removeLast() : null;
          final child1 = stack.isNotEmpty ? stack.removeLast() : null;

          /// This merges children by getting the
          /// end state of child1 and pushing child2 into
          /// its transitions.
          if (child1 != null && child2 != null) {
            var foundEnd = child1;

            while (foundEnd.transitions.isNotEmpty) {
              foundEnd = foundEnd.transitions[0].state;
            }

            foundEnd.transitions.add(AutomatonTransition(label: null, state: child2));
            stack.add(child1);
          }
        }
        break;
      default:
        {
          /// This creates a state like so:
          /// state --token--> state
          final start = AutomatonState(
            label: null,
            transitions: [],
          );

          final end = AutomatonState(label: null, transitions: []);

          start.transitions.add(AutomatonTransition(label: token, state: end));
          stack.add(start);
        }
        break;
    }
  }

  return stack.isNotEmpty ? stack.removeLast() : null;
}

/// This is an example usage of the Thompson Construction
/// implementation that creates states that we may render.
void exampleUsage() {
  final nfa = thompsonConstruction("aab+*?b?");
  print(nfa);
}