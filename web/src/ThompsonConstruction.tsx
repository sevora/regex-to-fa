import { useEffect, useRef } from 'react';
import { AutomatonState, getTransitionTable, thompsonConstruction } from './algorithms/thompson-construction';
import { drawArrow, drawArrowCurved } from './utilities/canvas';

interface ThompsonConstructionProps {
    postfixExpression: string;
}

/**
 * This is a Thompson Construction Component.
 * It includes the transition diagram and transition table
 * upon applying Thompson's construction.
 */
function ThompsonConstruction({ postfixExpression }: ThompsonConstructionProps) {
    const canvasReference = useRef<HTMLCanvasElement | null>(null);
    function startCanvasDrawSequence(canvas: HTMLCanvasElement, context: CanvasRenderingContext2D) {
        const tree = thompsonConstruction(postfixExpression);
        
        let renderedNodes: AutomatonState[] = [];
        let renderedPositions: [number, number][] = [];

        if (tree) {
            context.clearRect(0, 0, canvas.width, canvas.height);
            renderNode("ε", tree, null, 0);
            renderTable(tree, 0, 500);
        }
        
        /**
         * This is used to render the nodes individually and draw arrows connecting
         * them that is why this demands the previous node.
         * @param label the label of the transition
         * @param node the root or current node
         * @param previousNode the previous node
         * @param offsetY the offsetY used for layouting
         * @returns 
         */
        function renderNode(label: string | null, node: AutomatonState, previousNode: AutomatonState | null, offsetY: number) {
            const lineLength = 100;
            const radius = 60;
            
            const previousStateIndex = previousNode ? renderedNodes.indexOf(previousNode) : -1;
            const [previousX, previousY] = previousStateIndex > -1 ? renderedPositions[previousStateIndex] : [0, 150];

            const existIndex = renderedNodes.indexOf(node);
            context.fillStyle = '#000';

            if (existIndex > -1) {
                const [targetX, targetY] = renderedPositions[existIndex];
                if (targetX < previousX) {
                    const topOriginX = previousX + radius;
                    const topOriginY = previousY - radius;
                    const topTargetX = targetX + radius;
                    const topTargetY = targetY - radius;
                    const midPointX = (topOriginX + topTargetX) / 2;
                    const midPointY = (topOriginY + topTargetY) / 2;
                    const topMidPointY = Math.sqrt(midPointY) - Math.abs(topOriginX - topTargetX) * 0.05;                    
                    drawArrowCurved(context, topOriginX, topOriginY, topTargetX, topTargetY, midPointX, topMidPointY);
                    
                    // we don't want to forget rendering the transition label
                    context.fillStyle = '#000';
                    context.fillStyle = '#000';
                    context.font = "32px monospace";
                    context.textAlign = 'center';
                    context.fillText(label || "ε", midPointX + lineLength / 2, topMidPointY - 15);
    
                } else {
                    drawArrow(context, previousX + radius * 2, previousY, targetX, targetY);
                    
                    // we don't want to forget rendering the transition label
                    context.fillStyle = '#000';
                    context.font = "32px monospace";
                    context.textAlign = 'center';
                    context.fillText(label || "ε", (previousX + targetX) / 2, (previousY + targetY) / 2 - 6);
                }
                return;
            }
            
            const x = previousX + lineLength;
            const y = previousY + offsetY * 1.1 * radius * 2;
            drawArrow(context, previousX + radius * 2, previousY, x + lineLength, y);
            
            // ensure text is properly drawn
            context.textAlign = 'center';
            context.textBaseline = 'middle';

            // draw the label of the transition
            context.fillStyle = '#000';
            context.font = "32px monospace";
            context.textAlign = 'center';
            context.fillText(label || "ε", x + lineLength / 2, y - 15);

        
            // draw the circular state
            context.lineWidth = 3;
            context.beginPath();
            context.arc(x + lineLength + radius, y, radius, 0, 2 * Math.PI);
            context.fillStyle = '#fff';
            context.fill();
            context.stroke();

            // when this is a final state, we want to draw circles
            if (node.transitions.length === 0) {
                context.lineWidth = 3;
                context.beginPath();
                context.arc(x + lineLength + radius, y, radius * 0.8, 0, 2 * Math.PI);
                context.fillStyle = 'transparent';
                context.fill();
                context.stroke();
            }

            // draw the text inside the circular state
            context.fillStyle = '#000';
            context.font = "32px monospace";
            context.fillText(node.label || "ε", x + lineLength + radius, y);

            if (renderedNodes.indexOf(node) === -1) {
                renderedNodes.push(node);
                renderedPositions.push([x + lineLength, y]);
            }

            node.transitions.forEach((transition, index) => {
                renderNode(transition.label, transition.state, node, index);
            });
        }

        /**
         * This renders the table for the given tree.
         * @param node the root node
         * @param startX the starting x-coordinate
         * @param startY the starting y-coordinate
         */
        function renderTable(node: AutomatonState, startX: number, startY: number) {
            const table = getTransitionTable(node);
            const cellWidth = 120;
            const cellHeight = 50;

            for (let y = 0; y < table.length; ++y) {
                const row = table[y];
                for (let x = 0; x < row.length; ++x) {
                    const value = table[y][x];
                    context.strokeStyle = "#000";

                    context.strokeRect(
                        startX + x * cellWidth, 
                        startY + y * cellHeight, 
                        cellWidth, 
                        cellHeight
                    );

                    context.fillStyle = '#000';
                    context.font = "32px monospace";
                    context.textAlign = 'center';
                    context.textBaseline = 'middle';
                    context.fillText(value, startX + x * cellWidth + cellWidth/2,  startY + y * cellHeight + cellHeight / 2);
                }
            }
        }
    }

    useEffect(function () {
        if (canvasReference.current) {
            const canvas = canvasReference.current;
            const context = canvas.getContext('2d');
            if (context)
                startCanvasDrawSequence(canvas, context);
        }
    }, [postfixExpression]);

    return (
        <canvas style={{ width: 1920, height: 1080 }} width={3840} height={2160} ref={canvasReference}>
        </canvas>
    )
}

export default ThompsonConstruction;