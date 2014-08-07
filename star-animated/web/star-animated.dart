import 'dart:html';
import 'dart:math';

class Star {
  int points;
  int size;
  String color;
  double x;
  double y;
  double startAngle;
  bool filled;
  bool hasShadow;
  // Animation related
  double angleIncrease;
  double ratio;
  double vx;
  double vy;
  String originalColor;

  Star() {
    startAngle = 0.0;
    ratio = 0.4;
    angleIncrease = 0.0;
    hasShadow = false;
    
  }

  static const num thickness = 2.0;

  void animate() {
    startAngle += angleIncrease;
    if (x < size || x > 500 - size) {
      vx = -vx;
    }
    if (y < size || y > 500 - size) {
      vy = -vy;
    }
    x += vx;
    y += vy;
  }

  bool checkCollision(Star other) => 
      sqrt(pow(x - other.x, 2) + pow(y - other.y, 2)) <= (size + other.size);

  void collide(bool collided) {
    if (collided) {
      color = "#A05";
    } else {
      color = originalColor;
    }
  }
  
  void draw(CanvasRenderingContext2D context) {
    context.beginPath();
    // How many poins on the circle? = 2 * pi / (points * points).
    double _step = PI / points;
    // Short line length.
    double innerSize = size * ratio;
    for (int i = 0; i < points * 2 + 1; i++) {
      // One long, one short line (This is a star).
      double lineSize = i % 2 == 0 ? size.toDouble() : innerSize;
      // Angle increases towards 2 * Pi (A circle).
      double angle = startAngle + i * _step;
      // Basic trigonometry, convert polar coordinates to scalar.
      double sx = x + (lineSize * cos(angle));
      double sy = y + (lineSize * sin(angle));
      // If first point, only move to the point, otherwise, draw a line.
      if (i == 0) {
        context.moveTo(sx, sy);
      } else {
        context.lineTo(sx, sy);
      }
    }
    // Save the context
    context.save();
    if (hasShadow) {
      context.shadowColor = '#CCC';
      context.shadowOffsetX = 3;
      context.shadowOffsetY = 3;
    }
    if (filled) {
      context.lineWidth = 0.0;
      context.fillStyle = color;
      context.fill();
    } else {
      context.lineWidth = thickness;
      context.strokeStyle = color;
      context.stroke();
    }
    // Restore it to remove effects like shadow.
    context.restore();
    context.closePath();
  }
}

class Stars {
  CanvasElement canvas;
  num width;
  num height;
  CanvasRenderingContext2D context;
  List<Star> stars = [];
  Random rnd;

  Stars(this.canvas) {
    context = canvas.context2D;
    rnd = new Random();
  }

  void start() {
    Rectangle rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
    // Start animating.
    requestRedraw();
  }

  static List<String> colors = ["#F00", "#0A5", "#00F", "#08F", "#F50", "#F08"];

  void onMouseClick(MouseEvent m) {
    Point offset = m.offset;
    bool filled = false;
    if (m.button == 2) {
      filled = true;
    }
    
    String color = colors[rnd.nextInt(colors.length)];
    stars.add(new Star()
        ..points = getRandomInt(4, 9)
        ..x = offset.x.toDouble()
        ..y = offset.y.toDouble()
        ..size = getRandomInt(20, 50)
        ..color = color
        ..originalColor = color
        ..startAngle = getRandomDouble(0.0, 2 * PI)
        ..ratio = getRandomDouble(0.3, 0.6)
        ..filled = filled
        ..hasShadow = rnd.nextBool()
        ..angleIncrease = getRandomDouble(PI / 300, PI / 90)
        ..vx = getRandomDouble(0.1, 2.0)
        ..vy = getRandomDouble(0.1, 2.0));
    querySelector("#coordinates")
        ..text = "x: ${offset.x} y: ${offset.y}";
  }

  void drawAll(num _) {
    // Clear the canvas
    context.clearRect(0, 0, canvas.width, canvas.height);
    // Check collisions
    for (int i = 0; i < stars.length; i++) {
      bool collisionDetected = false;
      for (int j = 0; j < stars.length; j++) {
        if (j != i && stars[i].checkCollision(stars[j])) {
          collisionDetected = true;
          break;
        }
      }
      stars[i].collide(collisionDetected);    
    }
    
    for (Star s in stars) {
      s.draw(context);
    }
    // Do some animation.
    for (Star s in stars) {
      s.animate();
    }
    requestRedraw();
  }

  void requestRedraw() {
    window.requestAnimationFrame(drawAll);
  }

  int getRandomInt(int min, int max) => rnd.nextInt(max - min) + min;

  double getRandomDouble(double min, double max) => rnd.nextDouble() * (max - min) + min;
}

void main() {
  CanvasElement canvas = querySelector("#area");
  Stars drawing = new Stars(canvas);

  // Handle left mouse clicks.
  querySelector("#area")
      ..onClick.listen(drawing.onMouseClick);

  // Handle right mouse clicks as well.
  canvas..onContextMenu.listen((e) {
        // This will stop the browser from displaying the menu.
        e.preventDefault();
        // Now redirect click event to our handler.
        drawing.onMouseClick(e);
      });

  // Animate.
  drawing.start();
}
