
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

    const tree = stack.shift();
    if (tree) 
        setLabelNames(tree);

    return tree;
}

/**
 * This sets the label names accordingly by traversing
 * the tree by utilizing a stack.
 * @param node the root node
 */
function setLabelNames(node: AutomatonState) {
    let stateIndex = 0;
    let visited: AutomatonState[] = [];
    let nodes: AutomatonState[] = [node];

    while (nodes.length > 0) {
        const node = nodes.shift()!;
        node.label = "q" + stateIndex++;

        node.transitions.forEach(transition => {
            if (!visited.includes(transition.state))
                nodes.push(transition.state);
        })

        visited.push(node);
    }
}

/**
 * This gets the transition table of a tree by traversing
 * it twice. Once to retrieve all the headers, and for the second time
 * to get the associated values for each column in every row.
 * @param node the root node
 */
export function getTransitionTable(node: AutomatonState) {
    let headers: string[] = [];
    let table: string[][] = [];

    let visited: AutomatonState[] = [];
    let nodes: AutomatonState[] = [node];

    // retrieve headers or transitions
    while (nodes.length > 0) {
        const node = nodes.shift()!;
        node.transitions.forEach(transition => {
            if (!headers.includes(transition.label || "ε"))
                headers.push(transition.label || "ε");

            if (!visited.includes(transition.state))
                nodes.push(transition.state);
        })
        visited.push(node);
    }

    // we sort the headers for consistency
    headers.sort();

    visited = [];
    nodes = [node];

    // retrieve the values for each row
    while (nodes.length > 0) {
        const node = nodes.shift()!;
        const values: string[] = new Array(headers.length).fill("ε");

        node.transitions.forEach(transition => {  
            const index = headers.indexOf(transition.label || "ε");
            const value = transition.state.label;
            values[index] = value || "ε";

            if (!visited.includes(transition.state))
                nodes.push(transition.state);
        })

        // we include the name of the node with these transitions
        values.unshift(
            (node.label === "q0" ? "→" : "") +
            (node.transitions.length === 0 ? "*" : "") 
            + node.label || "ε"
        );
        table.push(values);
        visited.push(node);
    }

    // finally, add the headers into the table
    headers.unshift("state");
    table.unshift(headers);
    return table;
}

/**
 * This is an example usage of the Thompson Construction
 * implementation that creates states that we may render.
 */
export function exampleUsage() {
    const nfa = thompsonConstruction("aab+*?b?");
    console.log(nfa);
}