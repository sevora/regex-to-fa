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

  var automata = stack.isNotEmpty ? stack.removeLast() : null;
  if (automata != null) {
    setLabelNames(automata);
  }
  
  return automata;
}

/// This sets the label names accordingly by traversing
/// the tree by utilizing a stack.
/// @param node the root node
void setLabelNames(AutomatonState node) {
  int stateIndex = 0;
  List<AutomatonState> visited = [];
  List<AutomatonState> nodes = [node]; // Assuming 'tree' is defined

  while (nodes.isNotEmpty) {
    var node = nodes.removeAt(0);

    if (visited.contains(node)) {
      continue;
    }

    node.label ??= "q${stateIndex++}";

    for (var transition in node.transitions) {
      if (!visited.contains(transition.state)) {
        nodes.add(transition.state);
      }
    }

    visited.add(node);
  }
}

/// This gets the transition table of a tree by traversing
/// it twice. Once to retrieve all the headers, and for the second time
/// to get the associated values for each column in every row.
/// @param node the root node
List<List<String>> getTransitionTable(AutomatonState node) {
  List<String> headers = [];
  List<List<String>> table = [];

  List<AutomatonState> visited = [];
  List<AutomatonState> nodes = [node];

  // retrieve headers or transitions
  while (nodes.isNotEmpty) {
    var currentNode = nodes.removeAt(0);

    if (visited.contains(currentNode)) {
      continue;
    }

    for (var transition in currentNode.transitions) {
      String label = transition.label ?? "ε";
      if (!headers.contains(label)) {
        headers.add(label);
      }

      if (!visited.contains(transition.state)) {
        nodes.add(transition.state);
      }
    }

    visited.add(currentNode);
  }

  // we sort the headers for consistency
  headers.sort();

  visited = [];
  nodes = [node];

  // retrieve the values for each row
  while (nodes.isNotEmpty) {
    var currentNode = nodes.removeAt(0);

    if (visited.contains(currentNode)) {
      continue;
    }

    List<String> values = List.filled(headers.length, "ε", growable: true);

    for (var index = 0; index < currentNode.transitions.length; ++index) {
      var transition = currentNode.transitions[index];
      String value = transition.state.label ?? "ε";
      values[index] = value;

      if (!visited.contains(transition.state)) {
        nodes.add(transition.state);
      }
    }

    // we include the name of the node with these transitions
    values.insert(0,
        (currentNode.label == "q0" ? "→" : "") +
        (currentNode.transitions.isEmpty ? "*" : "") +
        (currentNode.label ?? "ε")
    );
    table.add(values);
    visited.add(currentNode);
  }

  // finally, add the headers into the table
  headers.insert(0, "state");
  table.insert(0, headers);
  return table;
}

/// This is an example usage of the Thompson Construction
/// implementation that creates states that we may render.
void exampleUsage() {
  final nfa = thompsonConstruction("aab+*?b?");
  print(nfa);
}