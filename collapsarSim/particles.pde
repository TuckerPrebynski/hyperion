class Particle{
    PVector pos;
    PVector vel;
    PVector acc;

    int press;
    int density;
    int mass;
    int temp; //colour value indicator

    boolean alive;

    Particle(PVector initPos){
        pos = initPos.copy();
        vel = acc = new PVector(0.0, 0.0, 0.0);
        press = density = mass = 0;
        temp = 255; //white for now, can change l8r
        alive = true;
    }

    void update(){
        if(alive){
            vel.add(acc);
            pos.add(vel);
        }
    }
}