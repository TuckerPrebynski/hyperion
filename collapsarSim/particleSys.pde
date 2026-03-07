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

    void initParticles(int numParts){
        maxParts = numParts;
        for(int i = 0; i < numParts; i++){
            particles.add(new Particle(origin));
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