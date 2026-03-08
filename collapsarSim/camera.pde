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
  boolean cWasPressed;
  boolean simPaused;
  boolean spaceWasPressed;

  SimCamera () {
    radius = (height / 2.0) / tan(PI / 6.0);
    theta = 0;
    phi = 0;

    targetX = 0;
    targetY = 0;
    targetZ = 0;
    
    //num = 0;

    is_moving = true;
    cWasPressed = false;   
    is_moving = true;
    cWasPressed = false; 
    
    simPaused = false;     // Simulation starts unpaused
    spaceWasPressed = false; 
  }

  void apply() {
    //keypress logic
    //pause
    if (keyPressed && key == ' ') { 
      if (!spaceWasPressed) {
        simPaused = !simPaused; // Toggle the pause state
        spaceWasPressed = true; // Lock it
      }
    } else if (!keyPressed || key != ' ') {
      spaceWasPressed = false;  // Unlock when released
    }

    

    //stop rotate
    if (keyPressed && (key == 'c' || key == 'C')) { // r pauses
      if (!cWasPressed) {
        is_moving = !is_moving; // state toggle
        cWasPressed = true;     // Lock it so it only toggles once per press
      }
    } else {
      // Unlock it as soon as the user lets go of the key
      cWasPressed = false;
    }

    //movement-logic
    float orbitSpeed = 0.05;
    if (is_moving) {
      theta += 0.005;
    } else {
      /*
      if (mousePressed) {
        theta -= (mouseX - pmouseY)*0.1;
        phi -= (mouseY - pmouseY)*0.1;

        phi = constrain(phi, -PI/2.1, PI/2.1);
      }
        */
      if (keyPressed) {
        orbitSpeed = 0.05;
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
      orbitSpeed = 0.05;
      float zoomSpeed = 50.0;
      if (keyCode == UP) {
          phi -= orbitSpeed;
        }
      if (keyCode == DOWN) {
          phi += orbitSpeed;
        }
      if (key == '-' || key == '_') {
          radius += zoomSpeed;
        }
      if (key == '=' || key == '+') {
          radius -= zoomSpeed;
          radius = max(10, radius); // Prevent zooming through the target completely
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