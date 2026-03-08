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
    // Made the box slightly taller to fit the new data
    rect(10, 10, 380, 260, 10);

    // --- LEFT ALIGNED (TELEMETRY) ---
     textFont(fTelemetry, 16);
     fill(255, 150, 0);
     text("BLACK HOLE MASS: " + nf(renderBhMass, 0, 2) + " Solar Masses", 20, 50);
     text("ENERGY OUTPUT:   " + nf(ergsPerFrameObj, 0, 2) + " x 10^51 Ergs", 20, 70);
     text("ACCRETION RATE:  " + nf(massPerFrameObj, 0, 4) + " M/dt", 20, 90);
     
     // --- RIGHT ALIGNED (CONTROLS HELP) ---
     textFont(fUI, 16);
     fill(200);
     text("[SPACE]  PAUSE SIMULATION", 20, 130);
     text("[R]      RESET SYSTEM", 20, 150);
     text("[C]      TRIGGER COLLAPSE", 20, 170); // Optional implementation depending on physics
     text("[+/-]    ZOOM CAMERA", 20, 190);
     text("[S/F]    TOGGLE SLOW-MO", 20, 210);
     
     // --- BOTTOM CENTER (STATUS) ---
     textFont(fStatus, 18);
     if (renderBhExists) {
        fill(255, 50, 50);
        text("STATUS: RELATIVISTIC JET DETECTED", 20, 240);
     } else {
        fill(50, 255, 50);
        text("STATUS: MAIN SEQUENCE STABLE", 20, 240);
     }
     
    /*

*/
    
    // Draw Right Side Data
    pushMatrix();
    translate(width - 350, 10);
    fill(0, 150);
    rect(0, 0, 340, 260, 10);
    
    textFont(fTitle, 22);
    fill(0, 255, 100);
    text("--- ENG READOUTS ---", 20, 20);

    textFont(fTelemetry, 16);
    fill(255);
    text("Cam X: " + nf(myCam.eyeX, 0, 2), 20, 50);
    text("Cam Y: " + nf(myCam.eyeY, 0, 2), 20, 70);
    text("Cam Z: " + nf(myCam.eyeZ, 0, 2), 20, 90);

    textFont(fTitle, 22);
    fill(0, 255, 100);
    text("--- TELEMETRY ---", 20, 130);
    
    textFont(fTelemetry, 16);
    fill(255);

    // Print the active particle count
    text("Active Mass: " + activeParticles, 20, 160);
    // Print the raw units and the scientific units!
    text("Avg Vel: " + nf(avgVelRaw, 0, 2) + " u/tick", 20, 180);
    // Uncomment this next line if you want to show the realistic km/s and % speed of light!
    text("Speed: " + nf(speedKmS, 0, 0) + " km/s", 20, 200);
    text("(" + nf(percentLight, 0, 2) + "% lightspeed)", 20, 220);
    popMatrix();

    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
