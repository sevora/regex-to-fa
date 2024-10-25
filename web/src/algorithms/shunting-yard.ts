export type BinaryOperator = "+" | "|" | "?";
export type UnaryOperator = "*";
export type GroupOperator = "(" | ")";
export type Operator = BinaryOperator | UnaryOperator | GroupOperator;

/**
 * This normalizes the regular expression by adding the merge operator (represented by ?)
 * properly. Example: a(a+b)*b -> a?(a+b)*?b
 * @param expression - A non-normalized regular expression, i.e. a(a+b)*b
 */
export function normalizeExpression(expression: string) {
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
 * This is an implementation of the Shunting-Yard algorithm.
 * It Converts a normalized regular expression to an postfix expression. 
 * Example: a?(a+b)*?b -> aab+*?b?
 * @param normalizedExpression - A normalized regular expression (use `normalizeExpression` to guarantee this) i.e.  a?(a+b)*?b
 */
export function infixToPostfix(normalizedExpression: string) {
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
    }

    while (operatorStack.length > 0) {
        outputQueue.push(operatorStack.shift());
    }

    return outputQueue.join("");
}

/**
 * This allows us to compare the precedence of operations needed for conversion 
 * from infix to postfix
 * @param a the first operator
 * @param b the second operator
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

/**
 * This is an example usage of these functions.
 * Running this would log the results of the working algorithms.
 */
export function exampleUsage() {
    /**
     * Original regular expression: a(a+b)*b
     * Normalized regular expression: a?(a+b)*?b
     * Postfix expression: aab+*?b?
     */
    const regularExpression = "a(a+b)*b";
    const normalizedExpression = normalizeExpression(regularExpression);
    const postfixExpression = infixToPostfix(normalizedExpression);
    
    console.table({
        regularExpression, 
        normalizedExpression, 
        postfixExpression
    });
}