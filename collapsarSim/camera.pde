class SimCamera {
    float x;
    float y;
    float z;
    int num;
    boolean inverseX, inverseY,inverseZ;
    boolean is_moving;

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

        /*
        if (num>=20) {
            println("X is " + x + " and Y is " + y + " and Z is " + z);
            num=0;
        }
        */

        num++;

        camera(x, y, z, width/2.0, height/2.0, 0, 0, 1, 0);
    }
}

void keyPressed(){
    if (key=='r' || key == 'R') {
        myCam.is_moving = false;
    }
}