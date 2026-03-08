class System{
    ArrayList<Particle> particles;
    PVector origin;

    int numParts;
    int maxParts;

    System(PVector originPos){
        numParts = maxParts = 0;
        origin = originPos.copy();
        particles = new ArrayList<Particle>();
    }

    void initParticles(int numParts, float rad){
        maxParts = numParts;
        for(int i = 0; i < numParts; i++){
            float theta = acos(1 - 2*random(1)); //polar angle
            float phi = random(TWO_PI);  //azimuth angle
            PVector newPos = new PVector(
                rad*sin(theta)*cos(phi), 
                rad*sin(theta)*sin(phi), 
                rad*cos(theta)
            );
            particles.add(new Particle(newPos));
        }
    }

    void add(){
        //TODO: figure out where new particles want to go
        particles.add(new Particle(origin));
    }

    void kill(Particle dead){
        particles.remove(dead);
    }
}