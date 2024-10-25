type BinaryOperator = "+" | "|" | "?";
type UnaryOperator = "*";
type GroupOperator = "(" | ")";
type Operator = BinaryOperator | UnaryOperator | GroupOperator;

/**
 * This normalizes the regular expression by adding the merge operator (represented by ?)
 * properly. Example conversion: a(a+b)*b -> a?(a+b)*?b
 * @param expression - A non-normalized regular expression, i.e. a(a+b)*b
 */
function normalizeExpression(expression: string) {
    let result = [];

    for (let index = 0; index < expression.length; ++index) {
        const token = expression[index];        
        const nextToken = expression[index + 1];

        result.push(token);
        
        if ( 
            !["+", "|", "(", ")"].includes(token) &&          // token can accept merge (?) operator such as transitions and unary operations
            !["+", "|", ")", undefined].includes(nextToken)   // next token is not a binary operator or a group closing
        ) result.push("?");
    }

    return result.join("");
}

/**
 * Converts a normalized regular expression to an postfix expression
 * @param normalizedExpression - A normalized regular expression (use `normalizeExpression` to guarantee this) i.e.  a?(a+b)*?b
 */
function infixToPostfix(normalizedExpression: string) {
    let operatorStack: Operator[] = [];
    let outputQueue = [];

    for (let index = 0; index < normalizedExpression.length; ++index) {
        const token = normalizedExpression[index];
        
        switch (token) {
            case "+":
            case "|":
            case "*":
            case "?":
                while (operatorStack.length > 0 && operatorStack[0] !== "(" && (operatorStack[0] === token || compareOperatorPrecedence(operatorStack[0], token))) {
                    outputQueue.push(operatorStack.shift());
                }

                operatorStack.unshift(token);
                break;

            case "(":
                operatorStack.unshift(token);
                break;

            case ")":
                clearStack:
                    while (operatorStack.length > 0) {
                        const operator = operatorStack.shift();
                        if (operator === "(")
                            break clearStack;
                        else 
                            outputQueue.push(operator);
                    }
                break;

            default:
                outputQueue.push(token);
                break;
        }

        console.log(operatorStack, outputQueue)
    }

    while (operatorStack.length > 0) {
        outputQueue.push(operatorStack.shift());
    }

    return outputQueue.join("");
}

/**
 * 
 * @param a 
 * @param b 
 * @returns true if the first operator has higher precedence than the second operator, false otherwise
 */
function compareOperatorPrecedence(a: Operator, b: Operator) {    
    /**
     * Precedence of operators from highest to lowest:
     * 1. Closure or Kleene Star a*
     * 2. Concatenation a?b
     * 3. Union a+b or a|b
     */
    const ranks = {
        "*": 4,
        "?": 3,
        "+": 2,
        "|": 2,
        "(": 1,
        ")": 1
    };

    return ranks[a] > ranks[b];
}

let x = normalizeExpression("a(a+b)*b");
let y = infixToPostfix(x);
console.log(x);
console.log(y);