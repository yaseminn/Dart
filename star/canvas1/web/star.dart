import 'dart:html';

class SimpleDrawing {
  CanvasElement canvas;
  num width;
  num height;

  SimpleDrawing(this.canvas);

  void start() {
    Rectangle rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
    CanvasRenderingContext2D context = canvas.context2D;
    drawStar(context);

  }

  static const String COLOR = 'green';
  static const String STROKE = '#003300';
  static const int LENGTH = 100;
  static const int STAR = 5;


  void drawStar(CanvasRenderingContext2D context) {

    // move into the middle of the canvas, just to make room
    context.translate(LENGTH, LENGTH * 2);

    // initial offset rotation so our star is straight
    context.rotate((3.14 * 0.1));

    // make a point, 5 times
    for (int i = STAR; i > 0; i--) {
      // draw line up
      context.lineTo(0, LENGTH);
      // move origin to current same location as pen
      context.translate(0, LENGTH);
      // rotate the drawing board
      context.rotate((3.14 * 0.2));
      // draw line down
      context.lineTo(0, -LENGTH);
      // again, move origin to pen...
      context.translate(0, -LENGTH);
      // ...and rotate, ready for next arm
      context.rotate(-(3.14 * 0.6));

    }

    // last line to connect things up
    context.lineTo(0, LENGTH);
    context.strokeStyle = STROKE;
    context.fillStyle = COLOR;
    context.fill();
    context.lineWidth = 5;
    context.shadowColor = '#999';
    context.shadowBlur = 25;
    context.shadowOffsetX = 20;
    context.shadowOffsetY = 20;
    context.closePath();

    // stroke the path, you could also .fill()
    context.stroke();

    text(context);


  }

  static const String TEXT = "yasemin";
  static const String TEXTCOLOR = "RED";
  void text(CanvasRenderingContext2D context) {
    context.font = 'bold 20pt Calibri';
    context.fillStyle = TEXTCOLOR ;
    context.fillText(TEXT, LENGTH, LENGTH);

  }

}

void main() {
  // Get the canvas
  CanvasElement canvas = querySelector("#area");
  SimpleDrawing drawing = new SimpleDrawing(canvas);
  drawing.start();
}
