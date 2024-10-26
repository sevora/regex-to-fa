typedef BinaryOperator = String;
typedef UnaryOperator = String;
typedef GroupOperator = String;
typedef Operator = String;

const String plus = "+";
const String pipe = "|";
const String questionMark = "?";
const String star = "*";
const String leftParenthesis = "(";
const String rightParenthesis = ")";

/// This normalizes the regular expression by adding the merge operator (represented by ?)
/// properly. Example: a(a+b)*b -> a?(a+b)*?b
/// @param expression - A non-normalized regular expression, i.e. a(a+b)*b
String normalizeExpression(String expression) {
  List<String> result = [];

  for (int index = 0; index < expression.length; ++index) {
    String token = expression[index];
    String? nextToken = index + 1 < expression.length ? expression[index + 1] : null;

    result.add(token);

    if (![plus, pipe, leftParenthesis].contains(token) &&
        ![plus, pipe, rightParenthesis, star, null].contains(nextToken)) {
      result.add(questionMark);
    }
  }

  return result.join("");
}

/// This is an implementation of the Shunting-Yard algorithm.
/// It Converts a normalized regular expression to a postfix expression.
/// Example: a?(a+b)*?b -> aab+*?b?
/// @param normalizedExpression - A normalized regular expression (use `normalizeExpression` to guarantee this) i.e.  a?(a+b)*?b
String infixToPostfix(String normalizedExpression) {
  List<Operator> operatorStack = [];
  List<String> outputQueue = [];

  for (int index = 0; index < normalizedExpression.length; ++index) {
    String token = normalizedExpression[index];

    switch (token) {
      case plus:
      case pipe:
      case star:
      case questionMark:
        while (operatorStack.isNotEmpty &&
            operatorStack.last != leftParenthesis &&
            (operatorStack.last == token || compareOperatorPrecedence(operatorStack.last, token))) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
        break;

      case leftParenthesis:
        operatorStack.add(token);
        break;

      case rightParenthesis:
        while (operatorStack.isNotEmpty) {
          String operator = operatorStack.removeLast();
          if (operator == leftParenthesis) break;
          outputQueue.add(operator);
        }
        break;

      default:
        outputQueue.add(token);
        break;
    }
  }

  while (operatorStack.isNotEmpty) {
    outputQueue.add(operatorStack.removeLast());
  }

  return outputQueue.join("");
}

/// This allows us to compare the precedence of operations needed for conversion
/// from infix to postfix
/// @param a the first operator
/// @param b the second operator
/// @returns true if the first operator has higher precedence than the second operator, false otherwise
bool compareOperatorPrecedence(Operator a, Operator b) {
  final ranks = {
    star: 4,
    questionMark: 3,
    plus: 2,
    pipe: 2,
    leftParenthesis: 1,
    rightParenthesis: 1,
  };

  return ranks[a]! > ranks[b]!;
}

/// This is an example usage of these functions.
/// Running this would log the results of the working algorithms.
void exampleUsage() {
  /**
   * Original regular expression: a(a+b)*b
   * Normalized regular expression: a?(a+b)*?b
   * Postfix expression: aab+*?b?
   */
  String regularExpression = "a(a+b)*b";
  String normalizedExpression = normalizeExpression(regularExpression);
  String postfixExpression = infixToPostfix(normalizedExpression);

  print({
    'regularExpression': regularExpression,
    'normalizedExpression': normalizedExpression,
    'postfixExpression': postfixExpression,
  });
}
