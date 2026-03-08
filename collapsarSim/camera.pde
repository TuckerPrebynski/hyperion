class SimCamera {
    float x;
    float y;
    float z;
    int num;

    SimCamera (){
        x = 0;
        y = 0;
        z = (height/2.0)/tan(PI/6.0);
        num = 0;
    }

    void apply() {
        x += 5;
        y += 5;
        z += 5;

        camera(x, y, z, width/2.0, height/2.0, 0, 0, 1, 0);
    }
}