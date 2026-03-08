class Particle{
    PVector pos;
    PVector vel;
    PVector acc;

    float press;
    float density;
    float mass;
    float temp; //colour value indicator

    boolean alive;

    Particle(PVector initPos){
        pos = initPos.copy();
        vel = new PVector(0.0, 0.0, 0.0);
        acc = new PVector(0.0, 0.0, 0.0);
        press = density = 0;
        mass = 1.0;
        temp = 255; //white for now, can change l8r
        alive = true;
    }

    Particle(Particle other){
        this.pos = other.pos;
        this.vel = other.vel;
        this.acc = other.acc;
        this.press = other.press;
        this.density = other.density;
        this.mass = other.mass;
        this.temp = other.temp; 
        this.alive = other.alive;
    }

    void update(){
        if(alive){
            vel.add(acc);
            pos.add(vel);
        }
    }
}