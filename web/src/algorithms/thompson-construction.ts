
/**
 * This is a single state with transitions
 * leading to other states.
 */
interface State {
    label: string | null;
    transitions: [string | null, State][]
}

/**
 * An implementation of Thompson's Construction algorithm. It accepts
 * a postfix expression and generates an NFA with nulls.
 */
function thompsonConstruction(postfixExpression: string) {
    const stack: State[] = [];

    for (let index = 0; index < postfixExpression.length; ++index) {
        const token = postfixExpression[index];

        switch (token) {
            case "+":
            case "|": {
                /**
                 * This does a union operation by connecting 
                 * both children's start state to a single start state 
                 * and connecting their end states to a single end state.
                 */
                const child2 = stack.shift();
                const child1 = stack.shift();
                
                if (child1 && child2) {
                    const end: State = { label: null, transitions: [] };

                    child1.transitions[0][1].transitions[0] = [null, end];
                    child2.transitions[0][1].transitions[0] = [null, end];

                    const start: State = {
                        label: null,
                        transitions: [
                            [null, child1],
                            [null, child2]
                        ]
                    }
    
                    stack.unshift(start);
                }
            } break;
            case "*": {
                /**
                 * This makes a circularity by making
                 * the diagram's end state transition  
                 * connect to the start state.
                 */
                const child = stack.shift();

                if (child) {
                    const start: State = {
                        label: null,
                        transitions: [
                            [null, child]
                        ]
                    };

                    const end: State = { 
                        label: null,
                        transitions: []
                    };

                    let foundEnd = child;

                    while (foundEnd.transitions.length > 0) {
                        foundEnd = foundEnd.transitions[0][1];
                    }

                    foundEnd.transitions.push([null, end]);
                    foundEnd.transitions.push([null, child]);
                    stack.unshift(start);
                }
            } break;
            case "?": {
                const child2 = stack.shift();
                const child1 = stack.shift();
                
                /**
                 * This merges children by getting the 
                 * end state of child1 and pushing child2 into
                 * its transitions.
                 */
                if (child1 && child2) {
                    let foundEnd = child1;

                    while (foundEnd.transitions.length > 0) {
                        foundEnd = foundEnd.transitions[0][1];
                    }

                    foundEnd.transitions.push([null, child2]);
                    stack.unshift(child1);
                }
            } break;
            default: {
                /**
                 * This creates a state like so:
                 * state --token--> state
                 */
                const start: State = {
                    label: null,
                    transitions: [],
                };

                const end: State = {
                    label: null,
                    transitions: []
                }

                start.transitions.push([token, end]);
                stack.unshift(start);
            } break;
        }
    }

    return stack.shift();
}

/**
 * This is an example usage of the Thompson Construction
 * implementation that creates states that we may render.
 */
export function exampleUsage() {
    const nfa = thompsonConstruction("aab+*?b?");
    console.log(nfa);
}