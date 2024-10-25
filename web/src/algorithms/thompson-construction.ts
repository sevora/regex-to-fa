
/**
 * This is a single state with transitions
 * leading to other states.
 */
export interface AutomatonState {
    label: string | null;
    transitions: AutomatonTransition[]
}

export type AutomatonTransition = {
    label: string | null,
    state: AutomatonState
};

/**
 * An implementation of Thompson's Construction algorithm. It accepts
 * a postfix expression and generates an NFA with nulls.
 */
export function thompsonConstruction(postfixExpression: string) {
    const stack: AutomatonState[] = [];

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
                    const end: AutomatonState = { label: null, transitions: [] };

                    child1.transitions[0].state.transitions.push({ label: null, state: end });
                    child2.transitions[0].state.transitions.push({ label: null, state: end });

                    const start: AutomatonState = {
                        label: null,
                        transitions: [
                            { label: null, state: child1 },
                            { label: null, state: child2 }
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
                    const start: AutomatonState = {
                        label: null,
                        transitions: [
                            { label: null, state: child }
                        ]
                    };

                    const end: AutomatonState = { 
                        label: null,
                        transitions: []
                    };

                    let foundEnd = child;

                    while (foundEnd.transitions.length > 0) {
                        foundEnd = foundEnd.transitions[0].state;
                    }

                    foundEnd.transitions.push({ label: null, state: end });
                    foundEnd.transitions.push({ label: null, state: child });
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
                        foundEnd = foundEnd.transitions[0].state;
                    }

                    foundEnd.transitions.push({ label: null, state: child2 });
                    stack.unshift(child1);
                }
            } break;
            default: {
                /**
                 * This creates a state like so:
                 * state --token--> state
                 */
                const start: AutomatonState = {
                    label: null,
                    transitions: [],
                };

                const end: AutomatonState = {
                    label: null,
                    transitions: []
                }

                start.transitions.push({ label: token, state: end });
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