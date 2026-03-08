class SimCamera {
  float radius;
  float theta;
  float phi;

  float targetX;
  float targetY;
  float targetZ;

  float eyeX, eyeY, eyeZ;

  //int num;

  boolean is_moving;
  boolean rWasPressed;

  SimCamera () {
    radius = (height / 2.0) / tan(PI / 6.0);
    theta = 0;
    phi = 0;

    targetX = width/2;
    targetY = height/2;
    targetZ = 0;
    
    //num = 0;

    is_moving = true;
    rWasPressed = false;    
  }

  void apply() {
    //keypress logic
    if (keyPressed && (key == 'r' || key == 'R')) { // r pauses
      if (!rWasPressed) {
        is_moving = !is_moving; // state toggle
        rWasPressed = true;     // Lock it so it only toggles once per press
      }
    } else {
      // Unlock it as soon as the user lets go of the key
      rWasPressed = false;
    }

    //movement-logic
    float orbitSpeed = 0.05;
    if (is_moving) {
      theta += 0.05;
    } else {
      /*
      if (mousePressed) {
        theta -= (mouseX - pmouseY)*0.1;
        phi -= (mouseY - pmouseY)*0.1;

        phi = constrain(phi, -PI/2.1, PI/2.1);
      }
        */

      

      if (keyPressed) {
        
        //float rightX = cos(theta);
        //float rightZ = -sin(theta);
        //float panSpeed = 10.0;

        if (keyCode == LEFT) {
            theta -= orbitSpeed;
            //targetX -= rightX * panSpeed;
            //targetZ -= rightZ * panSpeed;
        }
        if (keyCode == RIGHT) {
            theta += orbitSpeed;
            //targetX += rightX * panSpeed;
            //targetZ += rightZ * panSpeed;
        }
      }
    }

    if (keyPressed) {
      if (keyCode == UP) {
          phi -= orbitSpeed;
          //targetY -= panSpeed;
        }
        if (keyCode == DOWN) {
          phi += orbitSpeed;
          //targetY += panSpeed;
        }
    }

    eyeX = targetX + radius * cos(phi) * sin(theta);
    eyeY = targetY + radius * sin(phi);
    eyeZ = targetZ + radius * cos(phi) * cos(theta);

    float upY = 1.0;
    if (cos(phi) < 0) {
        upY = -1.0;
    }

    camera(eyeX, eyeY, eyeZ, targetX, targetY, targetZ, 0, upY, 0);
  }
}
/*
    void apply() {
 if (is_moving = true) {
 if (inverseX == false) {
 x += 5;
 } else {
 x -= 5;
 }
 if (inverseY == false) {
 y += 5;
 } else {
 y -= 5;
 }
 if (inverseZ == false) {
 z += 5;
 } else {
 z -= 5;
 }
 
 if (x >= 2000) {
 inverseX = true;
 }
 if (y >= 2000) {
 inverseY = true;
 }
 if (z >= 1000) {
 inverseZ = true;
 }
 
 if (x <= -2000) {
 inverseX = false;
 }
 if (y <= -2000) {
 inverseY = false;
 }
 if (z <= -1000) {
 inverseZ = false;
 }
 
 
 //if (num>=20) {
 //    println("X is " + x + " and Y is " + y + " and Z is " + z);
 //    num=0;
 //}
 
 
 num++;
 }
 
 camera(x, y, z, width/2.0, height/2.0, 0, 0, 1, 0);
 }
 }
 */

/*
void keyPressed(){
 if (key=='r' || key == 'R') {
 myCam.is_moving = false;
 }
 }
 */