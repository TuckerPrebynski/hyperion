class GUI {
    // Constructor now pipes in BOTH the camera and the system data
    GUI() {
    }

    void display() {
        // --- CALCULATE AVERAGE VELOCITY ---
        float totalVel = 0;
        int activeParticles = 0;
        
        for (Particle p : mySystem.particles) {
          if(p != null){  
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
        textSize(20);
        textAlign(LEFT, TOP);
        
        noStroke();
        fill(0, 150); 
        // Made the box slightly taller to fit the new data
        rect(10, 10, 320, 220, 10); 
        
        fill(0, 255, 100); 
        text("--- ENG READOUTS ---", 20, 20);
        
        fill(255);
        text("Cam X: " + nf(myCam.eyeX, 0, 2), 20, 50);
        text("Cam Y: " + nf(myCam.eyeY, 0, 2), 20, 80);
        text("Cam Z: " + nf(myCam.eyeZ, 0, 2), 20, 110);
        
        fill(0, 255, 100); 
        text("--- TELEMETRY ---", 20, 140);
        fill(255);
        
        // Print the active particle count
        text("Active Mass: " + activeParticles, 20, 170);
        // Print the raw units and the scientific units!
        text("Avg Vel: " + nf(avgVelRaw, 0, 2) + " u/tick", 20, 200);
        // Uncomment this next line if you want to show the realistic km/s and % speed of light!
        text("Avg Speed: " + nf(speedKmS, 0, 0) + " km/s (" + nf(percentLight, 0, 2) + "% c)", 20, 230);

        hint(ENABLE_DEPTH_TEST);
        popMatrix();
    }
}
