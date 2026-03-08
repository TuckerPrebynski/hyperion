class Render {
    System sysRef;
    PShader partShader;
    PShape partCloud;

    float baseSize = 6.0;
    PImage rampTex;

    Render (System systemToRender) {
        sysRef = systemToRender;
    }

    void init () {
      //load shaders
      partShader = loadShader("particles.frag", "particles.vert");

      rampTex = buildRamp();
    }

    void display(){
        for(int i = 0; i < sysRef.particles.size(); i++){
          sysRef.particles.get(i).update();
        }

        blendMode(ADD);
        hint(ENABLE_STROKE_PERSPECTIVE); //each vert renders as quad

        //bind shader and set uniforms
        shader(partShader, POINTS);
        strokeWeight(baseSize);
        partShader.set("rampTex", rampTex);

        //draw them!
        for(int i = 0; i < sysRef.particles.size(); i++){
          Particle p = sysRef.particles.get(i);
          if(p.alive){
            float t = p.temp/255.0;
            stroke(t*255, 0, 0, 180);
            point(p.pos.x, p.pos.y, p.pos.z);
          }
        }

        //cleanup
        resetShader();
        blendMode(BLEND);
    }

    PImage buildRamp(){
      int[] rampData = {
        color(0, 0, 0), //black, least intense
        color(51, 102, 179),
        color(51, 175, 255),
        color(51,  175, 255),
        color(57,  255, 20),
        color(150, 255, 50),
        color(150, 255, 50),
        color(255, 255, 75) //bright yellow, most intense (prob should be blue?? rethink one working) TODO
      };

      PImage rampTex = createImage(rampData.length, 1, ARGB);
      rampTex.loadPixels();
      for(int i = 0; i < rampData.length; i++){
        rampTex.pixels[i] = rampData[i];
      }

      rampTex.updatePixels();
      return rampTex;
    }
}