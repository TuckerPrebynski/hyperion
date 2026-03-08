class GUI {
  PFont fTitle, fUI, fTelemetry, fStatus;

  // Constructor now pipes in BOTH the camera and the system data
  GUI(PFont t, PFont u, PFont tel, PFont s) {
    fTitle = t;
    fUI = u;
    fTelemetry = tel;
    fStatus = s;
  }

  void display() {
    // --- CALCULATE AVERAGE VELOCITY ---
    float totalVel = 0;
    int activeParticles = 0;

    for (int i = 0; i < renderCount; i++) {
      RenderParticle p = renderBuffer[i];
      if (p != null) {
        if (p.alive) {
          totalVel += p.vel.mag(); // .mag() gets the absolute speed regardless of direction
          activeParticles++;
        }
      }
    }

    float avgVelRaw = 0;
    if (activeParticles > 0) {
      avgVelRaw = totalVel / activeParticles;
    }

    // --- SCIENTIFIC CONVERSION ---
    // Let's assume 1 Processing velocity unit = ~3,000 km/s in the simulation scale
    float speedKmS = avgVelRaw * 3000.0;

    // Speed of light is ~299,792 km/s. Let's find what percentage of lightspeed we are at!
    float percentLight = (speedKmS / 299792.0) * 100.0;

    // --- DRAW GUI ---
    pushMatrix();
    camera();
    hint(DISABLE_DEPTH_TEST);

    fill(255);
    //textSize(20);
    textAlign(LEFT, TOP);

    noStroke();
    fill(0, 150);
    // Expand box for larger 30+ fonts
    rect(10, 10, 600, 480, 10);

    // --- LEFT ALIGNED (TELEMETRY) ---
     textFont(fTelemetry, 30);
     fill(255, 150, 0);
     text("BLACK HOLE MASS: " + nf(renderBhMass, 0, 2) + " Solar Masses", 30, 30);
     text("ENERGY OUTPUT:   " + nf(ergsPerFrameObj, 0, 2) + " x 10^51 Ergs", 30, 70);
     text("ACCRETION RATE:  " + nf(massPerFrameObj, 0, 4) + " M/dt", 30, 110);
     
     // --- RIGHT ALIGNED (CONTROLS HELP) ---
     textFont(fUI, 30);
     fill(200);
     text("[SPACE]  PAUSE SIMULATION", 30, 180);
     text("[R]      RESET SYSTEM", 30, 220);
     text("[C]      TRIGGER COLLAPSE", 30, 260); // Optional implementation depending on physics
     text("[+/-]    ZOOM CAMERA", 30, 300);
     text("[S/F]    TOGGLE SLOW-MO", 30, 340);
     
     // --- BOTTOM CENTER (STATUS) ---
     textFont(fStatus, 32);
     if (renderBhExists) {
        fill(255, 50, 50);
        text("STATUS: RELATIVISTIC JET DETECTED", 30, 410);
     } else {
        fill(50, 255, 50);
        text("STATUS: MAIN SEQUENCE STABLE", 30, 410);
     }
     
    /*

*/
    
    // Draw Right Side Data
    pushMatrix();
    translate(width - 600, 10);
    fill(0, 150);
    rect(0, 0, 580, 480, 10);
    
    textFont(fTitle, 40);
    fill(0, 255, 100);
    text("--- ENG READOUTS ---", 30, 30);

    textFont(fTelemetry, 30);
    fill(255);
    text("Cam X: " + nf(myCam.eyeX, 0, 2), 30, 90);
    text("Cam Y: " + nf(myCam.eyeY, 0, 2), 30, 130);
    text("Cam Z: " + nf(myCam.eyeZ, 0, 2), 30, 170);

    textFont(fTitle, 40);
    fill(0, 255, 100);
    text("--- TELEMETRY ---", 30, 240);
    
    textFont(fTelemetry, 30);
    fill(255);

    // Print the active particle count
    text("Active Mass: " + activeParticles, 30, 300);
    // Print the raw units and the scientific units!
    text("Avg Vel: " + nf(avgVelRaw, 0, 2) + " u/tick", 30, 350);
    // Uncomment this next line if you want to show the realistic km/s and % speed of light!
    text("Speed: " + nf(speedKmS, 0, 0) + " km/s", 30, 400);
    text("(" + nf(percentLight, 0, 2) + "% lightspeed)", 30, 440);
    popMatrix();
    
    // Draw Logo Bottom Right
    if (logoImg != null) {
      image(logoImg, width - logoImg.width - 20, height - logoImg.height - 20);
    }

    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
