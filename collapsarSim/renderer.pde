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

        for (int i = 0; i < renderCount; i++) {
            RenderParticle p = renderBuffer[i];

            strokeWeight((p.mass)*0.02);
            if (p.alive) {
                point(p.x, p.y, p.z);
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
