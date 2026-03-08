class oldRender {
    System sysRef;

    oldRender (System systemToRender) {
        sysRef = systemToRender;
    }

    void init () {

    }

    void display(float newX, float newY, float newZ){
        //color changing
        stroke (255);
        strokeWeight(4);

        for (int i = 0; i < sysRef.particles.size(); i++) {
            Particle p = sysRef.particles.get(i);

            if (p.alive) {
                point(p.pos.x+random(-newX,newX), p.pos.y+random(-newY,newY), p.pos.z+random(-newZ,newZ));
            }
        }
    }
}