export function drawArrow(context: CanvasRenderingContext2D, fromX: number, fromY: number, toX: number, toY: number){
    let angle = Math.atan2(toY-fromY,toX-fromX);
    let width = 4;
    let headLength = 5;
    
    // This makes it so the end of the arrow head is located at tox, toy, don't ask where 1.15 comes from
    toX -= Math.cos(angle) * ((width*1.15));
    toY -= Math.sin(angle) * ((width*1.15));

    // starting path of the arrow from the start square to the end square and drawing the stroke
    context.beginPath();
    context.moveTo(fromX, fromY);
    context.lineTo(toX, toY);
    context.lineWidth = width;
    context.stroke();
    
    // starting a new path from the head of the arrow to one of the sides of the point
    context.beginPath();
    context.moveTo(toX, toY);
    context.lineTo(toX-headLength*Math.cos(angle-Math.PI/7),toY-headLength*Math.sin(angle-Math.PI/7));
    
    // path from the side point of the arrow, to the other side point
    context.lineTo(toX-headLength*Math.cos(angle+Math.PI/7),toY-headLength*Math.sin(angle+Math.PI/7));
    
    // path from the side point back to the tip of the arrow, and then again to the opposite side point
    context.lineTo(toX, toY);
    context.lineTo(toX-headLength*Math.cos(angle-Math.PI/7),toY-headLength*Math.sin(angle-Math.PI/7));

    // draws the paths created above
    context.lineWidth = width;
    context.stroke();
    context.fill();
}

export function drawArrowCurved(
    context: CanvasRenderingContext2D,
    fromX: number,
    fromY: number,
    toX: number,
    toY: number,
    middleX: number,
    middleY: number
) {
    let width = 4;
    let headLength = 5;

    // Draw the curved path
    context.beginPath();
    context.moveTo(fromX, fromY);
    
    // Quadratic curve to the middle point and then to the end point
    context.quadraticCurveTo(middleX, middleY, toX, toY);
    
    context.lineWidth = width;
    context.stroke();

    // Calculate angle for the arrow head
    let angle = Math.atan2(toY - fromY, toX - fromX);
    
    // Adjust the endpoint to be at the tip of the arrow
    toX -= Math.cos(angle) * (width * 1.15);
    toY -= Math.sin(angle) * (width * 1.15);

    // Draw the arrow head
    context.beginPath();
    context.moveTo(toX, toY);
    context.lineTo(toX - headLength * Math.cos(angle - Math.PI / 7),
        toY - headLength * Math.sin(angle - Math.PI / 7)
    );

    context.lineTo(
        toX - headLength * Math.cos(angle + Math.PI / 7),
        toY - headLength * Math.sin(angle + Math.PI / 7)
    );

    context.lineTo(toX, toY);
    context.lineTo(
        toX - headLength * Math.cos(angle - Math.PI / 7),
        toY - headLength * Math.sin(angle - Math.PI / 7)
    );

    context.lineWidth = width;
    context.stroke();
    context.fill();
}