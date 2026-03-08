class GUI {
    SimCamera camRef;
    // You can add physics_eng physRef here later to get particle counts, etc!

    // Constructor pipes in the camera data
    GUI(SimCamera cameraToTrack) {
        camRef = cameraToTrack;
    }

    void display() {
        // 1. Save the current 3D transformation matrix
        pushMatrix();
        
        // 2. Reset the camera to the default flat 2D projection
        camera(); 
        
        // 3. Disable depth testing so the text renders ON TOP of all particles
        hint(DISABLE_DEPTH_TEST);
        
        // --- DRAW YOUR GUI HERE ---
        fill(255); // White text
        textSize(20);
        textAlign(LEFT, TOP);
        
        // A nice semi-transparent background box for readability
        noStroke();
        fill(0, 150); // Black with transparency
        rect(10, 10, 250, 140, 10); // x, y, width, height, border-radius
        
        fill(0, 255, 100); // Hacker green for the text
        text("--- ENG READOUTS ---", 20, 20);
        
        fill(255);
        // We use nf() to format the floats to 2 decimal places so the text doesn't jitter
        text("Cam X: " + nf(camRef.eyeX, 0, 2), 20, 50);
        text("Cam Y: " + nf(camRef.eyeY, 0, 2), 20, 80);
        text("Cam Z: " + nf(camRef.eyeZ, 0, 2), 20, 110);
        // --------------------------

        // 4. Turn depth testing back on for the next 3D frame
        hint(ENABLE_DEPTH_TEST);
        
        // 5. Restore the 3D transformation matrix
        popMatrix();
    }
}