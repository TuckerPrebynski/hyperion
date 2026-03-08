System mySystem;
Render myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;

PFont fontTitle, fontUI, fontTelemetry, fontStatus;
PImage logoImg;

PShape starField;

// --- 1. MULTITHREADING VARIABLES ---
class RenderParticle {
  float x, y, z, temp;
  PVector vel;
  boolean alive;
  float mass;
}

RenderParticle[] renderBuffer;
int renderCount = 0;

// Thread-safe Black Hole Data
boolean renderBhExists = false;
float renderBhX, renderBhY, renderBhZ, renderBhRIn, renderBhRAcc, renderBhMass;
float ergsPerFrameObj = 0;
float massPerFrameObj = 0;

// Threading locks and flags
Object threadLock = new Object();
boolean isCalculating = false;
boolean isPaused = false;
boolean needsReset = false;

void resetSimulation() {
  // 1. Throw away the old system and make a new one
  mySystem = new System(new PVector(0, 0, 0));

  //mySystem.initParticles(6000, 200);
  mySystem.addStar(12000, 200, new PVector(0, 0, 0));
  //mySystem.addStar(6000,50,new PVector(-300,300,0));


  // --- 2. INITIALIZE THE RENDER BUFFER ---
  renderBuffer = new RenderParticle[mySystem.maxParts];
  for (int i = 0; i < renderBuffer.length; i++) {
    renderBuffer[i] = new RenderParticle();
  }

  // 3. Re-initialize the renderer
  myRenderer = new Render(mySystem);
  myRenderer.init();

  // 4. Create a fresh physics engine
  myPhys = new physics_eng();

  // 5. Reset camera and GUI
  myCam = new SimCamera();
  myGUI = new GUI(fontTitle, fontUI, fontTelemetry, fontStatus);

  renderBhExists = false;

  isCalculating = false;
}

void setup() {
  size(3500, 1900, P3D);

  // Load fonts first
  fontTitle = loadFont("FragileBombers.vlw");
  fontUI = loadFont("KogniGear.vlw");
  fontTelemetry = loadFont("Hack-Regular.vlw");
  fontStatus = loadFont("FreeMonoBold.vlw");

  // Load Logo
  logoImg = loadImage("media/logo.png");

  resetSimulation();

  // background stars
  starField = createShape();
  starField.beginShape(POINTS);
  starField.stroke(255); // White stars
  starField.strokeWeight(4); // Size of stars

  int[] starCols = {
    //blues
    color(173, 216, 230),
    color(135, 206, 235),
    color(65, 105, 225),
    //greens
    color(144, 238, 144),
    color(34, 139, 34),
    color(0, 100, 0),
    //whites (bright to dim)
    color(240, 250, 255),
    color(190, 210, 200),
    color(150, 165, 160)
  };

  // Generate 9,000 static stars in a sphere or box
  for (int i = 0; i < 9000; i++) {
    float x = 0, y = 0, z = 0;
    float innerLimit = 2000;
    float outerLimit = 10000;

    boolean insideForbiddenZone = true;

    while (insideForbiddenZone) {
      x = random(-outerLimit, outerLimit);
      y = random(-outerLimit, outerLimit);
      z = random(-outerLimit, outerLimit);

      // Check if it's inside the inner cube
      if (!(x > -innerLimit && x < innerLimit &&
        y > -innerLimit && y < innerLimit &&
        z > -innerLimit && z < innerLimit)) {
        insideForbiddenZone = false;
      }
    }

    starField.stroke(starCols[int(random(starCols.length))]);
    starField.vertex(x, y, z);
  }
  starField.endShape();
}

float x = 1;
float y = 1;
float z = 1;

void draw() {
  if (needsReset && !isCalculating) {
    resetSimulation();
    needsReset = false;
  }
  background(0);
  myCam.apply();

  // Box display for testing
  pushMatrix();
  //strokeWeight(2);
  //translate(0, 0, 0);
  //noFill();
  //stroke(250, 30, 30);
  //box(350);
  popMatrix();

  // --- 3. THREAD-SAFE RENDERING ---
  // We lock the thread briefly while drawing to prevent tearing/crashing
  synchronized(threadLock) {

    // Render Black Hole from BUFFER
    if (renderBhExists) {
      pushMatrix();
      translate(renderBhX, renderBhY, renderBhZ);

      // Event horizon
      fill(0);
      noStroke();
      sphere(renderBhRIn * 4f);

      // Magnetic zone
      noFill();
      strokeWeight(2);
      float time = millis() * 0.001f;
      int numRings = 10;
      for (int i = 0; i < numRings; i++) {
        pushMatrix();
        rotateX(time + (PI / numRings) * i);
        rotateY(time * 0.7f + (PI / numRings) * i);

        //outer boundary
        stroke (70, 20, 70, 150);
        ellipse(0, 0, renderBhRAcc*2, renderBhRAcc*2);

        //draw inner photon ring
        stroke(0, 12, 186, 120);
        ellipse(0, 0, renderBhRAcc*2.7, renderBhRAcc*2.7);

        popMatrix();
      }
      popMatrix();
    }

    shape(starField);
    // RENDER PARTICLES
    myRenderer.display();
  }



  // --- 4. TRIGGER BACKGROUND PHYSICS ---
  if (!isPaused && !isCalculating) {
    isCalculating = true;
    thread("runPhysics");
  }
  myGUI.display();
}

// --- 5. THE BACKGROUND THREAD ---
// This runs on a separate CPU core
void runPhysics() {
  myPhys.update();

  // The math is done! Briefly lock the thread to copy data safely
  synchronized(threadLock) {
    renderCount = mySystem.particles.size();

    // Copy particle data
    for (int i = 0; i < renderCount; i++) {
      Particle p = mySystem.particles.get(i);
      renderBuffer[i].x = p.pos.x;
      renderBuffer[i].y = p.pos.y;
      renderBuffer[i].z = p.pos.z;
      renderBuffer[i].temp = p.temp;
      renderBuffer[i].vel = p.vel;
      renderBuffer[i].alive = p.alive;
      renderBuffer[i].mass = p.mass;
    }

    // Copy Black Hole data
    if (myPhys.bh != null) {
      renderBhExists = true;
      renderBhX = myPhys.bh.pos.x;
      renderBhY = myPhys.bh.pos.y;
      renderBhZ = myPhys.bh.pos.z;
      renderBhRIn = myPhys.bh.r_in;
      renderBhRAcc = myPhys.bh.r_acc;
      // Calculate accretion stats to show on the UI
      float oldMass = renderBhMass;
      renderBhMass = myPhys.bh.mass;
      massPerFrameObj = max(0, renderBhMass - oldMass);
      // E = mc^2 rough estimation for visual effect
      ergsPerFrameObj = massPerFrameObj * 8.987f;
    } else {
      renderBhExists = false;
      renderBhMass = 0;
      massPerFrameObj = 0;
      ergsPerFrameObj = 0;
    }
  }
  isCalculating = false;
}


// --- CONTROLS ---
void keyPressed() {
  if (key == ' ') isPaused = !isPaused;
  if (key == 'r' || key == 'R') needsReset = true;
  if (key == 's') dt = 0.003f; // Slow motion
  if (key == 'f') dt = 0.016f; // Normal speed
}
