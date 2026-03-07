class System{
    ArrayList<Particle> particles;
    PVector origin;

    System(PVector originPos){
        origin = originPos.copy();
        particles = new ArrayList<Particle>();
    }

    void initParticles(int numParts){
        for(int i = 0; i < numParts; i++){
            particles.add(new Particle(origin));
        }
    }
}