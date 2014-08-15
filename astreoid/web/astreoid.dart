import 'dart:html';
import 'dart:math';
import 'dart:async';

class Room {
  num x1, y1, x2, y2;

  Room(this.x1, this.y1, this.x2, this.y2);

  Room.fromRect(Rectangle rect) {
    x1 = rect.left;
    y1 = rect.top;
    x2 = rect.right;
    y2 = rect.bottom;
  }

  num get width => (x1 - x2).abs();

  num get height => (y1 - y2).abs();

  void draw(CanvasRenderingContext2D context) {
    context.fillStyle = "black";
    context.clearRect(x1, y1, x2, y2);
    context.fillRect(x1, y1, this.width, this.height);
  }
}

class Astreoid {
  num xCoordinate;
  num yCoordinate;
  String color;
  int radius;
  num vx;
  num vy;
  CanvasElement canvas;
  ImageElement image;
  int width = 0;
  int height = 0;
  Random randNum = new Random();
  int choice = 0;

  static const int SMALL = 1;
  static const int MEDIUM = 2;
  static const int LARGE = 3;

  // For now,
  Astreoid(this.xCoordinate, this.yCoordinate, this.radius, this.choice) {
    switch (choice) {
      case SMALL:
        image = new ImageElement(src: "small.png");
        break;
      case MEDIUM:
        image = new ImageElement(src: "medium.png");
        break;
      case LARGE:
        image = new ImageElement(src: "large.png");
        break;
    }

    vx = getRandomDouble(-1.0, 1.0);
    vy = getRandomDouble(-1.0, 1.0);

    Future.wait([image.onLoad.first]).then((_) {
      width = image.width;
      height = image.height;
      print("Image loaded. $width $height");
    });
  }

  static const num thickness = 2.0;

  void draw(CanvasRenderingContext2D context) {
    context.drawImage(image, xCoordinate, yCoordinate);
  }

  static const double xCoordianate = 800.0;
  static const double yCoordianate = 500.0;

  void animate() {
    //velocity
    xCoordinate += vx;
    yCoordinate += vy;

    //change y direction
    if (yCoordinate <= -height) {
      yCoordinate = yCoordianate;
    } else if (yCoordinate >= yCoordianate) {
      yCoordinate = -height.toDouble();
    }

    if (xCoordinate <= -width) {
      xCoordinate = xCoordianate;
    } else if (xCoordinate >= xCoordianate) {
      xCoordinate = -width.toDouble();
    }

  }
  double getRandomDouble(double min, double max) => randNum.nextDouble() * (max
      - min) + min;

  //point in the rectangle or not
  bool hitTheBullet(Bullet bullet) => (xCoordinate <= bullet.x) && (xCoordinate
      + width >= bullet.x) && (bullet.y >= yCoordinate) && (bullet.y <= yCoordinate +
      height);
}

class Bullet {
  ImageElement bullet;
  double x;
  double y;
  double startAngle = -PI / 2;
  double angleIncrease = 0.0;
  double vx = 0.0;
  double vy = 0.0;

  Bullet(SpaceShip ship) {
    bullet = new ImageElement(src: "bullet.png");
    // Adjust velocity etc and angle according to spaceship coordinates and speed.
    x = ship.x + ship.centerX;
    y = ship.y + ship.centerY;
    // geminin hizi + ayni dogrultuda mermi icin ekstra hiz.
    vx = ship.vx + cos(ship.startAngle) * 3;
    vy = ship.vy + sin(ship.startAngle) * 3;
  }

  void animate() {
    x += vx;
    y += vy;
  }

  void draw(CanvasRenderingContext2D context) {
    context.drawImage(bullet, x, y);
  }

  bool outOfScreen(Room room) {
    if (x <= 0 || x >= room.width) return true;
    if (y <= 0 || y >= room.height) return true;
    return false;
  }

}

class SpaceShip {
  ImageElement firingRockets;
  ImageElement rocket;
  double x;
  double y;
  double startAngle = -PI / 2;
  double angleIncrease = 0.0;
  double vx = 0.0;
  double vy = 0.0;
  bool isFiringRoket = false;
  int width = 0;
  int height = 0;
  // Center of the spaceship from x,y corner coordinates.
  int centerX = 20;
  int centerY = 30;
  bool canFire = true;

  SpaceShip(this.x, this.y) {
    rocket = new ImageElement(src: "nofire.png");
    firingRockets = new ImageElement(src: "fire.png");
    var futures = [rocket.onLoad.first, firingRockets.onLoad.first];
    Future.wait(futures).then((_) {
      width = rocket.width;
      height = rocket.height;
      print("Images loaded. $width $height");
    });
  }

  void draw(CanvasRenderingContext2D context) {
    ImageElement image = isFiringRoket ? firingRockets : rocket;
    context.save();
    context.translate(x, y); // Move coordinate system to x,y
    context.translate(centerX, centerY);
    // Move it to center of image, 32: Half of image size
    context.rotate(startAngle + (PI / 2));
    // Adjust the angle and Rotate (Ship is looking upwards.)
    context.drawImage(image, -centerX, -centerY);
    // Draw it to correct coordinates according to moved origin.
    context.restore();
  }

