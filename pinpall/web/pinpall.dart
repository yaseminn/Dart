import 'dart:html';
import 'dart:math';


class Circle {

  num xCoordinate;
  num yCoordinate;
  String color;
  bool filled;
  int radius;
  bool hasShadow;
  num vx = 1;
  num vy = 1;
  CanvasElement canvas;
  String originalColor;

  Circle(this.xCoordinate, this.yCoordinate, this.radius) {
    hasShadow = false;
    filled = true;
  }

  static const num thickness = 2.0;

  void drawCircle(CanvasRenderingContext2D context) {

    context.beginPath();
    context.arc(xCoordinate, yCoordinate, radius, 0, 3 * PI, false);

    // Do the drawing on canvas.
    context.closePath();
    context.lineWidth = thickness;
    context.strokeStyle = color;
    // Fill it with same color if specified.
    if (filled) {
      context.fillStyle = color;
      context.fill();
    }
    //add shadow
    if (hasShadow) {
      context.shadowColor = '#999';
      context.shadowBlur = 25;
      context.shadowOffsetX = 10;
      context.shadowOffsetY = 10;
    }
    context.stroke();
  }

  void animate() {

    //velocity
    xCoordinate += vx;
    yCoordinate += vy;

    //change x direction
    if ((xCoordinate < this.radius) || (xCoordinate >= 960)) {
      vx = -vx;
    }
    //change y direction
    if ((yCoordinate >= 480) || (yCoordinate < this.radius)) {
      vy = -vy;
    }

  }

  bool checkCollision(Circle circle) {
    if (distance(this.xCoordinate, circle.xCoordinate, this.yCoordinate,
        circle.yCoordinate) < this.radius + circle.radius) {
      return true;
    }
    return false;
  }

  void collide(bool collided) {
    if (collided) {
      color = "red";
    } else {
      color = originalColor;
    }
  }
  // measure of distance between circles
  num distance(num x1, num x2, num y1, num y2) => sqrt(pow(x2 - x1, 2) + pow(y2
      - y1, 2));

}


class Pinpall {

  CanvasRenderingContext2D context;
  CanvasElement canvas;
  num width;
  num height;
  Random randNum;

  List<Circle> circles = [];

  Pinpall(this.canvas) {
    context = canvas.context2D;
    randNum = new Random();
  }

  void start() {
    Rectangle rect = canvas.parent.client;
    canvas.width = rect.width;
    canvas.height = rect.height;
    drawCircles(1);
  }

  void drawCircles(num_) {

    context.clearRect(0, 0, canvas.width, canvas.height);

    for (int i = 0; i < circles.length; ++i) {
      bool collisionDetected = false;
      for (int j = 0; j < circles.length; ++j) {
        if (j != i && circles[i].checkCollision(circles[j])) {
          collisionDetected = true;
          num m1 = circles[i].radius * 0.1;
          num m2 = circles[j].radius * 0.1;

          //http://en.wikipedia.org/wiki/Elastic_collision
          num nx = ((m1 - m2) / (m1 + m2)) * circles[i].vx + (2 * m2 / (m1 +
              m2)) * circles[j].vx;

          num ny = ((m1 - m2) / (m1 + m2)) * circles[i].vy+ (2 * m2 / (m1 +
              m2)) * circles[j].vy;

          circles[j].vx = ((m2 - m1) / (m1 + m2)) * circles[j].vx + 
              (2 * m1 / (m1 + m2)) * circles[i].vx;
          
          circles[j].vy = ((m2 - m1) / (m1 + m2)) * circles[j].vy + 
                        (2 * m1 / (m1 + m2)) * circles[i].vy;
              
          circles[i].vx = -nx;
          circles[i].vy = -ny;
          
          break;
        }
      }
      circles[i].collide(collisionDetected);
    }

    for (Circle c in circles) {
      c.drawCircle(context);
    }
    // Do some animation.
    for (Circle c in circles) {
      c.animate();
    }
    requestRedraw();
    drawRect();

  }

  void drawRect() {
    context.rect(0, 0, 1000, 500);
    context.lineWidth = 1;
    context.strokeStyle = 'white';
    context.stroke();
  }

  void requestRedraw() {
    window.requestAnimationFrame(drawCircles);
  }

  static List<String> colors = ["#FF0066", "#660066", "#993399", "#ff00ff",
      "#cc00ff", "#00ff00", "#006600", "#ff3399", "#9900cc"];


  void clickAndCreate(MouseEvent event) {
    Point coordinate = event.offset;
    String initialColor = colors.elementAt(randNum.nextInt(colors.length));

    circles.add(new Circle(coordinate.x, coordinate.y, randNum.nextInt(40))
        ..hasShadow = randNum.nextBool()
        ..color = initialColor
        ..filled = true
        ..originalColor = initialColor);


    print("x : " + coordinate.x.toString() + " y: " + coordinate.y.toString());
  }
}

void main() {
  CanvasElement canvas = querySelector("#area");
  Pinpall pin = new Pinpall(canvas);
  pin.start();
  querySelector("#area")..onClick.listen(pin.clickAndCreate);

}
