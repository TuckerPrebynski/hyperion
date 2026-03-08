class SimCamera {
    float x;
    float y;
    float z;
    int num;
    boolean inverseX, inverseY,inverseZ;
    boolean is_moving;

    boolean rWasPressed;

    SimCamera (){
        x = 0;
        y = 0;
        z = (height/2.0)/tan(PI/6.0);
        num = 0;
        inverseX = false;
        inverseY = false;
        inverseZ = false;
        is_moving = true;
    }

void apply() {
        // --- 1. KEY INPUT LOGIC ---
        // Check if 'r' (or 'R') is pressed
        if (keyPressed && (key == 'r' || key == 'R')) {
            if (!rWasPressed) {
                is_moving = !is_moving; // Toggle the state!
                rWasPressed = true;     // Lock it so it only toggles once per press
            }
        } else {
            // Unlock it as soon as the user lets go of the key
            rWasPressed = false; 
        }

        // --- 2. MOVEMENT LOGIC ---
        // Wrap all your movement math in this if statement!
        if (is_moving) {
            if (inverseX == false) { x += 5; } else { x -= 5; }
            if (inverseY == false) { y += 5; } else { y -= 5; }
            if (inverseZ == false) { z += 5; } else { z -= 5; }

            if (x >= 2000) { inverseX = true; }
            if (y >= 2000) { inverseY = true; }
            if (z >= 1000) { inverseZ = true; }

            if (x <= -2000) { inverseX = false; }
            if (y <= -2000) { inverseY = false; }
            if (z <= -1000) { inverseZ = false; }
        }

        // --- 3. APPLY CAMERA ---
        // Make sure you still have your actual camera call at the bottom!
        camera(x, y, z, width/2.0, height/2.0, 0, 0, 1, 0);
        textSize(50);
        fill (0,408,612);
        text ("X: " + x + " Y: " + y + " Z: " + z, x-20, y-200,z-100);
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