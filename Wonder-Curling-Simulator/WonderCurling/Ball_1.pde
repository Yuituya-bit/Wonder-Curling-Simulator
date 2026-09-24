class Ball {
  PVector position;
  PVector velocity;

  float radius, m;

  Ball(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = new PVector(0,0);
    radius = r_;
    m = radius*.1;
  }
  
  void cBall(float xv, float yv, float sn, int posi, int yposi, int n){
    velocity = new PVector(xv, yv);
    velocity.mult(1 + 15 * sn);
    if((n - 1) % 2 == 0){
      position = new PVector(3 * width/4 + posi, yposi);
    } else {
      position = new PVector(width/4 + posi, yposi);
    }
  }

  void update() {
    position.add(velocity);
    velocity.mult(0.99);
  }

  int checkBoundaryCollision(int n) {
    int bound = 0;
    println(n);
    if(n % 2 == 0){
      if (position.x > width/2 - 30) {
        position.x = width/2 - 30;
        velocity.x *= -1;
        bound = 1;
      } else if (position.x < 30) {
        position.x = 30;
        velocity.x *= -1;
        bound = 1;
      }
    } else if(n % 2 == 1){
      if (position.x > width - 30) {
        position.x = width - 30;
        velocity.x *= -1;
        bound = 1;
      } else if (position.x < width/2 + 30) {
        position.x = width/2 + 30;
        velocity.x *= -1;
        bound = 1;
      }
    }
    if (position.y > height-radius) {
      position.y = height-radius;
      velocity.y *= -1;
      bound = 1;
    } else if (position.y < radius) {
      position.y = radius;
      velocity.y *= -1;
      bound = 1;
    }
    return bound;
  }
  
  int checkDrop(){
   if(position.x < 600 || position.x > 1300 || position.y < 0 || position.y > height){
     return 1;
   }
   return 0;
  }

  int checkCollision(Ball other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.position, position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      return 1;
    }
    return 0;
  }

  void display(int bc, int pc_red1, int pc_green1, int pc_blue1, int pc_red2, int pc_green2, int pc_blue2) {
    noStroke();
    fill(255);
    if(bc <= 3) fill(255, 0, 255);
    ellipse(position.x, position.y, radius*2, radius*2);
    if(bc % 2 == 0 && bc >= 4){
      fill(pc_red1, pc_green1, pc_blue1); 
    }else if(bc % 2 == 1 && bc >= 4){
      fill(pc_red2, pc_green2, pc_blue2);
    }
    ellipse(position.x, position.y, radius, radius);
    fill(204);
  }
  
  float result(int n){
    float dis;
    if(n % 2 == 0 && n >= 4){
      dis = dist(width/4, 300, position.x, position.y);
    } else if(n % 2 == 1 && n >= 4){
      dis = dist(3*width/4, 300, position.x, position.y);
    } else {
      return 10000.0;
    }
    return dis;
  }
  int bs(){
    int bs_test;
    if(velocity.x <= 0.001 && velocity.y <= 0.001){
      bs_test = 0;
    } else {
      bs_test = 1;
    }
    return bs_test;
  }
}
