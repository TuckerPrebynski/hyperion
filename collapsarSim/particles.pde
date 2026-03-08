class Particle{
    PVector pos;
    PVector vel;
    PVector acc;

    float press;
    float density;
    float mass;
    int temp; //colour value indicator, based on vel later

    boolean alive;

    Particle(PVector initPos){
        pos = initPos.copy();
        vel = new PVector(random(-10.0,10.0), random(-10.0,10.0), random(-10.0,10.0));
        acc = new PVector(0.0, 0.0, 0.0);
        press = density = 0;
        mass = random(60.0,180.0);
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
        int maxVel = 100000; //TODO: calc max system velicity in sim
        if(alive){
            temp = (int)constrain(map(vel.magSq(), 0, maxVel, 0, 255), 0, 255);
        }
    }
}
