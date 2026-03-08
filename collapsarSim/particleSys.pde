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


    void initParticles(int numParts, float radIN){
        maxParts = this.numParts = numParts;
        println("2:",maxParts);
        for(int i = 0; i < numParts; i++){
            float theta = acos(1 - 2*random(1)); //polar angle
            float phi = random(TWO_PI);  //azimuth angle
            float rad = radIN;//*random(1);
            PVector newPos = new PVector(
                rad*sin(theta)*cos(phi), 
                rad*sin(theta)*sin(phi), 
                rad*cos(theta)
            );
            particles.add(new Particle(newPos));
        }
    }
    void addStar(int numParts, float radIN, PVector origin){
      maxParts += numParts;
      this.numParts = maxParts;
      println(maxParts);
      for(int i = 0; i < numParts; i++){
            float theta = acos(1 - 2*random(1)); //polar angle
            float phi = random(TWO_PI);  //azimuth angle
            float rad = radIN*random(1);
            PVector newPos = new PVector(
                origin.x + rad*sin(theta)*cos(phi), 
                origin.y + rad*sin(theta)*sin(phi), 
                origin.z + rad*cos(theta)
            );
            particles.add(new Particle(newPos));
        }
      
    
    }
    void add(){
        //TODO: figure out where new particles want to go
        particles.add(new Particle(origin));
        if(particles.size() < maxParts) numParts++;
    }

    void kill(Particle dead){
        particles.remove(dead);
        if(particles.size() >= 0) numParts--;
    }
}
