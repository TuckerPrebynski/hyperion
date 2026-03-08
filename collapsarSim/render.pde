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
        blendMode(ADD);
        hint(ENABLE_STROKE_PERSPECTIVE); //each vert renders as quad

        //bind shader and set uniforms
        shader(partShader, POINTS);
        strokeWeight(baseSize);
        partShader.set("rampTex", rampTex);

        //draw them!
        for(int i = 0; i < renderCount; i++){
          RenderParticle p = renderBuffer[i];
          int maxVel = 300000; //TODO: calc max system velicity in sim
          if(p.alive){
            p.temp = (int)constrain(map(p.vel.magSq(), 0, maxVel, 0, 255), 0, 255);
            float t = p.temp/255.0;
            stroke(t*255, 0, 0, 180);
            point(p.x, p.y, p.z);
          }
        }

        //cleanup
        resetShader();
        blendMode(BLEND);
    }

    PImage buildRamp(){
      int[] rampData = {
        color(220, 20, 60), //crimson, least intense
        color(255, 165, 0),
        color(255, 215, 0),
        color(173, 216, 230),
        color(65,  105, 225),
        color(0, 165, 255),
        color(255, 255, 255) //bright white, most intense
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