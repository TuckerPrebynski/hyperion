import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;
import processing.opengl.PGraphicsOpenGL;

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
        PGraphicsOpenGL pg = (PGraphicsOpenGL)g;
        pg.beginPGL();

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
        pg.beginPGL();
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
        color(255, 255, 255) //bright while, most intense
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