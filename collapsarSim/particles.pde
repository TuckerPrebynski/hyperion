class Particle{
    PVector pos;
    PVector vel;
    PVector acc;

    char alive;

    Particle(PVector initPos){
        pos = initPos.copy();
        vel = acc = new PVector(0.0, 0.0);
        alive = 1;
    }
}

void update(){

}

void display(){

}