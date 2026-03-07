class render {
    
    void init () {

    }

    void display(){
        
    }
}

/*
class Renderer {
  ParticleData data;
  PApplet app;

  // Camera
  float camAngle = 0;
  float camRadius = 800;
  float camHeight = 300;

  Renderer(ParticleData sharedData, PApplet appContext) {
    this.data = sharedData;
    this.app = appContext;
  }

  void render() {
    background(0);

    // --- CAMERA ---
    // Slowly orbit around the origin so we can see the 3D structure
    camAngle += 0.005;
    float camX = cos(camAngle) * camRadius;
    float camZ = sin(camAngle) * camRadius;
    camera(camX, camHeight, camZ,   // eye position
           0, 0, 0,                 // look-at target (origin)
           0, -1, 0);              // up direction

    // --- PARTICLE RENDERING ---
    // Additive blending makes overlapping particles glow brighter
    blendMode(ADD);
    noStroke();

    for (int i = 0; i < data.activeCount; i++) {
      // Map temperature to color: cool (red) -> hot (white-blue)
      color c = tempToColor(data.temperature[i]);
      fill(c, 60); // semi-transparent for a soft glow

      pushMatrix();
      translate(data.x[i], data.y[i], data.z[i]);
      // Billboard: always face the camera (cheap spherical impostor)
      sphere(2);
      popMatrix();
    }

    // Reset blend mode so UI text draws normally
    blendMode(BLEND);
  }

  // Maps a temperature in Kelvin to a star-like color
  // ~3000K = deep red/orange, ~6000K = yellow/white, ~10000K+ = blue-white
  color tempToColor(float tempK) {
    float t = constrain(map(tempK, 3000, 12000, 0, 1), 0, 1);

    float r, g, b;
    if (t < 0.5) {
      // Red/orange -> yellow/white
      r = 255;
      g = lerp(80, 255, t * 2);
      b = lerp(20, 200, t * 2);
    } else {
      // Yellow/white -> blue-white
      r = lerp(255, 180, (t - 0.5) * 2);
      g = lerp(255, 200, (t - 0.5) * 2);
      b = lerp(200, 255, (t - 0.5) * 2);
    }
    return color(r, g, b);
  }
}
  */