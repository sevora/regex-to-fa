interface BranchNode {
    value: Operation;
    children: Node[];
}

interface LeafNode {
    value: number;
    children?: undefined;
}

export type Operation = "+" | "-" | "*" | "/";

/**
 * Discriminated union, which allows us to do a bit of logic
 * with the types, i.e. identifying which is a BranchNode 
 * and LeafNode through a property.
 */
export type Node = BranchNode | LeafNode;

/**
 * This is meant to evaluate the given
 * tree. This does so recursively
 */
export function evaluate(node: Node): number {
    if (node.children === undefined) // if there is no children, then
        return node.value;           // this is a leaf node expected to be a number

    return (
        node.children
            .map(evaluate)               // we have to evaluate every children recursively
            .reduce(reducer[node.value]) // then apply the reducer accordingly
    );
}

/**
 * These are meant to reduce an array of values
 * into a singular value.
 */
const reducer: { [operation in Operation]: (x: number, y: number) => number } = {
    "+": (x, y) => {
        return x + y;
    },
    "-": (x, y) => {
        return x - y;
    },
    "*": (x, y) => {
        return x * y;
    },
    "/": (x, y) => {
        return x / y;
    }
}

export function example() {
    // This is the tree for 2*(5+3)
    const tree: Node = {
        value: "*",
        children: [
            {
                value: "+",
                children: [
                    { value: 5 },
                    { value: 3 }
                ]
            },
            { value: 2 }
        ]
    };

    const result = evaluate(tree);
    console.log(result);
}