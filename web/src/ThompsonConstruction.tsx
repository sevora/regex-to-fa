import { useEffect, useRef } from 'react';
import { AutomatonState, thompsonConstruction } from './algorithms/thompson-construction';
import { drawArrow } from './utilities/canvas';

interface ThompsonConstructionProps {
    postfixExpression: string;
}

/**
 * This is a Thompson Construction Visualizer
 * 
 */
function ThompsonConstruction({ postfixExpression }: ThompsonConstructionProps) {
    const canvasReference = useRef<HTMLCanvasElement | null>(null);
    function startCanvasDrawSequence(canvas: HTMLCanvasElement, context: CanvasRenderingContext2D) {
        const tree = thompsonConstruction(postfixExpression);
        
        let renderedNodes: AutomatonState[] = [];
        let renderedPositions: [number, number][] = [];
        let stateVisualIndex = 0;

        if (tree) {
            context.clearRect(0, 0, canvas.width, canvas.height);
            render([["s1", tree]], null);
        }

        function render(nodes: [string | null, AutomatonState][], previousState: AutomatonState | null) {
            if (nodes.length === 0)
                return;

            const lineLength = 90;
            const radius = 50;
            
            for (let index = 0; index < nodes.length; ++index) {
                const [transition, node] = nodes[index];

                const previousStateIndex = previousState ? renderedNodes.indexOf(previousState) : -1;
                const [previousX, previousY] = previousStateIndex > -1 ? renderedPositions[previousStateIndex] : [0, 150];

                const existIndex = renderedNodes.indexOf(node);
                context.fillStyle = '#000';

                if (existIndex > -1) {
                    const [targetX, targetY] = renderedPositions[existIndex];
                    drawArrow(context, previousX + radius * 2, previousY, targetX, targetY);
                    continue;
                }
                
                let x = previousX + lineLength;
                let y = previousY + index * radius * 2;
                drawArrow(context, previousX + radius * 2, previousY, x + lineLength, y);
                
                // transition value
                context.fillStyle = '#000';
                context.font = "32px monospace";
                context.fillText(transition || "ε", x + lineLength / 2 - 16, y - 10);

                // state 
                context.lineWidth = 3;
                context.beginPath();
                context.arc(x + lineLength + radius, y, radius, 0, 2 * Math.PI);
                context.fillStyle = '#fff';
                context.fill();
                context.stroke();

                context.fillStyle = '#000';
                context.font = "32px monospace";
                context.fillText(`q${stateVisualIndex}`, x + lineLength + radius/2, y);

                stateVisualIndex++;

                if (renderedNodes.indexOf(node) === -1) {
                    renderedNodes.push(node);
                    renderedPositions.push([x + lineLength, y]);
                }

                if (node.transitions) 
                    render(node.transitions, node);
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