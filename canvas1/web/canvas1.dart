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
    drawBoard( context);
  }

  static const String COLORBLACK = "#000000";
  static const String COLORRED = "#ff0000";
  static const int SIZE = 50;
  static const int COLS = 8;
  static const int ROWS = 8;


  void drawBoard(CanvasRenderingContext2D context) {
    for (int i = 0; i < ROWS; ++i) {
      for (int j = 0; j < COLS; ++j) {
        int x = i * SIZE;
        int y = j * SIZE;
        int selection = i % 2 + j % 2;
        context.fillStyle = selection == 1 ? COLORBLACK : COLORRED;
        context.fillRect(x, y, SIZE, SIZE);
      }
    }
  }

}

void main() {
  // Get the canvas
  CanvasElement canvas = querySelector("#area");
  SimpleDrawing drawing = new SimpleDrawing(canvas);
  drawing.start();
}
