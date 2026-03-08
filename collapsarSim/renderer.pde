class oldRender {
    System sysRef;

    oldRender (System systemToRender) {
        sysRef = systemToRender;
    }

    void init () {

    }

    void display(){
        //color changing
        stroke (255);
        strokeWeight(4);

          //blackhole stuff

        for (int i = 0; i < sysRef.particles.size(); i++) {
            Particle p = sysRef.particles.get(i);

            if (p.alive) {
                point(p.pos.x, p.pos.y, p.pos.z);
            }
        }
    }

    /*
      if ((sysRef.bh) != null) {
        pushMatrix();
        translate(sysRef.bh.pos.x, sysRef.bh.pos.y, sysRef.bh.pos.z);
        fill(0); // Pure black
        noStroke();
        sphere(sysRef.bh.r_in); // Draw it at the exact point of no return!
        popMatrix();
    }
        */
}