  void turn(double angle) {
    startAngle += angle;
  }

  static const double xCoordianate = 800.0;
  static const double yCoordianate = 500.0;

  void move() {
    // ship is always in distance
    if (y <= -height) {
      y = yCoordianate;
    } else if (y >= yCoordianate) {
      y = -height.toDouble();
    }

    if (x <= -width) {
      x = xCoordianate;
    } else if (x >= xCoordianate) {
      x = -width.toDouble();
    }

    x += vx;
    y += vy;

    //Add some friction
    vx = vx * 0.99;
    vy = vy * 0.99;
  }

  void applyThrust() {
    num t = 0.2;
    vx += cos(startAngle) * t;
    vy += sin(startAngle) * t;
  }
}

class Game {
  bool gameOver = false;
  CanvasRenderingContext2D context;
  CanvasElement canvas;
  Random randNum = new Random();

  //object of game
  Room room;
  SpaceShip ship;
  List<Astreoid> astreoids = [];
  List<Bullet> bullets = [];

  Game(this.canvas) {
    context = canvas.context2D;
  }

  void start() {
    room = new Room.fromRect(canvas.client);
    ship = new SpaceShip(400.0, 200.0);
    prepareAstreoids();
    requestRedraw();
  }

  void requestRedraw() {
    if (!gameOver) {
      window.requestAnimationFrame(drawAll);
    }
  }
  double getRandomDouble(double min, double max) => randNum.nextDouble() * (max
      - min) + min;

  int getRandomInt(int min, int max) => randNum.nextInt(max - min) + min;

  void prepareAstreoids() {
    for (int i = 0; i < 7; ++i) {
      num x = getRandomDouble(0.0, 750.0);
      num y = getRandomDouble(0.0, 350.0);
      // Check if asteroids is far away from ship.
      while (sqrt((x - ship.x) * (x - ship.x) + (y - ship.y) * (y - ship.y)) <
          250) {
        x = getRandomDouble(0.0, 750.0);
        y = getRandomDouble(0.0, 350.0);
      }
      astreoids.add(new Astreoid(x, y, randNum.nextInt(50), getRandomInt(1, 4))
          );
    }
  }

  void onKeyPress(KeyboardEvent k) {
    var keyEvent = new KeyEvent.wrap(k);
    if (keyEvent.keyCode == KeyCode.LEFT || keyEvent.keyCode == KeyCode.A) {
      ship.turn(-PI / 60);
    }
    if (keyEvent.keyCode == KeyCode.RIGHT || keyEvent.keyCode == KeyCode.D) {
      ship.turn(PI / 60);
    }
    if (keyEvent.keyCode == KeyCode.UP || keyEvent.keyCode == KeyCode.W) {
      ship.applyThrust();
      ship.isFiringRoket = true;
    }
    if (keyEvent.keyCode == KeyCode.SPACE) {
      bullets.add(new Bullet(ship));
      ship.canFire = false;
    }
    ship.canFire = true;
  }

  void onNotKeyPress(KeyboardEvent k) {
    var keyEvent = new KeyEvent.wrap(k);
    if (keyEvent.keyCode != KeyCode.UP || keyEvent.keyCode != KeyCode.W) {
      ship.isFiringRoket = false;
    }
  }

  void createTwoAstreoids(int j, int choice) {

    if (choice - 1 == 0) {
      astreoids.removeAt(j);
    } else {
      astreoids.add(new Astreoid(astreoids[j].xCoordinate,
          astreoids[j].yCoordinate, randNum.nextInt(50), choice - 1));

      astreoids.add(new Astreoid(astreoids[j].xCoordinate + 1,
          astreoids[j].yCoordinate + 1, randNum.nextInt(50), choice - 1));
      astreoids.removeAt(j);
    }

  }

  void drawAll(num _) {

      for (int i = 0; i < bullets.length; ++i) {
        bool hit = false;
        for (int j = 0; j < astreoids.length; ++j) {
          if (astreoids[j].hitTheBullet(bullets[i])) {
            createTwoAstreoids(j, astreoids[j].choice);
            hit = true;
            break;
          }
        }
        if (hit) {
          bullets.removeAt(i);
        }
      }

      for (Astreoid a in astreoids) {
        a.animate();
      }

      // if bullet is out of screen or collided with asteroids, it should be removed.
      for (int i = 0; i < bullets.length; i++) {
        if (bullets[i].outOfScreen(room)) {
          bullets.removeAt(i);
        }
      }

      for (Bullet b in bullets) {
        b.animate();
      }

      context.clearRect(0, 0, canvas.width, canvas.height);
      // draw everything.
      room.draw(context);
      for (Bullet b in bullets) {
        b.draw(context);
      }
      ship.draw(context);
      ship.move();
      for (Astreoid a in astreoids) {
        a.draw(context);
      }
      requestRedraw();
    }

  }

void main() {
  CanvasElement canvas = querySelector("#area");
  Game game = new Game(canvas);

  document..onKeyUp.listen(game.onNotKeyPress);
  document..onKeyDown.listen(game.onKeyPress);

  game.start();
}